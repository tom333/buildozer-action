FROM kivy/buildozer:latest
# See https://github.com/kivy/buildozer/blob/master/Dockerfile

# Buildozer will be installed in entrypoint.py
# This is needed to install version specified by user
RUN pip3 uninstall -y buildozer

# Remove a lot of warnings
# sudo: setrlimit(RLIMIT_CORE): Operation not permitted
# See https://github.com/sudo-project/sudo/issues/42
RUN echo "Set disable_coredump false" | sudo tee -a /etc/sudo.conf > /dev/null

# By default Python buffers output and you see prints after execution
# Set env variable to disable this behavior
ENV PYTHONUNBUFFERED=1

#Install du NDK
ENV ANDROID_NDK_HOME /github/workspace/./.buildozer_global/android/platform
ENV ANDROID_NDK_VERSION r19c

RUN mkdir /tmp/android-ndk-tmp && \
    cd /tmp/android-ndk-tmp && \
    wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# uncompress
    unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
# move to its final location
    mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
# remove temp dir
    cd ${ANDROID_NDK_HOME} && \
    rm -rf /tmp/android-ndk-tmp

# add to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}

#Install de apache ANT
ARG ANT_VERSION=1.9.4
WORKDIR /github/workspace/./.buildozer_global/android/platform/
RUN wget -q http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    tar xzf apache-ant-*.tar.gz && \
    rm apache-ant-*.tar.gz

#Install du sdk
ARG ANDROID_SDK_VERSION=6609375
ENV ANDROID_SDK_ROOT /github/workspace/./.buildozer_global/android/platform/android-sdk/
RUN mkdir -p ${ANDROID_SDK_ROOT} && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip && \
    unzip *tools*linux*.zip -d ${ANDROID_SDK_ROOT} && \
    rm *tools*linux*.zip

WORKDIR ${ANDROID_SDK_ROOT}
RUN yes 2>/dev/null | ${ANDROID_SDK_ROOT}tools/bin/sdkmanager --sdk_root=/opt/android-sdk --licenses

COPY entrypoint.py /action/entrypoint.py
ENTRYPOINT ["/action/entrypoint.py"]

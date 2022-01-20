FROM jenkins/inbound-agent

USER root
ENV HOME /root

# create unused group so docker is number 998
RUN groupadd -g 999 notuseful
RUN groupadd -g 998 docker

# install and update debian packages (for testing and more)
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget curl apt-transport-https dirmngr unzip build-essential apt-utils git vim netcat telnet \
  libgconf-2-4 libpangocairo-1.0-0 libdbus-1-dev libgtk-3-dev libnotify-dev libasound2-dev libcap-dev libcups2-dev \
  libxtst-dev libxss1 libnss3-dev xvfb cmake ca-certificates gnupg lsb-release

# install JDK 8
RUN mkdir -p /opt/java && \
  cd /opt/java && \
  wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jdk_x64_linux_hotspot_8u312b07.tar.gz
RUN cd /opt/java && \
  tar xzf OpenJDK8U-jdk_x64_linux_hotspot_8u312b07.tar.gz && \
  rm -rf OpenJDK8U-jdk_x64_linux_hotspot_8u312b07.tar.gz
ENV JAVA_HOME=/opt/java/jdk8u312-b07
ENV PATH=$JAVA_HOME/bin:$PATH

# install gradle
RUN mkdir /opt/gradle && \
  cd /opt/gradle && \
  wget https://services.gradle.org/distributions/gradle-7.3.3-bin.zip && \
  unzip -d /opt/gradle gradle-7.3.3-bin.zip && \
  rm -rf gradle-7.3.3-bin.zip
ENV PATH=$PATH:/opt/gradle/gradle-7.3.3/bin

# install docker engine
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | \
  gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
# RUN apt-get install -y docker-ce docker-ce-cli containerd.io
RUN apt-get install -y docker-ce-cli
RUN usermod -aG docker root && \
  usermod -aG docker jenkins

# add docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
  chmod +x ./kubectl && \
  mv ./kubectl /usr/local/bin/kubectl && \
  kubectl version --client

# install meteor
RUN curl https://install.meteor.com/ | sh

# install Android tools
RUN mkdir -p /opt/android/android-sdk-tools/cmdline-tools && \
  cd /opt/android && \
  wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip
RUN unzip /opt/android/commandlinetools-linux-7583922_latest.zip -d /opt/android/android-sdk-tools/cmdline-tools && \
  rm /opt/android/commandlinetools-linux-7583922_latest.zip && \
  mv /opt/android/android-sdk-tools/cmdline-tools/cmdline-tools /opt/android/android-sdk-tools/cmdline-tools/latest
ENV ANDROID_SDK_ROOT=/opt/android/android-sdk-tools
ENV ANDROID_HOME=$ANDROID_SDK_ROOT
ENV BUILD_TOOLS_VERSION="29.0.2"
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION:$ANDROID_HOME/build-tools/28.0.3
RUN mkdir -p $ANDROID_HOME/licenses && \
  echo -e "\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license
RUN yes | sdkmanager "platform-tools" "platforms;android-29" "build-tools;$BUILD_TOOLS_VERSION" "platforms;android-28" "build-tools;28.0.3"

USER jenkins
ENV HOME /home/jenkins

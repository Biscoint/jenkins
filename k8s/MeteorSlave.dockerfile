FROM jenkins/jnlp-slave

USER root
ENV HOME /root

# create unused group so docker is number 998
RUN groupadd -g 999 notuseful
RUN groupadd -g 998 docker

# install and update debian packages (for testing and more)
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget curl apt-transport-https dirmngr unzip gradle build-essential apt-utils git vim netcat telnet libgconf-2-4 libpangocairo-1.0-0 libdbus-1-dev libgtk-3-dev libnotify-dev libgnome-keyring-dev libasound2-dev libcap-dev libcups2-dev libxtst-dev libxss1 libnss3-dev xvfb

# install docker engine
# RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys F76221572C52609D
RUN echo 'deb https://apt.dockerproject.org/repo debian-stretch main' >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --allow-unauthenticated docker-engine
RUN usermod -aG docker root && usermod -aG docker jenkins

# add docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# install Android tools
RUN mkdir /opt/android/ && cd /opt/android && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip /opt/android/sdk-tools-linux-4333796.zip -d /opt/android/android-sdk-tools && rm /opt/android/sdk-tools-linux-4333796.zip

ENV ANDROID_HOME=/opt/android/android-sdk-tools
ENV BUILD_TOOLS_VERSION="28.0.1"
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION

RUN mkdir -p $ANDROID_HOME/licenses && echo -e "\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license
RUN yes | sdkmanager "platform-tools" "platforms;android-26" "build-tools;$BUILD_TOOLS_VERSION"
RUN ls -la $ANDROID_HOME/tools $ANDROID_HOME/platform-tools $ANDROID_HOME/build-tools

# RUN chown -R 1000:1000 $ANDROID_HOME

# install meteor
RUN curl https://install.meteor.com/ | sh

# install kubectl
# RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# RUN echo 'deb https://apt.kubernetes.io/ kubernetes-stretch main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
# RUN apt-get update
# RUN apt-get install -y kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl && kubectl version --client

USER jenkins
ENV HOME /home/jenkins

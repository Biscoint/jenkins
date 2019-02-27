FROM jenkins/jenkins:lts
COPY jenkins-plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

USER root

# install docker engine

RUN apt-get update
RUN apt-get install -y apt-transport-https dirmngr unzip gradle build-essential
RUN echo 'deb https://apt.dockerproject.org/repo debian-stretch main' >> /etc/apt/sources.list
#RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys F76221572C52609D
RUN apt-get update
RUN apt-get install -y --allow-unauthenticated docker-engine
RUN usermod -aG docker root && usermod -aG docker jenkins

# install kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
RUN echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl

# install meteor
RUN curl https://install.meteor.com/ | sh

# fixing ubuntu OOM bug
RUN uname -r
RUN apt-get upgrade -y

RUN mkdir /opt/android/ && cd /opt/android && wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip /opt/android/sdk-tools-linux-4333796.zip -d /opt/android/android-sdk-tools && rm /opt/android/sdk-tools-linux-4333796.zip

ENV ANDROID_HOME=/opt/android/android-sdk-tools
ENV BUILD_TOOLS_VERSION="28.0.1"
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION

RUN mkdir -p $ANDROID_HOME/licenses && echo -e "\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license
RUN yes | sdkmanager "platform-tools" "platforms;android-26" "build-tools;$BUILD_TOOLS_VERSION"
RUN ls $ANDROID_HOME/tools $ANDROID_HOME/platform-tools $ANDROID_HOME/build-tools

RUN chown -R 1000:1000 $ANDROID_HOME

# drop back to the regular jenkins user - good practice
USER jenkins

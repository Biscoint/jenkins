# Jenkins Meteor

A Jenkins docker image with meteor and other pre-installed tools, suitable for building meteor applications and its derivated android apks, including:
* Debian packages: apt-transport-https, dirmngr, unzip, gradle, build-essential, docker-engine
* [Meteor](https://install.meteor.com/)
* Android SDK Tools and pre-requisites for APK building.

Example of Jenkins Pipeline script commands that a Jenkins Job could use for building a meteor application and APK:
```
  stage('Build binaries') {
    sh "meteor build --architecture=os.linux.x86_64 ./build/ --server=${params.MOBILE_SERVER}"
  }
  
  stage('Sign APK') {
    withCredentials([string(credentialsId: 'biscoint-jks-passphrase', variable: 'JKSPASS')]) {
      sh "jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore /opt/apk-keystore.jks -storepass '${JKSPASS}' -keypass '${JKSPASS}' ${env.WORKSPACE}/build/android/project/build/outputs/apk/release/android-release-unsigned.apk ${CERTNAME}"
      sh "mkdir -p $JENKINS_HOME/releases/apk"
      sh "zipalign 4 ${env.WORKSPACE}/build/android/project/build/outputs/apk/release/android-release-unsigned.apk $JENKINS_HOME/releases/apk/android-release-signed-${env.BUILD_NUMBER}.apk"
    }
  }
  ```

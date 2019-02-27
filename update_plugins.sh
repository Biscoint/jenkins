JENKINS_HOST=$JENKINS_USER:"$JENKINS_PASSWORD"@jenkins.biscoint.io
# update the plugins list if an up and running jenkins is found, otherwise use the existing list
curl -sSL "https://$JENKINS_HOST/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g'|sed 's/ /:/' > jenkins-plugins.txt || true

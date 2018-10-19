#!/bin/sh

set -xe

pwd
ls -al
cf version
wget https://s3-us-west-1.amazonaws.com/cf-cli-releases/releases/v6.37.0/cf-cli-installer_6.37.0_x86-64.deb
dpkg -i *.deb
rm *.deb 
cf version

set +x
echo "\n\n\n\n(credential hided) cf login to $cf_api_url "
#cf login -a $cf_api_url -u $cf_username -p $cf_password -o $cf_org -s $cf_space --skip-ssl-validation &>/dev/null
cf login -a $cf_api_url -u $cf_username -p $cf_password -o $cf_org -s $cf_space --skip-ssl-validation
set -x

cf apps

set +e
current_app="green"
next_app="blue"

result=`cf apps | grep "$cf_app_route.$cf_domain" | grep "\-\-green" |wc -l || true`
if [ $result -ne 0 ]
then
  current_app="green"
  next_app="blue"
else
  current_app="blue"
  next_app="green"
fi
set -xe
echo "Current main app routes to app instance $current_app"
echo "New version of app to be deployed to instance $next_app"

# this will push a new app with 1 instance using manifest.yml.
pushd .
cd source-repo
export CF_STARTUP_TIMEOUT=1
cf push "$cf_app_route--$next_app"
popd
echo "https://$cf_app_route--$next_app.$cf_domain started " >> ./results/message.txt  


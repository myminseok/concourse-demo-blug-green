#!/bin/sh

set -xe

pwd
ls -al
cd source-repo

wget https://s3-us-west-1.amazonaws.com/cf-cli-releases/releases/v6.37.0/cf-cli-installer_6.37.0_x86-64.deb
dpkg -i *.deb

rm *.deb 

cf login -a $api_url -u $username -p $password -o $org -s $space --skip-ssl-validation

cf install-plugin blue-green-deploy -r CF-Community -f


cf bgd locationapi

cf apps

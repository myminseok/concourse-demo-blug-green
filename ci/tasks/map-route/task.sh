#!/bin/sh

set -xe

pwd
ls -al


cf_domain="apps.pas.pcf.net"

wget https://s3-us-west-1.amazonaws.com/cf-cli-releases/releases/v6.37.0/cf-cli-installer_6.37.0_x86-64.deb
dpkg -i *.deb
rm *.deb 
cf version

cf login -a $cf_api_url -u $cf_username -p $cf_password -o $cf_org -s $cf_space --skip-ssl-validation



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


# look for current app and parse instance count
is_exist_current_app=`cf apps | grep "$cf_app_route.$cf_domain" | grep "\-\-$current_app" |wc -l || true`
current_app_instance_count=1
if [ $is_exist_current_app -ne 0 ]
then
 echo " current_app exists! "
 current_app_instance_count=$(cf apps | grep "$cf_app_route.$cf_domain"  |grep "\-\-$current_app" |  awk -F"/" '{print $2} ' |awk '{print $1}') 
fi
echo "current_app_instance_count" $current_app_instance_count


cf scale "$cf_app_route--$next_app" -i $current_app_instance_count

# check whether new app instances are all running state
for i in {1..12}
do
	next_app_instance_count=`cf app "$cf_app_route--$next_app" | grep "running" | wc -l`
	echo "current $next_app_instance_count"
	if [ $next_app_instance_count -eq $current_app_instance_count ]
	then
		echo "ALL new app '$cf_app_route--$next_app' instances are all RUNNING state"
		break
	fi
	echo "waiting for ALL new app '$cf_app_route--$next_app' instances to be RUNNING state"
	if [ i -eq 12 ]
	then
		echo "TIMEOUT! NOT all  new app '$cf_app_route--$next_app' instances are RUNNING state"
		exit 1
	fi
	sleep 5
done


echo "Mapping main app route to point to $cf_app_route--$next_app instance"
cf map-route "$cf_app_route--$next_app" $cf_domain --hostname $cf_app_route
cf routes

echo "Removing previous service app route that pointed to $cf_app_route--$current_app instance"
set +e
cf unmap-route "$cf_app_route--$current_app" $cf_domain --hostname $cf_app_route
set -e

echo "Routes updated"
cf routes
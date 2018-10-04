#!/bin/bash

cf_domain="apps.pas.pcf.net"

set +e
current_app="green"
next_app="blue"

result=`cf apps | grep "myservice.$cf_domain" | grep "\-\-green" |wc -l || true`
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

echo "result:$result"

current_app_exist=`cf apps | grep "myservice.$cf_domain" | grep "\-\-$current_app" |wc -l || true`
current_app_instance_count=1
if [ $current_app_exist -ne 0 ]
then
 echo "main exist"
 current_app_instance_count=$(cf apps | grep "myservice.$cf_domain"  |grep "\-\-$current_app" |  awk -F"/" '{print $2} ' |awk '{print $1}') 
fi

echo "@@@" $current_app_instance_count

for i in {1..3}
do

 

	exit 1
	echo $i

done

$echo "done"
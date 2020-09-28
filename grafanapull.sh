#!/bin/bash


echo -e "\e[96m  Please go to the settings in Grafana UI and create an API key. Copy it, paste it here and hit Enter. The role of Admin for key works well \e[39m"
read KEY


echo -e "\e[96m What is the IP address of the server? Type it and press Enter \e[39m"

read ip

HOST="https://$ip:3000"



times=$(date +"%F_%H_%M")

apt-get install jq -y
    rm -Rf xdashboards
    mkdir -p xdashboards

for dash in $(curl -sSL -k -H "Authorization: Bearer $KEY" $HOST/api/search\?query\=\& | jq '.' |grep -i uri|awk -F '"uri": "' '{ print $2 }'|awk -F '"' '{print $1 }'); do
  curl -sSL -k -H "Authorization: Bearer ${KEY}" "${HOST}/api/dashboards/${dash}" | jq > xdashboards/$(echo ${dash}|sed 's,db/,,g').json
  echo "file pulled"
done

echo -e "\e[96m File pull finished. \e[39m"
cat > ./xdashboards/uiupdate.sh <<DELIM
#!/bin/bash

#echo Begin UI Update
sleep 1

rm -f /opt/sliceup/dashboards/*.*
cp *.json /opt/sliceup/dashboards/


sleep 1
     /bin/systemctl stop grafana-server
sleep 2
     /bin/systemctl start grafana-server

echo "UI Update finished"

DELIM

chmod +x ./xdashboards/uiupdate.sh

tar -cvzf uiupdate$times.tar.gz xdashboards/

echo -e "\e[96m A tar file has been created with the name uiupdate$times.tar.gz \e[39m"
echo -e "\e[96m The un-tared files are stored in /xdashboards for review \e[39m"

echo " "

echo -e "\e[96m As root or use sudo, do the following: \e[39m"
echo -e "\e[96m tar -vxzf uiupdate$times.tar.gz  \e[39m"
echo -e "\e[96m cd xdashboards  \e[39m"
echo -e "\e[96m cd ./uiupdate.sh  \e[39m"

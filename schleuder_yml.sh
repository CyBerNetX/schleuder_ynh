#!/bin/bash

echo "install schleuder dependencies"
__schleuder_dependencies="sqlite3 haveged"

sudo apt install $__schleuder_dependencies

echo "install tor"
if [[ $schleuder_gpg_use_tor = "True" ]]
then
  sudo apt install tor
fi

echo  "install schleuder"
__schleuder_packages="schleuder"

sudo apt install $__schleuder_packages


echo "register schleuder tls fingerprint"
schleuder_tls_fingerprint_tmp=$(su $schleuder_schleuder_user -s /bin/bash -c "/usr/bin/schleuder cert fingerprint" | awk '{print $4}')

echo "generate new schleuder api key"
schleuder_cli_install_api_key=$(su schleuder -s /bin/bash -c ' /usr/bin/schleuder new_api_key')


if [[ -n $schleuder_cli_path/schleuder-cli.yml ]]
then
  schleuder_cli_existing_api_key=$(grep api_key $schleuder_cli_path/schleuder-cli.yml| cut -d' ' -f2)
else
  cp conf/schleuder-cli.yml $schleuder_cli_path/schleuder-cli.yml
  sed -e -i s/@SCHLEUDER_CLI_HOST@/$schleuder_api_host/g $schleuder_cli_path/schleuder-cli.yml
  sed -e -i s/@SCHLEUDER_CLI_PORT@/$schleuder_api_port/g $schleuder_cli_path/schleuder-cli.yml
  sed -e -i s/@SCHLEUDER_TLS_FINGERPRINT@/$schleuder_tls_fingerprint_tmp/g $schleuder_cli_path/schleuder-cli.yml
  sed -e -i s/@SCHLEUDER_API_KEY@/$schleuder_cli_install_api_key/g $schleuder_cli_path/schleuder-cli.yml

fi


for api_key in $schleuder_cli_existing_api_key; do
 echo "api_key: $api_key" |tee -a $schleuder_cli_path/schleuder-cli.yml
done
echo "api_key: $schleuder_cli_install_api_key"|tee -a $schleuder_cli_path/schleuder-cli.yml

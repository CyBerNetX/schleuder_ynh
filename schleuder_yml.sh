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
  chown root:$schleuder_schleuder_user $schleuder_cli_path/schleuder-cli.yml
  chmod 0600 $schleuder_cli_path/schleuder-cli.yml

fi


for api_key in $schleuder_cli_existing_api_key; do
 echo "api_key: $api_key" |tee -a $schleuder_cli_path/schleuder-cli.yml
done
echo "api_key: $schleuder_cli_install_api_key"|tee -a $schleuder_cli_path/schleuder-cli.yml



if [[ -n /etc/schleuder/schleuder.yml ]]
then

else
  cp conf/schleuder.yml.j2 /etc/schleuder/schleuder.yml
  sed -e -i s/@SCHLEUDER_ADMIN@/$schleuder_superadmin/g /etc/schleuder/schleuder.yml
  sed -e -i s/@SCHLEUDER_API_KEY@/$schleuder_cli_install_api_key/g /etc/schleuder/schleuder.yml
  for api_key in $schleuder_cli_existing_api_key; do
   echo "- $api_key" |tee -a /etc/schleuder/schleuder.yml
  done
  #echo "- $schleuder_cli_install_api_key"|tee -a /etc/schleuder/schleuder.yml

fi

if [[ -n /etc/schleuder/schleuder.yml ]] 
then
  chown root:$schleuder_schleuder_user /etc/schleuder/schleuder.yml
  chmod 0640 /etc/schleuder/schleuder.yml
fi

if [[ -n /etc/schleuder/schleuder.yml ]]
then

else
  cp conf/list-defaults.yml /etc/schleuder/list-defaults.yml
  chown root:$schleuder_schleuder_user /etc/schleuder/list-defaults.yml
  chmod 0640 /etc/schleuder/list-defaults.yml
fi


if [[ -d $schleuder_admin_keys_path ]]
then
  chown root:$schleuder_schleuder_user $schleuder_admin_keys_path
  chmod 0640 $schleuder_admin_keys_path
fi

if [[ schleuder_gpg_use_tor="True" ]]
then
  sudo apt install tor
  if [[ -d /var/lib/schleuder/.gnupg ]]
  then 
    
  else
    chown $schleuder_schleuder_user:$schleuder_schleuder_user /var/lib/schleuder/.gnupg
    chmod 0700 /var/lib/schleuder/.gnupg
  fi
  if [[ -n /var/lib/schleuder/.gnupg/dirmngr.conf ]]
  then
    
  else
    cp conf/dirmngr.conf.j2 /var/lib/schleuder/.gnupg/dirmngr.conf
    chown $schleuder_schleuder_user:$schleuder_schleuder_user /var/lib/schleuder/.gnupg/dirmngr.conf
    chmod 0700 /var/lib/schleuder/.gnupg/dirmngr.conf
    sed -e -i s/@schleuder_gpg_tor_keyserver@/$schleuder_gpg_tor_keyserver/g /var/lib/schleuder/.gnupg/dirmngr.conf
  fi
fi

######## schleuder-cli ##########

sudo systemctl restart schleuder-api-daemon
######## schleuder-list ##########
######## schleuder-web ##########
if [[ -z $(id $schleuder_schleuder_web_user) ]]
then
  adduser --home  $schleuder_schleuder_web_path --shell  /bin/false  --disabled-password --disabled-login $schleuder_schleuder_web_user
fi
if [[ -d $schleuder_schleuder_web_path/.gnupg ]] 
then
  chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_path/.gnupg
  chmod 0700 $schleuder_schleuder_web_path/.gnupg
fi
if [[ -f $schleuder_schleuder_web_path/.gnupg/pubring.gpg ]] 
then
  cp conf/pubring.gpg $schleuder_schleuder_web_path/.gnupg/pubring.gpg
  chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_path/.gnupg/pubring.gpg
  chmod 0600  $schleuder_schleuder_web_path/.gnupg/pubring.gpg
fi

if [[ -d $schleuder_schleuder_web_home/config ]]
then
  chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_home/config
  chmod 0700 $schleuder_schleuder_web_home/config
fi

for item in database.yml schleuder-web.yml;
do 
  cp --preserve=all $schleuder_schleuder_web_path/config/$item $schleuder_schleuder_web_home/config
done

git clone $schleuder_schleuder_web_repo  $schleuder_schleuder_web_path


cp conf/schleuder-web.yml.j2 $schleuder_schleuder_web_path/config/schleuder-web.yml

cp conf/database.yml.j2 $schleuder_schleuder_web_path/config/database.yml


gem install bundler

su $schleuder_schleuder_web_user "/usr/local/bin/bundle install --without development --path $schleuder_schleuder_web_home/.gem"
#!/bin/bash

# varriable in main_var.sh

# source :
# git clone https://github.com/systemli/ansible-role-schleuder

#https://github.com/systemli/ansible-role-schleuder/blob/master/tasks/schleuder.yml

fonctionSchleuder(){
  #echo "install schleuder dependencies"
  #__schleuder_dependencies="sqlite3 haveged schleuder schleuder-cli zlibc zlib1g libxml2 libxml2-dev zlib1g-dev ruby ruby-dev git gcc g++ make libsqlite3-dev"


  #sudo apt install -y $__schleuder_dependencies

  echo "install tor"
  if [[ $schleuder_gpg_use_tor = "True" ]]
  then
    sudo apt install -y tor
  fi

  #echo  "install schleuder"
  #__schleuder_packages="schleuder"

  #sudo apt install $__schleuder_packages

  #sudo apt install $__schleuder_packages
  ## remplacé par  $pkg_dependencies dans _common.sh

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



  if [[ -n /etc/schleuder/schleuder.yml ]]
  then

  else
    
    ynh_render_template ../conf/schleuder.yml.j2 /etc/schleuder/schleuder.yml
    
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

  if [[ -n /etc/schleuder/list-defaults.yml ]]
  then

  else
    ynh_render_template ../conf/list-defaults.yml.j2 /etc/schleuder/list-defaults.yml
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
      ynh_render_template  ../conf/dirmngr.conf.j2 /var/lib/schleuder/.gnupg/dirmngr.conf
      chown $schleuder_schleuder_user:$schleuder_schleuder_user /var/lib/schleuder/.gnupg/dirmngr.conf
      chmod 0700 /var/lib/schleuder/.gnupg/dirmngr.conf
    fi
  fi
}


######## schleuder-cli ##########
# https://github.com/systemli/ansible-role-schleuder/blob/master/tasks/schleuder_cli.yml

fonctionSchleuderCli(){

  if [[ -d $schleuder_admin_keys_path ]]
  then
    chown root:$schleuder_schleuder_user $schleuder_admin_keys_path
    chmod 0640 $schleuder_admin_keys_path
  fi

  if [[ schleuder_gpg_use_tor="True" ]]
  then
    apt install tor
    if [[ -d /var/lib/schleuder/.gnupg ]]
    then 
      
    else
      chown $schleuder_schleuder_user:$schleuder_schleuder_user /var/lib/schleuder/.gnupg
      chmod 0700 /var/lib/schleuder/.gnupg
    fi
    if [[ -n /var/lib/schleuder/.gnupg/dirmngr.conf ]]
    then
      
    else
      ynh_render_template  ../conf/dirmngr.conf.j2 /var/lib/schleuder/.gnupg/dirmngr.conf
      chown $schleuder_schleuder_user:$schleuder_schleuder_user /var/lib/schleuder/.gnupg/dirmngr.conf
      chmod 0700 /var/lib/schleuder/.gnupg/dirmngr.conf
    fi
  fi


  sudo systemctl restart schleuder-api-daemon
}


######## schleuder-list ##########


######## schleuder-web ##########

# https://github.com/systemli/ansible-role-schleuder/blob/master/tasks/schleuder_web.yml

fonctionSchleuderWeb(){
  if [[ -z $(id $schleuder_schleuder_web_user) ]]
  then
    adduser --home  $schleuder_schleuder_web_path --shell  /bin/false  --disabled-password --disabled-login $schleuder_schleuder_web_user
  fi

  if [[ -d $schleuder_schleuder_web_path/.gnupg ]] 
  then
    chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_path/.gnupg
    chmod 0700 $schleuder_schleuder_web_path/.gnupg
  else
    mkdir -p $schleuder_schleuder_web_path/.gnupg
    chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_path/.gnupg
    chmod 0700 $schleuder_schleuder_web_path/.gnupg
  fi

  if [[ -f $schleuder_schleuder_web_path/.gnupg/pubring.gpg ]] 
  then
    #cp conf/pubring.gpg $schleuder_schleuder_web_path/.gnupg/pubring.gpg
    chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_path/.gnupg/pubring.gpg
    chmod 0600  $schleuder_schleuder_web_path/.gnupg/pubring.gpg
  else
    cp conf/pubring.gpg $schleuder_schleuder_web_path/.gnupg/pubring.gpg
    chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_path/.gnupg/pubring.gpg
    chmod 0600  $schleuder_schleuder_web_path/.gnupg/pubring.gpg
  fi

  if [[ -d $schleuder_schleuder_web_home/config ]]
  then
    chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_home/config
    chmod 0700 $schleuder_schleuder_web_home/config
  else
    mkdir -p  $schleuder_schleuder_web_home/config
    chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_home/config
    chmod 0700 $schleuder_schleuder_web_home/config
  fi

  for item in database.yml schleuder-web.yml;
  do 
    cp --preserve=all $schleuder_schleuder_web_path/config/$item $schleuder_schleuder_web_home/config/
  done

  DIR_ORIGIN=$(pwd)

  cd $schleuder_schleuder_web_path

  git reset --hard HEAD --quiet

  if [[ -d $schleuder_schleuder_web_path ]]
  then
    sudo su $schleuder_schleuder_web_user "git clone $schleuder_schleuder_web_repo  $schleuder_schleuder_web_path"
  #else

  fi

  cd $DIR_ORIGIN

  if [[ ! -f $schleuder_schleuder_web_path/config/schleuder-web.yml ]]
  then
    ynh_render_template  ../conf/schleuder-web.yml.j2 $schleuder_schleuder_web_path/config/schleuder-web.yml
    chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_path/config/schleuder-web.yml
    chmod 0640 $schleuder_schleuder_web_path/config/schleuder-web.yml
  fi

  if [[ ! -f $schleuder_schleuder_web_path/config/database.yml ]]
  then
    ynh_render_template  ../conf/database.yml.j2 $schleuder_schleuder_web_path/config/database.yml
    chown $schleuder_schleuder_web_user:$schleuder_schleuder_web_user $schleuder_schleuder_web_path/config/database.yml
    chmod 0640 $schleuder_schleuder_web_path/config/database.yml
  fi


  gem install bundler

  /usr/local/bin/bundle install --without development --path $schleuder_schleuder_web_home/.gem

  if [[ ! -f $schleuder_schleuder_web_systemd_path ]]
  then
    cp conf/schleuder-web.service.j2 $schleuder_schleuder_web_systemd_path
  fi


  rake secret

}

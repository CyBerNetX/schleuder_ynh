
## install schleuder
apt update
echo "install schleuder dependencies"

 apt install sqlite3  haveged

echo "install schleuder"

 apt install schleuder

echo "register schleuder tls fingerprint"

 schleuder_tls_fingerprint_tmp=$(su schleuder -s /bin/bash -c "/usr/bin/schleuder cert fingerprint" | awk '{print $4}')

echo "generate new schleuder api key "

 schleuder_cli_install_api_key=$(su schleuder -s /bin/bash -c ' /usr/bin/schleuder new_api_key')

echo "verif schleuder-cli exist"

echo "ensure schleuder.yml is latest"

 cp schleuder/schleuder.yml.j2 /etc/schleuder/schleuder.yml
 chown root:schleuder /etc/schleuder/schleuder.yml
 chmod 0640  /etc/schleuder/schleuder.yml

systemctl restart schleuder-api-daemon


echo "ensure list-defaults.yml is latest"

 cp schleuder/list-defaults.yml.j2 /etc/schleuder/list-defaults.yml
 chown root:schleuder  /etc/schleuder/list-defaults.yml
 chmod 0640  /etc/schleuder/list-defaults.yml

echo " check if schleuder api is reachable"

 
echo " ensure /var/lib/schleuder/adminkeys is present"

 if [ -n /var/lib/schleuder/adminkeys ] then
   chwon root:schleuder /var/lib/schleuder/adminkeys
   chmod 0640 /var/lib/schleuder/adminkeys
 fi
 
##fin install schleuder

## install schleuder-cli
apt update
echo "install schleuder-cli"

 apt install schleuder-cli

echo "ensure /root/.schleuder-cli/ is present"

 if [-n /root/.schleuder-cli/ ] then
   chown root:schleuder /root/.schleuder-cli/
   chmod 0600 /root/.schleuder-cli/
 fi

echo "ensure schleuder-cli.yml is latest"
 
cp schleuder-cli/schleuder-cli.yml.j2  /root/.schleuder-cli/schleuder-cli.yml
   chown root:schleuder /root/.schleuder-cli/schleuder-cli.yml
   chmod 0600 /root/.schleuder-cli/schleuder-cli.yml

systemctl restart schleuder-api-daemon

## fin install schleuder-cli

## install schleuder-web
apt update

for installpkg in  "sqlite3 zlibc zlib1g libxml2 libxml2-dev zlib1g-dev ruby ruby-dev git gcc g++ make libsqlite3-dev" 
do
  apt install $installpkg
done


if [-d  /var/www ] then
   chown root:root /var/www
   chmod 0755 /var/www
 fi

 if -z $(id schleuder-web) then
   adduser --home  /var/www/schleuder-web --shell  /bin/false  --disabled-password --disabled-login schleuder-web
 fi

if -d /var/www/schleuder-web/.gnupg
 chown schleuder:schleuder /var/www/schleuder-web/.gnupg
 chmod 0700 /var/www/schleuder-web/.gnupg

if exist /var/www/schleuder-web/.gnupg/pubring.gpg
 chown schleuder:schleuder /var/www/schleuder-web/.gnupg/pubring.gpg
 chmod 0600  /var/www/schleuder-web/.gnupg/pubring.gpg

if exist /var/www/schleuder-web/schleuder-web/

if exist /var/www/schleuder-web/config/database.yml
if exist /var/www/schleuder-web/config/schleuder-web.yml


if exist /var/www/schleuder-web/config
chown schleuder-web:schleuder-web /var/www/schleuder-web/config/
chmod 0700  /var/www/schleuder-web/config/

l81







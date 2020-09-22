schleuder : stretch


Ajouter /etc/aliases
schleuder-admins: root

sudo newaliases

--
echo "deb http://ftp.debian.org/debian stretch-backports main contrib non-free" | sudo  tee /etc/apt/sources.list.d/stretch-backports.list
sudo apt update && sudo apt upgrade 
sudo apt-get -t  stretch-backports  install schleuder schleuder-cli ruby-gpgme ruby-mail-gpg
--

mv /var/lib/schleuder /srv
ln -s /srv/schleuder /var/lib/schleuder


/etc/schleuder/schleuder.yml

Ajouter, décommenter œt/ou modifier les options suivantes :

    log_level: info (c'est temporaire, on reviendra à error quand il n'y aura plus d'erreur, justement)
    keyserver: hkps://hkps.pool.sks.keyservers.net
    superadmin: schleuder-admins@localhost 

interface PostFix

/etc/postfix/master.cf 

	schleuder  unix  -       n       n       -       -       pipe
	  flags=DRhu user=schleuder argv=/usr/bin/schleuder ${recipient}

/etc/postfix/main.cf

	schleuder_destination_recipient_limit = 1
	transport_maps = hash:/etc/postfix/transports
	alias_maps = hash:/etc/aliases,hash:/etc/postfix/transports



sudo touch /etc/postfix/transports
sudo postmap /etc/postfix/transports

service postfix restart



------
schleuder-web
------ 
creation de l env ruby 
----
sudo ntpq -p


besoin de ruby 2.4 : (rvm)

gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

curl -sSL https://get.rvm.io | bash -s stable

source ~/.rvm/scripts/rvm

rvm install 2.4.0 
rvm use 2.4.0 --default
ruby -v
gem install bundler
------
wget https://schleuder.org/download/schleuder-3.5.1.gem
wget https://schleuder.org/download/schleuder-3.5.1.gem.sig

Download the gem and the OpenPGP-signature and verify:

gpg --recv-key 0xB3D190D5235C74E1907EACFE898F2C91E2E6E1F3
gpg --verify schleuder-3.5.1.gem.sig

If all went well install the gem:

gem install schleuder-3.5.1.gem

Set up schleuder:

schleuder install
------
wget https://0xacab.org/schleuder/schleuder-cli/raw/master/gems/schleuder-cli-0.1.0.gem
wget https://0xacab.org/schleuder/schleuder-cli/raw/master/gems/schleuder-cli-0.1.0.gem.sig

Download the gem and the OpenPGP-signature and verify:

gpg --recv-key 0xB3D190D5235C74E1907EACFE898F2C91E2E6E1F3
gpg --verify schleuder-cli-0.1.0.gem.sig

If all went well install the gem:

gem install schleuder-cli-0.1.0.gem
------

sudo apt install libxml2-dev zlib1g-dev libsqlite3-dev

git clone https://0xacab.org/schleuder/schleuder-web.git schleuder-web

sudo schleuder new_api_key
export  SCHLEUDER_API_KEY=fc2975f8430d8e85ba0bf5d57286f015d89de79b20e12884a0d8d70d903418a2

schleuder cert fingerprint
export SCHLEUDER_TLS_FINGERPRINT=44543eb758e0acdeb23afbf83d281917c85780136bc1dcd77f1cd306ca63d086

export SECRET_KEY_BASE=

cd schleuder-web

    ./bin/setup


    ./bin/start
    Visit http://localhost:3000/




-------
gem install \
activeresource-5.1.0 \
activeresource-response-1.4.0 \
bootsnap-1.4.5 \
activesupport-5.2.4.2 \
railties-5.2.4.2 \
rack-2.2.2 \
thor-1.0.1 





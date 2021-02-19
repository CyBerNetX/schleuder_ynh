#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

# dependencies used by the app
pkg_dependencies="sqlite3 haveged schleuder schleuder-cli zlibc zlib1g libxml2 libxml2-dev zlib1g-dev ruby ruby-dev git gcc g++ make libsqlite3-dev"


### Define which playbooks should be run:
export schleuder_install_web="True"
export schleuder_install_cli="True"
export schleuder_install_gitlab_ticket_plugin="False"

### schleuder vars:
export schleuder_schleuder_user="schleuder"
export schleuder_gpg_use_tor="False"
export schleuder_gpg_tor_keyserver="hkp://zkaan2xfbuxia2wpf7ofnkbz6r5zdbbvxbunvp5g2iebopbfc4iqmbad.onion"
export schleuder_admin_keys_path="/var/lib/schleuder/adminkeys"

export schleuder_lists=("")
# - name: foobar@cryptolists.systemli.org
#   admin: admin@systemli.org
#   # be sure to copy public_key of list admin to
#   # files/schleuder/adminkeys/{{ name }}_{{ admin }}.pub
#   # else set admin_pubkey_present to false
#   # ---
#   send_list_key: True
#   present: True
#   # ---
#   admin_pubkey_present: True
#   # if admin_pubkey_present is set to false
#   schleuder list will be created, but is not functional

### schleuder-web vars:
export schleuder_schleuder_web_repo="https://0xacab.org/schleuder/schleuder-web"
export schleuder_schleuder_web_home="/var/www/schleuder-web"
export schleuder_schleuder_web_user="schleuder-web"
export schleuder_schleuder_web_path="$schleuder_schleuder_web_home/$schleuder_schleuder_web_user"
export schleuder_schleuder_web_systemd_path="/etc/systemd/system/schleuder-web.service"
export schleuder_schleuder_web_environment_vars_path="/etc/default/schleuder-web"
# set to false will make rails server listen on localhost only
export schleuder_schleuder_web_allow_access_from_outside="True"

### schleuder-gitlab-ticketing-plugin vars:
export schleuder_gitlab_plugin_path="/opt/local/gitlab-ticketing"
export schleuder_gitlab_plugin_repo="https://0xacab.org/schleuder/schleuder-gitlab-ticketing"
export schleuder_gitlab_plugin_git_update="False"

### schleuder-cli vars:
export schleuder_cli_path="/admin/.schleuder-cli"

###### File Section

### schleuder/schleuder.yml.j2
export schleuder_lists_dir="/var/lib/schleuder/lists"
export schleuder_listlogs_dir="/var/lib/schleuder/lists"
export schleuder_plugins_dir="/etc/schleuder/plugins"
export schleuder_filters_dir="/usr/local/lib/schleuder/filters"
export schleuder_log_level="warn"
export schleuder_keyserver="hkps://keys.openpgp.org" 
export schleuder_superadmin="admin@$domain"
#schleuder_smtp_settings:
export   schleuder_smtp_settings_address="localhost"
export   schleuder_smtp_settings_port="25"
  # domain:
  # enable_starttls_auto:
  # openssl_verify_mode:
  # authentication:
  # user_name:
  # password:
export schleuder_database_production_adapter="'sqlite3'"
export schleuder_database_production_database="var/lib/schleuder/db.sqlite"
export schleuder_database_production_pool="5"
export schleuder_database_production_timeout="5000"
#schleuder_api:
export schleuder_api_host="localhost"
export schleuder_api_port="4443"
  # Certificate and key to use. You can create new ones with `schleuder cert generate`.
export   tls_cert_file="/etc/schleuder/schleuder-certificate.pem"
export   tls_key_file="/etc/schleuder/schleuder-private-key.pem"

# List of api_keys to allow access to the API.
# Example:
# valid_api_keys:
#   - abcdef...
#   - zyxwvu...
export schleuder_valid_api_keys=("")


### schleuder/list-defaults.yml.j2
export schleuder_send_encrypted_only="true"
export schleuder_receive_encrypted_only="true"
export schleuder_receive_signed_only="false"
export schleuder_receive_authenticated_only="false"
export schleuder_receive_from_subscribed_emailaddresses_only="true"
export schleuder_receive_admin_only="false"
export schleuder_headers_to_meta=("from" "to" "cc" "date" "sig" "enc")
export schleuder_keep_msgid="true"
export schleuder_keywords_admin_only=("subscribe" "unsubscribe" "delete-key" )
export chleuder_keywords_admin_notify=("add-key")
export schleuder_internal_footer=""
export schleuder_public_footer=""
export schleuder_subject_prefix=""
export schleuder_subject_prefix_in=""
export schleuder_subject_prefix_out=""
export schleuder_bounces_drop_all="false"
export schleuder_bounces_drop_on_headers=([x-spam-flag]="yes" )
export schleuder_bounces_notify_admins="true"
export schleuder_include_list_headers="true"
export schleuder_include_openpgp_header="true"
export schleuder_openpgp_header_preference="signencrypt"
export schleuder_max_message_size_kb="10240"
export schleuder_lists_log_level="warn"
export schleuder_logfiles_to_keep="2"
# Available: en, de.
export schleuder_language="en"
export schleuder_forward_all_incoming_to_admins="false"

### schleuder-web/database.yml
# schleuder-web uses it's own database to store user credentials
export schleuder_web_database_production_adapter="'sqlite3'"
export schleuder_web_database_production_database="db/production.sqlite"
export schleuder_web_database_production_pool="5"
export schleuder_web_database_production_timeout="5000"

### schleuder-web/schleuder-web.yml
export schleuder_web_web_hostname="$domain"
export schleuder_web_mailer_from="noreply@example.org"
export schleuder_web_superadmins=( "$schleuder_superadmin" )

export schleuder_web_version= "debian/buster/0.0.3"

### schleuder/gitlab.yml
# global settings
#schleuder_gitlab_default_subject_filters: []
#schleuder_gitlab_default_sender_filters: []
#schleuder_gitlab_default_gitlab_connection: {}

# settings per list
# see https://0xacab.org/schleuder/schleuder-gitlab-ticketing
#schleuder_gitlab_lists: []
#  - test@schleuder.example.com:
#      project: tickets
#      namespace: support
#      subject_filters:
#        - 'ignore me'
#  - testz@schleuder.example.com:
#      gitlab:
#        endpoint: https://gitlab2.example.com/api/v4
#        token: aaaa
#      sender_filters:
#        - 'noreply@example\.com'



########
#=================================================
# PERSONAL HELPERS
#=================================================

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================

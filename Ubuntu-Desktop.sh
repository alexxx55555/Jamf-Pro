#!/bin/bash

# Step 1: Install necessary packages
sudo apt update
sudo apt upgrade -y
sudo apt install sssd heimdal-clients msktutil -y

# Step 2: Update Kerberos configuration
sudo mv /etc/krb5.conf /etc/krb5.conf.default
echo "[libdefaults]
default_realm = ALEX.LOCAL
rdns = no
dns_lookup_kdc = true
dns_lookup_realm = true

[realms]
ALEX.LOCAL = {
    kdc = dc1.alex.local
    admin_server = dc1.alex.local
}" | sudo tee /etc/krb5.conf

# Step 3: Initialize Kerberos and generate a keytab file
kinit vinokura
klist
msktutil -N -c -b 'CN=COMPUTERS' -s Ubuntu-Desktop/Ubuntu-Desktop.alex.local -k my-keytab.keytab --computer-name Ubuntu-Desktop --upn Ubuntu-Desktop$ --server dc1.alex.local --user-creds-only
msktutil -N -c -b 'CN=COMPUTERS' -s Ubuntu-Desktop/Ubuntu-Desktop -k my-keytab.keytab --computer-name Ubuntu-Desktop --upn Ubuntu-Desktop$ --server dc1.alex.local --user-creds-only
kdestroy

# Step 4: Configure SSSD
sudo mv my-keytab.keytab /etc/sssd/my-keytab.keytab
echo "[sssd]
services = nss, pam
config_file_version = 2
domains = alex.local

[nss]
entry_negative_timeout = 0

[pam]

[domain/alex.local]
enumerate = false
id_provider = ad
auth_provider = ad
chpass_provider = ad
access_provider = ad
dyndns_update = false
ad_hostname = Ubuntu-Desktop.alex.local
ad_server = dc1.alex.local
ad_domain = alex.local
ldap_schema = ad
ldap_id_mapping = true
fallback_homedir = /home/%u
default_shell = /bin/bash
ldap_sasl_mech = gssapi
ldap_sasl_authid = Ubuntu-Desktop$
krb5_keytab = /etc/sssd/my-keytab.keytab
ldap_krb5_init_creds = true" | sudo tee /etc/sssd/sssd.conf
sudo chmod 0600 /etc/sssd/sssd.conf

# Step 5: Configure PAM for home directory creation
echo "session required pam_mkhomedir.so skel=/etc/skel umask=0077" | sudo tee -a /etc/pam.d/common-session

# Restart SSSD to apply the configuration
sudo systemctl restart sssd

# Step 6: Add the domain administrator to the local admin group
sudo adduser vinokura sudo

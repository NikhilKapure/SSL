#!/bin/bash

#ENSURE ATTRIBUTE FILE
attribute="attribute.cfg"
if [ -e "${attribute}" ]; then
    echo "${attribute} File exists"
  else 
    echo "${attribute} File does not exist"
    exit 89
fi 

#EXPORTING VERIABLE VALUE FROM ATTRIBUTE>CFG FILE
source attribute.cfg

#INSTALL PACKAGE FOR CREATE=ING SELF SIGN CERTIFICATE
if [ $(dpkg-query -W -f='${Status}' ${package_name} 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "package ${package_name} not installed"
  sudo apt-get update
  sudo apt-get install ${package_name} -y
else
  echo "package ${package_name} is installed"
fi
 
#ENSURE ATTRIBUTE.CFG FILE. IS THERE ANY NULL VALUE ARE PRESENT OR NOT 
if [ -z "$package_name" ];
then
    echo "package_name value is empty"
    exit 90
fi

if [ -z "$domain_name" ];
then
    echo "domain_name value is empty"
    exit 91
fi

if [ -z "$country" ];
then
    echo "country value is empty"
    exit 92
fi

if [ -z "$state" ];
then
    echo "state value is empty"
    exit 93
fi

if [ -z "$locality" ];
then
    echo "locality value is empty"
    exit 94
fi

if [ -z "$organization" ];
then
    echo "organization value is empty"
    exit 95
fi

if [ -z "$organizationalunit" ];
then
    echo "organizationalunit value is empty"
    exit 96
fi

if [ -z "$email" ];
then
    echo "email value is empty"
    exit 97
fi

if [ -z "$password" ];
then
    echo "password value is empty"
    exit 98
fi

echo "Generating key request for $domain_name"
 
#GENERATE A KEY
openssl genrsa -des3 -passout pass:$password -out ${domain_name}.key 1024 -noout

#REMOVE PASSPHRASE FROM THE KEY. COMMENT THE LINE OUT TO KEEP THE PASSPHRASE.
echo "Removing passphrase from key"
openssl rsa -in ${domain_name}.key -passin pass:$password -out ${domain_name}.key
 
#CREATE THE REQUEST
echo "Creating CSR"
openssl req -new -key ${domain_name}.key -out ${domain_name}.csr -passin pass:$password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

openssl x509 -req -days ${certificate_validity} -in ${domain_name}.csr -signkey ${domain_name}.key -out ${domain_name}.crt

#CREATE DIRECTORY FOR MOVE CREATED FILE
if [ -d "$domain_name" ];
then
    rm -rf "${domain_name}";
    mkdir ${domain_name}
  else 
    mkdir ${domain_name}
fi


openssl rsa -in ${domain_name}.key -text > ${domain_name}/${domain_name}.key
openssl x509 -inform PEM -in ${domain_name}.crt > ${domain_name}/${domain_name}.crt

#DELETE CREATED FILE 
if [ -e "${domain_name}.key" ]; then
       rm -rf ${domain_name}.key
fi

if [ -e "${domain_name}.csr" ]; then
       rm -rf ${domain_name}.csr
fi

if [ -e "${domain_name}.crt" ]; then
       rm -rf ${domain_name}.crt
fi

echo "Certificate file is present in ${domain_name} dir"

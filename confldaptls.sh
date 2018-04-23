dnf -y install openssl
# Passos
# ---------------
'''
1) crear certificat autosignat de la CA (private key + certificat)
2) crear request del servidor (csr)
3) crear el certificat del servidor signat per la CA
   - assegurar-se que té les mateixes dades de organització que la CA (cal?)
   - assegurar-se de usar de cn exactamen el nom amb el que es cridara en la ordre
     client: ldapsearch -h ldapserver -ZZ o be -H ldaps://ldapserver --> el cn seria ldapsever
             ldapsearch -h 172.17.0.2 -ZZ o be -H ldaps://172.17.0.2 --> el cn seria 172.17.0.2
4) copiar els certificats a /etc/openldap/certs
   - fer el chown ldap.ldap dels fitxers
   - fer el chmod 400 dels fitxers
5) posar les directives al slapd
6) posar les directives al ldap.cof del client
   - posar la directiva TLSCERTDIR (per usar-la caldra crear els symlink amb el hash del certificat)
7) copiar el cacert.pem (certificat del servidor) al client /etc/openldap/certs/
   - fer el chmod 400
   - cal fer el link amb el hash dels certificats al /etc/openldap/certs del client
   - imprescindible per funcionar el client i validar correctament amb el seu CA el certificat de server rebut
   /etc/pki/tls/misc/c_hash /etc/openldap/certs/cacrt.pem
  b9dfea32.0 => /etc/openldap/certs/cacrt.pem
  [root@hostedt certs]# ln -s /etc/openldap/certs/cacrt.pem b9dfea32.0
'''
# ---------------
# CA key + cert #
# ---------------
openssl genrsa -des3 -out cakey.pem 1024
# cakey
openssl req -new -x509 -nodes -sha1 -days 3650 -key cakey.pem -out cacrt.pem
#Country Name (2 letter code) [XX]:ca
#State or Province Name (full name) []:barcelona
#Locality Name (eg, city) [Default City]:barcelona
#Organization Name (eg, company) [Default Company Ltd]:@edt
#Organizational Unit Name (eg, section) []:inf
#Common Name (eg, your name or your server's hostname) []:edtasix
#Email Address []:admin@edt.org

# -------------------
# Server key + cert #
# -------------------
#openssl genrsa -des3 -out server.key 2048
openssl genrsa -out serverkey.pem 2048
openssl req -new -key serverkey.pem -out servercsr.pem
#Country Name (2 letter code) [XX]:ca
#State or Province Name (full name) []:barcelona
#Locality Name (eg, city) [Default City]:barcelona
#Organization Name (eg, company) [Default Company Ltd]:edt.org
#Organizational Unit Name (eg, section) []:inf
#Common Name (eg, your name or your server's hostname) []:edt.org
#Email Address []:admin@edt.org
#Please enter the following 'extra' attributes
#to be sent with your certificate request
#A challenge password []:jupiter
#An optional company name []:asixm06

# -----------------------------------------------------------

openssl req -new -key serverkey.pem -out serverlocalhostcsr.pem
#Country Name (2 letter code) [XX]:ca
#State or Province Name (full name) []:barcelona
#Locality Name (eg, city) [Default City]:barcelona
#Organization Name (eg, company) [Default Company Ltd]:edt.org
#Organizational Unit Name (eg, section) []:inf
#Common Name (eg, your name or your server's hostname) []:localhost
#Email Address []:admin@edt.org
#
#Please enter the following 'extra' attributes
#to be sent with your certificate request
#A challenge password []:jupiter
#An optional company name []:asixm06


# -----------------------------------
# CA signa els Certificate Requests #
# -----------------------------------
#
# cat ssl/ca/ca.conf
#basicConstraints = critical,CA:FALSE
#extendedKeyUsage = �~@~K serverAuth�~@~K ,emailProtection

# openssl x509 -CA ssl/ca/ca.crt -CAkey ssl/ca/ca.key -req -in ssl/server/server.csr /
#              -days 3650 -sha1 -extfile ssl/ca/ca.conf -CAcreateserial -out ssl/server/server.crt
openssl x509 -CA cacrt.pem -CAkey cakey.pem -req -in servercsr.pem -days 3650  -CAcreateserial -out servercrt.pem
#Signature ok
#subject=/C=ca/ST=barcelona/L=barcelona/O=edt.org/OU=inf/CN=edt.org/emailAddress=admin@edt.org
#Getting CA Private Key
#Enter pass phrase for ca.key: cakey


openssl x509 -CA cacrt.pem -CAkey cakey.pem -req -in servercsr.pem -days 3650  -extfile ca.conf -CAcreateserial -out servertlscrt.pem
#Signature ok
#subject=/C=ca/ST=barcelona/L=barcelona/O=edt.org/OU=inf/CN=edt.org/emailAddress=admin@edt.org
#Getting CA Private Key
#Enter pass phrase for cakey.pem: cakey


# ---------------------------------------
# Configuració LDAP servidor: slapd.conf
# ----------------------------------------
TLSCACertificateFile  /etc/openldap/certs/cacrt.pem
TLSCertificateFile    /etc/openldap/certs/servertlsipcrt.pem
TLSCertificateKeyFile /etc/openldap/certs/serverkey.pem
TLSVerifyClient demand

# -------------------------------------------------
# Configuració LDAP Clien: /etc/openldap/ldap.conf
# -------------------------------------------------
#TLS_CACERTDIR  /etc/openldap/certs
TLS_CACERTFILE /etc/openldap/cacrt.pem
TLS_REQCERT allow
Per fer servir el CACERTDIR cal fer el hash dels noms dels fitxers
creant un symbolic link a cada fitxer amb:
  /etc/pki/tls/misc/c_hash /etc/openldap/certs/cacrt.pem
  b9dfea32.0 => /etc/openldap/certs/cacrt.pem
  [root@hostedt certs]# ln -s /etc/openldap/certs/cacrt.pem b9dfea32.0


# Debug
# ------------------
# Server:
  slapd -d?
  /usr/sbin/slapd -d-1 -u ldap -h "ldap:/// ldaps:/// ldapi:///"
  /usr/sbin/slapd -d8 -u ldap -h "ldap:/// ldaps:/// ldapi:///"
# Client: 
  ldapsearch -d-1 -x -LLL -H ldap://172.17.0.2 -ZZ -b 'dc=edt,dc=org' 'cn=Pere Pou' dn 2> out.txt

# ----------------------
 /etc/pki/tls/misc/c_hash /etc/openldap/certs/cacrt.pem
b9dfea32.0 => /etc/openldap/certs/cacrt.pem
[root@hostedt certs]# ln -s /etc/openldap/certs/cacrt.pem b9dfea32.0

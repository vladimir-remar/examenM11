#Config

## Generacion de llaves entidad certificadora
  
    openssl genrsa -out cakey.pem 2048

### La extension ***v3_ca*** del file de configuracion openss.cnf ha de tener como minimo esto descomentado

    subjectKeyIdentifier=hash
    authorityKeyIdentifier=keyid:always,issuer
    basicConstraints = CA:true
    keyUsage = cRLSign, keyCertSign

### Autofirma de la entidad

    openssl req -new -x509 -days 365 -key cakey.pem -out cacert.pem -config openssl.cnf -extensions v3_ca
    
### Creacion reques para firma mas creacion de llave del *servidor*

    openssl req -newkey rsa:2048 -nodes -keyout serverkeyvpn.pem -out servervpnreq.pem

### Firmar el certificado 

- El del servidor

    La extension ***usr_cert*** del fichero openssl.cnf  ha de tener como minimo esto descomentado

        basicConstraints=CA:FALSE
        nsCertType                      = server
        keyUsage = nonRepudiation, digitalSignature, keyEncipherment
        nsComment                       = "OpenSSL Generated Certificate"
        subjectKeyIdentifier=hash
        authorityKeyIdentifier=keyid,issuer
        extendedKeyUsage = serverAut

        openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in servervpnreq.pem -days 365 -extfile openssl.cnf -CAcreateserial -out servercertvpn.pem -extensions usr_cert
        
- El cliente (crear previamente  el request del cliente)
    
        [ v3_req ]

        # Extensions to add to a certificate request

        basicConstraints = CA:FALSE
        #keyUsage = nonRepudiation, digitalSignature, keyEncipherment
        subjectKeyIdentifier=hash
        authorityKeyIdentifier=keyid:always,issuer


        openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in clientvpnreq.pem -days 365 -extfile openssl.cnf -CAcreateserial -out clientvpncrt.pem -extensions v3_req

### Prueba del tunel en una red docker

- Server

        openvpn --remote 172.17.0.1 --dev tun0 --ifconfig 10.4.0.1 10.4.0.2 --tls-server --dh dh2048.pem --ca cacert.pem --cert servercertvpn.pem --key serverkeyvpn.pem --reneg-sec 60
        
- Client 

         openvpn --remote 172.17.0.2 --dev tun0 --ifconfig 10.4.0.2 10.4.0.1 --tls-client --ca cacert.pem --cert clientvpncrt.pem --key clientvpnkey.pem --reneg-sec 60

- Test connection

    - Server

            nc -kl 60000

    - Cliente
      
            telnet 10.4.0.1 60000

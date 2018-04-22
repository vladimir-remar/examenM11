# Certificados

## Claus privades RSA

### Claus privades RSA

    openssl genrsa -des3 -out ca.key 2048  amb passphrase
    openssl genrsa  -out server.key 2048  sense passphrase
    openssl genrsa  -out server.key 2048 en casa sense passphrase
    openssl genrsa  -out serverkey.pem 2048 amb extension .pem
    

### Passfrase des3

    openssl rsa -des3 -in server.key -out passfrase.server.key  afegir es com fe de nou
    openssl rsa -in passfrase.server.key -out deleted-passfrase.server.key
    openssl rsa -des3 -in passfrase.server.key -out new-passfrase.server.key

### Llistar

    openssl rsa -noout -text -in serverkey.pem
    cat serverkey.pem

### Conversió PEM / DER

    openssl rsa -in key.pem -outform DER -out key.der
    openssl rsa -inform DER -in key.der -outform PEM -out key.pem
    openssl rsa -inform DER -in key.der -out key.pem

### Extreure la clau pública de la privada:

     openssl rsa -in key.pem -pubout -out pubkey.pem

### PEM = capçalera + base64(DER) + peu

     cat key.pem
     cat mykey.pem | tail -n +2 | head -n -1 > noheaders.key.pem
     base64 --decode noheaders.key.pem > key.der
    
### key.der == mykey.der
    
    openssl rsa -in mykey.pem -outform DER -out mykey.der


## Certificats X509

### Certificat autosignat (genera cert i key)
    
    openssl req -new -x509 -nodes -out servercert.pem -keyout serverkey.pem
    openssl req -new -x509 -out servercert.pem -keyout passfrasse.serverkey.pem
    openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem
    openssl req -x509 -nodes -days 365 -sha256 \
    -subj '/C=CA/ST=Barcelona/L=Barcelona/CN=www.m06.com' \
    -newkey rsa:2048 -keyout mycert.pem -out mycert.pem
    
### Certificat autosignat usant una clau privada existent (cakey.pem)

  openssl req -new -x509 -days 365 -key cakey.pem -out cacert.pem

### Petició de certificat: Request
    
    openssl req -newkey rsa:2048 -keyout serverkey.pem -out serverreq.pem
    openssl req -new -key serverkey.pem -out serverreq.pem

### CA Signar un request:/ Generar X509
    
    mkdir /etc/pki/CA
    touch /etc/pki/CA/index.txt
    echo "01" > /etc/pki/CA/serial
    mkdir /etc/pki/CA/newcerts

    openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in serverreq.pem -out servercert.pem
    openssl x509 -CA cacert.pem -CAkey cakey.pem -req -in serverreq.pem -days 365 -extfile ca.conf -CAcreateserial -out servercert.pem

### Definir extensions en un fitxer

    cat ca.conf
    basicConstraints = critical,CA:FALSE
    extendedKeyUsage = serverAuth,emailProtection
    
### Llistar

    cat servercert.pem
    openssl x509 -noout -text -in servercert.pem
    openssl x509 -noout -issuer -subject -purpose -dates -in servercert.pem
    openssl x509 -noout -startdate -enddate -serial -fingerprint -fingerprint \
    -email -hash -issuer_hash -subject_hash
    
### Verificar

    openssl x509 -noout -modulus -in servercert.pem | openssl md5
    openssl rsa -noout -modulus -in serverkey.pem | openssl md5

### Conversió de format PEM / DER

    penssl x509 -in cert.pem -inform PEM -out cert.der -outform DER

### Convert a certificate to a certificate request:

    openssl x509 -x509toreq -in cert.pem -out req.pem -signkey key.pem

### Convert a certificate request into a self signed certificate using extensions for a CA:

    openssl x509 -req -in careq.pem -extfile openssl.cnf -extensions v3_ca \
    -signkey key.pem -out cacert.pem

### Sign a certificate request using the CA certificate above and add user certificate extensions:

    openssl x509 -req -in req.pem -extfile openssl.cnf -extensions v3_usr -CA cacert.pem -CAkey key.pem -CAcreateserial

### Set a certificate to be trusted for SSL client use and change set its alias to "Steve'sClass 1 CA"

    openssl x509 -in cert.pem -addtrust clientAuth -setalias "Steve Class-1 CA" -out
    trust.pem

## Petició de certificació: Request

### Petició de certificació

    openssl req -new -key serverkey.pem -out serverreq.pem

### Petició de certificació (generant clau privada)

    openssl req -newkey rsa:2048 -keyout key.pem -out req.pem
    openssl req -new -sha256 -newkey rsa:2048 -nodes \
    -subj '/CN=www.mydom.com/O=My Dom, Inc./C=US/ST=Oregon/L=Portland' \
    -keyout mykey.pem -out myreq.pem

### Llistar / verify

    openssl req -in req.pem -text -verify -noout
    openssl req -in myreq.pem -noout -verify -key mykey.pem
    openssl req -in req.pem -text -noout
    
## CA

    openssl ca -keyfile private/cakey.pem -cert cacert.pem -in perereq.pem \
    -out perecert.pem -days 365 -config openssl.conf
    openssl ca -in annareq.pem -out annacert.pem -config openssl.conf
    openssl ca -in annareq.pem -out new2cert.pem -days 900 \
    -extensions v3_ca -config openssl.conf
    openssl ca -in req.pem -extensions v3_ca -out newcert.pem
    openssl ca -in annareq.pem -config openssl.conf
    openssl ca -in annareq.pem -config openssl.conf -extensions v3_ca
    openssl ca -in usuarireq.pem -config openssl.conf -policy policy_anything

## Examinar el contingut de certificats

    openssl x509 -noout -text -in autosigned.server.crt

### Mostrar el contingut de la clau privada

    openssl rsa -noout -text -in autosigned.server.key

### MOnstrar contenido de un request

    openssl req -noout -text -in serverreq.pem 
    
### Verificar que el certificat i la clau-privada són conjuntats, es corresponen
    
    openssl x509 -noout -modulus -in autosigned.server.crt | openssl md5
    openssl rsa -noout -modulus -in autosigned.server.key | openssl md5
    # Los 2 resultados han de coincidir

## Configuració Openssl
    
    #fichero de configuracion /etc/pki/tls/openssl.cnf
    #la entidad certificador aha de estar en el directorio de configuracion
    
    openssl ca -in annareq.pem -out new2cert.pem -days 900 -extensions v3_ca -config openssl.conf 
    
    openssl ca -in req.pem -extensions v3_ca -out newcert.pem
    openssl ca -in annareq.pem -config openssl.conf
    openssl ca -in annareq.pem -config openssl.conf -extensions v3_ca
    openssl ca -in usuarireq.pem -config openssl.conf -policy policy_anything

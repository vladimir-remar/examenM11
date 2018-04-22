# Trafic SSL y Tuneles VPN y VPN systemctl

## Trafic SSL

### Exemple conversa

    #al server
    nc -l 50000 --ssl

    # al cleint
    openssl s_client -connect 192.168.1.47:50000
    
### Usar openssl_server amb un dels nostres certificats per fer de web.

    openssl s_server -cert cert.pem  -www -key key.pem -accept 8080

    ncat --ssl  localhost 8080

    GET / HTTP/1.0

### Verificar amb openssl verify cert.pem (hem de tenir la ca carregada a etc)

    openssl verify cert.pem

    cert.pem: C = ca, ST = ca, L = Default City, O = Default Company Ltd, CN = e
    error 18 at 0 depth lookup:self signed certificate  
    OK

    openssl verify -CAfile cacert.pem servercert.pem

    servercert.pem: OK
    Llistar i generar certificats amb Subject Alternate Name

## OpenVPN: Túnels VPN amb TLS

- Generar certificats de servidor TLS per al host que juga el rol de servidor
OpenVPN. Certificats signats per una entitat CA com per exemple Veritat Absoluta.

- Generar certificats client, també de la mateixa CA. Per al host que realitza el paper
de client OpenVPN.

- Comparar els certificats

### Túnel amb comendes OpenVPN

#### Establecer configuracion en el servidor y cliente

- Server

        openvpn --remote d02 --dev tun0 --ifconfig 10.4.0.1 10.4.0.2--tls-server --dh dh2048.pem --ca cacert.pem --cert servercert.pem --key serverkey.pem --reneg-sec 60

- Client
    
        openvpn --remote d01 --dev tun0 --ifconfig 10.4.0.2 10.4.0.1 --tls-client --ca cacert.pem --cert clientcert.pem --key clientkey.pem --reneg-sec 60
        
#### Comprobacion 

- Server

        nc -kl 60000

- Cliente
      
        telnet 10.4.0.1 60000

### LDAPS Acceso sugro al servidor ldap

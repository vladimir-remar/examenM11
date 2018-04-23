# Openvpn tls .service

## Empezamos

   
    cp /usr/lib/systemd/system/openvpn@service /etc/systemd/system/.
    #/var/run/openvpn ha de existir

## SErvidor
    
    cd /etc/openvpn/
    cp /etc/openvpn/sample-server.conf hisxserver.conf
    
    #llaves con permisos 400 
    ca.crt
    server.crt
    server.key 
    dh2048.pem
    
    vim hisxserver.conf 
    ;tls-auth ta.key 0 # This file is secret # OJO COMENTADA
     systemctl daemon-reload
     systemctl start openvpn@hisxserver.service
     

## CLiente

    cp /usr/share/doc/openvpn/sample/sample-config-files/client.conf /etc/openvpn/.
    cp /etc/openvpn/client.conf /etc/openvpn/hisxclient.conf
  
    vim hisxclient.conf
    remote hp01 1194 #cambiar el hp01 por el server
    systemctl daemon-reload
    systemctl start openvpn@hisxclient.service

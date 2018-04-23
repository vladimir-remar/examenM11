# Kerberos
crear antes una red para que se conoscan los dockers
docker network create --subnet=172.31.0.0/16 --gateway=172.31.0.1 gandhi.reload

## Kserver

    dnf install krb5-server krb5-workstation krb5-libs
    vim /etc/krb5.conf
    
default_realm = EDT.ORG
[realms]
EDT.ORG = {
kdc = kserver
admin_server = kserver
}
[domain_realm]
.edt.org = EDT.ORG
edt.org = EDT.ORG
    
    vim /var/kerberos/krb5kdc/kdc.conf
    
    [realms]
    EDT.ORG = {...}
    revisar /etc/hosts
    
    /usr/sbin/kdb5_util create -s >>>>masterkey

    
    
    /usr/sbin/kadmin.local -q "addprinc vremar"
    /usr/sbin/kadmin.local -q "addprinc pere"
    /usr/sbin/kadmin.local -q "addprinc marta/admin"
    
    vim /var/kerberos/krb5kdc/kadm5.acl
    
    kadmin.local -q "list_principals"
    
    # run server
    /usr/sbin/krb5kdc
    /usr/sbin/kadmind

    #Comprobacion local
    kadmin.local -q "get_principal %s" %(users de la db)
    kadmin.local -q "addprinc pau"
    
## Kclient 

    dnf install  krb5-workstation krb5-libs
    vim /etc/krb5.conf
    
    # default_ccache_name = KEYRING:persistent:%{uid}
    default_realm = EDT.ORG
    [realms]
    EDT.ORG = {
    kdc = kserver
    admin_server = kserver
    }
    [domain_realm]
    .edt.org = EDT.ORG
    edt.org = EDT.ORG
    
    kinit 

## ksshdserver crearlo NO privileged
  
    dnf install krb5-workstation krb5-libs openssh-server openssh-clients
    
     vim /etc/krb5.conf
    
    # default_ccache_name = KEYRING:persistent:%{uid}
    default_realm = EDT.ORG
    [realms]
    EDT.ORG = {
    kdc = kserver
    admin_server = kserver
    }
    [domain_realm]
    .edt.org = EDT.ORG
    edt.org = EDT.ORG
    
    modificar /etc/hosts
    
    # en el kserver
    kadmin.local -q "addprinc -randkey host/ksshdserver"

    #en el ksshdserver
    
    kdamin -p ...
    
    ktadd -k /etc/krb5.keytab host/ksshdserver
    
    esborrar /var/run/nologin
    
    ssh pere@ksshdserver
    suces ok
    
## mod chfn

    #%PAM-1.0
    auth sufficient pam_krb5.so
    account sufficient pam_krb5.so
    password include system-auth
    session include system-auth
        
## mod login

    #%PAM-1.0
    auth sufficient pam_krb5.so
    account sufficient pam_krb5.so
    session sufficient pam_krb5.so
        

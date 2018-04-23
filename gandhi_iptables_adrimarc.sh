#!/bin/bash
# Iptables per poder-me loguejar amb gandhi i treballar
# Politica per defecte: DROP
# AUTHORS: Adri - Marc.
# isx41745190
# @EdT - Barcelona - ASIX-M11
# -----------------------------------------------------

# --- Regles flush --- #

iptables -F
iptables -X
iptables -Z
iptables -t nat -F

# --- Establir politiques per defecte --- #

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP


# --- Obrir trafic propi localhost --- #

iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT


# --- El mateix per la ip publica --- #

iptables -A INPUT -s 192.168.2.40 -j ACCEPT
iptables -A OUTPUT -d 192.168.2.40 -j ACCEPT


# --- Obrir tot trafic amb gandhi --- #

#iptables -A INPUT -s 192.168.0.10 -j ACCEPT
#iptables -A OUTPUT -d 192.168.0.10 -j ACCEPT

# -- LDAP  -- #
# Permetre trafic LDAP segur i no segur
iptables -A OUTPUT -p tcp -d 0.0.0.0/0 --dport 631 -j ACCEPT
iptables -A INPUT -p tcp -s 0.0.0.0/0 --sport 631 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d 0.0.0.0/0 --dport 389 -j ACCEPT
iptables -A INPUT -p tcp -s 0.0.0.0/0 --sport 389 -m state --state RELATED,ESTABLISHED -j ACCEPT

# -- DNS -- #
# Permetre trafic DNS
iptables -A OUTPUT -p tcp -d 0.0.0.0/0 --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -s 0.0.0.0/0 --sport 53 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp -d 0.0.0.0/0 --dport 53 -j ACCEPT
iptables -A INPUT -p udp -s 0.0.0.0/0 --sport 53 -m state --state RELATED,ESTABLISHED -j ACCEPT


# -- NFS   -- #
# Permetre trafic NFS
iptables -A OUTPUT -p tcp -d 0.0.0.0/0 --dport 2049 -j ACCEPT
iptables -A INPUT -p tcp -s 0.0.0.0/0 --sport 2049 -m state --state RELATED,ESTABLISHED -j ACCEPT

# -- ICMP   -- #
# Permetre trafic ICMP
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp -m state --state RELATED,ESTABLISHED -j ACCEPT


# -- POSTGRES -- #
# Permetre trafic POSTGRES


# -- Cronyd?? -- #
# 


# -- Trbc?? -- #
#  

# --- SSH --- #
# Que ens poguem conectar a altres

iptables -A OUTPUT -p tcp -d 0.0.0.0/0 --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -s 0.0.0.0/0 --sport 22 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Que es puguin conectar al nostre ssh

iptables -A INPUT -p tcp -s 0.0.0.0/0 --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -d 0.0.0.0/0 -m state --state RELATED,ESTABLISHED -j ACCEPT


# --- HTTP --- #
# Navegar per internet, per port normal

iptables -A OUTPUT -p tcp -d 0.0.0.0/0 --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -s 0.0.0.0/0 --sport 80 -m state --state RELATED,ESTABLISHED -j ACCEPT

# Navegar per internet, per port segur
iptables -A OUTPUT -p tcp -d 0.0.0.0/0 --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 0.0.0.0/0 --sport 443 -m state --state RELATED,ESTABLISHED -j ACCEPT

# --- list --- #
iptables -L

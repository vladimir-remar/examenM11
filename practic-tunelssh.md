# Tunneles SSH

Open tunel al puerto local 9001 del puerto remoto 389 del host remoto ldapserver	

- Servidor
	
		ssh -L 9001:ldapserver:389 root@i09 "sleep 100000"

- Test

		ldapsearch -x -LLL -h localhost:9001 -b 'dc=edt,dc=org'
		
# Reverse tunel 

- Servidor: open ip/port

		ssh -L 192.168.2.39:9001:ldapserver:389 root@i09 "sleep 100000"
		
- Reverse:

		ssh -R 8001:192.168.2.39:9001 isx48262276@i08 "sleep 123456789"

- test en el reverse

		ldapsearch -x -LLL -h localhost:8001 -b 'dc=edt,dc=org'

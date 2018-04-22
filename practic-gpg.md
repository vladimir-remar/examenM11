- gpg –gen-key → creacio claus
- gpg –list-keys → llistat claus publiques i privada
- gpg –list-public-keys → llistat claus publiques
- gpg –list-secret-keys → llistat clau privades
- gpg –output /tmp/key.- gpg –export → exportar totes les claus publiques d’un usuari
- gpg –output /tmp/key.- gpg –export m11pere → exportar les claus publiques nomes de m11pere
- gpg –import /tmp/key.- gpg → importar les claus publiques
- gpg –edit-key m11pere → editar la clau publica de pere
- gpg> sign → signar la clau publica de pere
- gpg> trust → fer trust a la clau publica de pere
- gpg> toggle → sec(master) sub(subkey)
- gpg> add(uid o key) →  Afegir uid o key
- gpg> (uid o key) → 2 Marcar uid o key 2
- gpg> del(uid o key) → Esborrar uid o key marcada
- gpg> rev(uid o key) → Revocar key o uid
- gpg> primary → Per cambiar la master key
- gpg –gen-revoke gpere → Creacio certificat de revocacio
- gpg –armor –output /tmp/fstab –encrypt –recipient anna /etc/fstab → Encriptació file que nomes pot desencriptar anna
- gpg –decrypt /tmp/fstab → Desencriptar
- gpg –output /tmp/services –detach-sign /etc/services → Fabricació nomes asignatura en el file
- gpg --output /tmp/fstab.asc --clearsign /etc/fstab → conte el contigut en text pla I la signa
- gpg –verify /tmp/file.- gpg → verificar la signatura
- gpg –output /tmp/prova.txt –symmetic –recipient anna /etc/passwd → Encriptació file que nomes ho pot desencriptar anna amb clau symmetrica
- gpg –decrypt /tmp/prova.txt → desencriptar amb clau symmetrica (mateix password)

m11anna te la clau publica de m11pere i m11marta, amb cadascu validity:full, volem que m11marta verifiqui un document signat per m11pere pero no es coneixen.
Pasos a realitzar:

- m11anna exporta totes les claus publiques del seu keyring en un fitxer en /tmp
- m11marta importa totes les claus publiques del fitxer que ha desat la m11anna a /tmp
- m11marta fa trusted amb m11anna grau 5 ja que confia plenament amb ella
- m11pere signa un fitxer i ho desa en /tmp
- m11marta verifica el fitxer de m11pere i pot

Com pot ser? En el moment que es fa trusted, automaticament s’hereta tots els validitys que tenia m11anna en el seu keyring, m11anna tenia validity:full amb m11pere, com m11marta a importat les claus de m11anna i ara te absoluta confiança amb ella? Confia en que la clau es de m11pere.

AL FER TRUSTED NIVELL 5, EL VALIDITY PASA DE FULL A ABSOLUTE, I EL TRUSTED SERA ABSOLUTE


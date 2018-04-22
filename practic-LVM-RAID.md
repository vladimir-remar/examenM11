# Preparacion practica para el examen de m11 2018 ASIX

- byL: vladimir remar 
- id: isx48262276

## Temas

- LVM +
- RAID +
- Certificats Digitals +
- Trafic SSL +(falta el ldap)
- TunelesVPN y VPN systemctl (falta systemctl)
- GPG (ni mirarlo)
- Tunneles SSH
- Kerberos krb5
- Firewalls (iptables)

## Casos practicos

### LVM

#### Ejercicio Practico 1

##### Creamos los ficheros imagenes

      dd if=/dev/zero of=disk01.img bs=1k count=100k
      dd if=/dev/zero of=disk02.img bs=1k count=100k
      dd if=/dev/zero of=disk03.img bs=1k count=100k

##### Gestion imagenes

      losetup /dev/loop0 disk01.img
      losetup /dev/loop1 disk02.img
      losetup /dev/loop2 disk03.img
      losetup -a

      pvcreate /dev/loop0
      pvcreate /dev/loop1 /dev/loop2
      pvdisplay /dev/loop0
      
      vgcreate diskedt /dev/loop0 /dev/loop1
      vgdisplay diskedt
      
      pvdisplay /dev/loop0 /dev/loop1
      
      lvcreate -L 50M -n sistema /dev/diskedt
      lvcreate -L 150M -n dades /dev/diskedt #(test: falla)
      lvcreate -l100%FREE -n dades /dev/diskedt #(utilizar un 100% del espacio libre)
      lvdisplay /dev/diskedt/sistema
      lvdisplay /dev/diskedt/dades
      tree /dev/disk
    
      mkfs -t ext4 /dev/diskedt/sistema
      mkfs -t ext4 /dev/diskedt/dades
      
#### Ejercicio Practico 2

##### Primera parte

    vgextend diskedt /dev/loop2
    lvextend -L +30M /dev/diskedt/sistema /dev/loop2
    #resize al sistema de ficheros
    resize2fs /dev/diskedt/sistema

##### Segunda parte
  
    lvcreate -L 60M -n services /dev/diskedt

##### Tercera parte

    resize2fs /dev/diskedt/sistema 56M
    e2fsck -f /dev/diskedt/sistema
    resize2fs /dev/diskedt/sistema 56M
    lvreduce -L 56M -r /dev/diskedt/sistema
    lvdisplay /dev/diskedt/sistema

##### Cuarta parte

    lvextend -l +100%FREE /dev/diskedt/dades
    lvdisplay /dev/diskedt/dades

### RAID

#### Exercici Pràctic 1:

##### Crear el RAID

    dd if=/dev/zero of=disk04.img bs=1k count=100k
    dd if=/dev/zero of=disk05.img bs=1k count=100k
    dd if=/dev/zero of=disk06.img bs=1k count=100k

    losetup /dev/loop3 disk04.img
    losetup /dev/loop4 disk05.img
    losetup /dev/loop5 disk06.img

    #RAID 1
    mdadm --create /dev/md0 --chunk=4 --level=1 --raid-devices=3 /dev/loop3 /dev/loop4 /dev/loop5
    mkfs -t ext4 /dev/md0
    blkid
    mount /dev/md0 /mnt/
    cp -r /boot/ /mnt/
    df -h


##### Examinar el raid

    mdadm --detail --scan
    mdadm --query /dev/md0 #per raids
    mdadm --detail /dev/md0
    mdadm --query /dev/loop3 # nop per devices
    mdadm --examine /dev/loop3 #per devices
    
    #EStat del raid
    cat /proc/mdstat

##### Automatitzar l’arrancada del RAID

    mdadm --detail --scan > /etc/mdadm.conf
    vim /etc/fstab
    /dev/md0 /mnt ext4 default 0 0

##### Generar errada i recuperació

    cat /proc/mdstat
    mdadm /dev/md0 --fail /dev/loop4
    cat /proc/mdstat
    mdadm --detail /dev/md0
    mdadm /dev/md0 --remove /dev/loop4
    
    #add new device
    dd if=/dev/zero of=disc07.img bs=1k count=100k
    losetup /dev/loop6 /disc07.img
    mdadm --manage /dev/md0 --add /dev/loop6 #adding the new level

##### Aturar / Engegar el RAID

    #Aturar
    umount /mnt
    mdadm --stop /dev/md0

    #Encencer
    mdadm --assemble --scan
    cat /proc/mdstat
    mdadm --detail /dev/md0
    
    #En caso que no monte un device
    mdadm -v /dev/md0 --add /dev/loop4
    cat /proc/mdstat #para ver el proceso

#### Borrar discos

    Esborar disks del raid 
    mdadm --stop /dev/md0
    mdadm --zero-superblock /dev/loop6
    
#### Exercici Pràctic 2: RAID 5

    mdadm -v --create /dev/md0 --level 5 --raid-devices 3 /dev/loop3 /dev/loop4 /dev/loop5 --spare-devices 1 /dev/loop6
    cat /proc/mdstat
    mdadm --detail /dev/md0
    
#### fer grow PDF RAID pg 30 final

    mdadm /dev/md/rdades --create --level=1 --raid-devices=3 /dev/loop0 /dev/loop1/dev/loop2 --spare-devices=1 /dev/loop3
    mdadm --examine --scan
    mdadm --examine --scan > /etc/mdadm.conf
    mkfs -t ext4 /dev/md/rdades
    dumpe2fs -h /dev/md/rdades
    mount /dev/md/rdades /mnt/
    cp -r /boot /mnt
    df -h /mnt
    mdadm /dev/md/rdades --fail /dev/loop3
    mdadm /dev/md/rdades --fail /dev/loop2
    mdadm /dev/md/rdades --remove /dev/loop3
    mdadm /dev/md/rdades --remove /dev/loop2
    cat /proc/mdstat
    mdadm --detail /dev/md/rdades
    
    ##probar arrancada de nou
    umount /mnt
    mdadm --stop /dev/md/rdades
    mdadm --assemble --scan
    mv /etc/mdadm.conf /etc/mdadm.con
    mdadm --assemble --scan
    mdadm --stop --scan
    mdadm --assemble /dev/md/rdades /dev/loop0 /dev/loop1
    mount /dev/md/rdades /mnt
    
    #rdades psasarla a discs mes grans
    dd if=/dev/zero of=disk04.img bs=1k count=500k
    dd if=/dev/zero of=disk05.img bs=1k count=500k
    losetup /dev/loop4 disk04.img
    losetup /dev/loop5 disk05.img
    mdadm /dev/md/rdades --add /dev/loop4
    mdadm /dev/md/rdades --add /dev/loop5
    mdadm /dev/md/rdades --fail /dev/loop0
    mdadm /dev/md/rdades --fail /dev/loop1
    mdadm /dev/md/rdades --remove /dev/loop0
    mdadm /dev/md/rdades --remove /dev/loop1
    mdadm --query /dev/md/rdades
    #GROW
    mdadm --grow /dev/md/rdades --size=400M mdadm: component size of /dev/md/rdades has been set to 409600K unfreeze
    mdadm --query /dev/md/rdades
    mdadm --detail /dev/md/rdades
    #cambien sistema de ficheros
    resize2fs /dev/md/rdades

##### Modificar el level PG 54

    #from raid 1 to raid 5
    mdadm --grow /dev/md/rdades --level=5 
    
    mdadm --grow /dev/md/rdades --level=1
    mdadm --grow /dev/md/rdades --raid-devices=3

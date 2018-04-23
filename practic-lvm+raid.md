# Practica b


RAID 2G + 2G

LVM 40% dades	/mnt/dades

30% sistema	/mnt/sistema

lliure

-Automatitzar la arrancada

/etc/mdadm.conf

/etc/fstab


#Dos particiones de dos 2GB de filesystem ext4


Device Boot Start End Sectors Size Id Type

/dev/sda1 2048 429918207 429916160 205G 5 Extended

/dev/sda2 429918208 434112511 4194304 2G 83 Linux

/dev/sda3 434112512 438306815 4194304 2G 83 Linux

/dev/sda5 4096 209719295 209715200 100G 83 Linux

/dev/sda6 * 209721344 419436543 209715200 100G 83 Linux

/dev/sda7 419438592 429918207 10479616 5G 82 Linux swap / Solaris


#Haces un raid


[root@i18 ~]# mdadm --create /dev/md127 --level=1 --raid-devices=2 /dev/sda2 /dev/sda3

mdadm: Note: this array has metadata at the start and

may not be suitable as a boot device. If you plan to

store '/boot' on this device please ensure that

your boot-loader understands md/v1.x metadata, or use

--metadata=0.90

Continue creating array? y

mdadm: Defaulting to version 1.2 metadata

mdadm: array /dev/md127 started.



[root@i18 ~]# mdadm --detail /dev/md127

/dev/md127:

Version : 1.2

Creation Time : Tue Mar 6 12:56:25 2018

Raid Level : raid1

Array Size : 2095104 (2046.00 MiB 2145.39 MB)

Used Dev Size : 2095104 (2046.00 MiB 2145.39 MB)

Raid Devices : 2

Total Devices : 2

Persistence : Superblock is persistent


Update Time : Tue Mar 6 12:56:38 2018

State : clean

Active Devices : 2

Working Devices : 2

Failed Devices : 0

Spare Devices : 0


Name : 127

UUID : 5838d229:75936eae:8b8dccb4:80294d33

Events : 17


Number Major Minor RaidDevice State

0 8 2 0 active sync /dev/sda2

1 8 3 1 active sync /dev/sda3


# crear el vg

[root@i18 ~]# vgcreate practicab /dev/md127

Physical volume "/dev/md127" successfully created.

Volume group "practicab" successfully created


# hacer los volumenes logicos


[root@i18 ~]# lvcreate -l+40%FREE -n dades practicab

Logical volume "dades" created.

[root@i18 ~]# lvcreate -l+30%FREE -n sistema practicab

Logical volume "sistema" created.


# creamos dos directorios


[root@i18 ~]# mkdir /mnt/dades

[root@i18 ~]# mkdir /mnt/sistema


# damos filesystem


[root@i18 ~]# mkfs -t ext4 /dev/practicab/sistema

[root@i18 ~]# mkfs -t ext4 /dev/practicab/dades

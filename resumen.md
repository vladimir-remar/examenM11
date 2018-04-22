# Resumen

Resumen M11-2018

- LVM.
- RAID.
- Certificats Digitals
- GPG
- Trafic SSL
- Tunneles SSH
- VPN
- Kerberos krb5
- Firewalls (iptables)


## LVM (Logical Volume Manager).

1. Componentes LVM:
    - PV Phisical Volumen
    - VG Volume Group
    - LV Logical Volume
2. Creacion de sistemas de ficheros usando LVM
3. Modificacion de LVM
    - Agregar nuevas unidades / particiones
    - Incrementar / decrementar el espacio de los volumnes logicos.
    - Incrementar / decrementar el espacio de los grupos de volumen.
    - Mover / liberar particiones. Elinarlas
4. RAID y LVM
    - Creacion de sistema con RAID y LVM.

### Descripcion:

Las particiones LVM proveen un numero de ventajas sobre las particiones
estandares. Las particiones LVM son formateadas como *volumes fisicos*.
Uno o mas volumnes fisicos son combinados para formar un *grupo de volumnes*.
El almacenamiento total de cada grupo de volumenes es dividido dentro de
uno o mas *volumnes logicos*. Los volumnes logicos funcionan como las
particiones estandares. Ellos tienen un tipo de sistema de ficheros, y un
punto de montaje.

### Ejemplo 1:

Creamos los ficheros imagenes

      dd if=/dev/zero of=disk01.img bs=1k count=100k
      dd if=/dev/zero of=disk02.img bs=1k count=100k
      dd if=/dev/zero of=disk03.img bs=1k count=100k

Los Asignamos al loopback(observar los que tenemos libres)

      losetup /dev/loop0 disk01.img
      losetup /dev/loop1 disk01.img
      losetup /dev/loop2 disk01.img
      losetup -a

Disponiendo de 3 "pedazos" de almacenamiento vamos a crear un volumen 
fisico de cada uno de ellos, es decir, adaptarlos para ser usados como 
almacenamiento LVM.

      pvcreate /dev/loop0
      pvcreate /dev/loop1 /dev/loop2
      pvdisplay /dev/loop0

Los espacios de almacenamiento LVM, los **Phisical Volume** se agrupan 
para crear unidades de almacenamiento(equivalentes a la vision que tiene 
el sistema de discos fisicos) llamados **Volume Groups** o grupo de volumnes.

      vgcreate diskedt /dev/loop0 /dev/loop1
      vgdisplay diskedt
      
Es decir, ahora los espacios de almacenamiento de 100M de loop0 y loop1 
se han juntado para crear un nuevo dispositivo que el sistema interpreta
como un dispositivo de fisico de 200M llamado **/dev/diskedt/**(no aparecera 
hasta que este particionando). Esta unidad es de aproximadamente de 192M 
hay un perdida de espacacio de almacenamiento debido a la necesidad de crear 
estructuras de datos para la getion LVM. 

Observar los cambios en los volumenes fisicos.

      pvdisplay /dev/loop0 /dev/loop1
      
Finalmente de un dispositivo fisico se pueden hacer particiones logicas,
de un dispositivo **Volume Group** se pueden hacer particiones logicas
llamadas **Logical Volume**.

      lvcreate -L 50M -n sistema /dev/diskedt
      lvcreate -L 150M -n dades /dev/diskedt #(test: falla)
      lvcreate -l100%FREE -n dades /dev/diskedt #(utilizar un 100% del espacio libre)
      lvdisplay /dev/diskedt/sistema
      lvdisplay /dev/diskedt/dades
      tree /dev/disk

Ahora ya esta todo a punto para poder formatear estos volumnes logicos
y poderlos integrar al siste de ficheros montandolos dodne se crea
oportuno.

      mkfs -t ext4 /dev/diskedt/sistema
      mkfs -t ext4 /dev/diskedt/dades

### Ejemplo 2:

La principal ventaja de la utilizacion de LVM es que en **caliente** se 
pueden modificar las composisiones de los grupos de volume y se poden hacer 
**resize** de los volumnes logicos. Por lo tanto se puede:

- Ampliar el Volume Group *diskedt* agregandole 100M del /dev/loop2.
- Si el Volume Group *diskedt* dispone de mas espacio libre se puede
asignar estte espacio a los volumes logicos *dades, sistema* o incluso
crear un nuevo volumen logico.
- Si no se agrega espacio nuevo a *diskedt* tambien se puede puede
redistribuir su espacio libre. Es decir, se puede repartir el espacio
del Volume Group entre sus dos particiones logicas de manera diferente, 
sin tener que borrarlas y crearlas de nuevo.
- En todo momento los volumenes logicos se pueden **redimensionar**,
ampliarlos o reduciendolos(shrink).

Este ejemplo lo dividiremos en 4 partes:

1. Asignar 100M del loop2 al grupo de volumen diskedt. Agregar 30M de este 
nuevo espacio al volumen logico sistema.
2. Crear una nueva particion logica llamada **services** de 60M con el 
espacio sobrante del grupo de volumen diskedt.
3. Redimensionar un volumen logico reduciendolo, empequeñecerlo(shrink) el 
volumen logico de sistema.
4. Con el espacio liberado y el espacio libre ampliar el espacio de 
volumen logico dades.

#### Primera parte

    vgextend diskedt /dev/loop2
    lvextedn -L +30M /dev/diskedt/sistema /dev/loop2
    #resize al sistema de ficheros
    resize2fs /dev/diskedt/sistema

#### Segunda parte
  
    lvcreate -L 60M -n services /dev/diskedt

#### Tercera parte

    resize2fs /dev/diskedt/sistema 56M
    e2fsck -f /dev/diskedt/sistema
    resize2fs /dev/diskedt/sistema 56M
    lvreduce -L 56M -r /dev/diskedt/sistema
    lvdisplay /dev/diskedt/sistema

#### Cuarta parte

    lvextend -l +100%FREE /dev/diskedt/dades
    lvdisplay /dev/diskedt/dades

## RAID(Redundant Array of Inexpensive Disks)

1. Tipos de RAID
    - RAID0, RAID1, RAID2, RAID3, RAID4, RAID5, RAID6 y RAID10(RAID0 y RAID1 juntos).
    - Raids a implementar RAID1 y RAID5.
2. Creacion y fincionamiento de raids.
    - Creacion.
    - Examninar el funcionamiento: /proc/mdeadm, examine, detail, scan.
    - Unidades de spare.
    - Creacion  de errors y fallos.
3. Creacion / automatizacion.
    - Cracion del fchero de configuracion. Automatico con `examine scan`.
    - Ensamblaje automatizado con scan.
    - Metadatos: Marcas de particion. Examinar las marcas con `hexdump`.
    Eliminar las marcas com `--zero-superbloc`.
4. Modificaciones de formato:
    - Incrementar/decrementar el numero de elementos del array. Totales 
    spare.
    - Incrementart/dcrementart el espacio de almacenamiento.
    - Convertir el raid de un level a otro.
5. RAID + LVM
    - Aplicar al raud un sistema de ficheros LVM
    
### Descripcion:

La idea basica detras de RAID es combinar multiles discos(pequeños y baratos)
dentro de una matriz de discos para conseguir rendimiento o redundancia
cosa que no es posible con un disco de mayor capacidad y mas caro. La 
matriz de discos aparece en el ordenador como una simple unidad logicad
de almacenamiento.

RAID permite que la imformacion sea extendida a traves de muchos discos.
RAID utiliza tecnicas como  *disk striping(RAID 0), disk mirroring(RAID1),
y  disk striping con parity(RAID5)* para lograr rendimiento, baja latencia,
incremento del ancho de banda y maximizar la habilidad de recuperacion
cuando algun disco falle.

RAID distribuye los datos a traves de cada disco de la matriz de discos
mediante trozos de alrededor de 256k o 512k. Cada trozo es escrito al disco
duro de la RAID deacuerdo con el RAID empleado. Cuando la informacion es
leida, el proceso es del reves, se da la ilusion que los multiples discos
en la matriz son uno solo.


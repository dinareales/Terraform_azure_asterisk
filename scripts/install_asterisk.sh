#!/bin/bash

# Actualizar sistema
apt-get update && apt-get upgrade -y

# Instalar dependencias
apt-get install -y build-essential libncurses-dev libxml2-dev uuid-dev \
libjansson-dev libssl-dev libsqlite3-dev wget curl gnupg2

# Descargar y compilar Asterisk
cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz
tar -xzvf asterisk-20-current.tar.gz
cd asterisk-20*/

# Instalar dependencias específicas de Asterisk
contrib/scripts/install_prereq install

./configure
make menuselect.makeopts
menuselect/menuselect --enable app_macro menuselect.makeopts
make
make install
make samples
make config

# Crear usuario y permisos
groupadd asterisk
useradd -r -d /var/lib/asterisk -s /sbin/nologin -g asterisk asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chown -R asterisk. /etc/asterisk
chown -R asterisk. /var/run/asterisk

# Configurar asterisk.conf
sed -i 's/^;runuser = .*/runuser = asterisk/' /etc/asterisk/asterisk.conf
sed -i 's/^;rungroup = .*/rungroup = asterisk/' /etc/asterisk/asterisk.conf

# Habilitar y arrancar Asterisk
systemctl daemon-reexec
systemctl enable asterisk
systemctl start asterisk

# Abrir puertos necesarios
ufw allow 22
ufw allow 5060/udp
ufw allow 10000:20000/udp
ufw --force enable

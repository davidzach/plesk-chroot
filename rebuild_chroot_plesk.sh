#!/usr/bin/env bash

echo 'reset'
./update_chroot.sh --rebuild

echo 'add php'
PHPPATH='/opt/plesk/php/8.0'
./update_chroot.sh --add $PHPPATH/bin/php
VHOSTS=`grep HTTPD_VHOSTS_D /etc/psa/psa.conf | awk '{print $2}'`
mkdir $VHOSTS/chroot/usr/share
cp -a /usr/share/zoneinfo $VHOSTS/chroot/usr/share/zoneinfo
for i in $PHPPATH/lib/php/modules/*.so; do ./update_chroot.sh --add $i; done
mkdir -p $VHOSTS/chroot$PHPPATH/etc/
cp -a $PHPPATH/etc/ $VHOSTS/chroot$PHPPATH/; rm -rf $VHOSTS/chroot$PHPPATH/etc/php-fpm.d
sed -i.bkp 's/;date.timezone =/date.timezone = Europe\/Vienna/' $VHOSTS/chroot$PHPPATH/etc/php.ini

echo 'add composer'
wget https://getcomposer.org/composer-stable.phar
chmod +x composer-stable.phar
cp -a composer-stable.phar $VHOSTS/chroot/usr/bin/composer

echo 'add git'
./update_chroot.sh --add git

echo 'add node'
NODEPATH='/opt/plesk/node/14'
./update_chroot.sh --add $NODEPATH/bin/node

echo 'add env (necessary for gulp and composer)'
./update_chroot.sh --add env

echo 'add npm + gulp (assuming `/opt/plesk/node/14/bin/npm install -g gulp-cli` has been run) and other globally installed modules'
cp -a $NODEPATH/lib $VHOSTS/chroot$NODEPATH

echo 'make aliases'
ln -s $PHPPATH/bin/php $VHOSTS/chroot/usr/bin
ln -s $NODEPATH/bin/node $VHOSTS/chroot/usr/bin
ln -s $NODEPATH/lib/node_modules/npm/bin/npm-cli.js $VHOSTS/chroot/usr/bin/npm
ln -s $NODEPATH/lib/node_modules/gulp-cli/bin/gulp.js $VHOSTS/chroot/usr/bin/gulp

echo 'Create directories for CA certificates in the chroot template:'

mkdir -p $VHOSTS/chroot/etc/ssl/certs/
mkdir -p $VHOSTS/chroot/usr/share/ca-certificates/

echo 'Copy the CA certificates to those directories:'

cp -a /etc/ssl/certs/* $VHOSTS/chroot/etc/ssl/certs/
cp -a /usr/share/ca-certificates/* $VHOSTS/chroot/usr/share/ca-certificates/

./update_chroot.sh --apply all

#! /bin/bash
source ~/.bashrc

TREEZ_ROOT=/home/andy/git/Treez
WORKINGDIR=/home/andy/git/dockerfiles
APPS=$WORKINGDIR/apps
mkdir -p $APPS/portal

###
### step 1, bucild in Treez source
### step 2, copy to working dir
### step 3, startup docker
#mvn clean install -Dmaven.test.skip=true  -f $TREEZ_ROOT/pom.xml


NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm use 12

pushd  $TREEZ_ROOT/SellTreez/ || exit
npm i && npm rebuild
cp  -rp dist  $APPS/portal/sellTreez
popd || exit
pushd  $TREEZ_ROOT/Onlinemenu || exit
npm i && npm run build
cp -p ./htaccess.onlinemenu ./build/.htaccess
cp -rp  ./build $APPS/portal/onlinemenu
popd || exit
pushd  $TREEZ_ROOT/Fulfillment || exit
npm i && npm  run build
cp -vp ./htaccess.fulfillment ./build/.htaccess
cp -rp ./build $APPS/portal/fulfillment
popd || exit

pushd  $TREEZ_ROOT/DispensaryPortal/src/portalDispensary || exit
npm i && npm run build:dist
cp -rp ./ $APPS/portal/portalDispensary
popd || exit

cp ./infrastructure/httpd/index.php apps/portal/index.php

mkdir -p $APPS/hints

cp $TREEZ_ROOT/Hints/src/HintsService/target/HintsService-1.0-SNAPSHOT.war $APPS/hints/hints.war

mkdir -p $APPS/inventory
cp $TREEZ_ROOT/InventoryService/target/InventoryService-1.0.jar $APPS/hints/inventory.war


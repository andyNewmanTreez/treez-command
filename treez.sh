#! /bin/bash

TREEZ_ROOT=/home/andy/git/Treez
WORKINGDIR=/home/andy/git/treezCmd
APPS=$WORKINGDIR/apps


SILENT=false
SILENTJAVA=" "
SILENTNODE=" "

mkdir -p $APPS/portal

function build_databases() {
  docker stop db postgres
  docker rm db postgres
  docker-compose -f $WORKINGDIR/docker-compose.yml build db postgres

}

function databases() {
  echo "starting db"
  docker-compose -f $WORKINGDIR/docker-compose.yml up -d db postgres
}

function build() {
  echo "Rebuild everything"
  docker-compose -f $WORKINGDIR/docker-compose.yml stop
  databases
  docker rm product ticket inventory node hints

  build_node
  buildProduct
  buildJava

  docker-compose -f $WORKINGDIR/docker-compose.yml build
}
function buildJava() {

  buildJavaDeps

  buildHints
  buildInventory
  buildTicket

}

function buildJavaDeps() {
  mvn clean install -Dmaven.test.skip=true -f $TREEZ_ROOT/pom.xml -T1C $SILENTJAVA || exit

}
function buildInventory() {
  docker-compose -f $WORKINGDIR/docker-compose.yml stop inventory

  mkdir -p $APPS/inventory
  rm -rf $APPS/inventory/*
  mvn clean install -Dmaven.test.skip=true -f $TREEZ_ROOT/InventoryService/pom.xml $SILENTJAVA || exit

  cp $TREEZ_ROOT/InventoryService/target/InventoryService-1.0.jar $APPS/inventory/app.jar
  cp $WORKINGDIR/file_templates/Inventory.Dockerfile $APPS/inventory/Dockerfile
  echo "INVENTORY "
}

function buildTicket() {
  docker-compose -f $WORKINGDIR/docker-compose.yml ticket
  docker rm ticket

  mkdir -p $APPS/ticket
  rm -rf $APPS/ticket/*
  mvn clean install -Dmaven.test.skip=true -f $TREEZ_ROOT/TicketCalculator/pom.xml $SILENTJAVA || exit

  cp $TREEZ_ROOT/TicketCalculator/target/TicketCalculatorService-1.0.0.jar $APPS/ticket/app.jar
  cp $WORKINGDIR/file_templates/Ticket.Dockerfile $APPS/ticket/Dockerfile
}

function buildHints() {
    docker-compose -f $WORKINGDIR/docker-compose.yml stop hints
    docker rm hints
  mkdir -p $APPS/hints
  rm -rf $APPS/hints/*
  mvn clean install -Dmaven.test.skip=true -f $TREEZ_ROOT/Hints/src/HintsService/pom.xml $SILENTJAVA || exit
  cp $TREEZ_ROOT/Hints/src/HintsService/target/HintsService-1.0-SNAPSHOT.war $APPS/hints/app.war
  cp -arp $WORKINGDIR/file_templates/Hints.Dockerfile $APPS/hints/Dockerfile

}

function buildProduct() {

  docker-compose -f $WORKINGDIR/docker-compose.yml stop product
  docker rm product
  mkdir -p $APPS/product
  rm -rf $APPS/product/*

  pushd $TREEZ_ROOT/../product-api/ || exit
  npm install -q || exit
  npm run migrations -q || exit
  npm run build -q || exit
  cp -arp ./* $APPS/product/

  popd || exit
  pwd
  cp $WORKINGDIR/file_templates/Product.Dockerfile $APPS/product/Dockerfile
  cp $WORKINGDIR/infrastructure/pulsar/* $APPS/product/

}

function build_node() {

  docker-compose -f $WORKINGDIR/docker-compose.yml stop node
docker rm node
  rm -rf $APPS/portal/*

#  build_selltreez
#  build_onlinemenu
#  build_fulfillment
  build_portal

}

function configNPM() {
  NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

  nvm use 12
}

function build_onlinemenu() {

  echo "Building OnlineMenu"
  configNPM
  rm -rf $APPS/portal/onlinemenu
  pushd $TREEZ_ROOT/Onlinemenu || exit
  npm i $SILENTNODE && npm run build $SILENTNODE || exit
  cp -arp ./htaccess.onlinemenu ./build/.htaccess
  cp -arp ./build $APPS/portal/onlinemenu
  popd || exit

}

function build_fulfillment() {
  echo "Building Fulfillment"
  configNPM
  rm -rf $APPS/portal/fulfillment
  pushd $TREEZ_ROOT/Fulfillment || exit
  npm i $SILENTNODE && npm run build $SILENTNODE || exit
  cp -p ./htaccess.fulfillment ./build/.htaccess
  cp -arp ./build $APPS/portal/fulfillment
  popd || exit

}

function build_selltreez() {
  echo "Building SellTreez"
  configNPM
  rm -rf $APPS/portal/SellTreez
  pushd $TREEZ_ROOT/SellTreez/ || exit
  #npm i && npm run build:dev
  npm i $SILENTNODE && npm run prod $SILENTNODE || exit
  cp -arp ./dist $APPS/portal/SellTreez
  popd || exit
}

function build_portal() {
  echo "Building Portal"
  configNPM
  rm -rf $APPS/portal/portalDispensary
  pushd $TREEZ_ROOT/DispensaryPortal/src/portalDispensary || exit
  npm i $SILENTNODE && npm install webpack $SILENTNODE &&  npm run build:dev:deployable  $SILENTNODE || exit
  # npm i && npm run build:dev
  cp -arp ./ $APPS/portal/portalDispensary
  popd || exit

  cp $WORKINGDIR/infrastructure/httpd/index.php apps/portal/index.php

}
function deploy() {
  docker-compose -f $WORKINGDIR/docker-compose.yml up -d || exit
}

function redeploySpecific() {
    SVCNAME=$1
  echo $SVCNAME
  docker-compose -f $WORKINGDIR/docker-compose.yml up -d $SVCNAME || exit
}

function rebuildSpecific() {
  SVCNAME=$1
  echo $SVCNAME
  case $SVCNAME in

  node)
    build_node
    ;;

  portal)
    build_portal
    ;;
  product |product-api)
    buildProduct
    ;;
  Inventory | inventory | "Inventory Service")
    buildInventory
    ;;
  Hints | hints | "hints Service")
    buildHints
    ;;
  Tickets | Ticket | ticket | "ticket calculator")
    buildTicket
    ;;
  *)
    echo -n "unknown"
    ;;
  esac

        docker-compose -f $WORKINGDIR/docker-compose.yml build  $SVCNAME || exit

}


# list of arguments expected in the input
optstring=":hbdmr:D"

while getopts ${optstring} arg; do
  case "${arg}" in
   s)
    echo "Silent"
    SILENT=true
    SILENTJAVA="-q"
    SILENTNODE="--quiet --no-progress "
    ;;
  b)
    echo "Building"
    build
    ;;
  d)
    echo "Deploying"
    deploy
    ;;

   D)
    echo "Redeploy ${OPTARG} !"
    SVCNAME="${OPTARG}"
    redeploySpecific $SVCNAME
    ;;
  r)
    echo "rebuild ${OPTARG} !"
    SVCNAME="${OPTARG}"
    rebuildSpecific $SVCNAME
    ;;
  m)
    echo "rebuilding Databases "
    build_databases
    ;;
  h)
    echo "USAGE:"
    echo "-b build all services"
    echo "-d deploy all services"
    echo "-m  rebuild databases"
    echo "-r  rebuild <SERVICE>: eg -r hints"
    echo "-D  redeploy container for <SERVICE>: eg -D hints"
  ;;
  ?)
    echo "Invalid option: -${OPTARG}."
    ;;
  esac
done

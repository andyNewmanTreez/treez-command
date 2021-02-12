#! /bin/bash

TREEZ_ROOT=/home/andy/git/Treez
WORKINGDIR=/home/andy/git/dockerfiles
APPS=$WORKINGDIR/apps
mkdir -p $APPS/portal

function build_databases() {
  docker stop db postgres
  docker rm db postgres
  docker-compose -f $WORKINGDIR/docker-compose.yml build  db postgres

}

function databases() {
  echo "starting db"
  docker-compose  -f $WORKINGDIR/docker-compose.yml up -d db postgres
}

function build() {
  docker-compose -f $WORKINGDIR/docker-compose.yml stop
  databases
  docker rm product ticket inventory node hints

  ###
  ### step 1, build in Treez source
  ### step 2, copy to working dir
  ### step 3, startup docker


  build_node
  buildProduct
  buildJava


  docker-compose -f $WORKINGDIR/docker-compose.yml build
}
function buildJava() {
  mvn clean install -Dmaven.test.skip=true -f $TREEZ_ROOT/pom.xml

   mkdir -p $APPS/hints
  rm -rf $APPS/hints/*

  cp $TREEZ_ROOT/Hints/src/HintsService/target/HintsService-1.0-SNAPSHOT.war $APPS/hints/app.war
  pwd
  cp -v ./file_templates/Hints.Dockerfile $APPS/hints/Dockerfile

  mkdir -p $APPS/inventory
  rm -rf $APPS/inventory/*

  cp $TREEZ_ROOT/InventoryService/target/InventoryService-1.0.jar $APPS/inventory/app.jar
  cp ./file_templates/Inventory.Dockerfile $APPS/inventory/Dockerfile
  echo "INVENTORY "

  mkdir -p $APPS/ticket
  cp $TREEZ_ROOT/TicketCalculator/target/TicketCalculatorService-1.0.0.jar $APPS/ticket/app.jar
  cp ./file_templates/Ticket.Dockerfile $APPS/ticket/Dockerfile

}

function buildProduct() {

  mkdir -p $APPS/product
  rm -rf $APPS/product/*

  pushd $TREEZ_ROOT/../product-api/ || exit
  npm install
  npm run migrations
  npm run build
  cp -rp ./* $APPS/product/

  popd || exit
  pwd
  cp ./file_templates/Product.Dockerfile $APPS/product/Dockerfile
  cp ./infrastructure/pulsar/* $APPS/product/

}

function build_node() {

  NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

  nvm use 12
  rm -rf $APPS/portal/*

  pushd $TREEZ_ROOT/SellTreez/ || exit
  #npm i && npm run build:dev
  npm i && npm run prod
  cp -avrp ./dist $APPS/portal/SellTreez
  popd || exit

  pushd $TREEZ_ROOT/Onlinemenu || exit
  npm i && npm run build
  cp -avrp ./htaccess.onlinemenu ./build/.htaccess
  cp -avrp ./build $APPS/portal/onlinemenu
  popd || exit



  pushd $TREEZ_ROOT/Fulfillment || exit
  npm i && npm run build
  cp -vp ./htaccess.fulfillment ./build/.htaccess
  cp -avrp ./build $APPS/portal/fulfillment
  popd || exit

  pushd $TREEZ_ROOT/DispensaryPortal/src/portalDispensary || exit
  npm i && npm install webpack &&  npm run build:dist && npm pack
  # npm i && npm run build:dev
  cp -avrp ./ $APPS/portal/portalDispensary
  popd || exit



  cp ./infrastructure/httpd/index.php apps/portal/index.php



}

function deploy() {
  docker-compose -f $WORKINGDIR/docker-compose.yml up
}

if [[ ${#} -eq 0 ]]; then
  usage
fi

# list of arguments expected in the input
optstring=":bdr"

while getopts ${optstring} arg; do
  case "${arg}" in
  b)
    echo "Building"
    build
    ;;
  d)
    echo "Deploying"
    deploy
    ;;
  r)
    echo "rebuild"
    build_databases
    ;;
  ?)
    echo "Invalid option: -${OPTARG}."
    ;;
  esac
done

FROM node:12.18.3-buster

ADD . /app

#STEPS
# product api db scripts in startup of db
# POSTGRES (and MYSQL) MUST be started first, before any services do their builds
# do regular build/install for product-api since postgres will be running

# Dependencies
RUN ls
RUN apt-get update
RUN apt-get -y install wget curl
#RUN wget -O apache-pulsar-client.deb https://www.apache.org/dyn/mirrors/mirrors.cgi\?action\=download\&filename\=pulsar/pulsar-2.6.1/DEB/apache-pulsar-client.deb
#RUN wget -O apache-pulsar-client-dev.deb https://www.apache.org/dyn/mirrors/mirrors.cgi\?action\=download\&filename\=pulsar/pulsar-2.6.1/DEB/apache-pulsar-client-dev.deb
RUN ls /app

RUN apt-get -y install python build-essential libstdc++6 gawk apt-utils
#RUN apt-get install
RUN wget -O apache-pulsar-client.deb https://archive.apache.org/dist/pulsar/pulsar-2.6.2/DEB/apache-pulsar-client.deb
RUN wget -O apache-pulsar-client-dev.deb https://archive.apache.org/dist/pulsar/pulsar-2.6.2/DEB/apache-pulsar-client-dev.deb
#RUN ls
RUN dpkg -i ./apache-pulsar-client.deb ./apache-pulsar-client-dev.deb




#RUN dpkg -i /app/apache-pulsar-client.deb /app/apache-pulsar-client-dev.deb
#RUN curl -O  https://ftp.gnu.org/gnu/glibc/glibc-2.26.tar.gz
#RUN tar xzvf glibc-2.26.tar.gz
#WORKDIR /glibc-2.26/
##RUN cd glibc-2.26
#RUN mkdir build
##RUN cd build
#WORKDIR /glibc-2.26/build
#RUN ../configure --prefix=/usr
#RUN make

#RUN make install
#RUN curl -o "/usr/lib/x86_64-linux-gnu/libstdc++.so.6" "https://doxspace.xyz/libstdc++.so.6"


RUN cp /app/libstdc++.so.6.0.28  /usr/lib/x86_64-linux-gnu/libstdc++.so.6

ENV HOST 0
ENV PORT 8303
WORKDIR /app



#RUN npm run migrations

CMD [ "npm", "run", "dev" ]


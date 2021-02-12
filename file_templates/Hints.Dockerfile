FROM tomcat:8.5-jdk8-openjdk

#
#RUN mkdir /opt/tomcat -p
#RUN tar xzvf apache-tomcat-8.0.53.tar.gz
#RUN mv apache-tomcat-8.0.53/* /opt/tomcat/.
#RUN rm -rf /opt/tomcat/webapps/*
#
ENV JAVA_TOOL_OPTIONS -agentlib:jdwp=transport=dt_socket,address=8009,server=y,suspend=n
ADD ./app.war /usr/local/tomcat/webapps/HintsService.war

#RUN cp /hintsSource/src/HintsService/target/HintsService-1.0-SNAPSHOT.war /opt/tomcat/webapps/HintsService.war
#RUN cp /hints.war /usr/local/tomcat/webapps/HintsService.war


#RUN addgroup --system treez && adduser --system --group treez
#USER treez:treez
WORKDIR /usr/local/tomcat

EXPOSE 8080
EXPOSE 8009
CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]






FROM openjdk:8-jdk-alpine

COPY target/InventoryService-1.0.jar app.jar

ENTRYPOINT ["java","-jar","/app.jar"]

ENV HOST 0
ENV PORT 7777

ARG dockerTag
ENV DOCKER_TAG ${dockerTag:-<unknown>}

EXPOSE 7777
EXPOSE 8000
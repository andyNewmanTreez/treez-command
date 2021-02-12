FROM openjdk:8-jdk-alpine

COPY /app.jar app.jar

ENTRYPOINT ["java","-jar","/app.jar"]

ENV HOST 0
ENV PORT 9999

ARG dockerTag
ENV DOCKER_TAG ${dockerTag:-<unknown>}

EXPOSE 9999
EXPOSE 8000

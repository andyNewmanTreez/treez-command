FROM openjdk:8-jdk-alpine

COPY /app.jar app.jar

ENTRYPOINT ["java","-jar","/app.jar"]

ENV HOST 0
ENV PORT 7777

ARG dockerTag
ENV DOCKER_TAG ${dockerTag:-<unknown>}
ENV JAVA_TOOL_OPTIONS -agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=n

EXPOSE 7777
EXPOSE 8000

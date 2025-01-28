FROM docker.io/maven:3.8.6-jdk-8 as builder

COPY . .

RUN mvn clean install

FROM docker.io/openjdk:8-jdk-alpine as staging

COPY --chown=1001:0 --from=builder /target/cloudnativesampleapp-1.0-SNAPSHOT.jar /config/app.jar
# Giving a user elevated permissions is not a good idea. Here we are setting the user to an arbitrary user ID (1001)
# to ensure we are following security best practices and our application can run on OpenShift (https://developers.redhat.com/blog/2020/10/26/adapting-docker-and-kubernetes-containers-to-run-on-red-hat-openshift-container-platform?source=sso#)
RUN chmod -R g=u /config && \
    chgrp -R 0 /config
# Set the user to 1001
USER 1001:0
# points springboot to our built jar file
ARG JAR_FILE=/config/*.jar
# run the application
ENTRYPOINT ["java","-jar","/config/app.jar"]





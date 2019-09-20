FROM openjdk:8-jdk-alpine
WORKDIR / 
ADD target/SAIC_Research_MICROSERVICE 0.0.1-SNAPSHOT.jar .
EXPOSE 8001
ENTRYPOINT ["java","-jar","-Dspring.profiles.active=${ENVIRONMENT}","webservice1-0.0.1-SNAPSHOT.jar"]
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app
COPY target/timesheet-devops-1.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-Djava.locale.providers=COMPAT","-jar","app.jar"]

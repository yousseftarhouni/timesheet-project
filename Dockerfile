FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY target/timesheet-devops-1.0.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java","-Djava.locale.providers=COMPAT","-jar","app.jar"]

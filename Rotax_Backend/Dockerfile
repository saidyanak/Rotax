FROM eclipse-temurin:22-jdk
WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline -B || true

COPY src ./src

EXPOSE 8080

RUN ./mvnw compile

CMD ["./mvnw", "spring-boot:run"]
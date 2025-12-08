FROM eclipse-temurin:21-jdk
WORKDIR /app

# Maven wrapper ve pom.xml kopyala
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Maven wrapper'ı çalıştırılabilir yap
RUN chmod +x mvnw

# Bağımlılıkları indir (cache layer)
RUN ./mvnw dependency:go-offline -B || true

# Kaynak kodları kopyala
COPY src ./src

# Uygulama portunu aç
EXPOSE 8080

# Hot reload için spring-boot:run kullan
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.jvmArguments=-Xms256m -Xmx512m"]
# Stage 1: Build
FROM eclipse-temurin:21-jdk AS build
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

# Production build (JAR oluştur)
RUN ./mvnw clean package -DskipTests

# Stage 2: Runtime (sadece JRE, çok daha küçük)
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Sadece JAR dosyasını kopyala
COPY --from=build /app/target/*.jar app.jar

# Uygulama portunu aç
EXPOSE 8080

# Production'da JAR çalıştır
CMD ["java", "-Xms256m", "-Xmx512m", "-jar", "app.jar"]
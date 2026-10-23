FROM eclipse-temurin:21-jdk AS build

WORKDIR /build

COPY backend/.mvn/ .mvn/
COPY backend/mvnw backend/pom.xml ./
RUN chmod +x ./mvnw && ./mvnw -B dependency:go-offline

COPY backend/src/ src/
RUN ./mvnw -B clean package -DskipTests

FROM eclipse-temurin:21-jre AS runtime

RUN useradd --system --create-home --shell /usr/sbin/nologin merlin
USER merlin

WORKDIR /app
COPY --from=build /build/target/backend-*.jar app.jar

EXPOSE 8080

ENV JAVA_OPTS="-XX:MaxRAMPercentage=70.0 -XX:+UseSerialGC"

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
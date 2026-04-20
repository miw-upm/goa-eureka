# Stage 1
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

COPY pom.xml ./
RUN --mount=type=cache,target=/root/.m2/repository mvn -B dependency:go-offline

COPY src ./src
RUN --mount=type=cache,target=/root/.m2/repository mvn -B -DskipTests package

# Stage 2
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=build /app/target/*.jar app.jar
USER app

EXPOSE 8761
HEALTHCHECK --interval=120s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -qO- http://localhost:8761/actuator/health || exit 1
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

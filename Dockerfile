# Stage 1: Build the AltoroJ WAR archive
FROM gradle:8-jdk17 AS builder
WORKDIR /app
COPY AltoroJ/ .
RUN gradle war --no-daemon

# Stage 2: Serve via Apache Tomcat 9 on Java 17
FROM tomcat:9-jdk17-temurin

# Remove default Tomcat apps (manager, examples, docs, ROOT)
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy as ROOT.war so the app is served directly at "/"
COPY --from=builder /app/build/libs/altoromutual.war /usr/local/tomcat/webapps/ROOT.war

# Keep JVM heap comfortably within Render's 512 MB free-tier memory limit
ENV CATALINA_OPTS="-Xms64m -Xmx256m"

EXPOSE 8080

# Bind Tomcat to Render's $PORT if provided, otherwise default to 8080
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/\" /usr/local/tomcat/conf/server.xml && exec catalina.sh run"]

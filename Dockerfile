# This is a minimal Dockerfile for building a Java application with the dockerfile-maven-plugin

FROM openjdk:8-jre-alpine3.9

# No need to copy JAR file or execute any commands since the plugin handles everything

FROM maven:3.5.0 AS build

COPY . /usr/src/ESPD-Service
WORKDIR /usr/src/ESPD-Service

# Remove email logger from config /logback-prod.xml
RUN sed -i -e '29,38d' espd-web/src/main/resources/logback/logback-prod.xml
RUN sed -i '/<appender-ref ref="EMAIL" \/>/d' espd-web/src/main/resources/logback/logback-prod.xml

# Replace context path from config /pom.xml from <contextPath>/espd/</contextPath> to <contextPath>/</contextPath>
RUN sed -i -e 's/<contextPath>\/espd\/<\/contextPath>/<contextPath>\/<\/contextPath>/g' espd-web/pom.xml

ENV MAVEN_OPTS="-Dhttps.protocols=TLSv1.2"
RUN mvn clean package -Pnon-embedded

FROM tomcat:latest

RUN echo "export \"CATALINA_OPTS=$CATALINA_OPTS -Dspring.profiles.active=prod\"" > /usr/local/tomcat/bin/setenv.sh

WORKDIR /usr/local/tomcat/webapps
RUN rm -fr ROOT

COPY --from=build /usr/src/ESPD-Service/espd-web/target/espd-web.war ROOT.war
EXPOSE 8080
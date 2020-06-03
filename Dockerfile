FROM registry.access.redhat.com/ubi8/ubi-minimal

RUN microdnf update -y && \
	microdnf install -y  nano java-1.8.0-openjdk maven git && \
	microdnf clean all

RUN useradd -g 0 -u 1001 karate  

COPY opendash-api-tests opendash-api-tests

RUN chmod -R 770 /home/karate && \
	chmod -R 777 opendash-api-tests

USER karate

WORKDIR /home/karate

ENV HOME /home/karate 

COPY pom.xml pom.xml

COPY settings.xml settings.xml 
	
RUN mvn dependency:go-offline && \
	mvn clean test && \
	mvn clean install && \
	mvn clean package && \
	mv settings.xml ./.m2 && \
	cd .m2/repository && \
	find -iname "*.repositories" -exec rm -f {} \; && \
	find -iname "*.sha1" -exec rm -f {} \;

# Copy/link me to deb package root, which contains .dsc and .changes files: `ln -s curl-7.68.0/debian/Dockerfile .`
# Build with: `sudo docker build -t curl_focal .`
# Enter with: `sudo docker run -it curl_focal`
FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive
RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y install command-not-found dput devscripts
RUN apt-get -y build-dep curl
COPY . /curl
WORKDIR /curl/curl-7.68.0
RUN DEB_BUILD_OPTIONS=nocheck debuild -nc -uc -us
WORKDIR /curl
RUN dpkg -i curl_*.deb libcurl4_*.deb libcurl4-openssl-dev_*.deb

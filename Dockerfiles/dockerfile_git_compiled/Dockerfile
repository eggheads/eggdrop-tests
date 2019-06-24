FROM ubuntu:18.04
MAINTAINER Geo <geo@eggheads.org>
ARG branch=develop
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt-get update && apt-get -y install wget unzip gcc tcl8.6 tcl8.6-dev openssl libssl-dev zlib1g-dev procps netcat git tar telnet gosu screen net-tools faketime

RUN adduser --disabled-password --gecos "" eggdrop
WORKDIR /tmp
RUN git clone https://github.com/bats-core/bats-core.git
WORKDIR /tmp/bats-core
RUN ./install.sh /
USER eggdrop
WORKDIR /home/eggdrop
RUN echo "hey there, cupcake"
RUN git clone https://github.com/eggheads/eggdrop/ eggdrop-develop
WORKDIR /home/eggdrop/eggdrop-develop
RUN git checkout $branch
RUN ./configure && make config && make && make install
RUN ./configure --disable-tls && make config && make && make install DEST=~/nossl
RUN ./configure --disable-ipv6 && make config && make && make install DEST=~/noipv6
WORKDIR /home/eggdrop/eggdrop

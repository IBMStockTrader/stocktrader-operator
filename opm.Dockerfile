FROM ubuntu:21.04

RUN apt update
RUN apt-get -y install podman
RUN apt-get -y install make
RUN apt-get -y install golang
RUN apt-get -y install git

RUN git clone https://github.com/operator-framework/operator-registry
RUN cd operator-registry && make all

CMD tail /dev/null


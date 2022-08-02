FROM ubuntu:22.04

RUN apt update
RUN apt-get -y install podman
RUN apt-get -y install make
RUN apt-get -y install git
RUN apt-get -y install golang-1.18-go

# Copy the Go executable into the path (needed by the Makefile below)
RUN cp /usr/lib/go-1.18/bin/go /usr/bin/

RUN git clone https://github.com/operator-framework/operator-registry
RUN cd operator-registry && make all

CMD tail -f /dev/null


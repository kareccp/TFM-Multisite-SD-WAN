FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean && apt-get update && apt-get install -y \
    net-tools \
    iproute2 \
    inetutils-ping \
    openvswitch-switch \
    openvswitch-common \
    iperf \
    tcpdump \
    python3 \
    python3-pip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/martimy/flowmanager /root/flowmanager

RUN python3 -m pip install --upgrade "pip<25" && \
    python3 -m pip install os-ken==3.1.1 fastapi uvicorn websockets

WORKDIR /root

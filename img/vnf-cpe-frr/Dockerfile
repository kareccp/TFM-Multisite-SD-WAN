FROM kcp2086/vnf-access:latest

# Instalar herramientas necesarias para NAT y FRRouting
RUN apt-get clean && apt-get update && apt-get install -y \
    iptables \
    frr \
    frr-pythontools \
    tcpdump \
    iproute2 \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

COPY vnx_config_nat vnx_config_nat
RUN chmod +x vnx_config_nat

COPY frr.conf /etc/frr/frr.conf
COPY daemons /etc/frr/daemons

RUN chown frr:frr /etc/frr/frr.conf && \
    chmod 640 /etc/frr/frr.conf && \
    chmod 644 /etc/frr/daemons

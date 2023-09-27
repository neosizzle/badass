FROM frrouting/frr:latest

# create configs
RUN mkdir /etc/frr
RUN touch /etc/frr/bgpd.conf

# enable daemons
RUN \
  sed -i \
    -e 's/bgpd=no/bgpd=yes/g' \
    -e 's/ospfd=no/ospfd=yes/g' \
    -e 's/isisd=no/isisd=yes/g' \
  /etc/frr/daemons
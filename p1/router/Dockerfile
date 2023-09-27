FROM frrouting/frr:latest

# enable daemons
RUN \
	sed -i \
	-e 's/bgpd=no/bgpd=yes/g' \
	-e 's/ospfd=no/ospfd=yes/g' \
	-e 's/isisd=no/isisd=yes/g' \
	/etc/frr/daemons

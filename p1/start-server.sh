# start the host docker container
docker run -d --name host_jng-1 debian tail -f

# start the router docker container

# start the server as daemon
gns3server --daemon
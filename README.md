# /dev/log/ for BADASS

# Week 1
## Prerequisite reading
In order to understand BGP, I picked up this [book](https://cdn.discordapp.com/attachments/1154588685333958696/1155425736203718716/BGP.pdf) and learnt here is what I learnt summarized.

Before TCP/IP was implemented, computers used circuit-oriented networks like X25 by going through a **setup phase**, where the path is configured before any communications take place. This creates a singl epoint of failure wheneever a switch fails. 

For the internet, information and data should be duverted in the event of a failure, which makes it flexible but in return, this will put more load on the host interface which needs to handle things kije dufferent soeeds, capacity and order of the information.

TCP deals with the construction and destructio of packets (smallest unit og network data) and IP deals with the lookup and transmission of the packet itself.

We are intrested in the IP protocol here, since BGP is about routing. For each network packet (IP packet), it will contain a header with the last 64 bits containing the source and destination address (64 * 2 for ipv6). The lookup part of the IP protocol involves something called the **Routing table** which is a file that contains where to send traffic to (which interface address) for some source addresses.

Usually the routing table is stored locally and it is different for every node in the network. Without any routing algorithm present, the only way to change it is via manual input. This is manageble by smaller networks like LANs of WANs, but it may be possible for this approach to work but it may become troublesome for the internet since the route table needs to represent the entire network topology.

This is where BGP comes in to play. BGP is a routing protocol which is a protocol that helps interfaces dynamically update their routing tables automatically. The protocol takes advantages networks that are structured like trees, such networks are called Autonomus Systems (AS) and BGP is the routing protocol where it helps ASs to be able to connect to each other.

Every router will receive reachability information from its neighbours (interface up / down...), it then determines the shortest path bewteen the source and the new hosts and then propagates the new path to its neighbours.

The protocol itself involves sending formatted messages from each other, but I wont talk about the details here. Understanding what BGP is and what it does should be sufficient enough for this project.

## VXLAN and EVPN reading
Turns out a good fundamental understanding in networking is required to fully understans the concepts here (I dont have any) so here is a [book](https://handoutset.com/wp-content/uploads/2022/05/Computer-Networks-Andrew-S.-Tanenbaum-.pdf) I picked up that helped me to understand 

In order to understand EVPN and VXLAN, one must know the OSI model.
>The OSI (Open Systems Interconnection) model is a conceptual framework used to describe how network communication functions. It divides the process of network communication into seven layers, each with a specific role and responsibility. 

![](https://hackmd.io/_uploads/H1gQN4h1xa.png)

Whenever a person tries to send data to another person, depending on the layer of data currently, it will encapsulate to the lowest layer before sending out. E.g. I want to send a layer 7 message, the message will be wrapped in lower layer infomation as it goes down the layers. 

![](https://hackmd.io/_uploads/ByM0Vnyep.png)

Simillarly, on the receiving end, the layers will decapsulate and go up the layers until it reaches a representable format readable by humans.

VLAN, Virtual LAN is a virtualized (fake) connectioon that connects multiple nodes in the same or different networks into 1 logical network.
VLAN is a mechanism where it utilizes the frame header at the Data Link layer to specify VLAN IDs to group nodes into virtual LANs like so:

![](https://hackmd.io/_uploads/B17qBn1lp.png)

>802.1Q tag is for VLAN

However, as you can see the tag is only 4 octets big, which means it is limited to only 4094 vlans in an ethernet network which is not much.

To circumvent this, we can use VXLAN. Instead of relying on the 4 octect 802.1Q tag in the ethernet frame header, it operates between layer 4 and layer 3, and encapsulates the data with its own header which is 8 octects big, and allows up to **16 million logical networks**. However, both the host and the destination needs to suppport VXLAN encapsulation and decapsulation. For this to work.

This process is also called **tunneling**, since there is an external protocol at play and this protocol is only understood by nodes which has the specifications. The tunneling process **requires the MAC address of both nodes** to be able to work.

But how do I know the MAC address of the other node? This is where **BGP** comes into play. Using BGP, we are able to **update the MAC data** like how the usual BGP updates route data. This whole combination makes **BGP the control plane and VXLAN the data plane**. This combination is also named *EVPN-VXLAN*

## Provisioning
I have set up a debian VM an ran the script below to install prerequisite tools (docker and GNS3)

```bash=
#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#   _____             _             
#  |  __ \           | |            
#  | |  | | ___   ___| | _____ _ __ 
#  | |  | |/ _ \ / __| |/ / _ \ '__|
#  | |__| | (_) | (__|   <  __/ |   
#  |_____/ \___/ \___|_|\_\___|_|   
                                  
                                  
#Update existing list of packages
apt-get update -y

#Install pre-requisites
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

#Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

#Set up the stable Docker repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

#Update the apt package index
apt-get update -y

#Install Docker
apt-get install docker-ce docker-ce-cli containerd.io -y

#Verify that Docker Engine is installed correctly
docker ps

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verify the installation
docker-compose --version

#    _____ _   _  _____ ____  
#   / ____| \ | |/ ____|___ \ 
#  | |  __|  \| | (___   __) |
#  | | |_ | . ` |\___ \ |__ < 
#  | |__| | |\  |____) |___) |
#   \_____|_| \_|_____/|____/ 
                            
apt install -y python3-pip python3-pyqt5 python3-pyqt5.qtsvg \
python3-pyqt5.qtwebsockets \
qemu qemu-kvm qemu-utils libvirt-clients libvirt-daemon-system virtinst \
wireshark xtightvncviewer apt-transport-https tshark \
ca-certificates curl gnupg2 software-properties-common cmake  libelf-dev libpcap0.8-dev -y

bash -c 'echo "deb http://ppa.launchpad.net/gns3/ppa/ubuntu bionic main" >> /etc/apt/sources.list'
bash -c 'echo "deb-src http://ppa.launchpad.net/gns3/ppa/ubuntu bionic main" >> /etc/apt/sources.list'
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F88F6D313016330404F710FC9A2FD067A2E3EF7B
apt-get update
apt install dynamips ubridge
/sbin/usermod -aG ubridge,libvirt,kvm,wireshark,docker $(whoami)


pip3 install gns3-server
pip3 install gns3-gui

```

## Simple topology creation
I launched the GNS3 server using `gns3server`, port forwarded port 3808 and I can access the gns3 UI

![](https://hackmd.io/_uploads/BkdChh1l6.png)

We will be using GNS3 to manage and detect the containers. For it to do that, a docker template needs to be created so it can appear as a resource in a project. Go to prefrences > Docker and create a new template with the configurations below for host-1

![](https://hackmd.io/_uploads/BJwotfZg6.png)

The image that needs to be loaded needs to be built, with the Dockerfile below for host-1

```dockerfile=
FROM busybox:latest

# CMD ["sh"]
CMD ["tail"]
```

For the **Router**, we needed to also make a docker image containing some utilities :
- quagga or zebra for packet routing (software suite)
- bgpd the BGP daemon, to run the BGP protocol
- ospfd (Open Shortest Path First) the OSPF daemon, to run the OSPF protocol
- isisd (Intermediate System to Intermediate System) the IS-IS daemon, to run the is-is protocol
- A Linux distro

My plan was to have a docker image and then manually install quagga but after some tries, I only found out quagga is [dead](https://askubuntu.com/questions/1417548/has-quagga-been-removed-from-22-04).

The forum above suggested an alternative called **FRRouting** which acts as an alternative for quagga, nad turns out is had a docker image so I went with that instead.

Upon pulling the image letting it run by its own, I did notice that its spawning services, just not the ones we want yet.

```dockerfile!
FROM frrouting/frr:latest

# enable daemons
RUN \
	sed -i \
	-e 's/bgpd=no/bgpd=yes/g' \
	-e 's/ospfd=no/ospfd=yes/g' \
	-e 's/isisd=no/isisd=yes/g' \
	/etc/frr/daemons

```


After having the options added to config, the services can't launch and there are permission errors, 
```
privs_init: initial cap_set_proc failed: Operation not permitted
Wanted caps: = cap_net_admin,cap_net_raw,cap_sys_admin+p
Have   caps: = cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_admin,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap+ip
```

![](https://hackmd.io/_uploads/rk1yFHZlp.png)

I did some searching and the message above had to so something with container capabilities to the host (unsecure!) but I wanted to know if it fixes the issue so I launched the container with extended capabilities.
 `docker run --cap-add SYS_ADMIN --cap-add=NET_BIND_SERVICE --cap-add=NET_ADMIN --cap-add=NET_RAW --rm -it --name router_jng-1 router` Turns out its solved when I run from GNS3

Same thing as before, we will be creating a docker template to classify this resource.

![](https://hackmd.io/_uploads/H1BIMD-ep.png)

`route_switch_processor.svg` is made the symbol to match the subject.

A new project is created and I just need to add the two nodes and start them.
![](https://hackmd.io/_uploads/Bkvo7Pbg6.png)

![](https://hackmd.io/_uploads/S1LzmP-lT.png)
![](https://hackmd.io/_uploads/rJM9XvZga.png)

## Part 2 starting
Using the resources from part one, I started by creating a simple topology like so

![](https://hackmd.io/_uploads/rkwOxbvea.png)

The issues I have moving forward are : 
- My containers cant talk to each other
- I know how VXLAN works, but just dont know how to configure them

I looked for ways to configire VXLAN for a debian machine and stumbled upon this [book](https://www.actualtechmedia.com/wp-content/uploads/2017/12/CUMULUS-NETWORKS-Linux101.pdf) and this [article](https://joejulian.name/post/how-to-configure-linux-vxlans-with-multiple-unicast-endpoints/) and since I havent got to the hardware level of the networking concepts yet, I had to go back to the studying room to refine my understanding.

# Week 2
## Internetworking and Bridging
After reading about internetworking and bridging, I have made a more detailed sketech on how I want my part 2 to look like down to the hardware level :

![](https://hackmd.io/_uploads/BkYvPTvg6.png)

First thing I did with the GNS3 topology above was to assign IP addresses to the interfaces of the routers, and try to ping them using the `ip addr add` command. All commands that were used to set up and manage interfaces are a part of the **[ip_link](https://www.man7.org/linux/man-pages/man8/ip-link.8.html)** package.

Looks like I couldnt ping.. weird
![](https://hackmd.io/_uploads/ryra5avxa.png)

After restarting the containers, the pings work

![](https://hackmd.io/_uploads/BkOd2Twea.png)

![](https://hackmd.io/_uploads/SyuKhaPxT.png)


I then added new hardware interfaces by configuring the nodes in GNS3 

![](https://hackmd.io/_uploads/B1qGFyula.png)

I have no make the router talk to the hosts now, so I did the ip address assignement to the hosts **ethernet interface** which will talk to the hosts **eth1 interface from the same subnet**

![](https://hackmd.io/_uploads/SJ6gylulp.png)

![](https://hackmd.io/_uploads/Syfokx_l6.png)

Now instead of re-configuring everytime the containers restart, I converted the changes into declarative manner inside the [configuration file](https://manpages.debian.org/stretch/ifupdown/interfaces.5.en.html) `/etc/network/interfaces`.

Instead of running command `ip addr add 30.1.1.1/24 dev eth1`, I can let it be run automatically by converting it to
```
auto eth1
iface eth1 inet static
    address 30.1.1.1
    netmask 255.255.255.0
``` 
and putting it in the `/etc/network/interfaces` file.

HOWEVER, if i try to ping **host2(30.1.1.2) from host1(30.1.1.1)** nothing will happen since they are from different lan but yet they use the same subnet address. Right now the topology looks like this :
![](https://hackmd.io/_uploads/S1vgSlOe6.png)


This is where VXLAN comes in. We will first need to create the VTEP controller to make our host a VXLAN endpoint. We can do so by adding the following to the config file 

```
auto eth0
iface eth0 inet static
    address 10.1.1.1
    netmask 255.255.255.0
    # add below
    post-up ip link add vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.2
    post-down ip link del vxlan10
```
this makes the system run `link add vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.2` after eth0 is up and `ip link del vxlan10` which are both setting up and tearing down the vtep controller respectively.

> This needs to also be done on the other router

After that, we will need to make a bridge from the VTEP to the eth1 interface of the router so that the hosts can communicate via the VXLAN protocol, which involves creating a bridge interface, and simple adding the two interfaces (eth1 and vxlan10) to the bridge.

```
     post-up ip link add br0 type bridge
    post-up ip link set vxlan10 master br0
    post-up ip link set eth1 master br0
    post-up ip link set dev br0 up
```

## Fuckup 1
Remeber when I said putting everything in a declarative config is good? It is not.

Upon applying the config on boot, my VXLAN10 is getting **transaction (upload) packet drops** I couldnt find the exact reason the drops occur, but I got some clues by running the **EXACT SAME POST UP COMMANDS** and got it to work again.

The catch is when I ommited `ip link set dev vxlan10 up` and / or `p link set dev br0 up` the same packet loss occurs. 

Hence, my deduction was simply that putting everything in /etc/network/interfaces does not garentee full dependency control on the interfaces, or they are not thread safe (since i do see vxlan10 being in the UP state while testing.). That said, I replaced by config with bootstrap scripts and I will need to run them everytime the container starts

```
R1
ip link del vxlan10
ip link del br0
ip addr del 10.1.1.1/24 dev eth0
ip addr add 10.1.1.1/24 dev eth0
ip link add vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.2 dstport 0
ip link set dev vxlan10 up
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set dev br0 up

R2
ip link del vxlan10
ip link del br0
ip addr del 10.1.1.2/24 dev eth0
ip addr add 10.1.1.2/24 dev eth0
ip link add vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 dstport 0
ip link set dev vxlan10 up
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set dev br0 up

```

The `/etc/network/interfaces` file contains all the initial interface configuration. 

## Multicasting group
After the fixes above have been implemented, the hosts should be able to ping each other.

![](https://hackmd.io/_uploads/rJkp7Hug6.png)

![](https://hackmd.io/_uploads/S16p7BOxp.png)

Now if you refer to the manual of [vxlan](https://www.kernel.org/doc/Documentation/networking/vxlan.txt), to enable multicase group, we just need to replace the remote option with the group option while specifying a multicast address.

`ip link add vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 dstport 0
` -> `ip link add vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 0
`

And the ping should still work
![](https://hackmd.io/_uploads/SkWZSBOlT.png)

![](https://hackmd.io/_uploads/S1h-HrOxa.png)

We should also be able to see the discovered MAC addresses

![](https://hackmd.io/_uploads/SJ1OBH_gp.png)

![](https://hackmd.io/_uploads/HyrOrBOeT.png)

## Packet capturing
A bit late on this, I realized you can actually read the packets being sent to and from the nodes in GNS3 by doing the following:

Right click on a link and click start capture
![](https://hackmd.io/_uploads/HJQTgynxp.png)

Proceed as usual and eventually you will see a magnifying glass on the link:
![](https://hackmd.io/_uploads/SyAWz13la.png)


Play around with the topology, right click on the magnifying glass and click stop capture to save to the capture file.

You should be able to see your capture file in `/root/GNS3/projects/<projectid>/project-files/captures/`

You can read that file using tshark by doing `tshark -r <path-to-capturefile>`

You should see the following output

![](https://hackmd.io/_uploads/ryFyEyhxp.png)


## EVPN Topology creation 
I set up the topology in GNS3 according to the subject

![](https://hackmd.io/_uploads/Sktex2J-6.png)

![](https://hackmd.io/_uploads/rJT7OL0ga.png)


## Route reflector reading
The top node of the topology (router_jng-1) is also known as a **Route Reflector** (RR). Its job is to relay route information to the clients (router_jng-2 to 4) without the clients needing to have a direct connection to each other.

The more naive way to do so is to have a **full mesh of connection between each client** which may be unscalable.

## OSPF reading
In OSPF (Open Shortest Path First), an area is a logical and structured way of grouping contiguous routers. The main purpose of dividing a network into different **areas** is to optimize the path and reduce the routing tables on the routers. This significantly reduces the time required to run the OSPF algorithm.

Different areas have different responsibilities in carrying out the OSPF algorithm, the leaf nodes in your topology will all be in **Backbone Area (Area 0)**.

The backbone area is a special area in OSPF that serves as the central part of the OSPF network. It connects all other areas and is responsible for the distribution of routing information between different areas in the OSPF network

## Address configuration for hosts
Following the steps from the previous parts, The configuration for hosts will be identical, except for the actual addresses themselves.

```
auto eth1
iface eth1 inet static
    address 20.1.1.3
    netmask 255.255.255.0
```

## Spine and leaf architecture
In a leaf-spine architecture, every leaf switch (LAYER 2) connects to every spine (LAYER 3) switch, which increases redundancy and reduces potential bottlenecks. This design also minimizes latency and bottlenecks because each payload only has to travel to a spine switch and to another leaf switch to reach its endpoint.

Spine switches have high port density and form the core of the architecture. They can also help in scaling, as multiple switches can be used in a data center switching architecture. The leaf-spine architecture is also known for its performance, scalability, and lower latency compared to other architectures.

![](https://hackmd.io/_uploads/BJLTs2Jb6.png)


## Leaf configuration
For each leaf, the things we need to set up are quite simillar. We first need to set up the VXLAN interface, and bridge to the hosts. It can be done in the following:

```bash=
# Create VTEP with id 10 with the default port
ip link add vxlan10 type vxlan id 10 dev eth0 dstport 0
# ip link add vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 dstport 0
ip link set dev vxlan10 up

# Create a bridge between VTEP and eth1, so that hosts can communicate
# using this VTEP
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set dev br0 up
```

Note that unlike the previous part, there is **no multicast group or unicast destination**. The VTEPs routes will be discovered using BGP EVPN later.

Now the connection between the leaf and the end machines are configured, its time to configure the connection between the leaf and the spine.


We first need to address the interface to the spine, we can do it like so in the vtyshell

```
interface eth0
 ip address 10.1.1.2/30
 exit
```

Since we want to also enable OSPF with this interface, we will add it to OSPF area 0

```
interface eth0
 ip address 10.1.1.2/30
 ip ospf area 0
 exit
```

We will also configure the loopback interface, since our BGP will use that to send information, not the interfaces for reliability issues.

```
interface lo
 ip address 1.1.1.2/32
 ip ospf area 0
exit
```

We will now enable BGP on this node, declare the IPs of neighbours (their loopback addresses), specify the interface that we will receive updates on (loopback), enable evpn address family with the new BGP configuration and declare our neighbour to EVPN
```
router bgp 1
 neighbor 1.1.1.1 remote-as 1
 neighbor 1.1.1.1 update-source lo
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
 exit-address-family
exit
```
We will also enable OSPF
```
router ospf
```

The final configuration will look something like this

```
# Create VTEP with id 10 with the default port
ip link add vxlan10 type vxlan id 10 dev eth0 dstport 0
# ip link add vxlan10 type vxlan id 10 dev eth0 remote 10.1.1.1 dstport 0
ip link set dev vxlan10 up

# Create a bridge between VTEP and eth1, so that hosts can communicate
# using this VTEP
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set dev br0 up

vtysh << EOF
configure terminal

interface eth0
 ip address 10.1.1.2/30
 ip ospf area 0
exit
interface lo
 ip address 1.1.1.2/32
 ip ospf area 0
exit
router bgp 1
 neighbor 1.1.1.1 remote-as 1
 neighbor 1.1.1.1 update-source lo
 address-family l2vpn evpn
  neighbor 1.1.1.1 activate
  advertise-all-vni
 exit-address-family
exit
router ospf
exit
EOF
```

## Spine configuration
Since we have 3 leaves that connect to the spine, we will need to address the 3 spine interfaces the leaves connect to. 

```
interface eth0
 ip address 10.1.1.1/30
exit
! Set the IP addres on eth1 interface
interface eth1
 ip address 10.1.1.5/30
exit
! Set the IP addres on eth2 interface
interface eth2
 ip address 10.1.1.9/30
exit
```

Our spine will also participate in the BGP, so the loopback address is configured as well
```
interface lo
 ip address 1.1.1.1/32
exit
```

Now like our leaves, we need to declare our neighbours (the leaves). But since they all share similar IP, we can have a dynamic rule to declare any node that is in this IP range our neighbour

```
router bgp 1
 ! Create a BGP peer-group tagged DYNAMIC
 neighbor DYNAMIC peer-group
 ! Assign the peer group to AS number 1
 neighbor DYNAMIC remote-as 1
 neighbor DYNAMIC update-source lo
 bgp listen range 1.1.1.0/24 peer-group DYNAMIC
```

Now to activate EVPN address family and declare the spine as a route reflector 

```
address-family l2vpn evpn
  neighbor DYNAMIC activate
  neighbor DYNAMIC route-reflector-client
 exit-address-family
exit
```

Finally, we can enable OSPF and allow all connected members to use the utility

```
router ospf
 network 0.0.0.0/0 area 0
exit
```

The final config will look like 

```
vtysh << EOF
configure terminal
no ipv6 forwarding
interface eth0
 ip address 10.1.1.1/30
exit
interface eth1
 ip address 10.1.1.5/30
exit
interface eth2
 ip address 10.1.1.9/30
exit
interface lo
 ip address 1.1.1.1/32
exit
router bgp 1
 neighbor DYNAMIC peer-group
 neighbor DYNAMIC remote-as 1
 neighbor DYNAMIC update-source lo
 bgp listen range 1.1.1.0/24 peer-group DYNAMIC
 address-family l2vpn evpn
  neighbor DYNAMIC activate
  neighbor DYNAMIC route-reflector-client
 exit-address-family
exit
router ospf
 network 0.0.0.0/0 area 0
exit
EOF
```

## Demonstration
I am able to ping all hosts from the machines.

![](https://hackmd.io/_uploads/BkRK17g-p.png)

Current route table in one of the leaves, shows that it has connections to all other leaves
![](https://hackmd.io/_uploads/rkQylmxWa.png)


Shows only 1 neighbour configured, which is our spine and RR
![](https://hackmd.io/_uploads/SywfemeWT.png)

Shows Type 2 and 3 EVPN routes, which means that there are MAC addresses learned
![](https://hackmd.io/_uploads/S1kixXebT.png)


Here are the packets that I get while doing pinging, it has BGP and OSPF packets
![](https://hackmd.io/_uploads/HkqQ-Ql-a.png)

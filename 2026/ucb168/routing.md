---
author: lencelg from Arcadia Bay
title: Routing
---
# Routing
sending packet, two situtations :
* sending in the LAN: interior gateway protocols (IGPs)
* sending to the host in different LAN: exterior gateway protocols (EGPs)

IGPs example
* OSPF (Open Shortest Path First)
* IS-IS (Intermediate System to Intermediate System).

EGPs :
only one protocol implemented at scale on the Internet, namely **BGP (Border Gateway Protocol)**.

# Model for Intra-Domain Routing
## Full Mesh Network Topology
![](./img/full%20mesh%20network%20topology%20)

every machine connect to each other

performance view:
* not scalable
* a lof of bandwidth

## Single-Link Network Topology
![](./img/single-link%20network%20topology)

performance view:
* good at scale
* bad at bandwidth

## Network Topologies with Routers
![](./img/Network%20Topologies%20with%20Routers)

**End hosts** are machines connecting to the Internet to send and receive data. 

**Routers** are machines connected to the Internet responsible for receiving and forwarding intermediate packets closer to their final destination.

performance view:
* combine the benefits of the full-mesh and single-link topologies
* more robust to failure. If a link goes down, the packet can take a different path through the network and still reach its destination.

---

**Routing Protocols are Distributed**

each router must compute its own part of the answer (possibly without full knowledge of the network topology). Collectively, the answers computed by each router must form a global answer to the routing problem that allows packets to reach their end destination.

The distributed nature of routing protocols also means that we have to account for individual routers failing

# Routing Protocols
problem: given rules and packets, how should we forward the packets(which way to send the packets)

**routing state**:
a set of rules that each router uses to forward packets it receives

in reality, routers will often map destinations to physical ports

![](./img/map%20ports)

**Destination-Based Forwarding**:
A consequence of using a forwarding table is that given a packet, the decision of where to forward the packet depends only on the destination field of the packet.

---

**Routing State Validity is Global**:
we need to consider the global routing state to forward our packet

A global routing state is valid if and only if, for any destination, packets do not get stuck in **dead ends** or **loops**.

---
the arrows in a valid delivery tree must form an **oriented spanning tree**, rooted at the destination

**Least-Cost Routing**:
we can assign the cost between two routers(posistive cost) to run the dijkstra algorithm to computer the best way to forward our packets

# Distance-Vector Protocols
given empty forwarding table in all routers, our goal is to **fill in** the forwarding tables of every router

graph below for a better inituition

![](./img/distance-verctor%20protocols)

##  Distributed Bellman-Ford Algorithm
![](./img/bellman%20ford%20algorithm)

basic idea:

**eventful update**:
There are three occasions where a router might want to send advertisements:

1. Send advertisements when the table changes. These are called triggered updates. The table might change when we accept a new advertisement, or when a new link is added (e.g. new static route), or when a link goes down (e.g. route gets poisoned).
2. Send advertisements periodically, once every advertisement interval.
3. Send advertisements when a table entry expires (and gets replaced by poison

**Distance-vecotr Protolcol idea**

For each destination:
* If you hear about a path to that destination, update the table if:
    * The destination isn’t in the table.
    * The advertised cost, plus the link cost to the neighbor, is better than the best-known cost.
    * The advertisement is from the current next-hop.
* Advertise to all your neighbors when the table updates, and periodically (advertisement interval).
* If a table entry expires, delete it.
    * But don’t advertise back to the next-hop.
    * …Or, advertise poison back to the next-hop.
    * Any cost greater than or equal to the maxmium value(example: 16) is advertised as infinity.
* If a table entry expires, make the entry poison and advertise it.

## Link-State Protocols
just yet another major class of routing protocols

basic idea: Every router learns the full network graph, and then runs shortest-paths on the graph to populate the forwarding table.

## Comparison
In distance-vector, when we receive an announcement, we don’t necessarily know all the details about the path we’re accepting. slow to converge

Link-state protocols are good for small local networks, but don’t scale well to the global Internet. 

# Adressing
An **IP address** is a number that uniquely identifies a **host**

![](./img/hierarchical%20network)

hierarchical network makes the network much more **scalable**

**default route**:
If the router can’t find any matches, it will eventually match the \*. wildcard

problem: record that In the early Internet, IPv4 addresses had an 8-bit network ID and a 24-bit host ID, it does not meet the demand of large internet

we need to somehow get more ip address

## classful addressing
![](./img/classful%20addressing)

PS: Classful addressing is now obsolete(过时的) on the modern Internet.

## Classless Inter-Domain Routing
**CIDR** 

improved version of classful addressing

still have variable-length network IDs, but instead of only 3 different network ID lengths (Class A, B, C), we make the number of fixed bits arbitrary.

example below from official textbook
```
If we allocated a 28-bit network ID, the host ID would be 4 bits long (16 possible addresses).
If we allocated a 29-bit network ID, the host ID would be 3 bits long (8 possible addresses).
We can’t allocate exactly 10 addresses, but a 28-bit network ID would be sufficient for this company’s purposes.
There’s a little bit of waste (6 unused addresses), but this is still way better than allocating 256 addresses.
```
## Multi-Layered Hierarchical Assignment
hierarchies can be multi-layered. 

For example, inside a network, an organization can choose to assign specific ranges of addresses to specific sub-organizations (e.g. departments in a company or university).

![](./img/Multi-Layered%20Hierarchical%20Assignment)

## IPv6 Address Notation
128bits

IPv6 addresses are usually written in hexadecimal 

# Router Hardware
recall that A router runs some routing protocol to populate the forwarding table.

a router mainly contains three parts:
|part|desription|
|:---|:---|
|Data Plane| mainly responsible for forwarding packets
|Control Plane| mainly responsible for communicating with other routers and running routing protocols
|Management Planes|used to tell routers what to do, and see what they are doing. Systems and humans interact with the management plane to configure and monitor the router.

# Model for Inter-Domain Routing
**autonomous system (AS)**, which is one or more local network(s) all run by the same operator.

there are two types of AS
|name| descrption|
|:---|:---|
| **stub autonomous system**   |only exists to provide Internet connectivity to the hosts in its local networks. 
| **transit autonomous system**|forwards packets on behalf of other ASes.

AS Graphs are **Acyclic(无环的)**(only in provider-consumer relationship)

**policy-based routing**: 
each autonomous system has its own business goals and relationships with other ASes, so there are different routing protocols in the LAN of the same operator

# Border Gateway Protocol (BGP)
BGP is based on Distance-Vector(good for protecting privacy)

---

**Path-Vector Protocol**
a version modified from Distance-Vector Protocols

it consider the policy of ISP router with perference  and solve the problem of possible loops

ASes can determine whether an advertised path contains a loop by tracing through the path in the advertisement. Specifically, if I receive an advertisement, I just need to check if the path includes myself. That would cause the packet to be sent back to me, creating a loop, so I would ignore that advertisement and not accept or advertise the route with the loop.

---

**Border router**(BGP Speaker):
have at least one link to a router in a different AS 

**Interior router**:
only have links to other routers within the same AS

---

**BGP session** consists of two routers exchanging information between each other.

**external BGP (eBGP)**:
session is between two routers from different ASes

**internal BGP (iBGP)**:
session is between two routers in the same AS (not necessarily directly connected by a link).

eBGP and iBGP sessions are different from **interior gateway protocols (IGP)**


every router has two forwarding tables.
* One is a table mapping all internal destinations (same AS) to a next hop, populated with information **from IGP**.
* The other is a table mapping all external destinations to an egress router (who knows a route to the external destination), populated with information **from eBGP**.

example graph below for better understanding

![](./img/two%20router%20table)

---

some problem: what if one router get multiple message that can get to the same destination, which should the router select

**potato routing**:
selecting the nearest egress router. We want the packet to leave our AS as soon as possible, and start traveling over somebody else’s links as soon as possible.

**MDE**:
with additional information of cost, we can select the best one

# IP Header
header include needed infomation to transmit the packets

ipv4 header:

![](./img/ipv4%20header)

ipv6 header:

![](./img/ipv6)
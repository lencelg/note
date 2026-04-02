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

# Routing States
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
basic idea:
```
For each destination:
If you hear about a path to that destination, update the table if:
    The destination isn’t in the table.
    The advertised cost, plus the link cost to the neighbor, is better than the best-known cost.
Then, tell all your neighbors.
```

![](./img/bellman%20ford%20algorithm)

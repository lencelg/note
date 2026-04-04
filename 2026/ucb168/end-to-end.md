---
author: lencelg from Arcadia Bay
title: End-to-End
---
[TOC]

# Ethernet Introduction
recall that

![](./img/layers)

and the predominant(主要的) protocol at Layer 2 is **Ethernet**

a **bus** topology, where we connect all the computers along a single wire, is pretty common and practical in a local network.

![](./img/mutliple%20access%20protocols)

|part|description|
|:---|:---|
|frequency-division multiplexing|allocate a different slice of frequencies to each computer. (Consider AM/FM radio or broadcast TV, which divide up frequencies into channels.)|
|time-division multiplexing|divide time into fixed slots and allocate a slot to every connected node.|
|polling protocol|a centralized coordinator goes to each node one by one and asks if the node has something to say.|
|token passing|a virtual token that can be passed between nodes, and only the node with the token is allowed to speak, node pass between nodes|
|Random Access Approaches|allow nodes to talk whenever they have something to say, and deal with collisions when they occur|
|Carrier Sense Multiple Access (CSMA)|Nodes listen to the shared medium first to see if anybody is speaking, and only start talking when it is quiet|
|CSMA/CD (Carrier Sense Multiple Access with Collision Detection)|In addition to listening before speaking, we also listen while we speak. If you start hearing something while you’re transmitting, you stop immediately|
|ALOHANet|a combination of fixed allocation and random access|

---

LAN Communication on **MAC Addresses**

every computer has a **MAC address (Media Access Control)**. MAC addresses are 48 bits long, and are usually written in hexadecimal with colons separating every 2 hex digits (8 bits), e.g. `f8:ff:c2:2b:36:16`. MAC addresses are sometimes called `ether addresses` or `link addresses`.

MAC addresses are usually permanently **hard-coded**  on a device (例如计算机中的网卡)

---

**frame**

![](./img/frame)

To *broadcast a message*, we set the destination MAC to the special address FF:FF:FF:FF:FF:FF (all ones). 

---

need a routing protocols that are specifically designed for local Layer 2 networks:
if we had a Layer 2 network with multiple links, a switch only needs to pass the packet up to Layer 2 and forward the packet to the next switch over Ethernet.

## Flooding
naive approach to forwarding is to flood every packet you receive. When a switch receives a packet, it sends the packet out of every port.

two problem
* wastes bandwidth
* loops can overwhelm the network

##  Learning Switch
Learning switches solved the problem of wasting banwidth of flooding
交换机自学习能力


learning switches have two rules to follow:

* When you receive an incoming packet, update the forwarding table to associate the sender with the incoming port.

* If the destination is in your forwarding table, then forward the packet to the correct next-hop. Otherwise, flood the packet out of all ports except the incoming port.

## STP
Recall that flooding has two problems: It wastes bandwidth, and loops can overwhelm the network. Learning switches solved the first problem, but they do not solve the problem of loops.

**Spanning Tree Protocol**

---

**Port States**

STP classify every on one of three states
* Designated Port: These are ports pointing away from the root (i.e. they lead somewhere further from the root).
* Root Port: There are one or more ports pointing toward the root (i.e. they lead somewhere closer to the root). Of these ports, the one along the least-cost path to the root is the root port.
* Blocked Port: All ports pointing toward the root, that are not the root port (best way to reach the root), are blocked ports.

---

**Disabling Links**
every port has been assigned a state (designated port, root port, or blocked port)

To remove loops, each switch simply needs to pretend like its blocked ports don’t exist. In other words, do not send any user data out of that port, and do not receive any user data from that port.

graph below for better understanding

![](./img/disabling%20links)

---

**BPDU Exchanges**

problem: our protocol so far assumes global knowledge of the network, we need to somehow learn it

In order for switches to learn the information they need to label their ports, the switches exchange messages called **Bridge Protocol Data Units (BPDUs)**

running rules:
* When the protocol begins, every switch thinks that the root is itself, and the cost to the root (itself) is 0.
* The root in the BPDU has a lower ID. This means that you have discovered a better root. You should abandon your current root and cost, and instead adopt the new root and the path to the new root.
* The root in the BPDU is the same, but the BPDU is offering a better path to the root. You should adopt the new path to the root.
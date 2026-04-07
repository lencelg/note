---
author: lencelg from Arcadia Bay
title: introduction
---
[TOC]

# Introduction
internet feature:
* Federated: every one cooeprate with each other
* Scalable

**Protocols**: everyone speaks the same language(communicate in the same protocols)

# Layers of Internet

|layer|descrption|
|:---|:---|
|Physical Layer | looking for a way to signal bits (1s and 0s) across space.|
| Link Layer| define a way to send **packets** in LAN(Local Area Network)|
|Internet Layer|define a way to send data throw different LAN, use **router**|
|Transport Layer|define transport protocols|
|Application Layer|built app upon the abstraction of internet|

![](./img/internet%20layer)

## Internet Abstraction
with layer of **abstraction**, different people can work together but focusing on his/her area without worry anything else(kind like OOP)

---


**Best-Effort Service Mode**:
the Internet only supports **best effort delivery of data**

If you send data over Layer 3, the Internet will try its best to deliver it, but there is no guarantee that the data will be delivered. The Internet also won’t tell you whether or not the delivery succeeded.

---

**Packets Abstraction**:
divide large data into small **packets** to transport

# Headers
idea: when we send data, we need **additional information** for how to deliver

![](./img/header)

we use **headers** to tell the sender and receiver information and other information

as you can image, headers are standardized

## content of header
* destination address
* source address(not required)
* checksum(for checking packet integrity)
* metatdata(the length of the packe and so on)

## example
![](./img/sending%20example)

# Network Architecture
![](./img/network%20architecture)

---

**Port**:
use port to identify the which network service the packet belong to

![](./img/port)

---

**socket**:
refers to an OS mechanism for connecting an application to the networking stack in the OS. 

When an application opens a socket, that socket is associated with a logical port number. When the OS receives a packet, it uses the port number to direct that packet to the **associated socket**.

---

**End-to-End Principle**:
the end host identify the packet integrity instead of router

# Designing Resource Sharing
problem: how can we efficiently share the resources between different user in the same time

## Statistical Multiplexing
assign the resources based on demand

![](./img/statisitical%20multiplexing)

performance view:
based on analysis, efficient usage of resources, but can not deal with Peaks(流量峰值)

## Sharing Resources: Circuit Switching vs. Packet Switching
best-effort design **Packet Switching**:
The switch looks at each packet independently and forwards the packet closer to its destination. The switches don’t think about flows or reservations.

reservation design **Circuit Switching**:
At the start of a flow, users explicitly request and reserve the bandwidth they need. After the data is sent, the resources can be released for others to reserve. 

graph below for a better understanding of curcuit switching 

![](./img/circuit%20switching)

---

performance view:
Circuit switching gives the application better performance with reserved bandwidth. It also gives the developer more predictable behavior. but hard to implement

However, packet switching gives us more efficient sharing of bandwidth, and avoids startup time. It also gives us easier recovery from failure, and is generally simpler to implement (less for routers to think about).

# Links
Links has three property:
* **bandwidth**: descript how many bits we can send on the link per unit time
* **propagation delay**: descript how long it takes for a bit to travel along the link 
* **bandwidth-delay product (BDP)**: descript the capacity of the link

**packet delay** is the time it takes for an entire packet to be sent

---
image the following situtation

![](./img/overload%20links)

this is called **overloaded links**

so the router maintain a queue for packets

but when many packets continuous come the router, the queue will be filled out and loss packets
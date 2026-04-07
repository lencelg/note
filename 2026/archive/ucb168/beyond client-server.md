---
author: lencelg from Arcadia Bay
title: Beyond Client-Server
---
[TOC]

# Multicast
motivation: In a multi-player game or a video-conferencing app, there isn’t a single client or a single server.

here is definition:

![](./img/cast%20types)

we need to implement another protocol for this, two ways to do it
* implement multicast in Layer 3, called **IP multicast**. better performance, but harder to implement
* implement multicast in Layer 7, called **overlay multicast**. worse performance, but simpler to implement.

![](./img/mutlicast)

## IP multicast 
model
* You can send packets to a group (even if you are not a part of that group yourself).
* You can announce that you are joining a group.
* You can announce that you are leaving a group. 

### IGMP 
two basic idea

**Queries**: The router periodically sends Queries to the hosts. These messages ask: What group(s) do you belong to?
**Reports**: In response, hosts send Reports back to the router. Reports answer the question: These are the group(s) I belong to. Hosts can also send unsolicited Reports (i.e. without waiting for a Query).

### DVMRP
recall the idea of least-cost routing, we want a spanning tree, and we need to learn the tree

---

### PS
performance view:
IP multicast is mostly used today within a single domain, and not across different domains, bad security

note not in detail for ip multicast, only the baisc idea included

## Overlay Mutlitcast
problem: recall that in ip multicast, it’s difficult to implement multicast across different networks.

idea: build a *virtual network topology* that directly connects the hosts to each other

![](./img/virtual%20network%20topology)

The virtual links we’ve drawn form the **overlay network**

the **nodes** in the overlay network are the *end hosts*: This means that the end hosts need to understand the multicast routing protocol, build their own forwarding tables, and forward packets.

The end hosts could also be proxy servers installed by some company (similar to *CDN servers*)

# PS 
note for Collective Operations is not made(lack of interest)
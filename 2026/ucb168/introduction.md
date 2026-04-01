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

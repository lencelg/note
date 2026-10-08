---
author: lencelg form Arcadia Bay
title: datacenter
---
[TOC]

# Datecenter
In datacenters, transmission delay is usually relatively small, Propagation delay is also relatively small in datacenters, **queuing delay** is often the dominant source of delay

two class of connection
* Most connections are **mice**, which are short and latency-sensitive.
* some connections are **elephants**, which are large and throughput-sensitive.

we use the **pFabric: Packet Priorities** to prioritize the mice packet, and the last few bytes in an elephant connection will be higher-priority

then we get good performance

---

note is not finished for datacenter, lack of interest
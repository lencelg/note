---
author: lencelg from Arcadia Bay
title: Applications
---
[TOC]

# Reminder
recall that

![](./img/layers)

# DNS
## Name Server
**name servers** are servers dedicated to replying to DNS requests.

Each name server is responsible for a specific zone of domains, e.g `.com` , `.edu`

graph for better understanding

![](./img/DNS%20view)

## DNS Lookup
basic idea: we query from root down to the bottom if we have not cache in our computer(or expired), then we store the mapping in our local cache

detail: local computer usually delegates the task of DNS lookups to a **DNS Recursive Resolver**, which queries the name servers for you. When performing a lookup, the **DNS Stub Resolver** on your computer sends a query to the recursive resolver, lets the resolver do all the work, and receives the response back from the resolver.

![](./img/DNS%20resolover)

## DNS Message Format
DNS use **UDP**

![](./img/DMS%20message%20format)

```console
$ dig +norecurse eecs.berkeley.edu @192.5.6.30

;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 36257
;; flags: qr; QUERY: 1, ANSWER: 0, AUTHORITY: 3, ADDITIONAL: 5

;; QUESTION SECTION:
;eecs.berkeley.edu.           IN   A

;; AUTHORITY SECTION:
berkeley.edu.        172800   IN   NS   adns1.berkeley.edu.
berkeley.edu.        172800   IN   NS   adns2.berkeley.edu.
berkeley.edu.        172800   IN   NS   adns3.berkeley.edu.

;; ADDITIONAL SECTION:
adns1.berkeley.edu.  172800   IN   A    128.32.136.3
adns2.berkeley.edu.  172800   IN   A    128.32.136.14
adns3.berkeley.edu.  172800   IN   A    192.107.102.142
...
```

# HTTP
a protocol and file format that would allow linking pages to each other and fetching those pages.

## Basis
HTTP runs over **TCP**

HTTP is a **client-server** protocol

The client is almost always running HTTP in **a web browser** (e.g. Firefox or Chrome), though HTTP can also be run in other ways (e.g. directly on the terminal).

HTTP is a **request-response** protocol. For each request that the client sends, the server sends exactly one corresponding response.

## Content
HTTP response contains four parts:
|part| desciption|
|:---|:---|
|version|the version specifies the version of HTTP being used.|
|status code|a number that allows the server to indicate the result of the client’s request|
|optional message|additional information about the response, such as server details, content type, and caching instructions|
|content| content that you get|

**HTTP header**: additional metadata, e.g the Location header can be used in HTTP 300 responses to indicate where the resource has moved.

## Speed Up Strategy
Speeding Up HTTP with **Pipelining**

HTTP 1.1 optimized this by allowing *multiple* HTTP requests and responses to be pipelined over the **same connection**.

---

Speeding Up HTTP with **Caching**

three types of cache
|type|description|
|:---|:---|
|**private cache**|associated with a specific end client connecting to the server (e.g. the cache in your own browser), not shared between users|
|**Proxy caches**|controlled by the network operator, shraed between users|
|**Managed caches**|controlled by the application provider, this gives the application more control|

---
about implementation

basic idea: use headers to carry some metadata about caching (e.g. how long to cache the data). 

to Deploying managed caches across the network, use CDNs:
**content delivery networks (CDNs)** are sets of servers in the network serving content (e.g. HTTP resources).

## Variants
**HTTPS** is an extension to HTTP that introduces extra security, runs over TLS

A protocol called **TLS (Transport Layer Security)** is built on top of TCP, where users exchange secret keys and encrypt messages before sending them through the bytestream.
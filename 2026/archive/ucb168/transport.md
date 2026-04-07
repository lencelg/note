---
author: lencelg from Arcadia Bay
title: Transport
---
[TOC]

# Introduction
mainly tow protocols

![](./img/transport%20layer%20protocols)

**demultiplex**:
the transport layer header includes an **additional port number**, which can be used to identify a **specific application** on an end host.

**round-trip time (RTT)**:
The time it takes for a packet to travel from sender to receiver, plus the time for a reply packet to travel from receiver to sender

to send packet in parallel, we need to attach **a unique sequence number** to every packet to detect the result of each packet

## TCP Design
problem: Sending packets one at a time is too slow, but sending all packets at once overwhelms the network.

we use **Window-Based Algorithms** to send $W$ parallely at most at any given time 

some property
* **Filling the Pipe**: we want to use all the bandwidth all the time to achive maxmium efficiency
* **Flow Control**: ensures that the recipient’s buffer does not run out of memory using the **advertised window**
* **Congestion Control**: a link could used by mutliple hosts, we run some algorithm to assign the bandwidth
* **Smarter Acknowledgments**:
  * **full information ack**:  each time we send an acknowledgement, we can actually list every packet we have received.
  * **cumulative acks**: the ack encodes the highest sequence number for which all previous packets have been received.(没有中断的列表)
* **Detecting loss early**: full-information acks will show the missing packet clearly

image below for better understanding of flow control:

![](./img/flow%20control)

## TCP Segment
MSS (TCP segment limit) = MTU (IP packet limit) - IP header size - TCP header size

Each segment’s header will contain a **initial sequence number(ISN)** corresponding to the number of the first byte in that segment.

use cumulative ack model to confirm the packets

**three-way handshake**:
* SYN
* SYN-ACK
* ACK

we use **sliding window** to model the windos-based algorithm
## TCP Header

![](./img/tcp%20header)

# Congestion Control 
All modern congestion control algorithms are based on dynamic adjustment.

two broad class of solutions
* host-based
* router-assisted

a overall view of the considerations of congestion control algorithm
![](./img/congestion%20control%20protocols)

## host-based algorithm
basic idea: Each source independently runs the following logic repeatedly, in a loop: Try sending at a rate R for some period of time. Then, ask: Did I experience congestion in this time period? If yes, then reduce R. If no, then increase R.v

and problem comes:
* how we pick the initial rate?
* How do we detect congestion?
* how much should we increase and decrease each time?

we use a slow start and fast ramp-up called  strategy **slow start**

detailed slow start strategy **AIAD**: additive increase, additive decrease

AIAD is the best to achive best fair among all the class of slow start 

we can combine the sliding window with slow start idea

### Fast Recovery
problem: The isolated packet loss caused the window to get stuck, which causes the sender to stall and send nothing. Eventually, when that packet is re-sent and acked, the window leaps forward, causing the sender to scramble and send a bunch of new packets at once. The sender now has to wait another round-trip for those new packets to get acked, before it can resume business as usual.

solution basic idea: When a duplicate ack arrives, we can deduce that one fewer packet is in flight, though we don’t know which one. To account for this, we will artificially extend the window by 1 packet, to allow the sender to send one more packet.

### TCP state machine
The sender maintains 5 values:

The duplicate ack count helps us detect loss earlier than timeouts. It’s initialized to 0.

The timer is used to detect loss. There’s just a single timer.

RWND is used for flow control (don’t overwhelm recipient buffer).

CWND is used for congestion control. It’s initialized to 1 packet.

SSTHRESH helps the congestion control algorithm remember the latest safe rate. It’s initialized to infinity.

The sender responds to 3 events: Ack for new data (not previously acked), duplicate ack, and timeout.

---

The recipient maintains a buffer of out-of-order packets.

The recipient responds to receiving a packet, by replying with an ack and a RWND value.

# Router-Assisted algorithm
Router-Assisted Congestion Control

problem: TCP confuses congestion and corruption. TCP fills up queues, has choppy rates, and performs poorly on short flows, all because hosts need to constantly adjust their rates to detect congestion.

strategy: enforcing fair queuing

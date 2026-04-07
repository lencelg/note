# Data Link layer
![](./img/data%20link%20initution.png)

data unit: `frame`

![](./img/data%20link%20initution.png)

## Problem
### framing
add `header` and `tailer` to a data

![](./img/frame.png)

### Transparent Transmission
![](./img/frame%20transfer%20problme.png)

`solution: byte stuffing`

![](./img/byte%20stuffing.png)

## Error detection
* CRC
* FCS
## PPP(Point-to-Point Protocol)
![](./img/ppp%20overview.png)

![](./img/ppp%20frame.png)

* F(flag)
* A(preserved)
* C(preserved)
### byte stuffing and zero-bit stuffing
![](./img/zero%20bit%20stuffing.png)
## boradcast
owned by one unit with limited amout of stations and area

*   LLC(Logical Link Control)
*   MAC(Medium Access Control) 

![](./img/broadcast.png)

CSMA/CD Protocol
hardware address

Filter frame
* unicast
* broadcast
* multicast

`Sniffer` track the frame

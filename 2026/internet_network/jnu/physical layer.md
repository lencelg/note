# Physical Layer

features

![](./img/physical%20layer%20features)

## Model
* source
* transmitter
* receiver
* destination

![](./img/data%20transmission%20model)

---
Signal
* continue signal
* discrete signal

## Channel
three basic ways
```
（1）单向通信又称为单工通信，即只能有一个方向的通信而没有反方向的交互。无线电广播或有线电广播以及电视广播就属于这种类型。

（2）双向交替通信又称为半双工通信，即通信的双方都可以发送信息，但不能双方同时发送（当然也就不能同时接收）。这种通信方式是一方发送另一方接收，过一段时间后可以再反过来。

（3）双向同时通信又称为全双工通信，即通信的双方可以同时发送和接收信息。

单向通信只需要一条信道，而双向交替通信或双向同时通信则都需要两条信道（每个方向各一条）。显然，双向同时通信的传输效率最高。

```

Baseband Signal(基带信号)。

Data signals representing various text or image files output by a computer are all baseband signals. Baseband signals often contain a significant amount of `low-frequency components`, and even `DC components`, which many channels `cannot transmit`. To solve this problem, baseband signals must be perform modulation.

### Modulation
two ways

* coding
   - ![](./img/coding%20method)
* Bandpass Modulation
    * AM
    * PM
    * FM
    * QAM

### Capcaity
Nyquist
```
WHz bandwidth , 2W at most
```

Shannon formula

$C = Wlog_2(1 + S/N)\ (bits/s)$  

## Transmission Medium
![](./img/transmission%20mediumn)
### Guided
* Twisted pair
  * UTP(Unshielded Twisted Pair)
  * STP(Shielded Twisted Pair)
* Coaxial Cable
* Optical fiber
### Unguided
transfer in free space

Radio Waves
## Channel Mutliplexing
![](./img/channel%20multiplexing)
* FDM(Frequency Division Multiplexing)
* TDM(Time Division Multiplexing)
* STDM(static TDM)
![](./img/STDM)
* WDM(Wavelength Division Multiplexing) and DWDM(Dense Wavelength Division Multiplexing)
* CDM(Code Division Multiplexing)
## Broadband Access Technology
`connect to ISP`

ASDL

![](./img/ASDL)
HFC

![](./img/HFC)

FTTx
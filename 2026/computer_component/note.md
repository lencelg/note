# Introduction
电子计算分类
* 电子数字计算机
* 电子模拟计算机

![](./img/computer%20classification)

用途分类
* 通用计算机
* 装用计算机

## Moore's law
![](./img/moore's%20law)

## Architecture

### Hardware
![](./img/computer%20architecture)

* 运算器
* 储存器
* 控制器
* 适配器与输入/输出输出设备

### software
![](./img/computer%20software)

数据库管理系统 = 数据库 + 数据管理软件

## Performance
CPU执行时间 = CPU始终周期数 X CPU始终周期长

* CPI
* MIPS
* FLOPS

benchmark

## computer architecture
![](./img/computer%20organization)

# ALU
## interger
|type|description|
---|---
原码|![](./img/sign%20magnitude)
反码|none
补码|![](./img/two's%20complement)

补码的补充

![](./img/tow's%20complement%20second)

`三种类型的关系`

![](./img/interger%20relationship%20example)

```
一个正整数，当用原码、反码、补码表示时，符号位都固定为 0，用二进制表示的数位
值都相同，即三种表示方法完全一样。
 一个负整数，当用原码、反码、补码表示时，符号位都固定为 1，用二进制表示的数位
值都不相同。此时由原码表示变成补码表示的规则如下：
    (1)原码符号位为 1 不变，数值部分的每一位二进制数位求反得到反码；
    (2)反码符号位为 1 不变，反码数值部分最低位加 1，得到补码。
```

例子

![](./img/relationship%20example)

![](./img/more%20interger%20example)


## Floating point
`IEEE774`

![](./img/floating%20point%20representation)
![](./img/floating%20point%20example)
![](./img/floating%20point64)

IEEE744的补充说明
```
对 32 位浮点数 N，IEEE754 定义：
    (1)若 E = 255 且 M <> 0，则 N = NaN。符号 NaN 表示无定义数据，采用这个标志的
目的是让程序员能够推迟进行测试及判断的时间，以便在方便的时候进行。
    (2)若 E = 255 且 M = 0，则 N = (–1)S∞。当阶码 E 为全 1 且尾数 M 为全 0 时，表示的
真值 N 为无穷大，结合符号位 S 为 0 或 1，也有+∞和–∞之分。
    (3)若 E = 0 且 M = 0，则 N = (–1)S0。当阶码 E 为全 0 且尾数 M 也为全 0 时，表示的
真值 N 为零(称为机器 0)，结合符号位 S 为 0 或 1，有正零和负零之分。
    (4)若 0 < E < 255，则 N = (–1)S ×(1.M)×2E–127(规格化数)。除去用 E 为全 0 和全 1(即
十进制 255)表示零、无穷大和无定义数据的特殊情况外，规格化浮点数的指数的偏移值不
选 27=128(二进制 10000000)，而选 27–1= 127(二进制 01111111)。故规格化浮点数的阶码 E
的取值范围为 1～254，相应的指数值 e 则为–126～+127。因此 32 位浮点数表示的绝对值
的范围是 10–38～1038。
    (5)若 E = 0 且 M <> 0，则 N = (–1)S×(0.M)×2–126(非规格化数)。对于规格化无法表示
的数据，可以用非规格化形式表示。
```

整数装换到浮点数

![](./img/interger%20to%20floating%20example)

奇校验与偶校验

![](./img/crc)

补码加法

$$ [x+y]_补=[x]_补+[y]_补 (mod 2^{n+1}) $$

补码减法

$$[x–y]_补 = [x＋(–y)]_补 = [x]_补+[–y]_补 $$

$$[–y]_补 = ~[y]_补 + 1$$

overflow

![](./img/interger%20overflow)

### 整数乘法

#### 无符号数阵列乘法器

![](./img/interger%20multiplcation)
![](./img/interger%20multipulication%20road)

#### 有符号数阵列乘法器

![](./img/signed%20interger%20multipulication%20)

## 定点除法运算

![](./img/division)
![](./img/division%20example)

## 逻辑运算
* 逻辑与
* 逻辑非
* 逻辑或
* 逻辑异或

## ALU
![](./img/ALU)

## 总线
内部总线是指 CPU 内各部件的连线，而外部总线是指系统总线，即 CPU 与存储器、 I/O 系统之间的连线。

![](./img/ALU%20architecture)

# 存储系统
![](./img/cache)

储存器分类
* RAM
  * SRAM
  * DRAM
* ROM
* PROM
* EPROM
* Flash

大小端

！[](./img/endian)

## Performance
* 储存容量
* 存取时间
* 存储周期
* 储存器带宽

## SRAM
![](./img/SDRAM)
![](./img/SRAM%20detail)

## 存储器容量的扩充
* 位扩展
* 字扩展
* 字位扩展

## DRAM
![](./img/DRAM)

刷新操作
* 集中式刷新策略: 每一个刷新周期中集中一段时间对 DRAM 的所有行进行刷新
* 分散式刷新策略: 每一行的刷新操作被均匀地分配到刷新周期时间内

## 同步DRAM(SDRAM)
传统的 DRAM 是`异步`工作的, 在 DRAM 接口上增加时钟信号则可以降低存储器芯片与控制器同步的开销，优化 DRAM 与 CPU 之间的接口，这是`同步`DRAM(SDRAM)的最主要改进

![](./img/DRAM%20difference)

## DDR SDRAM
DDR SDRAM 的最大特点便是在时钟的上升沿和下降沿都能传输数据, 双倍数据率结构本质上是一个 2n 预取结构

![](./img/DDR%20SDRAM)

### DRAM 读/写校验
设置校验码

！[](./img/RAM%20validation)

## CDRAM
CDRAM(Cached DRAM)是一种附带高速缓冲存储器的动态存储器，它是在常规的 DRAM 芯片封装内又集成了一个小容量 SRAM 作为高速缓冲存储器，从而使 DRAM 芯片 的访问速度得到显著提升。

![](./img/CDRAM)

## 只读存储器
![](./img/M%20comparsion)
## NOR闪存
NOR 闪存更适用 于擦除和编程操作较少而直接执行代码的场合，尤其是纯代码存储应用。由于擦除和编程 速度相对较慢，且区块尺寸较大，NOR 闪存不太适合纯数据存储和文件存储等应用场景。

![](./img/NOR)

判定编程和写入的状态的方 法称为 `data# polling`

![](./img/data%20poliing)

## 并行存储器
CPU 和主存储器之间在速度上是不匹配的，这种情况成为限制高速计算机设计的主要 问题。为了提高 CPU 和主存之间的数据交换速率，可以在不同层次采用不同的技术加速存 储器访问速度

* 双端口储存器
* 无冲突读写控制
* 有冲突读写控制

### 多模块交叉存储器
* 顺序
* 交叉

## Cache
cache 是一种高速缓冲存储器，是为了解决 CPU 和主存之间速度不匹配而采用的一项 重要技术。其原理基于程序运行中具有的空间局部性和时间局部性特征。

![](./img/cache%20view)

![](./img/cache%20%20performance)

### 主存与 cache 的地址映射
* 全相联映射方式

![](./img/full%20associative)

* 直接映射方式

直接映射方式也是一种多对一的映射关系，但一个主存块只能拷贝到 cache 的一个特定 行位置上去。cache 的行号 i 和主存的块号 j 有如下函数关系： 

$$ i = j mod m $$

![](./img/direction%20map)

* 组相联映射方式

```
这种方式将 cache 分成 u 组，每组 v 行。主存块存放到哪个组是固定的，取决于主存块 在主存区中是第几块。至于存到该组哪一行是灵活的，即有如下函数关系：
                        m = u× v
                    组号 q = j mod u
```

![](./img/group%20map)

### cache 的替换策略
* 最不经常使用(LFU)算法
* 近期最少使用(LRU )算法
* 随机替换

### cache 的写操作策略
|type|description|
|---|---|
|写回法(write back, copy back)|当 CPU 写 cache 命中时，只修改 cache 的内容，而不立即写入主存|
|全写法(write through)|当写 cache 命中时， cache 与主存同时发生写修改，因而较好地维护了 cache 与主存的内容的一致性|
|写一次法(write once)|写一次法是基于写回法并结合全写法的写策略：写命中与写未命中的处理方法和写回 法基本相同，只是第一次写命中时要同时写入主存|

---
使用多级 cache 减少缺失损失

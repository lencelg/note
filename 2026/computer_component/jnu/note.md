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
#import "@preview/minimal-note:0.10.1": minimal-note

#show: minimal-note.with(
  title: [note of seven languages in seven weeks],
  author: [lencelg from Arcadia Bay],
  date: datetime.today().display("[month repr:long], [year]"),
  show-outline: true,
)

#show raw: set text(font: "Hack Nerd Font")
#pagebreak()

= Introduction

#text(size: 15pt, fill: red)[*编程说到底是个理解问题*]

#pagebreak()
= Ruby

== Basic
Ruby是一门纯面向对象语言, 也是强类型语言

下面是在irb的REPL环境里面的实例
````ruby
@irb(main):002> x = 0
=> 0
@irb(main):003> x
=> 0
@irb(main):004> x = x + 1 while x < 10
=> nil
@irb(main):005> x
=> 10
@irb(main):006> x == x
=> true
@irb(main):007> true.class
=> TrueClass
@irb(main):008> x.class
=> Integer
@irb(main):009> 4.class
=> Integer
@irb(main):010> language = 'ruby'
=> "ruby"
@irb(main):011> puts "hello, #{language}"
hello, ruby
=> nil
@irb(main):016> x
=> 10
@irb(main):017> x = x - 1 until x == 1
=> nil
@irb(main):018> x
=> 1
@irb(main):019> puts 'something here' if not true
=> nil
````

#pagebreak()

== hash table
符号是前面带有冒号的标识符，类似于#text(fill: blue)[`:symbol`]的形式。它在给事物和概念命名时非常好用

在hash table里面使用#text(fill: blue)[:symbol]作为#text(fill: blue)[key]的行为

````ruby
@irb(main):020> stuff = {:array => [1, 2, 3], :string => 'Hi, mom!'}
@irb(main):021> stuff
=> {array: [1, 2, 3], string: "Hi, mom!"}
@irb(main):022> stuff[:string]
=> "Hi, mom!"
@irb(main):023> stuff[:array]
=> [1, 2, 3]
@irb(main):024> stuff[:string].object_id
=> 145408
@irb(main):025> "Hi, mom!".object_id
=> 153656
````

== Mixin
面向对象语言利用继承，将行为传播到相似的对象上。但对象若想继承并不相似的多种行
为，一方面可通过允许从多个类继承（多继承）而实现，另一方面也可借助于其他解决方案。
过往经验表明，#text(fill: red)[多继承不仅复杂，且问题多多.]

#text(fill: blue)[Java采用接口解决这一问题，而Ruby采用的是模块]

下面就是一个moudle的例子
````ruby
module ToFile
  def filename
    "object_#{self.object_id}.txt"
  end

  def to_f
    File.open(filename, 'w') { |f| f.write(to_s) }
  end
end

class Person
  include ToFile
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def to_s
    name
  end
end
````

=== Comparable
#text(fill: red)[为避免方法实现之苦], <=>被人们叫做太空船操作符，它比较a、b两操作数，b较大返回-1，a较大返回1，相等返回0

````ruby
@irb(main):027> 'begin' <=> 'end'
=> -1
@irb(main):028> 'same' <=> 'same'
=> 0
````

正如类的思想一样，数组内部友内置的方法, 虽然和本小节的标题内容无关......

````ruby
@irb(main):029> a = [5, 3, 4 ,1]
=> [5, 3, 4, 1]
@irb(main):030> a.sort
=> [1, 3, 4, 5]
@irb(main):031> a.any?{|i| i > 6}
=> false
@irb(main):032> a.any?{|i| i > 4}
=> true
@irb(main):033> a.all?{|i| i > 4}
=> false
@irb(main):034> a.collect?{|i| i * 4}
(irb):34:in '<main>': undefined method 'collect?' for an instance of Array (NoMethodError)
Did you mean?  collect
               collect!
	from <internal:kernel>:168:in 'Kernel#loop'
	from /usr/lib/ruby/gems/3.4.0/gems/irb-1.15.0/exe/irb:9:in '<top (required)>'
	from /usr/bin/irb:25:in 'Kernel#load'
	from /usr/bin/irb:25:in '<main>'
@irb(main):035> a.collect{|i| i * 4}
=> [20, 12, 16, 4]
@irb(main):036> a.max
=> 5
````

== Metaprogramming
元编程是“写能写程序的程序”

首先是开放类, 开放类可以给已经存在的类添加方法，类如基类`Integer`, `NilClass`和`String`等

然后是method_missing, Ruby找不到某个方法时，会调用一个特殊的调试方法显示诊断信息。该特性不仅让Ruby更
易于调试，有时还能实现一些#text(fill: blue)[不易想到的有趣行为].

最后就是模块了， 不多介绍

== pros and cons
#table(
  columns: 2,
  [
pros
- Ruby是一门梦幻般的脚本语言
- Rails现已成为有史以来最成功的Web开发框架之一
- 市场投放时间

  ],
  [
cons 
- Ruby的最大弱点就是性能
- 该编程模型成立的一切前提条件，都建立在一种思想（围绕状态包装一系列行为）的基础之上, 有效地管理并发成为问题
  ] 
)

= Io

Io 是基于原型的语言

在原型语言中，每个对象都不是类的复制品，而是一个实实在在的对象。

== Basic

对象内部带有数据，称之为#text(fill: blue)[槽(slot)]

#text(fill: blue)[对象不过是槽的容器而已], 这就是Io对象模型的工作方式。

````io
> io
Io> "Hi ho, Io" print
Hi ho, Io==> Hi ho, Io
Io> Vehicle := Object clone
==> Vehicle_0x1003b61f8:
    type    = "Vehicle"
Io> Vehicle description := "Something to take you places"
==> Something to take you places
Io> Vehicle description = "Something to take you far away"
    => Something to take you far away
Io> Vehicle nonexistingSlot = "This won't work."

Exception: Slot nonexistingSlot not found.
    Must define slot using := operator before updating.
    message 'updateSlot' in 'Command Line' on line 1
Io> Vehicle description
==> Something to take you far away
Io> Vehicle slotNames
==> list("type", "description")
Io> Vehicle type
==> Vehicle
Io> Object type
==> Object
Io> Car := Vehicle clone
==> Car_0x100473938:
    type    = "Car"
Io> Car slotNames
==> list("type")
Io> Car type
==> Car
Io> Car description
==> Something to take you far away
Io> ferrari := Car clone
==> Car_0x1004f43d0:
Io> ferrari slotNames
==> list()
Io> ferrari type
==> Car
Io> Ferrari := Car clone
==> Ferrari_0x9d085c8:
type = "Ferrari"
Io> Ferrari type
==> Ferrari
Io> Ferrari slotNames
==> list("type")
Io> ferrari slotNames
==> list()
````

其他的不多做介绍了

= Prolog
Prolog是一门声明式编程语言, 跳过阅读

= Scala
Scala与Java紧密集成
- Scala运行在Java虚拟机上
- Scala可以直接使用Java类库, 和Java一样都是静态类型语言，遵循一样的编程哲学
- Scala的语法与Java比较接近, 既支持面向对象范型也支持函数式编程范型

== Basic

基础的部分和java差不多，下面仅介绍部分

````scala
def whileLoop { // java like, but no public keyword or private
    var i = 1
    while(i <= 3) {
        println(i)
        i += 1
    }
}
def forLoop {
    println("for loop using Java-style iteration")
    for(i <- 0 until args.length) { // initialValue until endingValue的形式
        println(args(i))
    }
}
````

== Concurrency

Scala最重要的方面之一就是其处理并发的方式。其主要结构包括#text(fill: blue)[actor和消息传递]

actor拥有#text(fill: blue)[线程池和队列池]。当发送一条消息给actor时（使用!操作符），是将一个对象放到该actor的队列中, actor读取消息并采取行动, 通常情况下， actor通过模式匹配器去检测消息并执行相应的消息处理。

下面是一个简单的小程序来使用了actor模型, 运行的结果表明是并发成功的，这里不做展示了。
````scala
import scala.actors._
import scala.actors.Actor._

case object Poke
case object Feed

class Kid() extends Actor {
    def act() {
        loop {
            react {
                case Poke => {
                    println("Ow...")
                    println("Quit it...")
                }
                case Feed => {
                    println("Gurgle...")
                    println("Burp...")
                }
            }
        }
    }
}

val bart = new Kid().start
val lisa = new Kid().start

printIn("Ready to poke and feed...")
bart ! Poke
lisa ! Poke
bart ! Feed
lisa ! Feed
````
actor是为并发而构建出来的对象, 它们通常拥有一个包含react或receive方法的循环，用于接收发给该对象的队列消息。


这里是一个异步发起web请求的方法，简单的api使用
````scala
def getPageSizeConcurrently() = {
    val caller = self

    for(url <- urls) {
        actor { caller ! (url, PageLoader.getPageSize(url)) }
    }

    for(i <- 1 to urls.size) {
        receive {
            case (url, size) =>
                println("Size for " + url + ": " + size)
        }
    }
}
````

= Erlang
Erlang是一门函数式语言, 为并发量身打造

有三个特点
- 无进程
- 轻量级线程
- 可靠性

== Basic
\% 表示是注释

变量以大写字母开头，且它们是不可变的

````erlang
Eshell V17.0.1 (press Ctrl+G to abort, type help(). for help)
1> var = 1.
** exception error: no match of right hand side value 1
2> Var = 2.
2
3> Var = 3.
** exception error: no match of right hand side value 3
````

Erlang可以做一些基本类型强制转换。

````erlang
5> [72, 97, 32, 72, 97, 32, 72, 97] .
"Ha Ha Ha"
````

函数式语言中，符号（symbol）是最基本的数据元素，可以表示任何事物

其他跳过阅读(兴趣一般)

= Haskell
函数是整个Haskell编程范型的核心。

````haskell
[i]○ → ghci 
GHCi, version 9.6.6: https://www.haskell.org/ghc/  :? for help
ghci> let fact x = if x == 0 then 1 else fact(x - 1) * x
ghci> fact 3
6
ghci> fact 50
30414093201713378043612608166064768844377641568960512000000000000
````

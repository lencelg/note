---
author: lencelg from Arcadia Bay
title: java note
---

PS: reason? just want to know more about java backend

[TOC]

# Basic
java basis is similar to other language, so only record part of it

## classpath
`classpath` 是 JVM 用到的一个环境变量，它用来指示JVM如何搜索 `class` .

`classpath`是一组目录的集合.

在windows上用`;`分隔， linux上用`:`分隔

`java -cp .;C:\work\project1\bin;C:\shared abc.xyz.Hello`的命令
- 先在`.`目录里面寻找
- 然后`C:\work\project1\bin`
- 最后就是`C:\shared`

由于可能有很多`.class`文件，逐个声明还是很麻烦的，于是把目录的结构变成单独的一个`jar`包

jar包实际上就是一个zip格式的压缩文件，而jar包相当于目录。

个人感觉应该就是src目录和bin目录的下面的目录结构打包成jar包就好了，但是一般使用管理构建工具，如`Maven`

## Module
一个大型Java程序会生成自己的jar文件，同时引用依赖的第三方jar文件.

problem: jar只是用于存放class的容器，它并不关心class之间的依赖。

method: 编写module来声明依赖关系

目录的结构如下：

```
oop-module
├── bin
├── build.sh
└── src
    ├── com
    │   └── itranswarp
    │       └── sample
    │           ├── Greeting.java
    │           └── Main.java
    └── module-info.java
```

`src` 目录下的`module-info.java`就是编写module的文件

```java

module hello.world {
    exports com.itranswarp.sample;

    requires java.base;
	requires java.xml;
}
```

但是一般使用管理构建工具自动帮助完成，感觉大概了解一下就好了

# Core class
## 字符串
- java的字符串不可变
- 两个字符串比较，必须总是使用`.equals()`的方法

## StringBuilder
可以高效拼接字符串

`.append()`, `.toString()`

## StringJoiner
类似用分隔符拼接数组的需求很常见，于是有`StringJoiner`来干这个事情

```java
import java.util.StringJoiner;
public class Main {
    public static void main(String[] args) {
        String[] names = {"Bob", "Alice", "Grace"};
        var sj = new StringJoiner(", ", "Hello ", "!");
        for (String name : names) {
        sj.add(name);
    }
        System.out.println(sj.toString());
    }
}
```

这里面的第一个参数是分隔符，第二个是开头的字符串，第三个是结尾的字符串

## String.join()
`String.join()`算是joiner的简化便捷版，但是不能指定开头和结尾

```java
String[] names = {"Bob", "Alice", "Grace"};
var s = String.join(", ", names);
```

## 包装类
Java核心库提供的包装类型可以把**基本类型**包装为`class`

自动装箱和自动拆箱都是在**编译期**完成的

装箱和拆箱会影响执行效率，且拆箱时可能发生 `NullPointerException` ；

包装类型的比较必须使用 `equals()` ；

整数和浮点数的包装类型都继承自 Number ；

包装类型提供了大量实用方法。

## enum
为了让编译器能自动检查某个值在枚举的集合内，并且，不同用途的枚举需要不同的类型来标记，不能混用，使用`enum`来定义枚举类;

## exceptions
在`catch`中抛出异常，不会影响`finally`的执行。JVM会先执行`finally`，然后抛出异常。

### logging
java 本身的logging库用的不多, api 如下
```java
Logger logger = Logger.getLogger(Main.class.getName());
logger.server("some info string");
logger.info("some info string");
logger.warning("some info string");
logger.config("some info string");
logger.fine("some info string");
logger.finer("some info string");
logger.finest("some info string");
```

Commons Logging是一个第三方日志库，它是由Apache创建的日志模块. 参数其实和java自身的差不多，但是有重载的`(String, Throwable)`的方法, 还有`getClass()`也是很方便的
```java
static final Log log = LogFactory.getLog(getClass());
log.info();
log.error();
log.warning();
log.debug();
log.trace();
log.fatal();
```

后面介绍的就是日志的实现框架，大概意思就是可以通过xml文件来定义日志的基础格式之类的，了解一下就可以了

# reflection
反射让代码可以“反观自身” —— 可以在不直接知道类名的情况下，操作该类。

暂时做一些简单的了解就算了

# generics
对于静态方法，我们可以单独改写为“泛型”方法，只需要使用另一个类型即可。 use `<K>` instead of `<T>`
```java
public class Pair<T> {
    private T first;
    private T last;
    public Pair(T first, T last) {
        this.first = first;
        this.last = last;
    }
    public T getFirst() { ... }
    public T getLast() { ... }

    // 静态泛型方法应该使用其他类型区分:
    public static <K> Pair<K> create(K first, K last) {
        return new Pair<K>(first, last);
    }
}
```

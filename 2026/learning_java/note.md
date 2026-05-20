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

虚拟机JVM对泛型其实一无所知，所有的工作都是编译器做的。

Java的泛型是采用**擦拭法(type erase)**实现的；

擦拭法决定了泛型<T>：
- 不能是基本类型，例如：`int`；
- 不能获取带泛型类型的Class，例如：`Pair<String>.class`；
- 不能判断带泛型类型的类型，例如：`x instanceof Pair<String>`；
- 不能实例化T类型，例如：`new T()`。
- 泛型方法要防止重复定义方法，例如：`public boolean equals(T obj)`；

使用类似 `<? extends Number>` 通配符作为方法参数时表示：

- 方法内部可以调用获取 `Number` 引用的方法，例如：  
  ```java
  Number n = obj.getFirst();
  ```

- 方法内部无法调用传入 `Number` 引用的方法（`null` 除外），例如：  
  ```java
  obj.setFirst(Number n);
  ```

即一句话总结：使用 `extends` 通配符表示可以读，不能写。

使用类似 `<T extends Number>` 定义泛型类时表示：

- 泛型类型限定为 `Number` 以及 `Number` 的子类。

使用类似 `<? super Integer>` 通配符作为方法参数时表示：

- 方法内部可以调用传入 `Integer` 引用的方法，例如：`obj.setFirst(Integer n);`
- 方法内部无法调用获取 `Integer` 引用的方法（`Object` 除外），例如：`Integer n = obj.getFirst();`

使用 `super` 通配符表示只能写不能读。

使用 `extends` 和 `super` 通配符要遵循PECS原则。

无限定通配符 `<? extends T>` 很少使用，可以用 `<T>` 替换，同时它是所有 `<T>` 类型的超类。

# Collections
`java.util`包主要提供了以下三种类型的集合：
- `List`
    - `ArrayList`
    - `LinkedList`
- `Map`
- `Set`

不应该继续使用的遗留类：
- `Hashtable`：一种线程安全的`Map`实现；
- `Vector`：一种线程安全的`List`实现；
- `Stack`：基于`Vector`实现的`LIFO`的栈。

不应该使用的遗留接口： `Enumeration<E>`：已被`Iterator<E>`取代。

## List
`List` 和 `Array` 可以装换， 使用`.toArray()` 就可以了

## equals()
`equals()` 必须满足以下条件：
- 自反性（Reflexive）：对于非 `null` 的`x` 来说，`x.equals(x)` 必须返回 `true`；
- 对称性（Symmetric）：对于非 `null` 的 `x` 和 `y` 来说，如果 `x.equals(y)` 为 `true`，则 `y.equals(x)` 也必须为 `true`；
- 传递性（Transitive）：对于非 `null` 的 `x`、`y` 和 `z` 来说，如果 `x.equals(y)` 为 `true`，`y.equals(z)` 也为 `true`，那么 `x.equals(z)` 也必须为 `true`；
- 一致性（Consistent）：对于非 `null` 的 `x` 和 `y` 来说，只要 `x` 和 `y` 状态不变，则 `x.equals(y)` 总是一致地返回 `true` 或者 `false`；
- 对 `null` 的比较：即 `x.equals(null)` 永远返回 `false`。

## Map
iterate a map

```java
import java.util.HashMap;
import java.util.Map;

public class Main {
    public static void main(String[] args) {
        Map<String, Integer> map = new HashMap<>();
        map.put("apple", 123);
        map.put("pear", 456);
        map.put("banana", 789);
        for (String key : map.keySet()) {
            Integer value = map.get(key);
            System.out.println(key + " = " + value);
        }
    }
}
```

or use

```java
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    String key = entry.getKey();
    Integer value = entry.getValue();
    System.out.println(key + " = " + value);
}
```

## Hashcode()
在计算`hashCode()`的时候，经常借助`Objects.hash()`来计算：

```java
int hashCode() {
    return Objects.hash(firstName, lastName, age);
}
```
要正确使用 HashMap，作为 key 的类必须正确覆写 `equals()` 和 `hashCode()` 方法；

一个类如果覆写了 `equals()`，就必须覆写 `hashCode()`，并且覆写规则是：
- 如果 `equals()` 返回 `true`，则 `hashCode()` 返回值必须相等；
- 如果 `equals()` 返回 `false`，则 `hashCode()` 返回值尽量不要相等。

## TreeMap
`SortedMap`是接口，它的实现类是`TreeMap`, 它在内部会对Key进行排序.

使用`Comparator`来构建比较的方法
```java
Map<Student, Integer> map = new TreeMap<>(new Comparator<Student>() {
            public int compare(Student p1, Student p2) {
                return p1.score > p2.score ? -1 : 1;
            }
        });
        map.put(new Student("Tom", 77), 1);
        map.put(new Student("Bob", 66), 2);
        map.put(new Student("Lily", 99), 3);
        for (Student key : map.keySet()) {
            System.out.println(key);
        }
        System.out.println(map.get(new Student("Bob", 66))); // 2
```

## Set
`Set`
- `HashSet`是无序的
- `TreeSet`是有序的

# Thread
java 的 thread 接口还是很简洁的, 和一些主流语言的概念都差不多
- `start()`
- `join()`
- `synchronized(resource)`
- `setDaemon()`

Java的`synchronized`锁是可重入锁；

死锁产生的条件是多线程各自持有不同的锁，并互相试图获取对方已持有的锁，导致无限等待；

避免死锁的方法是多线程获取锁的**顺序要一致**。

# Java8
## lambda
```
// 1. 不需要参数,返回值为 5  
() -> 5  
  
// 2. 接收一个参数(数字类型),返回其2倍的值  
x -> 2 * x  
  
// 3. 接受2个参数(数字),并返回他们的差值  
(x, y) -> x – y  
  
// 4. 接收2个int型整数,返回他们的和  
(int x, int y) -> x + y  
  
// 5. 接受一个 string 对象,并在控制台打印,不返回任何值(看起来像是返回void)  
(String s) -> System.out.print(s)
```

## Optional
Optional 类是一个可以为null的容器对象。如果值存在则isPresent()方法会返回true，调用get()方法会返回该对象。

---
author: lencelg from Arcadia Bay
title: database
PS: this note is made from Database System Concepts Seventh Edition
---
[TOC]

# Introduction
**数据库管理系统** (DataBase-Management System) 由一个互相关联的数据的集合和一组用以访问这些数据的程序组成 。 

大概要做到几点
* 安全性
* 并发性(多个用户同时访问)
* 高性能

数据库系统提供了 **数据库语言** 来操控数据库的数据

## personal summary
第一章讲了数据库的各个方面，没什么好做笔记

# relationship model introduction
这一章节从数学的角度来介绍数据库中的数据关系和运算关系, 可以参考cmu15-445中的笔记

# SQL
SQL(Structured Query Language, 结构化查询语言)

## sql basic type
SQL 数据类型

| 数据类型 | 说明 |
| --- | --- |
| `char(n)` | 固定长度的字符串，长度为 `n`|
| `varchar(n)` | 可变长度的字符串，最大长度为 `n`|
| `int` | 整数（依赖于机器的整数的有限子集）|
| `smallint` | 小整数（依赖于机器的整数类型的子集）。 |
| `numeric(p, d)` | 定点数，总位数 `p`（含符号位），小数位数 `d`。例如 `numeric(3,1)` 可精确存储 `44.5`，但不能存储 `444.5` 或 `0.32`。 |
| `real` | 浮点数，精度依赖于机器。 |
| `double precision` | 双精度浮点数，精度依赖于机器。 |
| `float(n)` | 精度至少为 `n` 位数字的浮点数。 |

## sql basic mode
- **PRIMARY KEY (A<sub>j1</sub>, A<sub>j2</sub>, …, A<sub>jm</sub>)**  
  声明这些属性构成关系的主码。主码属性必须**非空且唯一**

- **FOREIGN KEY (A<sub>k1</sub>, A<sub>k2</sub>, …, A<sub>km</sub>) REFERENCES s**  
  声明这些属性是外码，其取值必须对应关系 `s` 中某个元组在主码属性上的取值

- **NOT NULL**  
  限制某属性不能取空值

- **DEFAULT <表达式>**  
  为属性指定默认值

- **UNIQUE**  
  确保属性（或属性组）的取值在关系中**唯一**，不允许重复。与主键的区别在于：UNIQUE 允许一个空值（具体取决于数据库实现），而主键不允许任何空值。

---

- **CREATE TABLE** → 建空表  
- **INSERT/UPDATE/DELETE** → 改里面的数据  
- **DELETE FROM** → 清空数据，保留表  
- **DROP TABLE** → 表和数据一起消失  
- **ALTER TABLE … ADD** → 加新列（旧行新列变 NULL）  
- **ALTER TABLE … DROP** → 删列（很多数据库不支持）

---

### DISTINCT and ALL
SQL 查询中如何控制重复结果的关键词
- **`DISTINCT`** → 去重（集合风格）  
- **`ALL`**(默认) → 保留重复（多集风格）

### AS
as 关键词是起别名，看个例子就行了

```sql
select T.name, S.course_jd
from instructor as T, teaches as S
where T.ID= S.ID;
```

### string operation
sql的字符串匹配和re不太一样，有一些sql的实现但是和re差不多

模式匹配是大小写敏感的

关键字是`LIKE`, 下面是一些例子

| 模式符号 | 含义 | 示例 | 说明 |
| --- | --- | --- | --- |
| `%` | 匹配任意子串（包括空串） | `'Intro%'` | 匹配以 "Intro" 开头的任意字符串 |
| `%` | 匹配任意子串 | `'%Comp%'` | 匹配包含 "Comp" 子串的任意字符串（如 `'Intro. to Computer Science'`、`'Computational Biology'`） |
| `_` | 匹配任意**一个**字符 | `'___'` （三个下划线） | 匹配恰好三个字符的任意字符串（原文写为 `'_'`，但实际应为三个下划线，此处按标准SQL解释） |
| `_` | 匹配任意一个字符 | `'___%'` 或 `'___'` 的扩展 | 匹配至少三个字符的任意字符串（原文表述：“至少含有三个字符” 对应 `'___%'`，但原文简化为 `'_'`，可能存在笔误） |

### unknown
sql 将涉及null值的任何比较操作的结果视为 `unknown`

## aggreate function
**聚集函数** (aggregate function) 是以值集（集合或多重集合）为输入并返回单个值的函数 。 

- 平均值: avg
- 最小值: min
- 最大值: max
- 总和:  sum
- 计数:  count

### group by
我们希望将聚集函数作用在一组元组集上

```sql
select deptJ1ame, avg (salary) as avg_salary
from instructor
group by deptJ1ame;
```

![](./img/group%20by)

having 语句可以对group by的属性进行筛选

```sql
select dept...name, avg (salary) as avg...salary
from instructor
group by dept...name
having avg (salary) > 42000;
```

"至少比一个大"在 SQL 中用 `>some` 表示, 以此类推  `<some` 、 `<＝ some` 、`>＝ some` 、 `=some` 和 `<>some`

## exist
`exist` 可测试一个子查询的结果中是否存在元组

＂找出在 2017 年秋季学期和 2018 年春季学期都开课的所有课程”:
```sql
select course_jd
from section as S
where semester='Fall'and year= 2017 and
  exists (select *
    from section as T
    where semester='Spring'and year= 2018 and
      S.course_jd= T.course_jd);
```

## unique
`unique` 用于测试在一个子查询的结果中是否存在重复元组. 不做例子介绍

## modify data
* delete from
* insert into 
* update

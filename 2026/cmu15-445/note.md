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

# SQL Introduction
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

## personal summary
基础的sql章节主要介绍查询的一些关键字和用法

## unique
`unique` 用于测试在一个子查询的结果中是否存在重复元组. 不做例子介绍

## modify data
* delete from
* insert into 
* update set

# intermediate sql
## connection experssion
**natural join**, 自然连接只考虑在两个关系的模式中都出现的那些属性上取值相同的元组对。和笛卡尔积的cross join不一样

还可以有连接的条件， 使用 `join` 和 `on` 关键字, 下面是一个例子

```sql
select student.ID as ID, name. dept_name, tot_cred,
  course_id, sec_id, semester, year, grade
from student join takes on student.ID= takes.ID;
```

外连接(outer join)有三种连接方式

| 连接类型 | 保留的元组 | 说明 |
| --- | --- | --- |
| **左外连接** (LEFT OUTER JOIN) | 只保留**左边**关系中的所有元组 | 即使右边关系中没有匹配，左边关系的元组也会出现，右边属性填充 NULL |
| **右外连接** (RIGHT OUTER JOIN) | 只保留**右边**关系中的所有元组 | 即使左边关系中没有匹配，右边关系的元组也会出现，左边属性填充 NULL |
| **全外连接** (FULL OUTER JOIN) | 保留**两个关系**中的所有元组 | 无论哪一边没有匹配，缺失的一方属性填充 NULL |

默认情况下是内连接(inner join),

## create view
视图是一种保存了查询语句的虚拟表，像是定义了一个函数但是没有执行, 语法如下：

`create view v as ＜查询表达式＞；`

当构成视图定义的任何关系被更新时，可以马上进行视图维护, 来维持最新状态

## update view
一般不允许对视图关系进行修改 。

下面了解一下就可以了，只有满足以下所有条件的视图才是可更新的：

1. **`FROM` 子句中只有一个数据库关系**（即只能基于一张基表，不能多表连接）。
2. **`SELECT` 子句中只包含属性名**，不能包含表达式、聚集函数（如 `SUM`、`COUNT`）或 `DISTINCT` 关键字。
3. **未出现在 `SELECT` 中的属性必须允许为 `NULL`**：即这些属性没有 `NOT NULL` 约束，也不属于主码的一部分（这样才能在插入时自动补 `NULL`）。
4. **查询中没有 `GROUP BY` 或 `HAVING` 子句**。

简而言之：**简单到只投影一张表的部分列，且其他列可为空的视图，才是可更新的**。否则视图只读。

## constarints
* not null;
* unique;
* check(＜谓词＞);
* create assertion \<assertion-name\> check \<predicate\>;

## permission
SQL 标准包括选择 (select) 、插入 (insert) 、更新 (update) 和删除 (delete) 四种权限 。 

`grant` 语句用于授权

下面的授权语句给数据库用户 Amit 和 Satoshi 授予了 department 关系上的选择权限：
```sql 
grant select on department to Amit, Satoshi;
```

下面的授权语句授予用户 Amit 和 Satoshi 在 department 关系的 budget 属性上的更新权限：
```sql
grant update (budget) on department to Amit, Satoshi;
```

`revoke` 用于收回权限

```sql
revoke select on department from Amit, Satoshi;
revoke update (budget) on department from Amit. Satoshi:
```

## role
我们可以创建角色， 正如前面的 Amit 和 Satoshi, 我们可以将角色授权给另外一个角色，这样会提高效率

```sql
-- create a role
create role instructor,

-- grant a role
grant select on takes to instructor,

-- create another role
create role dean;

-- grant a role to another role
grant instructor to dean;

-- same thing
grant dean to Satoshi;
```

后面是视图授权， 模式授权， 权限转移， 权限回收，行级授权的内容, 大概了解一下语法，没做笔记

## personal summary
中级sql涉及了更多的关键字和语法，大概过了一遍语法，只做了部分笔记

# advanced sql
这一章节我没有怎么看书，笔记参考cmu15-445,

5 ~ 10章节不做笔记

# data analysis

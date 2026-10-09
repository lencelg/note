# System Design Introduction
[A good chinese guide](https://github.com/donnemartin/system-design-primer/blob/master/README-zh-Hans.md) on this topic

System design is the process of defining the architecture, components, modules, and data flow of a system to satisfy a set of requirements

the system design process
- Step 1: Constraints and use cases  
- Step 2: Abstract design  
- Step 3: Understanding bottlenecks  
- Step 4: Scaling your abstract design

basic concepts
- Horizontal and Vertical Scaling
- Redundancy and Replication
- Microservices Architecture
- CAP Theorem
- Proxy Servers
- Message Queues
- File Systems

System Design Architecture and Patterns
- Two-Phase Commit (2PC)
- Replicated Load-Balanced Services (RLBS)
- Command and Query Responsibility Segregation (CQRS)
- Saga
- Sharded Services

Tools and Techniques of System Design
- Data Flow Diagrams (DFD)
- Architecture Diagrams
- Data Dictionaries
- Decision Trees
- Decision Tables
- Pseudocode
- Unified Modelling Language (UML)
- API and Contracts

How to approach System Design?
1. **澄清需求与约束**:功能需求 + 非功能需求 (QPS、延迟、数据量、一致性要求、预算)
2. **规模估算**:QPS、存储、带宽 (back-of-the-envelope)
3. **高层设计**:画架构图 —— 客户端 / CDN / LB / API 网关 / 服务 / 缓存 / 数据库 / 消息队列
4. **深入关键组件**:数据库选型与分片、缓存策略、一致性模型、索引
5. **找瓶颈并扩展**:识别单点与热 key,做水平扩展 / 复制 / 分片
6. **明确取舍**:说清每个选择放弃了什么 (CAP、延迟 vs 吞吐、成本)

## CAP Theorem & Core Trade-offs

### CAP Theorem

CAP 只在分区发生期间成立。

CAP Theorem: 分布式系统中 **一致性 (Consistency)**、**可用性 (Availability)**、**分区容错性 (Partition Tolerance)** 三者最多同时满足两个。

网络分区必然发生,故 P 必选,实际取舍在 C 与 A 之间。


### CP (Consistency + Partition Tolerance)
分区时优先保证一致性:宁可拒绝或阻塞请求,也不返回过期数据。
- 适用:支付、转账、分布式锁、配置中心
- 代表:ZooKeeper、etcd、HBase

### AP (Availability + Partition Tolerance)
分区时优先保证可用性:每个节点照常响应,可能返回旧数据,分区恢复后再同步解决冲突。
- 适用:社交信息流、商品列表、购物车
- 代表:Cassandra、DynamoDB、Eureka

### Performance vs Scalability
- **Performance (性能)**:单个请求处理多快
- **Scalability (可扩展性)**:增加资源时性能能否随之提升
- 二者独立:可性能好但不可扩展(单机 MySQL);也可可扩展但性能差(多跳微服务调用链)

### Latency vs Throughput
- **Latency (延迟)**:完成单次request所需时间 (ms) 
- **Throughput (吞吐量)**:单位时间处理的request数 (QPS/RPS) 
- 常需权衡:批处理提升吞吐但拉高单次延迟;

goal: **在可接受延迟下最大化吞吐**

### Availability vs Consistency
- **一致性**:所有节点读到同一份最新数据
- **可用性**:每个请求都能获得非错误响应

强一致需等副本同步,牺牲可用性;

高可用则允许读到短暂过期数据 —— 即 CAP 中 C 与 A 的拉扯

## Consistency Patterns

有同一份数据的多份副本，我们面临着怎样同步它们的选择，以便让客户端有一致的显示数据。回想CAP 理论中的一致性定义 - 每次访问都能获得最新数据但可能会收到错误响应

### 弱一致性

在写入之后，访问可能看到，也可能看不到（写入数据）。尽力优化之让其能访问最新数据。

这种方式可以 memcached 等系统中看到。弱一致性在 VoIP，视频聊天和实时多人游戏中等真实实例中表现不错。打个比方，如果你在通话中丢失信号几秒钟时间，当重新连接时你是听不到这几秒钟所说的话的。

### 最终一致性

在写入后，访问最终能看到写入数据（通常在数毫秒内）。数据被异步复制。

DNS 和 email 等系统使用的是此种方式。最终一致性在高可用性系统中效果不错。

### 强一致性

在写入后，访问立即可见。数据被同步复制。

文件系统和关系型数据库（RDBMS）中使用的是此种方式。强一致性在需要记录的系统中运作良好。

## Availability Patterns
### Fail-Over（故障转移）

**定义**：当系统中的一个节点（服务器/数据库）发生故障时，自动将流量或工作负载切换到备用节点，以保证服务不中断。图片中给出了两种常见的节点部署模式：

#### 1. Active-Passive（主备模式 / 活动-待机）
*   **工作方式**：只有主节点（Active）对外提供服务，备用节点（Passive）处于待命状态，实时同步主节点的数据。
*   **故障切换（Fail-Over）**：当主节点宕机，负载均衡器或心跳检测机制会检测到故障，并将备用节点提升为新的主节点，接管所有流量。
*   **优点**：数据一致性强（可以同步复制），架构简单。
*   **缺点**：资源浪费（备用节点平时不干活）；切换过程中可能出现短暂的服务中断。
*   **场景**：传统关系型数据库主库、核心支付系统。

#### 2. Active-Active（双活模式 / 活动-活动）
*   **工作方式**：两个或多个节点同时对外提供服务（通常通过 **Load Balancing** 负载均衡分发流量）。它们互为备份。
*   **故障切换（Fail-Over）**：当一个节点宕机，负载均衡器自动将原本发给它的流量分发给其他存活节点。
*   **优点**：资源利用率高（没有闲置机器）；吞吐量高；切换速度快。
*   **缺点**：架构复杂，最难的是**数据同步**（容易产生冲突），通常需要配合最终一致性或复杂的分布式共识算法。
*   **场景**：Web 服务器集群、微服务架构。

### 二、 Replication

**定义**：为了保证数据不丢失和高可用，通常需要把数据复制到多个节点上。图片列出了两种主要的数据库复制架构：

#### 1. Master-Slave（主从复制）
*   **工作方式**：一个主节点（Master）负责处理写操作（Write），多个从节点（Slave）从主节点同步数据，只负责处理读操作（Read）。
*   **故障处理**：如果主节点宕机，需要手动或自动（如使用 Sentinel、Proxy）将一个从节点提升（Promote）为新的主节点。这本质上是结合了 Active-Passive 的 Fail-Over 机制。
*   **优点**：**读扩展性极好**（可以把大量读请求分摊给从节点）；数据备份方便。
*   **缺点**：写操作仍是单点瓶颈；从节点有复制延迟（容易读到旧数据，即最终一致性）。
*   **场景**：读多写少的业务，如新闻网站、内容管理系统。

#### 2. Master-Master（双主 / 主主复制）
*   **工作方式**：两个或多个节点都可以处理写操作，互为主从，相互同步数据。
*   **故障处理**：任何一台宕机，另一台可以继续提供读写服务，实现真正的 Active-Active。
*   **优点**：写操作也可以水平扩展；可用性极高。
*   **缺点**：**写冲突（Write Conflict）是噩梦**。如果两个节点同时修改同一条数据，必须制定复杂的冲突解决策略（如时间戳、版本号，甚至人工介入）。一致性极难保证。
*   **场景**：多数据中心部署，跨地域高可用系统。

在实际系统设计中，它们通常是交叉使用的：
*   前端 Web 层通常用 **Active-Active + Load Balancing**（无状态，容易扩展）。
*   后端数据库层通常用 **Master-Slave + Fail-Over**（保证数据一致性，读扩展）。

#### 3. No-leader Architecture

客户端可以并行地向多个节点发送写入请求，并从多个节点读取数据。

无主节点复制可以提供高可用性和容错能力以及高读写吞吐量。

**缺点**：很难确保所有节点始终拥有相同的数据视图, 处理并发写入可能引发的冲突也十分复杂，需要精心设计以确保数据一致性。

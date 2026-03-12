# Operating System
## Introduction
history
* Simple Batch Porcessing System
* Mulitprogrammed Batch Porcessing System
* Time Sharing System
* Real Time System
---
basic feature
* Concurrence
* Sharing
* Virtual
* Asynchronism
## Process
use Precedence Graph(DAG) to record the sequence relation of process or command<br>

remember that a process is a instance of programme<br>

a process has to be one of the three basic status
* Ready
* Running
* Block
* Suspend(added status)

![](./img/process%21status)
---
system has several datastructure to control resources
![](./img/resouce%20table)
---
PCB(Process Control Block)
mainly contains four infomation
* id(PID and internal id)
* context
* Process Scheduling Information
* Process Control Information
---
Oragnization of PCB
* Sequential(for small system)
* linking
* indexing
---
kernal status<br>
user status<br>
---
Creation of process
* get empty PCB, get unique ID for new process
* allocate resouce
* initlize PCB
* enqueue if possible
---
Termination of process
* normal exit
* exception
* interurrption
---
Resource constraints
undirectly constraints(CPU, I/O device and so on)<br>
directly constarints(Critial Resouce)

--- 
The proceducer-consumer problem
* use singal
* pipeline(container of all opertaion, one at a time)
---
Process Communication
* Shared-Memory System(small amout of resource)
* pipe communication system
* Message passing system
* Client-Server system
---
Theards(Light-Weight Process, part of a tarditional process)
* less cost in context switch and system cost
* better resource usage
* owned resouce(system resouce exclude)
* independency(corporation between different threads in one process)
* Concurrency<br>
---
`KST`(Kernal Supported Threads): better resouce usage generally<br>
`ULT`(User Level Threads): can use customized distribution algorithm, run in user level.
## Processor Scheduling
to achieve higher cpu resouce usage
|Scheduling|operation object|frequency|
---|---|---
High Level Scheduling|Job|lowest(general sereval minutes)
Low Level Scheduling|process|most frequency
intermediate Level Scheduling|Suspended process|in between
---
### Job
`Job`: a scheduled or automated unit of work executed by an operating system or application to manage, maintain, and process tasks—such as data processing, backups, or report generation—independent of direct user interaction.

`Job step`: a distinct, actionable stage or task within a larger process, representing a specific unit of work that must be completed to achieve a final goal.

Job Control Block(JCB)

Job status
* ready(in the queue, but not run yet)
* running
* finish

Scheduling algorithm|full name|view|
---|---|---
|FCFS|first-come first-served| poor resource usage
|SJF|short job first|better resource usage, but must know the time a job needed
PSA|priority-scheduling algorithm|solved high priority job first
HRRN|Highest Response Ratio Next|combine advantage of SJF and FCFS

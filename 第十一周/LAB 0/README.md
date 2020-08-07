### 基础性知识

#### ucore的通用数据结构

双向链表结构定义

```c
struct list_entry{
    struct list_entry *prev,*next;
};
```

形成一个闭环的循环双向链表，如下图

![image-20200803174618226](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200803174618226.png)

如何确定宿主数据结构（page头指针）

![image-20200803182716843](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200803182716843.png)

![image-20200803182559654](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200803182559654.png)

**注意此处的一点**

这行宏定义的含义是查找member在type结构体中的偏移

首先将0地址强制"转换"为type数据结构（比如struct Page）的指针，再访问到type数据结构中的member成员（比如page_link）的地址，即是type数据结构中member成员相对于数据结构变量的偏移量。

```c
#define offsetof(type,member) ((size_t)(&((type *)0)->member))
```

**插入（__list_add_after）**

```c
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
    elm->next = next;
    elm->prev = prev;
}
```

![image-20200803200817240](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200803200817240.png)

插入后

![image-20200803200741472](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200803200741472.png)

#### Intel 80386运行模式

实模式：这是个人计算机早期的8086处理器采用的一种简单运行模式，当时微软的MS-DOS操作系统主要就是运行在8086的实模式下。80386加电启动后处于实模式运行状态，在这种状态下软件可访问的物理内存空间不能超过1MB，且无法发挥Intel 80386以上级别的32位CPU的4GB内存管理能力。实模式将整个物理内存看成分段的区域，程序代码和数据位于不同区域，操作系统和用户程序并没有区别对待，而且每一个指针都是指向实际的物理地址。这样用户程序的一个指针如果指向了操作系统区域或其他用户程序区域，并修改了内容，那么其后果就很可能是灾难性的。

保护模式：保护模式的一个主要目标是确保应用程序无法对操作系统进行破坏。实际上，80386就是通过在实模式下初始化控制寄存器（如GDTR，LDTR，IDTR与TR等管理寄存器）以及页表，然后再通过设置CR0寄存器使其中的保护模式使能位置位，从而进入到80386的保护模式。当80386工作在保护模式下的时候，其所有的32根地址线都可供寻址，物理寻址空间高达4GB。在保护模式下，支持内存分页机制，提供了对虚拟内存的良好支持。保护模式下80386支持多任务，还支持优先级机制，不同的程序可以运行在不同的特权级上。特权级一共分0～3四个级别，操作系统运行在最高的特权级0上，应用程序则运行在比较低的级别上；配合良好的检查机制后，既可以在任务间实现数据的安全共享也可以很好地隔离各个任务。
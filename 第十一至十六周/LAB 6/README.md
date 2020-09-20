## 练习0

此处推荐选择2020版本，我的2015版本的proc.h中proc_struct结构体少了一部分lab6的结构定义注释，233333333

主要改动的地方有：

### proc_struct函数

```c
struct run_queue *rq;                       // running queue contains Process
    list_entry_t run_link;                      // the entry linked in run queue
    int time_slice;                             // time slice for occupying the CPU
    skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
    uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process 
    uint32_t lab6_priority;						// 优先级，视频里的权重
```

### alloc_proc函数

```c
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
	proc->state = PROC_UNINIT; // 设置进程为“初始”态
        proc->pid = -1;            // 设置进程pid未初始化的值
        proc->runs = 0;            // 初始化运行时间
        proc->kstack = 0;          // 初始化内核栈地址
        proc->need_resched = 0;    // 初始化，不需要调度
        proc->parent = NULL;       // 父进程为空
        proc->mm = NULL;           // 虚拟内存为空
        memset(&(proc->context),0, sizeof(struct context)); // 初始化上下文
        proc->tf = NULL;           // 中断帧指针为空
        proc->cr3 = boot_cr3;       // 使用内核页目录表的基址
        proc->flags = 0;            // flag为0
        memset(proc->name,0,PROC_NAME_LEN); // 进程名为0
        proc->wait_state = 0; //初始化进程等待状态
        proc->cptr = proc->optr = proc->yptr = NULL; //设置指针
        proc->rq = NULL; // 初始化运行队列
        list_init(&(proc->run_link));
        proc->time_slice = 0; // 初始化时间片
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
        proc->lab6_stride = 0; // 设置步长为0
        proc->lab6_priority = 0; // 设置优先级为0
    }
    return proc;
}
```

### trap_dispatch函数

```c
ticks ++;
        assert(current != NULL);c
        sched_class_proc_tick(current);
```

## 练习一

完成练习0后，建议大家比较一下（可用kdiff3等文件比较软件）个人完成的lab5和练习0完成后的刚修改的lab6之间的区别，分析了解lab6采用RR调度算法后的执行过程。执行make grade，大部分测试用例应该通过。但执行priority.c应该过不去。

请在实验报告中完成：

- 请理解并分析sched_class中各个函数指针的用法，并结合Round Robin 调度算法描ucore的调度执行过程
- 请在实验报告中简要说明如何设计实现”多级反馈队列调度算法“，给出概要设计，鼓励给出详细设计

——————————————————————————————————————————————————

**lab6**在schedule文件中新增了三个文件来支持调度算法

在default_sched.c文件中：

### RR_init函数

实现了进程队列的初始化

```c
static void
RR_init(struct run_queue *rq) {
    list_init(&(rq->run_list));
    rq->proc_num = 0; // RUNNABLE进程数目初始化为0
}
```

其中的run_queue结构体：

```c
struct run_queue {
  //其运行队列的链表
    list_entry_t run_list;
  //内部进程总数
    unsigned int proc_num;
  //每个进程一轮占用的最多时间片
    int max_time_slice;
    // For LAB6 ONLY
  //优先队列形式的进程容器
    skew_heap_entry_t *lab6_run_pool;
};
```

skew_heap_entry结构体：

```c
struct skew_heap_entry {
   //树形结构的进程容器
     struct skew_heap_entry *parent, *left, *right;
};
typedef struct skew_heap_entry skew_heap_entry_t;
```

### RR_enqueue函数

将就绪进程以尾插法入队

```c
static void
RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    assert(list_empty(&(proc->run_link))); // 进程控制块指针非空
    list_add_before(&(rq->run_list), &(proc->run_link)); //尾插法
    //进程控制块的时间片为0或者进程的时间片大于分配给进程的最大时间片
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }
    proc->rq = rq; // 加入进程池
    rq->proc_num ++; // 就绪进程+1
}
```

### RR_dequeue函数

将从等待运行状态变化为运行状态的进程从就绪队列从移除

```c
static void
RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
    list_del_init(&(proc->run_link));
    rq->proc_num --;//就绪进程数减一
}
```

### RR_pick_next函数

当前运行进程时间片结束后选择下一个进程的算法

```c
static struct proc_struct *
RR_pick_next(struct run_queue *rq) {
    // 选取就绪进程队列中的首元素
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
        return le2proc(le, run_link); // 返回进程控制块指针
    }
    return NULL;
}
```

### RR_proc_tick函数

设置时间片

```c
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) {
        proc->time_slice --; // 执行进程的时间片-1
    }
    if (proc->time_slice == 0) {
        proc->need_resched = 1; // 该进程需要调度
    }
}
```

即每一次时间片到时的时候，当前执行进程的时间片`time_slice`便减一。如果`time_slice`降到零，则设置此进程成员变量`need_resched`标识为1，这样在下一次中断来后执行trap函数时，会由于当前进程程成员变量`need_resched`标识为1而执行schedule函数，从而把当前执行进程放回就绪队列末尾，而从就绪队列头取出在就绪队列上等待时间最久的那个就绪进程执行。

### sched_class

提供调度算法的接口

```c
struct sched_class default_sched_class = {
    .name = "RR_scheduler",
    .init = RR_init,
    .enqueue = RR_enqueue,
    .dequeue = RR_dequeue,
    .pick_next = RR_pick_next,
    .proc_tick = RR_proc_tick,
};

```

### 问题：

### 请理解并分析sched_class中各个函数指针的用法，并结合Round Robin 调度算法描ucore的调度执行过程

```c
struct sched_class {
 // 调度器的名字
  const char *name;
 // 初始化运行队列
  void (*init) (struct run_queue *rq);
 // 将进程 p 入队
  void (*enqueue) (struct run_queue *rq, struct proc_struct *p);
 // 将进程 p 出队
  void (*dequeue) (struct run_queue *rq, struct proc_struct *p);
 // 返回 运行队列 中下一个可执行的进程
  struct proc_struct* (*pick_next) (struct run_queue *rq);
 // timetick 处理函数
  void (*proc_tick)(struct run_queue* rq, struct proc_struct* p);
};
```

调度执行过程：

+ ucore内核初始化总入口kern_init调用sched_init来初始化调度器sched_class，接下来调用proc_init来初始化进程。
+ proc_init首先为当前正在运行的ucore程序分配一个进程控制块，并将其命名为idle，因此第一个内核线程idleproc应运而生。
+ idleproc调用kernel_thread来创建一个新的内核线程initproc，kernel_thread进一步调用do_fork来完成具体的进程初始化操作，完成后调用wakeup_proc来唤醒新进程，并将内核线程initproc放在RUNNABLE队列rq的末尾。这时rq队列有了第一个进程在等待调度。
+ proc_init结束后，继续一路运行到cpu_idle，在cpu_idle中，不断判断当前进程是否需要调度，如果需要则调用schedule进行调度。由于当前进程是idleproc，其need_resched设置为1，因此进入schedule进行调度。
+ schedule首先判断当前进程是否RUNNABLE，以及是不是idleproc，如果当前进程不是idleproc而且RUNNABLE，则将其加入到rq队列的末尾。由于当前进程是idleproc，因此不会将其加入rq队列。
+ 接下来从RUNNABLE队列中取出队首的进程（此时是initproc），通过调用proc_run来运行initproc进程。这时rq队列已空。
+ initproc进程运行init_main，init_main调用kernel_thread来创建第三个进程userproc。同理，在完成userproc的初始化后，会调用wakeup_proc将其唤醒，并将其加入到rq队列的末尾。这时rq队列有一个进程userproc在等待调度。
+ initproc进程接下来调用do_wait来等待子进程结束运行，其中搜索到其子进程userproc的state不为ZOMBIE，因此调用schedule来试图调度子进程来运行。由于rq队列只有一个进程initproc在排队，因此会调用idleproc来运行。这时rq队列又空了。另外注意，由于initproc进程在调用schedule之前将自己的state设置为SLEEPING，因此在进入schedule后，不会再次将其加入到rq队列，也就是说initproc需要睡眠了。什么时候睡醒呢？等子进程userproc运行结束后再将其唤醒。
+ userproc进程运行user_main，加载ELF文件并运行之。运行完毕，则调用do_exit，在do_exit中，将自己的state设置为Zombie，然后调用wakeup_proc来唤醒initproc，这时会将initproc加入到rq队列，因此rq队列又有一个进程在等待了。接着调用schedule，选择刚加入的initproc来运行，rq队列再次变空。
+ initproc回收子进程userproc的资源后，打印一些字符串信息，然后退出init_main，接下来进入do_exit，do_exit调用panic，panic停留在kmonitor界面一直等待用户输入。

### 设计实现“多级反馈队列调度算法”：

¿ ，不会.jpg

## 练习2: 实现 Stride Scheduling 调度算法

Stride Scheduling调度算法，按照视频中的讲解

![image-20200819224105603](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200819224105603.png)

可以近似的理解为赛跑，每个进程有步数和步长，哪个进程的步数最低，就将哪个进程从就绪队列取出，变为运行进程，走步长距离，同时该进程的步数加上步长，这样一次筛选结束

后续就是上述过程的循环往复。

### 宏定义

```c
#define BIG_STRIDE    0x7FFFFFFF /* ??? */
```



### stride_init函数

```c
static void
stride_init(struct run_queue *rq) {
    list_init(&(rq->run_list)); // 初始化调度器类
    rq->lab6_run_pool = NULL; // 初始化当前进程运行队列为空
    rq->proc_num = 0; // 设置运行队列为空
}
```

### stride_enqueue函数

```c
static void
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    rq->lab6_run_pool =skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
    assert(list_empty(&(proc->run_link)));
    list_add_before(&(rq->run_list),&(proc->run_link));
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }
    proc->rq = rq;
    rq->proc_num ++; //进程数加一
}
```

其中，**skew_heap_insert** 函数：

```c
static inline skew_heap_entry_t *
skew_heap_insert(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_init(b); //初始化进程b
     return skew_heap_merge(a, b, comp);//返回a与b进程结合的结果
}
```

**skew_heap_init**函数

```c
static inline void
skew_heap_init(skew_heap_entry_t *a)
{
     a->left = a->right = a->parent = NULL; //初始化相关指针
}
```

**skew_heap_merge**函数

初始化刚进入运行队列的进程proc的stride属性，然后与队首元素比较当前步数大小，选择步数最小的运行，将其放入运行队列。最后初始化时间片，将运行队列进程数目加一

```c
static inline skew_heap_entry_t *
skew_heap_merge(skew_heap_entry_t *a, skew_heap_entry_t *b,
                compare_f comp)
{
     if (a == NULL) return b; 
     else if (b == NULL) return a;

     skew_heap_entry_t *l, *r;
     if (comp(a, b) == -1) //a进程的步长小于b进程
     {
          r = a->left; //a的左指针为r
          l = skew_heap_merge(a->right, b, comp);// 说实话，递归搞这个，没看懂

          a->left = l;
          a->right = r;
          if (l) l->parent = a;

          return a;
     }
     else
     {
          r = b->left;
          l = skew_heap_merge(a, b->right, comp);

          b->left = l;
          b->right = r;
          if (l) l->parent = b;

          return b;
     }
}
```

### stride_dequeue函数

```c
static void
stride_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    rq->lab6_run_pool =
            skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
    rq->proc_num --;

}
```

**skew_heap_remove**函数

```c
static inline skew_heap_entry_t *
skew_heap_remove(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_entry_t *p   = b->parent;
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
     if (rep) rep->parent = p;

     if (p)
     {
          if (p->left == b)
               p->left = rep;
          else p->right = rep;
          return a;
     }
     else return rep;
}
```

### stride_pick_next函数

先找到运行队列里步数最小的进程，如果优先级为0，步长就最大，否则将其进程的步长设置为优先级的倒数

```c
static struct proc_struct *
stride_pick_next(struct run_queue *rq) {
#if USE_SKEW_HEAP
    if (rq->lab6_run_pool == NULL) return NULL;
    struct proc_strcut *p = le2proc(rq->lab6_run_pool,lab6_run_pool);
#else
    list_entry_t *le = list_next(&(rq->run_list));

    struct proc_struct *p = le2proc(le,run_link);
    le = list_next(le);
    // 在运行队列里寻找步数最小的进程
    while (le != &rq->run_list)
        {
            struct proc_struct *q = le2proc(le,run_link);
            if ((int32_t) (p->lab6_stride - q->lab6_stride) > 0)
                p = q;
            le = list_next(le);
        }
#endif
    if (p->lab6_priority == 0) // 优先级为0
        p->lab6_stride += BIG_STRIDE; // 步长设置为最大值
    // 步长设置为优先级的倒数
    else p->lab6_stride += BIG_STRIDE / p->lab6_priority;
    return p;
}
```

### stride_proc_tick函数

```c
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0){
        proc->time_slice --;
    }
    if (proc->time_slice == 0){
        proc->need_resched = 1;
    }
}
```

## 扩展练习 Challenge 1 ：实现 Linux 的 CFS 调度算法

原本想按照CFS算法设计的，在ucore中查找调度周期变量，但是发现ucore中的一系列设计全是基于时间片的，Stride Scheduling 调度算法就是当你落后，你就运行一个时间片的时间。

```c
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
        proc->time_slice = rq->max_time_slice;
    }

rq->max_time_slice = MAX_TIME_SLICE;
#define MAX_TIME_SLICE 5
```

不过，这里似乎可以借用时间片？毕竟总共为5，跑一次减一次。那这里的运行周期就假设为5？好像又不行。总共跑五个时间片的时间，但是拿时间片当运行周期又不是很恰当的样子。

没办法，如果真要实现CFS调度算法的话，似乎要对ucore进行大改，修改基于时间片的调度，实现运行周期，来贴合CFS调度算法。

最终只是实现终极阉割版，基于时间片的，简化了virutime中的运行周期 * 1024 / 进程权重，转而变成 1024 / 进程权重

修改的代码如下

```c
static struct proc_struct *
stride_pick_next(struct run_queue *rq) {
#if USE_SKEW_HEAP
    if (rq->lab6_run_pool == NULL) return NULL;
    struct proc_struct *p = le2proc(rq->lab6_run_pool,lab6_run_pool);
#else
    list_entry_t *le = list_next(&(rq->run_list));

    struct proc_struct *p = le2proc(le,run_link);
    le = list_next(le);
    // 在运行队列里寻找步数最小的进程
    while (le != &rq->run_list)
        {
            struct proc_struct *q = le2proc(le,run_link);
            if ((int32_t) (p->lab6_stride - q->lab6_stride) > 0)
                p = q;
            le = list_next(le);
        }
#endif
    
    // 修改从此处开始
    if (p->lab6_priority == 0) // 优先级为0
        p->lab6_stride += NICE_0_LOAD; // virtual runtime设置为最大值
    else
    {
        p->lab6_stride += NICE_0_LOAD / p->lab6_priority;
    }
```


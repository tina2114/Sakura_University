## 练习一：分配并初始化一个进程控制块

该练习主要做的就是进程控制块的初始化工作

### 相关数据结构定义

```c
// 进程状态
enum proc_state {              //进程状态
    PROC_UNINIT = 0,           //未初始状态 
    PROC_SLEEPING,             //睡眠（阻塞）状态 
    PROC_RUNNABLE,             //运行与就绪态 
    PROC_ZOMBIE,               //僵死状态
};

struct context {                //进程上下文
    uint32_t eip;               
    uint32_t esp;
    uint32_t ebx;
    uint32_t ecx;
    uint32_t edx;
    uint32_t esi;
    uint32_t edi;
    uint32_t ebp;
};

// 存储新建立的内核线程的管理信息
struct proc_struct {
    enum proc_state state;                      // 进程所处的状态
    int pid;                                    // 进程 ID
    int runs;                                   // 运行时间
    uintptr_t kstack;                           // 内核栈位置
    volatile bool need_resched;                 // 是否需要调度
    struct proc_struct *parent;                 // 用户进程的父进程（创建它的进程）
    struct mm_struct *mm;                       // 内存管理的信息，包括内存映射列表、页表指针等
    struct context context;                     // 进程的上下文，用于进程切换
    struct trapframe *tf;                       // 中断帧的指针，总是指向内核栈的某个位置
    uintptr_t cr3;                              // 保存页表的物理地址(PDT)
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // Process name
    list_entry_t list_link;                     // Process link list 
    list_entry_t hash_link;                     // Process hash list
};
```

### 相关代码

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
       proc-cr3 = boot_cr3;       // 使用内核页目录表的基址
       proc->flag = 0;            // flag为0
       memset(proc->name,0,PROC_NAME_LEN); // 进程名为0

    }
    return proc;
}
```

### 问题一：struct context context和struct trapframe *tf 成员 变量的含义和作用

+  tf：中断帧的指针，总是指向内核栈的某个位置：当进程从用户空间跳到内核空间时，中断帧记录了进程在被中断前的状态。当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。除此之外，uCore内核允许嵌套中断。因此为了保证嵌套中断发生时tf 总是能够指向当前的trapframe，uCore 在内核栈上维护了 tf 的链，可以参考trap.c::trap函数做进一步的了解。
+ context：进程的上下文，用于进程切换（参见switch.S）。在 uCore中，所有的进程在内核中也是相对独立的（例如独立的内核堆栈以及上下文等等）。使用 context 保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。实际利用context进行上下文切换的函数是在*kern/process/switch.S*中定义switch_to。

## 练习2：为新创建的内核线程分配资源

需要完善kern/process/proc.c中的do_fork函数，该函数主要实现功能是：创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。

do_fork函数主要做了以下几件事情：

1. 分配并初始化进程控制块（alloc_proc函数）；
2. 分配并初始化内核栈（setup_stack函数）；
3. 根据clone_flag标志复制或共享进程内存管理结构（copy_mm函数）（但是此处的clone_flag函数好像没有真正实现该功能）；
4. 设置进程在内核（将来也包括用户态）正常运行和调度所需的中断帧和执行上下文（copy_thread函数）；
5. 把设置好的进程控制块放入hash_list和proc_list两个全局进程链表中；
6. 自此，进程已经准备好执行了，把进程状态设置为“就绪”态；
7. 设置返回码为子进程的id号。

### 相关函数定义

```c
static int //内核栈复制函数
setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE); //申请 8K的内存用于进程堆栈
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

static int  //该函数在本次实验并没有实现
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    assert(current->mm == NULL); //判断当前函数的虚拟内存非空
    return 0;
}

static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    //在内核堆栈的顶部设置中断帧大小的一块栈空间
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    *(proc->tf) = *tf; //拷贝在kernel_thread函数建立的临时中断帧的初始值
    proc->tf->tf_regs.reg_eax = 0;
    //设置子进程/线程执行完do_fork后的返回值
    proc->tf->tf_esp = esp; //设置中断帧中的栈指针esp
    proc->tf->tf_eflags |= FL_IF; //使能中断，即此内核线程在执行过程中，能响应中断，打断当前的执行
    proc->context.eip = (uintptr_t)forkret;
    proc->context.esp = (uintptr_t)(proc->tf);
}

#define local_intr_save(x)      \
                  do { x = __intr_save(); } while (0)

static inline bool
__intr_save(void) {
    if (read_eflags() & FL_IF){ //如果允许屏蔽中断，即IF=1.则中断
        intr_disable(); //禁止中断
        return 1;
    }
    return 0;
}

void
intr_disable(void) { //禁止中断函数
    cli(); //禁止中断
}

#define local_intr_restore(x)   __intr_restore(x);

static inline void
__intr_restore(bool flag) { //如果中断被屏蔽，则恢复中断
    if (flag) {
        intr_enable();  //恢复中断
    }
}
```

### 相关代码

```c
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //调用alloc_proc，首先获得一块用户信息块。
    if((proc = alloc_proc()) == NULL){
        goto fork_out; //返回
    }
    proc->parent = current; // 设置父进程名字
    // 为进程分配一个内核栈。
    if (setup_kstack(proc) !=0){ //申请一块2*PGSZIE内存用于进程堆栈
        goto bad_fork_cleanup_proc; // 返回
    }
    // 复制父进程的内存管理信息到子进程（但内核线程不必做此事）
    if (copy_mm(clone_flags,proc) != 0){
        goto bad_fork_cleanup_kstack; // 返回
    }
    // 复制中断帧和原进程上下文到新进程
    copy_thread(proc,stack,tf);
    bool intr_flag;
    local_intr_save(intr_flag); // 禁止中断，intr_flag置为1
    // 将新进程添加到进程列表
    {
        proc->pid = get_pid();
        hash_proc(proc);
        list_add(&proc_list,&(proc->list_link));
        nr_process ++;
    }
    local_intr_restore(intr_flag); // 恢复中断
    // 唤醒新进程
    wakeup_proc(proc);
    
fork_out:
    return ret;
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

### 问题：ucore是否做到给每个新fork的线程一个唯一的id？

站在本实验的角度来看，并没有提供释放现场的函数，pid只分配不回收。当fork的线程总数小于MAX_PID的时候，pid是唯一的，但是last_pid > MAX_PID的话，pid就会变为1，这样就会出现重复的pid。

## 练习三：理解 proc_run 函数和它调用的函数如何完成进程切换的

### 对proc_run函数的分析如下：

+ 判断要切换到的进程是不是当前进程，是就不做任何操作，直接返回
+ 调用local_intr_save和local_intr_restore函数来使得进程切换时能够屏蔽中断
+ 将代表当前进程的current赋值为proc
+ 将esp变为proc的内核栈顶
+ 将cr3寄存器变为proc->cr3的值，使页目录表更新为新进程的页目录表
+ 上下文切换，把当前进程（current）的当前各寄存器的值保存在其proc_struct结构体的context变量中，再把要切换到的进程的proc_struct结构体的context变量加载到各寄存器。
+ local_intr_restore函数来恢复中断

### 对其调用proc_run函数的schedule函数的分析：

+ 调度开始时，先屏蔽中断。
+ 在进程链表中，查找第一个可以被调度的程序
+ 运行新进程，允许中断
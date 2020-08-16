## 练习0：填写已有实验

本实验依赖实验1/2/3/4。请把你做的实验1/2/3/4的代码填入本实验中代码中有“LAB1”/“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验1/2/3/4的代码进行进一步改进。

### 改进的trap函数

```c
void
idt_init(void) {
     /* LAB5 YOUR CODE */ 
    extern uintptr_t __vectors[];
    for(int i = 0; i < 256 ; i++){
        if(i == 128){
            SETGATE(idt[i],1,8,__vectors[i],3); // int 80，syscall
            // 第一个参数为对应的中断处理，第二个参数0代表中断门，1代表陷阱门
            // 第三个参数是中断处理例程对应处理程序的代码段，第四个是对应的偏移量，第五个是特权级
        }
        else if(i == 121){
            SETGATE(idt[i],0,8,__vectors[i],3); // 从用户态切换到内核态
        }
        else{
            SETGATE(idt[i],0,8,__vectors[i],0);
        }        
        //first     idt[i] for store descriptors
        //second    istrap: 1 for a trap (= exception) gate, 0 for an interrupt gate
        //third     sel: Code segment selector for interrupt/trap handler kenal's sel=1<<3=8
        //fourth    off: Offset in code segment for interrupt/trap handler
        //fifth     dpl: Descriptor Privilege Level - the privilege level required
        //          for software to invoke this interrupt/trap gate explicitly
        //          using an int instruction.
    }
    // 将中断门描述符表的起始地址装入IDTR寄存器中
    lidt(&idt_pd);
}
```



### 改进的alloc_proc函数

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
    }
    return proc;
}

相应的指针解释
//process relations
//parent:           proc->parent  (proc is children)
//children:         proc->cptr    (proc is parent)
//older sibling:    proc->optr    (proc is younger sibling)
//younger sibling:  proc->yptr    (proc is older sibling)
```

### 改进的do_fork函数

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
    assert(current->wait_state == 0); // 确保进程在等待
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
        set_links(proc); //设置进程链接
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

### 改进trap_dispatch函数

```c
ticks ++;
        if (ticks % TICK_NUM == 0) {
            assert(current != NULL);
            current->need_resched = 1;
        }
        break;
```

## 练习一：加载应用程序并执行

**do_execv**函数调用load_icode（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好proc_struct结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。

请在实验报告中简要说明你的设计实现过程。

请在实验报告中描述当创建一个用户态进程并加载了应用程序后，CPU是如何让这个应用程序最终在用户态执行起来的。即这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

### 相关数据结构

```c
struct trapframe {
    struct pushregs tf_regs;
    uint16_t tf_gs;
    uint16_t tf_padding0;
    uint16_t tf_fs;
    uint16_t tf_padding1;
    uint16_t tf_es;
    uint16_t tf_padding2;
    uint16_t tf_ds;
    uint16_t tf_padding3;
    uint32_t tf_trapno;
    /* below here defined by x86 hardware */
    uint32_t tf_err;
    uintptr_t tf_eip;
    uint16_t tf_cs;
    uint16_t tf_padding4;
    uint32_t tf_eflags;
    /* below here only when crossing rings, such as from user to kernel */
    uintptr_t tf_esp;
    uint16_t tf_ss;
    uint16_t tf_padding5;
}
```

### 相关函数定义

#### page_insert函数

该函数用于建立虚拟地址和物理地址之间的映射

```c
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    // pgdir参数是页目标表的内核虚拟基地址，page参数是需要映射的页面，la是需要映射的虚拟地址，perm为此页面的权限
    pte_t *ptep = get_pte(pgdir, la, 1);// 虚拟地址la对应的页表项入口地址
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_P) {
        struct Page *p = pte2page(*ptep);
        if (p == page) {
            page_ref_dec(page);
        }
        else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
    tlb_invalidate(pgdir, la);
    return 0;
}
```

### 相关代码实现

主要是填写lab5/kern/process/proc.c中的load_icode函数

```c
static int
load_icode(unsigned char *binary, size_t size) {
    // 当前进程空间为空
    if (current->mm != NULL) {
        panic("load_icode: current->mm must be empty.\n");
    }

    int ret = -E_NO_MEM;  //错误信息：未分配内存
    struct mm_struct *mm;
    //(1) 为进程分配一个新的内存
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) 创建新的PDT（页目标表）, 并且 mm->pgdir= PDT的内核虚拟地址
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA 段, 在进程的内存空间中将bss以二进制的形式存储
    struct Page *page;
    //(3.1) 获取二进制（ELF）程序的文件头 (ELF format)
    struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) 获取二进制程序（ELF）的程序头表入口(ELF format)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) 该程序是否是ELF文件
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;// 段数目
    for (; ph < ph_end; ph ++) {
    //(3.4) 找到每个程序段的开头
        if (ph->p_type != ELF_PT_LOAD) { // 当前段不能被加载
            continue ;
        }
        // 比较当前程序段的虚拟空间大小和分配的物理空间大小
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        // 当前段大小为0
        if (ph->p_filesz == 0) {
            continue ;
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        if (vm_flags & VM_WRITE) perm |= PTE_W;
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        unsigned char *from = binary + ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;

     //(3.6) 分配内存，并将每个程序段的内容（from，from end）复制到进程的内存（la，la end）
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) 从二进制（ELF）程序中copy 数据|代码段
        while (start < end) {
            // 创建page结构大小的内存，使得虚拟地址la和物理地址建立映射
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) 创建二进制（ELF）程序的bss段
        end = ph->p_va + ph->p_memsz;
        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) 创建用户栈的内存空间
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    
    //(5) 设置当前进程的mm，sr3，并设置CR3 reg =页面目录的物理地址
    mm_count_inc(mm);
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));

    //(6) 设立用户态的陷阱门
    struct trapframe *tf = current->tf;
    memset(tf, 0, sizeof(struct trapframe));
    tf->tf_cs = USER_CS;
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
    tf->tf_esp = USTACKTOP;
    tf->tf_eip = elf->e_entry;
    tf->tf_eflags = FL_IF;
    /* LAB5:EXERCISE1 YOUR CODE
     * should set tf_cs,tf_ds,tf_es,tf_ss,tf_esp,tf_eip,tf_eflags
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf_cs should be USER_CS segment (see memlayout.h)
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}
```

### 设计实现过程

注释里写的非常详细

+ tf_cs设置为用户态代码段的段选择子
+ tf_ds，tf_es，tf_ss设置为用户态数据段的段选择子
+ tf_esp设置为用户栈的栈顶
+ tf_eip设置为ELF文件的程序入口e_entry(应该是第一条程序指令的入口)
+ tf_eflags使能中断位

### 用户态进程被ucore选择到具体执行应用程序第一条指令的整个过程

神仙，真的神仙，爷服辣！

参考博客的地址：

https://www.cnblogs.com/wuhualong/p/ucore_lab5_report.html

1. 内核线程initproc在创建完成用户态进程userproc后，调用do_wait函数，do_wait函数在确认存在RUNNABLE的子进程后，调用schedule函数。
2. schedule函数通过调用proc_run来运行新线程，proc_run做了三件事情：
   - 设置userproc的栈指针esp为userproc->kstack + 2 * 4096，即指向userproc申请到的2页栈空间的栈顶
   - 加载userproc的页目录表。用户态的页目录表跟内核态的页目录表不同，因此要重新加载页目录表
   - 切换进程上下文，然后跳转到userproc->context.eip指向的函数，即forkret
3. forkret函数直接调用forkrets函数，forkrets先把栈指针指向userproc->tf的地址，然后跳到__trapret
4. __trapret先将userproc->tf的内容pop给相应寄存器，然后通过iret指令，跳转到userproc->tf.tf_eip指向的函数，即kernel_thread_entry
5. kernel_thread_entry先将edx保存的输入参数（NULL）压栈，然后通过call指令，跳转到ebx指向的函数，即user_main
6. user_main先打印userproc的pid和name信息，然后调用kernel_execve
7. kernel_execve执行exec系统调用，CPU检测到系统调用后，会保存eflags/ss/eip等现场信息，然后根据中断号查找中断向量表，进入中断处理例程。这里要经过一系列的函数跳转，才真正进入到exec的系统处理函数do_execve中：vector128 -> __alltraps -> trap -> trap_dispatch -> syscall -> sys_exec -> do_execve
8. do_execve首先检查用户态虚拟内存空间是否合法，如果合法且目前只有当前进程占用，则释放虚拟内存空间，包括取消虚拟内存到物理内存的映射，释放vma，mm及页目录表占用的物理页等。
9. 调用load_icode函数来加载应用程序
   - 为用户进程创建新的mm结构
   - 创建页目录表
   - 校验ELF文件的魔鬼数字是否正确
   - 创建虚拟内存空间，即往mm结构体添加vma结构
   - 分配内存，并拷贝ELF文件的各个program section到新申请的内存上
   - 为BSS section分配内存，并初始化为全0
   - 分配用户栈内存空间
   - 设置当前用户进程的mm结构、页目录表的地址及加载页目录表地址到cr3寄存器
   - 设置当前用户进程的tf结构
10. load_icode返回到do_exevce，do_execve设置完当前用户进程的名字为“exit”后也返回了。这样一直原路返回到alltraps函数时，接下来进入trapret函数
11. trapret函数先将栈上保存的tf的内容pop给相应的寄存器，然后跳转到userproc->tf.tf_eip指向的函数，也就是应用程序的入口（exit.c文件中的main函数）。注意，此处的设计十分巧妙：alltraps函数先将各寄存器的值保存到userproc->tf中，接着将userproc->tf的地址压入栈后，然后调用trap函数；trap返回后再将current->tf的地址出栈，最后恢复current->tf的内容到各寄存器。这样看来中断处理前后各寄存器的值应该保存不变。但事实上，load_icode函数清空了原来的current->tf的内容，并重新设置为应用进程的相关状态。这样，当__trapret执行iret指令时，实际上跳转到应用程序的入口去了，而且特权级也由内核态跳转到用户态。接下来就开始执行用户程序（exit.c文件的main函数）啦。

## 练习2: 父进程复制自己的内存空间给子进程

创建子进程的函数do_fork在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过copy_range函数（位于kern/mm/pmm.c中）实现的，请补充copy_range的实现，确保能够正确执行。

请在实验报告中简要说明如何设计实现”Copy on Write 机制“，给出概要设计，鼓励给出详细设计。

### 函数调用过程

**do_fork-->copy_mm-->dup_mmap-->copy_range**

### do_fork函数

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

### copy_mm函数

```c
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    struct mm_struct *mm, *oldmm = current->mm;

    /* 当前是一个内核线程 */
    if (oldmm == NULL) {
        return 0;
    }
    if (clone_flags & CLONE_VM) { //可以共享地址空间
        mm = oldmm; // 共享地址空间
        goto good_mm;
    }

    int ret = -E_NO_MEM;
    if ((mm = mm_create()) == NULL) { // 创建地址空间失败
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }

    lock_mm(oldmm); //打开互斥锁，避免多个进程同时访问内存
    {
        ret = dup_mmap(mm, oldmm);
    }
    unlock_mm(oldmm); // 释放互斥锁

    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm); //共享地址空间的进程数加一
    proc->mm = mm; // 复制地址空间
    proc->cr3 = PADDR(mm->pgdir); // 复制页表地址
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
}
```

### dup_mmap函数

```c
int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
    assert(to != NULL && from != NULL);
    // mmap_list为虚拟地址空间的首地址
    list_entry_t *list = &(from->mmap_list), *le = list;
    while ((le = list_prev(le)) != list) {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        // 创建该段？
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }
        // 向新进程插入新创建的段
        insert_vma_struct(to, nvma);

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
}
```

### copy_range函数

```c
int
copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end, bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // copy content by page unit.
    do {
        //调用get_pte根据addr start查找进程A的页表项入口地址
        // call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue ;
        }
        // 调用get_pte以根据addr开始查找进程B的pte。 如果pte为NULL，只需分配一个PT
        // call get_pte to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (*ptep & PTE_P) {
            if ((nptep = get_pte(to, start, 1)) == NULL) {
                return -E_NO_MEM;
            }
            uint32_t perm = (*ptep & PTE_USER);
            //get page from ptep
            struct Page *page = pte2page(*ptep);
            // alloc a page for process B
            struct Page *npage = alloc_page();
            assert(page != NULL);
            assert(npage != NULL);
            int ret = 0;
            // 返回父进程的内核虚拟页地址
            void *kva_src = page2kva(page);
            // 返回子进程的内核虚拟页地址
            void *kva_dst = page2kva(npage);
            // 复制父进程到子进程
            memcpy(kva_dst, kva_src, PGSIZE);
            // 建立子进程页起始地址与物理地址的映射关系
            ret = page_insert(to, npage, start, perm);

        assert(ret == 0);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}
```

总的来说，memcpy将父进程内存copy给子进程

## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现


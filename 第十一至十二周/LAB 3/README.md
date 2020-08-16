![image-20200810205044131](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200810205044131.png)



## 练习一

### 相关函数定义

```c
find_vma -- 查询vma
    //查找在mm变量中的mmap_list链表中某个vma包含此addr,返回其vma的地址
vm_flags -- 表示了这个虚拟内存空间的属性
    //#define VM_READ 0x00000001 //只读
	//#define VM_WRITE 0x00000002 //可读写
	//#define VM_EXEC 0x00000004 //可执行

struct mm_struct {  
        list_entry_t mmap_list;  //双向链表头，链接了所有属于同一页目录表的虚拟内存空间
        struct vma_struct *mmap_cache;  //指向当前正在使用的虚拟内存空间
        pde_t *pgdir; //指向的就是 mm_struct数据结构所维护的页表
        int map_count; //记录mmap_list里面链接的vma_struct的个数
        void *sm_priv; //指向用来链接记录页访问情况的链表头
 };      
struct vma_struct {  
        struct mm_struct *vm_mm;  //指向一个比vma_struct更高的抽象层次的数据结构mm_struct 
        uintptr_t vm_start;      //vma的开始地址
        uintptr_t vm_end;      // vma的结束地址
        uint32_t vm_flags;     // 虚拟内存空间的属性
        list_entry_t list_link;  //双向链表，按照从小到大的顺序把虚拟内存空间链接起来
    }; 
struct swap_manager    
{    
    const char *name;    
    /* Global initialization for the swap manager */    
    int (*init) (void);    
    /* Initialize the priv data inside mm_struct */    
    int (*init_mm) (struct mm_struct *mm);    
    /* Called when tick interrupt occured */    
    int (*tick_event) (struct mm_struct *mm);    
    /* Called when map a swappable page into the mm_struct */    
    int (*map_swappable) (struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);     
    /* When a page is marked as shared, this routine is called to delete the addr entry from the swap manager */  
    int (*set_unswappable) (struct mm_struct *mm, uintptr_t addr);    
    /* Try to swap out a page, return then victim */    
    int (*swap_out_victim) (struct mm_struct *mm, struct Page *ptr_page, int in_tick);    
    /* check the page relpacement algorithm */    
    int (*check\_swap)(void);     
}; 
```

数据结构**mm_struct**和**vma_struct**之间的关系示意图。

mm_strcut->sm_priv指向链接记录页访问情况的链表头（该链表的概念等于视频中的栈）

![image-20200812015940628](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200812015940628.png)

### Page Fault异常处理流程

首先，产生页访问异常的原因主要有：

+ 目标页帧不存在（页表项全为0，即该线性地址与物理地址尚未建立映射或者已经撤销）
+ 相应的物理页帧不在内存中（页表项非空，但Present标志位为0，比如在swap分区或磁盘文件上）
+ 不满足访问权限（此时页表项P标志=1，但低权限的程序试图访问高权限的地址空间，或者有程序试图写只读页面）

如果有以上情况之一，就会产生Page Fault异常，CPU将产生异常的线性地址存储在CR2[^1]中，并把errorCode[^2]保存在中断栈中。

[^1]: CR2是页故障线性地址寄存器，保存最后一次出现页故障的全32位线性地址。CR2用于发生页异常时报告出错信息。当发生页异常时，处理器把引起页异常的线性地址保存在CR2中。操作系统中对应的中断服务例程可以检查CR2的内容，从而查出线性地址空间中的哪个页引起本次异常。
[^2]: 页访问异常错误码有32位。位0为１表示对应物理页不存在；位１为１表示写异常（比如写了只读页；位２为１表示访问权限异常（比如用户态程序访问内核空间的数据）

**处理流程**：

+ 根据从CPU的控制寄存器CR2中获取的页访问异常的物理地址以及根据errorCode的错误类型来查找此地址是否在某个VMA的地址范围内以及是否满足正确的读写权限
+ 如果该虚地址不在某VMA范围内，则认为是一次非法访问
+ 如果在此范围内且权限也正确，则认为是一次合法访问，但没有建立虚实对应关系。所以会分配一个空闲的内存页，并且修改页表完成虚地址到物理地址的映射，刷新TLB，然后调用iret中断，返回到页访问异常的指令处重写执行该指令

### 代码部分

```c

    // 获取页表项，但找不到虚拟地址所对应的页表项
    if ((ptep = get_pte(mm->pgdir,addr,1)) == NULL){
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }

    // 页表项为0，不存在映射关系，则要建立虚拟地址和物理地址的映射关系
    if (*ptep == 0){
        // 权限不够,失败
        // Present为1,但低权限访问高权限内存空间 OR 程序试图写属性只读的页
        if (pgdir_alloc_page(mm->pgdir,addr,perm) == NULL){
            cprintf("pgdir_alloc_page in do_pgfault failed");
            goto failed;
        }
    }
    else {
        // 页表项非空，尝试换入页面
        if (swap_init_ok){
            struct Page *page = NULL; // 根据mm结构和addr地址，尝试将硬盘中的内容换入至page中
            if ((ret = swap_in(mm,addr,&page)) != 0){
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }
            page_insert(mm->pgdir,page,addr,perm); //建立虚拟地址和物理地址之间的对应关系
            swap_map_swappable(mm,addr,page,1); //将此页面设置为可交换的
            page->pra_vaddr = addr;
        }
        else{
            cprintf("no swap_init_ok but ptep is %x,failed\n",*ptep);
            goto failed;
        }
    }

```

## 练习二

### 相关数据结构定义

该lab对Page进行了拓展，pra_page_link来构成一个按访问时间排序的链表（相当于视频中的栈），该链表的开始表示第一个访问时间最近的页，链表结尾表示第一次访问时间最远的页。

```c
struct Page {  
……   
list_entry_t pra_page_link;   //构成一个按访问时间排序的链表（相当于视频中的栈）
uintptr_t pra_vaddr;   //记录此物理页对应的虚拟页起始地址。
};

// 为了实现各种页替换算法，设计了一个页替换算法的类框架swap_manager:
struct swap_manager
{
     const char *name;
     /* Global initialization for the swap manager */
     int (*init)            (void);
     /* 在mm_struct中初始化priv数据 */
     int (*init_mm)         (struct mm_struct *mm);
     /* tick中断发生时调用 */
     int (*tick_event)      (struct mm_struct *mm);
     /* 将可交换页面映射到mm_struct时调用 */
     int (*map_swappable)   (struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);
     /* 当页面标记为共享时，将调用此例程以从交换管理器中删除addr条目 */
     int (*set_unswappable) (struct mm_struct *mm, uintptr_t addr);
     /* 挑选要换出的页 */
     int (*swap_out_victim) (struct mm_struct *mm, struct Page **ptr_page, int in_tick);
     /* check the page relpacement algorithm */
     int (*check_swap)(void);     
};
//这里关键的两个函数指针是map_swappable和swap_out_vistim，前一个函数用于记录页访问情况相关属性，后一个函数用于挑选需要换出的页。显然第二个函数依赖于第一个函数记录的页访问情况。tick_event函数指针也很重要，结合定时产生的中断，可以实现一种积极的换页策略。
```

### 页错误异常

+ 目标页帧不存在（页表项全为0，即该线性地址与物理地址尚未建立映射或者已经撤销）
+ 相应的物理页帧不在内存中（页表项非空，但Present标志位为0，比如在swap分区或磁盘文件上）
+ 不满足访问权限（此时页表项P标志=1，但低权限的程序试图访问高权限的地址空间，或者有程序试图写只读页面）

这里我们主要处理目标页帧不存在的情况，即要访问的页的内容未被放入物理页中

所以我们需要通过页面分配解决这个问题。 页面替换主要分为两个方面，页面换出和页面换入。

- 页面换入主要在上述的`do_pgfault()`函数实现；
- 页面换出主要在`swap_out_vistim()`函数实现。

### 相应算法

先进先出(First In First Out, FIFO)页替换算法：

该算法总是淘汰最先进入内存的页，即选择在内存中驻留时间最久的页予以淘汰。只需把一个应用程序在执行过程中已调入内存的页按先后次序链接成一个队列，队列头指向内存中驻留时间最久的页，队列尾指向最近被调入内存的页。这样需要淘汰页时，从队列头很容易查找到需要淘汰的页。

FIFO算法只是在应用程序按线性顺序访问地址空间时效果才好，否则效率不高。因为那些常被访问的页，往往在内存中也停留得最久，结果它们因变“老”而不得不被置换出去。FIFO算法的另一个缺点是，它有一种异常现象（Belady现象），即在增加放置页的页帧的情况下，反而使页访问异常次数增多。

### 算法实现的页面置换机制

#### 1. 可以被换出的页

只有映射到用户空间且被用户程序直接访问的页面才能被交换，而被内核直接使用的内核空间的页面不能被换出。

但在实验三实现的ucore中，我们只是实现了换入换出机制，还没有设计用户态执行的程序，所以我们在实验三中仅仅通过执行check_swap函数在内核中分配一些页，模拟对这些页的访问，然后通过do_pgfault来调用swap_map_swappable函数来查询这些页的访问情况并间接调用相关函数，换出“不常用”的页到磁盘上。

#### 2. 虚存中的页与硬盘上的扇区之间的映射关系

如果一个页被置换到了硬盘上，在ucore里利用了页表中的PTE来表示这种情况：当一个PTE用来描述一般意义上的物理页时，显然它应该维护各种权限和映射关系，以及应该有PTE_P标记；但当它用来描述一个被置换出去的物理页时，它被用来维护该物理页与 swap 磁盘上扇区的映射关系，并且该 PTE 不应该由 MMU 将它解释成物理页映射(即没有 PTE_P 标记)，与此同时对应的权限则交由 mm_struct 来维护，当对位于该页的内存地址进行访问的时候，必然导致 page fault，然后ucore能够根据 PTE 描述的 swap 项将相应的物理页重新建立起来，并根据虚存所描述的权限重新设置好 PTE 使得内存访问能够继续正常进行。



### 页面换出代码部分

```C
// FIFO初始化
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);//先将按访问时间排序的链表进行初始化
     mm->sm_priv = &pra_list_head;//把mm变量指向用来链接记录页访问情况的属性指向该链表
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}

//将最近被用到的页面添加到算法所维护的次序队列。
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;//获取页访问情况的链表头
    list_entry_t *entry=&(page->pra_page_link);//获取最近被使用到的页面
    assert(entry != NULL && head != NULL);
    list_add(head, entry);//头插，将最近被用到的页面添加到记录页访问情况的链表

    return 0;
}

//查询哪个页面需要被换出。
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;//获取按访问时间排序的链表
         assert(head != NULL);
     assert(in_tick==0);
     list_entry_t *le = head->prev; //找到要被换出的页（即链表尾，找的是第一次访问时间最远的页）
     assert(head != le);
     struct Page *p = le2page(le,pra_page_link); //找到page结构的head
     list_del(le); //将进来最早的页面从队列中删除
     assert (p != NULL);
     *ptr_page = p;

     return 0;
}
```


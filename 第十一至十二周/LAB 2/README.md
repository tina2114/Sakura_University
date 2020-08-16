## 练习一：**实现 first-fit 连续物理内存分配算法**

first_fit分配算法需要维护一个查找有序（地址按从小到大排列）空闲块（以页为最小单位的连续地址空间）的数据结构

### 相关的函数与定义

```c
// list_init(&free_list)溯源，相当于初始化了一个头尾指针都指向自身的循环双向链表
struct list_entry {
    struct list_entry *prev, *next; // 定义双向链表结构
};
typedef struct list_entry list_entry_t;
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
}

typedef struct {
            list_entry_t free_list;         // 空闲块双向链表的头
            unsigned int nr_free;           // 空闲块的总数（以页为单位）
} free_area_t;

struct Page {
    int ref;        // 这页被页表的引用记数
    uint32_t flags; // bit 0表示此页是否被保留（reserved），bit 1表示此页是否是free的
    unsigned int property;// 连续内存空闲块利用这个页的成员变量property来记录在此块内的空闲页的个数
    list_entry_t page_link;// free list link
};

static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
}
// 头插法的封装？
static inline void    
list_add(list_entry_t *listelm, list_entry_t *elm) {
    list_add_after(listelm, elm);
}
// 头插法
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
}
// 尾插法
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
}
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
    elm->next = next;
    elm->prev = prev;
}

// 将此块取出
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
}
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
    next->prev = prev;
}
```

在内存分配和释放方面最主要的作用是建立了一个物理内存页管理器框架，这实际上是一个函数指针列表，定义如下：

```c
struct pmm_manager {
            const char *name; //物理内存页管理器的名字
            void (*init)(void); //初始化内存管理器
            void (*init_memmap)(struct Page *base, size_t n); //初始化管理空闲内存页的数据结构
            struct Page *(*alloc_pages)(size_t n); //分配n个物理内存页
            void (*free_pages)(struct Page *base, size_t n); //释放n个物理内存页
            size_t (*nr_free_pages)(void); //返回当前剩余的空闲页数
            void (*check)(void); //用于检测分配/释放实现是否正确的辅助函数
};
```



最终的数据结构是形成这样一个循环双向链表来对空闲块进行控制，free_list->next代表空闲链表中储存的最低地址的空闲块

![image-20200803174618226](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200803174618226.png)

但是实际上这图还有一点不准确，这里的Page其实应该指的是内存块，内存块结构如下：

![img](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/UMJ85JVS55UX8I7]5UTF4N8.png)

page结构中property和page_link的设计，在内存块中只有head page会用到，块中剩下的page结构似乎这俩属性全用不到。（那么问题来了，能不能重新设计page结构，给内存块重新设计一个head + 修改后的page结构，以减小内存浪费呢）

### default_init_memmap函数

但是呢，这么设计有点问题，这种init设计的前提是ucore得多次调用init函数来形成一个完整的free_list链表。

而真实的ucore标准答案中，只调用了一次init，形成完整链表，此链表只链接了head_page。在后续的lab中会出现问题。

```c
default_init_memmap(struct Page *base, size_t n) {
    // 传进来的第一个参数是某个连续地址的空闲块的起始页
    // 第二个参数是页个数
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p)); // 判断此页是否为保留页
        p->flags = p->property = 0; // flag位与块内空闲页个数初始化
        set_page_ref(p, 0); // page->ref = val;
    }
    base->property = n;
    SetPageProperty(base); // 将其标记为已占有的物理内存空间
    nr_free += n;
    list_add(&free_list, &(base->page_link)); // 运用头插法将空闲块插入链表
}
```

### default_alloc_pages函数

```c
default_alloc_pages(size_t n) {
    // 边界情况检查
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // 若list_next == &free_list代表该循环双向链表被查询完毕
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link) // 由list_entry_t结构转换为Page结构，找到该page结构的头地址
        if (p->property >= n) {
            page = p; // 如果该空闲块里面的空闲页个数满足要求，就找到了
            break;
        }
    }
    // 匹配空闲块成功后的处理
    if (page != NULL) {
        list_del(&(page->page_link)); //将此块取出
        // 如果空闲页个数比要求的多
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p); // 标为已使用块
            list_add(&(page->page_link), &(p->page_link));
    }
        list_del(&(page->page_link)); //从链表中删除
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}
```

### default_free_pages函数

此为原始代码，原始代码的想法是，遍历空闲链表，发现链表当前内存块对应的空闲页和要释放的页在物理地址上是连续的，就进行合并，再将合并后的页用头插放入链表。这是不符合first fit算法要求的，因为它无法确保空闲页按地址从小到大排序。

```c
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        // 检测flag的bit 0是否是0，bit 1是否是0。即是否被保留，是否被free
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0); // 此页被引用次数清零
    }
    base->property = n;
    SetPageProperty(base); // 设置为保留页
    list_entry_t *le = list_next(&free_list);
    // 找到要free的页，将其合并
    while (le != &free_list) {
        p = le2page(le, page_link);
        le = list_next(le);
        // 这里是两种情况，看下图
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        else if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) //检测需释放的这段内存页 是否与head page相邻，详情见图三
    {
        p = le2page(le, page_link);
        if (base + base->property <= p)
        {
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(&free_list, &(base->page_link)); //尾插，存疑，为何可行
}
```

图一代表if里的情况，图二代表else if里的情况，图三代表要free的页不与head page相邻的情况

![image-20200809011013976](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200809011013976.png)

![image-20200809014959732](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200809014959732.png)

### 练习2：实现寻找虚拟地址对应的页表项

题目中给出的参考：

- PDX(la)： 返回虚拟地址la的页目录索引

- KADDR(pa): 返回物理地址pa相关的内核虚拟地址

- set_page_ref(page,1): 设置此页被引用一次

- page2pa(page): 得到page管理的那一页的物理地址

- struct Page * alloc_page() : 分配一页出来

- memset(void * s, char c, size_t n) : 设置s指向地址的前面n个字节为字节‘c’

- PTE_P 0x001 表示物理内存页存在

- PTE_W 0x002 表示物理内存页内容可写

- PTE_U 0x004 表示可以读取对应地址的物理内存页内容

  ```c
  pte_t *
  get_pte(pde_t *pgdir, uintptr_t la, bool create) {
          pde_t *pdep = &pgdir[PDX(la)];  //尝试获得页表
          if (!(*pdep & PTE_P)) { //如果获取不成功
              struct Page *page;
              //假如不需要分配或是分配失败
              if (!create || (page = alloc_page()) == NULL) { 
                  return NULL;
          }
          set_page_ref(page, 1); //引用次数加一
          uintptr_t pa = page2pa(page);  //得到该页物理地址
          memset(KADDR(pa), 0, PGSIZE); //物理地址转虚拟地址，并初始化
          *pdep = pa | PTE_U | PTE_W | PTE_P; //设置控制位
      }
      return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)]; 
      //KADDR(PDE_ADDR(*pdep)):这部分是由页目录项地址得到关联的页表物理地址， 再转成虚拟地址
      //PTX(la)：返回虚拟地址la的页表项索引
      //最后返回的是虚拟地址la对应的页表项入口地址
  }
  ```

### 练习3：释放某虚地址所在的页并取消对应二级页表项的映射

#### tlb_invalidate函数

```c
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    if (rcr3() == PADDR(pgdir)) { 
        invlpg((void *)la);
    }
}
```

#### page_ref_dec函数

```c
static inline int
page_ref_dec(struct Page *page) {
    page->ref -= 1; //引用数减一
    return page->ref;
}
```

#### page_remove_pte()

```c
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    if (*ptep & PTE_P){ // 二级页表项存在
        struct Page *page = pte2page(*petp); //找到页表项
        if (page_ref_dec(page) == 0){ // 此页的被引用数为0，即无其他进程对此页进行引用
            free_pages(page);
        }
        *ptep = 0; // 该页目录项清零
        tlb_invalidate(pgdir,la); //当修改的页表是进程正在使用的那些页表，使之无效。
    }
```


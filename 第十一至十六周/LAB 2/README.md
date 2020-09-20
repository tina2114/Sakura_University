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

### 拓展练习**Challenge：buddy system（伙伴系统）分配算法**

Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...

- 参考[伙伴分配器的一个极简实现](http://coolshell.cn/articles/10427.html)， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

在此链接的极简实现中，主要是设计了一个树状结构，举个例子，假设你一共给予了16byte的内存大小，就会形成如下图的树状结构，按照伙伴系统的概念，你要求size大小的内存块，它会先判断你要求的size是否是2的整数次方倍，如果不是则会向上取整，并在该二叉树中选取合适的内存块进行分配。

![image-20200902223935672](C:\Users\zhz\AppData\Roaming\Typora\typora-user-images\image-20200902223935672.png)

#### 基础的数据结构和宏

如果要实现伙伴系统与该树状算法的对应，需要定义一些宏来辅助我们完成。

首先判断你输入的size是否是2的整数次幂，宏定义如下

```c
// 判断是否是2的整数次幂，是就返回1
#define IS_POWER_OF_2(x)    (!((x)&((x)-1)))
```

如果不是，就需要向上取整，相关定义如下

```c
#include <stdio.h>
// 拓展size为2的整数次方倍
static unsigned fixsize(unsigned size){
  size |= size >> 1;
  size |= size >> 2;
  size |= size >> 4;
  size |= size >> 8;
  size |= size >> 16;
  return size+1;
}
```

接下来就需要考虑的情况是当你alloc操作，在树状结构中进行检索的时候，当你检索到一半的时候有可能出现你当前节点的size大于需求的size，同时当前节点的左右子节点的size也大于需求的size，你就需要和左右子节点进行比对，同时更新父节点的信息，相关宏定义如下

```c
// 取左子节点的值
#define GET_LEFT_LEAF(index) ((index)*2+1)
// 取右节点的值
#define GET_RIGHT_LEAF(index) ((index)*2+2)
// 取父节点的值
#define GET_PARENT(index) ((index)/2 - 1)
// 判断最大的数
#define MAX(a,b) ((a) > (b) ? (a) : (b))
```

同时为了方便寻找出size对应的大于size的最小的2的整数次方和小于size的最大的2的整数次方，也需要对应设置宏。

```c
// 大于a的一个最小的2次方倍数
#define UINT32_MASK(a)  (UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(a,1),2),4),8),16))    
//检测大于a的最小的2^(k-1)是否小于等于a
#define UINT32_REMAINDER(a)     ((a)&(UINT32_MASK(a)>>1))
//小于a的最大的2^k
#define UINT32_ROUND_DOWN(a)    (UINT32_REMAINDER(a)?((a)-UINT32_REMAINDER(a)):(a))
```

相关的数据结构定义

```c
struct buddy2 {
    // 表明管理内存，树的节点个数
    unsigned size;
    // 记录对应的内存块的空闲单位
    unsigned longest;
};

// 存放二叉树的数组，用于内存分配
struct buddy2 root[80000];

// 记录分配块的信息
struct allocRecord{
    struct Page* base;
    int offset;
    size_t nr; // 块大小
};

// 存放偏移量的数组
struct allocRecord rec[80000];
// 已分配的块数
int nr_block;
```

#### 初始化二叉树上的节点

```c

void buddy2_new( int size){
    unsigned node_size;
    int i;
    nr_block = 0;
    if (size < 1 || !IS_POWER_OF_2(size))
        return;

    root[0].size = size;
    node_size = size * 2 ; // 二叉树上一共size *2 个节点
    // 这里初始化了整棵二叉树
    for (i = 0; i < 2 * size -1; ++i){
        if (IS_POWER_OF_2(i+1))
            node_size /= 2;
        root[i].longest = node_size; // longest记录了该节点的内存大小
    }
    return;
}
```

#### 初始化内存映射关系

这里倒是和原本的没什么差别，只不过唯一有点不同的是初始化了一块树的根节点，这是原本的函数中没有的

```c
static void buddy_init_memmap(struct  Page *base, size_t n)
{
    assert (n>0);
    struct Page* p = base;
    for (; p!=base + n; p++)
    {
        assert(PageReserved(p));
        p->flags = 0; // flag位
        p->property = 1;
        set_page_ref(p, 0); // page->ref = val;
        SetPageProperty(p); // 将其标记为已占有的物理内存空间
        list_add_before(&free_list, &(p->page_link)); // 运用尾插法将空闲块插入链表
    }
    nr_free += n;
    int allocpages = UINT32_ROUND_DOWN(n);
    buddy2_new(allocpages);
}
```

#### 内存分配

在alloc的时候，要注意的是，这里进行分配会先判断是否可以分配，需求的size是否超出树的最大容量。如果都满足就进行分配，会在左右子节点中选择内存较小的节点进行分配。将该节点分配出去后，此时就相当于二叉树的总体内存减小了，就需要对逐层的对父节点的内存进行修改

```c
int buddy2_alloc(struct buddy2* self, int size){
    unsigned index = 0; // 节点的标号
    unsigned node_size;
    unsigned offset = 0;

    if (self == NULL) // 无法分配
        return -1;

    if (size <= 0)
        size = 1;
    else if (!IS_POWER_OF_2(size)) // 当size不为2的幂时，向上取整
        size = fixsize(size);

    if (self[index].longest < size) // 如果一开始根节点的可分配内存就不足
        return -1;

    for(node_size = self->size; node_size != size; node_size /=2){
        if(self[GET_LEFT_LEAF(index)].longest >= size){
            if(self[GET_RIGHT_LEAF(index)].longest >= size){
                // 找到两个相符合的节点中内存较小的节点
                index = self[GET_LEFT_LEAF(index)].longest <= self[GET_RIGHT_LEAF(index)].longest? GET_LEFT_LEAF(index):GET_RIGHT_LEAF(index);
            }
            else{
                index = GET_LEFT_LEAF(index);
            }
    }
    else
    {
        index = GET_RIGHT_LEAF(index);
    }
    self[index].longest = 0; // 标记节点为已使用
    offset = (index + 1) * node_size - self->size;
    while (index){
        index = GET_PARENT(index);
        self[index].longest = MAX(self[GET_LEFT_LEAF(index)].longest,self[GET_RIGHT_LEAF(index)].longest);
    }
    // 向上刷新，修改父节点的数值
    return offset;
}
    
static struct  Page* buddy_alloc_pages(size_t n){
    assert(n>0);
    if (n>nr_free)
        return NULL;

    struct Page* page = NULL;
    struct Page* p;
    int allocpage;
    list_entry_t *le = &free_list;
    list_entry_t *len;
    rec[nr_block].offset = buddy2_alloc(root,n); // 记录偏移量

    for (int i = 0; i < rec[nr_block].offset + 1; i++)
        le = list_next(le);
    page = le2page(le,page_link);

    if (!IS_POWER_OF_2(n))
        allocpages = fixsize(n);
    else
    {
        allocpages = n;
    }

    // 根据需求n得到块大小
    rec[nr_block].base = page; // 记录分配块首页
    rec[nr_block].nr = allocpages; // 记录分配的页数
    nr_block++;
        for(int i = 0; i < allocpages; i++)
        {
            len = list_next(le);
            p = le2page(le,page_link);
            ClearPageProperty(p);
            le = len;
        } // 修改每一页的状态
        nr_free -= allocpages; // 减去已被分配的页数
        page->property = n;
        return page;
}
```

#### 内存回收

先确保传入分配的内存地址索引是有效值，再反向回溯，从最后的节点向上回溯到longest为0的节点，即当初被分配出去的块的位置。将longest还原为原来的值，再次向上回溯，检查是否可以合并块。也就是左右子树的值相加是否等于父节点的longest的大小，如果相等就合并。

```c
void buddy_free_pages(struct Page* base, size_t n){
    unsigned node_size,index = 0;
    unsigned left_longest, right_longest;
    struct buddy2* self = root;

    list_entry_t le = list_next(&free_list);
    int i = 0;
    for ( i = 0; i < nr_block; i++ ){
        // 找到块
        if(rec[i].base = base)
            break;
    }
    int offset = rec[i].offset;
    int pos = i; // 暂存i
    i = 0;
    while ( i < offset){
        le = list_next(le);
        i++
    }
    int allocpages;
    if (!IS_POWER_OF_2(n))
        allocpages = fixsize(n);
    else 
        allocpages = n;
    assert(self && offset >= 0 && offset < self->size); // 是否合法
    node_size = 1;
    index = offset + self->size -1;
    nr_free += allocpages; // 更新空闲页的数量
    struct Page* p;
    self[index].longest = allocpages;
    for (i = 0; i < allocpages; i++){
        // 回收已分配的页
        p = le2page(le,page_link);
        p->flags = 0;
        p->property = 1;
        SetPageProperty(p);
        le = list_next(le);
    }
    while (index){
        // 向上合并，修改父节点的记录值
        index = GET_PARENT(index);
        node_size *= 2;

        left_longest = self[GET_LEFT_LEAF(index)].longest;
        right_longest = self[GET_RIGHT_LEAF(index)].longest;
        // 如果左右子节点都是free状态就合并，更新父节点的size
        if (left_longest + right_longest = node_size)
            self[index].longest = node_size;
        // 左右子节点有一个处在free状态，更新父节点的size
        else 
            self[index].longest = MAX(left_longest,right_longest);
    }
    for (i = pos; i < nr_block ; i++) // 清除此次的分配记录
        rec[i] = rec[i+1]

    nr_block--; // 更新分配出去的块的数量
}
```


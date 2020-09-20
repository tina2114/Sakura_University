## 练习1: 完成读文件操作的实现

首先了解打开文件的处理流程，然后参考本实验后续的文件读写操作的过程分析，编写在sfs_inode.c中sfs_io_nolock读文件中数据的实现代码。

请在实验报告中给出设计实现”UNIX的PIPE机制“的概要设方案，鼓励给出详细设计方案

### ucore的文件系统架构

- 通用文件系统访问接口层：该层提供了一个从用户空间到文件系统的标准访问接口。这一层访问接口让应用程序能够通过一个简单的接口获得ucore内核的文件系统服务。

- 文件系统抽象层z(vfs)：向上提供一个一致的接口给内核其他部分（文件系统相关的系统调用实现模块和其他内核功能模块）访问。向下提供一个同样的抽象函数指针列表和数据结构屏蔽不同文件系统的实现细节。

- Simple FS文件系统层(sfs)：一个基于索引方式的简单文件系统实例。向上通过各种具体函数实现以对应文件系统抽象层提出的抽象函数。向下访问外设接口

- 外设接口层(dev)：向上提供device访问接口屏蔽不同硬件细节。向下实现访问各种具体设备驱动的接口，比如disk设备接口/串口设备接口/键盘设备接口等。

  ![image-20200830215931043](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200830215931043.png)

### 重要的数据结构(自上而下)

进程控制块的结构体proc_struct包含文件控制信息结构体file_struct

#### files_struct

```c
struct files_struct {
    struct inode *pwd;      // inode of present working directory
    struct file *fd_array;  // opened files array
    int files_count;        // the number of opened files
    semaphore_t files_sem;  // lock protect sem
};
```

#### inode

![image-20200829221225299](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200829221225299.png)

index node是位于内存的索引节点，它是VFS结构中的重要数据结构，因为它实际负责把不同文件系统的特定索引节点信息（甚至不能算是一个索引节点）统一封装起来，避免了进程直接访问具体文件系统

**device**

+ 两个变量d_blocks，d_blocksize，标记文件块数目和大小
+ 四个函数指针，分别对应open，close和io操作

**sfs_inode**

​		inode序号，文件大小，文件块的数目以及位置等信息

**inode如何与文件进行绑定？**

​		借助sfs_disk_entry结构体，将inode的ino序号与文件名name绑定在一起

```c
struct inode {
union { //包含不同文件系统特定inode信息的union域
struct device __device_info;  //设备文件系统内存inode信息
struct sfs_inode __sfs_inode_info; //SFS文件系统内存inode信息
} in_info;
enum {
inode_type_device_info = 0x1234,
inode_type_sfs_inode_info,
} in_type;  //此inode所属文件系统类型
atomic_t ref_count;   //此inode的引用计数
atomic_t open_count;  //打开此inode对应文件的个数
struct fs *in_fs;     //抽象的文件系统,包含访问文件系统的函数指针
const struct inode_ops *in_ops;   //抽象的inode操作,包含访问inode的函数指针
};

struct sfs_disk_entry {
    uint32_t ino;                                   /* inode number */
    char name[SFS_MAX_FNAME_LEN + 1];               /* file name */
};
```

#### sfs_inode结构体

定义了inode的ino序号，inode是否被修改的记录（写文件时会发生改动），有多少进程打开了这个文件，信号量，sfs_fs中的链表目录和哈希目录

```c
struct sfs_inode {
    struct sfs_disk_inode *din;                     /* on-disk inode */
    uint32_t ino;                                   /* inode的ino序号 */
    bool dirty;                                     /* inode是否被修改的记录（写文件时会发生改动） */
    int reclaim_count;                              /* 有多少进程打开了这个文件，如果没进程了，变为0，就kill了这个inode */
    semaphore_t sem;                                /* semaphore for din */
    list_entry_t inode_link;                        /* entry for linked-list in sfs_fs */
    list_entry_t hash_link;                         /* entry for hash linked-list in sfs_fs */
};
```

#### sfs_disk_inode结构体

文件大小(bytes)，文件类型，与此文件的硬链接数目，文件块数目，direct[]直接指向了保存文件内容数据的数据块索引值，indirect间接指向了保存文件内容数据的数据块

直接和间接索引个人感觉可以用这图解释

![image-20200831214704485](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200831214704485.png)

```c
struct sfs_disk_inode {
    uint32_t size;                                  /* size of the file (in bytes) */
    uint16_t type;                                  /* one of SYS_TYPE_* above */
    uint16_t nlinks;                                /* # of hard links to this file */
    uint32_t blocks;                                /* # of blocks */
    uint32_t direct[SFS_NDIRECT];                   /* direct blocks */
    uint32_t indirect;                              /* indirect blocks */
};
```

#### fs结构体

```c
struct fs {
    union {
        struct sfs_fs __sfs_info;                   
    } fs_info;                                     // filesystem-specific data 
    enum {
        fs_type_sfs_info,
    } fs_type;                                     // 文件系统的类型 
    int (*fs_sync)(struct fs *fs);                 // Flush all dirty buffers to disk 
    struct inode *(*fs_get_root)(struct fs *fs);   // Return root inode of filesystem.
    int (*fs_unmount)(struct fs *fs);              // 尝试卸载文件系统.
    void (*fs_cleanup)(struct fs *fs);             // Cleanup of filesystem.???
};
```

#### sfs_fs结构体

```c
struct sfs_fs {
    struct sfs_super super;                         /* on-disk superblock */
    struct device *dev;                             /* device mounted on */
    struct bitmap *freemap;                         /* blocks in use are mared 0 */
    bool super_dirty;                               /* true if super/freemap modified */
    void *sfs_buffer;                               /* buffer for non-block aligned io */
    semaphore_t fs_sem;                             /* semaphore for fs */
    semaphore_t io_sem;                             /* semaphore for io */
    semaphore_t mutex_sem;                          /* semaphore for link/unlink and rename */
    list_entry_t inode_list;                        /* inode linked-list */
    list_entry_t *hash_list;                        /* inode hash linked-list */
};
```

#### file

```c
struct file {
enum {
FD_NONE, FD_INIT, FD_OPENED, FD_CLOSED,
} status;       //访问文件的执行状态
bool readable; //文件是否可读
bool writable; //文件是否可写
int fd;        //文件在filemap中的索引值
off_t pos;    //访问文件的当前位置
struct inode *node;//该文件对应的内存inode指针
atomic_t open_count;//打开此文件的次数
};
```

### 文件系统的初始化执行流程

先看图，对整体的流程有个大概了解，再来看具体代码的实现

![image-20200829214345687](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200829214345687.png)

1. 文件系统的初始化如图，分为三部分，分别是vfs，dev，sfs的初始化

   ```c
   kern_init ->
       fs_init ->
           vfs_init (VirtualFileSystem，虚拟文件系统)
           dev_init (设备文件系统，个人理解是管理设备的驱动程序，为I/O提供支持)
           sfs_init (SimpleFileSystem，一个基于索引方式的简单文件系统实例)
   ```

+ vfs的初始化

  ![image-20200829230405404](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200829230405404.png)

  - 初始化信号量bootfs_sem，将其value设置为1
  - 初始化vdev_list为空链表，初始化信号量vdev_list_sem，将其value设置为1

```c
void vfs_init(void) {
    sem_init(&bootfs_sem, 1);
    vfs_devlist_init();
}
```

+ dev的初始化：stdin，stdout和disk0这三部分的初始化

  ```c
  void dev_init(void) {
      init_device(stdin);
      init_device(stdout);
      init_device(disk0);
  }
  ```

  - stdin的初始化
    - 分配一个inode并初始化，将其函数表设置为dev_node_ops
    - 初始化inode里面的device，将其函数表分别设置为stdin相关的函数，包括stdin_open，stdin_close，stdin_io，stdin_ioctl等
    - 分配一个vfs_dev_t，设置好其中的devname，devnode和fs等成员，然后添加到vdev_list

  ```c
  void dev_init_stdin(void) {
      struct inode *node;
      if ((node = dev_create_inode()) == NULL) {
          panic("stdin: dev_create_node.\n");
      }
      stdin_device_init(vop_info(node, device));
  
      int ret;
      if ((ret = vfs_add_dev("stdin", node, 0)) != 0) {
          panic("stdin: vfs_add_dev: %e.\n", ret);
      }
  }
  ```

  - stdout的初始化，disk0的初始化与stdin类似，只不过其中初始化devive时的函数表不同

+ sfs的初始化:调用sfs_mount将sfs挂载到disk0，也就是最后通过sfs_do_mount将这个文件系统加载到ucore的kernel去，即第三个磁盘，前两个磁盘分别是 ucore.img 和 swap.img，使得我们的应用系统可以去访问

  通常文件系统中，磁盘的使用是以扇区（Sector）为单位的，但是为了实现简便，SFS 中以 block （4K，与内存 page 大小相等）为基本单位。
  
  ```c
  sfs_init ->
      sfs_mount ->
          vfs_mount ->
              sfs_do_mount
  ```

### 用户执行open的详细流程

1.从用户调用open接口到触发系统调用

```c
open (user/libs/file.c) -> // 用户接口
    sys_open (user/libs/syscall.c) ->  // 封装系统调用接口给用户
        syscall(SYS_open, path, open_flags) ->  // 系统调用统一实现接口，根据不同系统调用号从函数表中找到相应处理函数
            sys_open (kern/syscall/syscall.c) -> // 发生open系统调用的实际处理接口
                sysfile_open (kern/fs/sysfile.c) // VFS提供给系统调用的接口,把位于用户空间的字符串user/libcs/file.c拷贝到内核空间的字符串path中
```

2.找到文件所在目录对应的inode节点

分配一个空闲的file数据结构变量file在文件系统抽象层的处理中（当前进程的打开文件数组current->fs_struct->filemap[]中的一个空闲元素），到了这一步还仅仅是给当前用户进程分配了一个file数据结构的变量，还没有找到对应的文件索引节点。进一步调用vfs_open函数来找到path指出的文件所对应的基于inode数据结构的VFS索引节点node。然后调用`vop_open`函数打开文件。然后层层返回，通过执行语句`file->node=node;`，就把当前进程的`current->fs_struct->filemap[fd]`（即file所指变量）的成员变量node指针指向了代表文件的索引节点node。这时返回fd。最后完成打开文件的操作。

```c
sysfile_open (kern/fs/sysfile.c) ->
    file_open (kern/fs/file.c) ->
        vfs_open (kern/fs/vfs/vfsfile.c) ->  // 根据文件名获取或生成一个inode
            vfs_lookup (kern/fs/vfs/vfsloopup.c) ->
                get_device -> // 根据文件名获取对应的inode 
                vop_lookup (kern/fs/vfs/inode.h) -> 
                    sfs_lookup (kern/fs/sfs/sfs_inode.c)
            vop_open (kern/fs/vfs/inode.h) ->
                sfs_opendir (kern/fs/sfs/sfs_inode.c)
```

3.当前目录与对应的inode绑定

```c
init_main ->
    vfs_set_bootfs("disk0:") ->  // 设置当前目录对应的inode为disk0
        vfs_chdir("disk0:") ->
            vfs_lookup("disk0:") ->
                get_device("disk0:") ->
                    vfs_get_root // 由于初始化时已将disk0的vfs_dev_t结构添加到vdev_list中，这里遍历链表即可找到对应的inode
            vfs_set_curdir ->
                set_cwd_nolock
```

4.根据目录的inode及文件名找到文件的inode

- inode->fs->sfs_fs：sfs_buffer提供数据缓冲区、dev提供block数目信息、hash_list提供inode链表信息
- inode->sfs_inode->sfs_disk_inode：含有block数目、block内容等信息
- 查找文件inode流程简析：首先根据inode->sfs_inode->sfs_disk_inode->blocks得知目录inode的block数目，然后遍历每个block，读取每个block的sfs_disk_entry信息，将sfs_disk_entry->name与文件名对比，若相同，则对应的sfs_disk_entry->ino即为文件的inode号。
- 根据ino读取inode内容流程：inode->fs->sfs_fs->hash_list记录有disk0所有inode的信息，首先用ino索引哈希表得到一个链表，再遍历该链表，找到inode号等于ino的节点。

```c
sfs_lookup (kern/fs/sfs/sfs_inode.c) ->
    sfs_lookup_once ->
        sfs_dirent_search_nolock ->  // 读取当前目录下的每一个file entry，搜索与文件名name匹配的entry
            sfs_dirent_read_nolock -> // 根据当前目录的inode及slot找到相应entry并读取其内容
                sfs_bmap_load_nolock ->
                    sfs_bmap_get_nolock
                sfs_rbuf ->
                    sfs_rwblock_nolock ->
                        dop_io -> disk0_io ->
                            disk0_read_blks_nolock ->
                                ide_read_secs
        sfs_load_inode ->
            lookup_sfs_nolock
```

#### sfs_io_nolock函数

源代码中提供两个接口函数**sfs_rbuf**和**sfs_rblock**，分别用于以字节和文件块为单位来读取文件。

主要考虑到读文件的时候，文件的起始和结束位置可能没与block的起始位置对齐，这时候，对于首尾两部分没对齐的部分就调用**sfs_rbuf**来读取内容，对于中间多个完整的block采用**sfs_rblock**来进行读取，这就是为什么**sfs_io_nolock**函数分成三部分读取数据的原因

```c
if ((blkoff = offset % SFS_BLKSIZE) != 0){ // 读取第一部分的数据
        ret = sfs_bmap_load_nolock(sfs,sin,blkno,&ino);
        size = (nblks != 0)? (SFS_BLKSIZE - blkoff) : (endpos - offset);// 计算第一个数据块的大小
        ret |= sfs_buf_op(sfs,buf,size,ino,blkoff); // 找到内存文件索引对应的block的编号ino
        if (ret != 0)
            goto out;
        // 完成实际的读写操作
        alen += size;
        blkno++;
    }
    // 读取中间部分的数据，将其分为size大小的块，然后一次读一块直至读完
    if (nblks){
        ret = sfs_bmap_load_nolock(sfs,sin,blkno,&ino);
        ret |= sfs_block_op(sfs,buf,ino,nblks);
        if (ret != 0)
            goto out;
        alen += nblks * SFS_BLKSIZE;
    }
    // 读取第三部分的数据
    if (offset + alen < endpos){
        ret |= sfs_bmap_load_nolock(sfs,sin,blkno + nblks,&ino);
        ret |= sfs_buf_op(sfs,buf,endpos % SFS_BLKSIZE,ino,0);
        if (ret != 0)
            goto out;
        alen += endpos % SFS_BLKSIZE;
    }
```

## 练习2: 完成基于文件系统的执行程序机制的实现

#### alloc_proc函数

```c
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
        proc->state = PROC_UNINIT; //进程状态为为初始化
        proc->pid = -1;            //进程ID为-1
        proc->runs = 0;            //进程运行时间为0
        proc->kstack = 0;          //内核栈为0
        proc->need_resched = 0;    //进程不需要调度
        proc->parent = NULL; //父进程为空
        proc->mm = NULL; //内存管理为空
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL; //中断帧为空
        proc->cr3 = boot_cr3; //cr3寄存器
        proc->flags = 0; //标记
        memset(proc->name, 0, PROC_NAME_LEN);
        proc->wait_state = 0; //等待状态
        proc->cptr = proc->optr = proc->yptr = NULL; //相关指针初始化
        proc->rq = NULL; //运行队列
        list_init(&(proc->run_link)); //运行队列链表
        proc->time_slice = 0; //进程运行的时间片
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL; //进程池
        proc->lab6_stride = 0;
        proc->lab6_priority = 0; //优先级
        proc->filesp = NULL;  //初始化fs中的进程控制结构
    }
    return proc;
}
```

#### load_icode函数

load_icode主要是将文件加载到内存中执行，从注释中了解到一共有七个步骤

+ 建立内存管理器
+ 建立页目录
+ 将文件逐个段加载到内存中，这里要注意设置虚拟地址与物理地址之间的映射
+ 建立相应的虚拟内存映射表
+ 建立并初始化用户堆栈
+ 处理用户栈中传入的参数
+ 最后很关键的一步是设置用户进程的中断帧
+ 发生错误还需要进行错误处理

```c
static int
load_icode(int fd, int argc, char **kargv) {
    assert(argc >= 0 && argc <= EXEC_MAX_ARG_NUM); // 判断输入的命令个数是否超出
    // 1.建立内存管理器
    if (current->mm != NULL){ // 当前内存管理器为空
        panic("load)icode: current->mm must be empty!\n");
    }

    int ret = -E_NO_MEM; // E_NO_MEM代表因为存储设备产生的请求错误
    struct mm_struct *mm; // 建立内存管理器
    if ((mm == mm_create()) == NULL)
        goto bad_mm;

    // 2.建立页目录
    if (setup_pgdir(mm) != 0)
        goto bad_pgdir_cleanup_mm;
    struct Page *page; // 建立页表

    // 3.从文件加载程序到内存
    struct elfhdr __elf, *elf = &__elf;
    if (( ret = load_icode_read(fd,elf, sizeof(struct elfdr),0)) != 0) // 读取elf文件头
        goto bad_elf_cleanup_pgdir;

    if (elf->e_magic != ELF_MAGIC){
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    struct proghdr __ph, *ph = &__ph;
    uint32_t vm_flags,perm,phnum;
    for (phnum =0;phnum <elf->e_phnum;phnum++){ //e_phnum代表程序段入口地址数目，即多少个段
        off_t phoff = elf->e_phoff + sizeof(struct proghdr) * phnum; // 循环读取程序的每个段的头部
        if ((ret = load_icode_read(fd,ph, sizeof(struct proghdr), phoff)) != 0)
            goto bad_cleanup_mmap;
        if (ph->p_type != ELF_PT_LOAD)
            continue;
        if (ph->p_filesz > ph->p_memsz){
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0)
            continue;
        vm_flags = 0, perm = PTE_U; // 建立虚拟地址与物理地址之间的映射
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        if (vm_flags & VM_WRITE) perm |= PTE_W;
        if ((ret = mm_map(mm,ph->p_va,ph->p_memsz,vm_flags,NULL)) != 0)
            goto bad_cleanup_mmap;
        off_t offset = ph->p_offset;
        size_t off,size;
        uintptr_t start = ph->p_va,end,la = ROUNDDOWN(start,PGSIZE);

        ret = -E_NO_MEM;

        // 复制数据段和代码段
        end = ph->p_va + ph->p_filesz; // 计算数据段和代码段的终止地址
        while (start < end){
            if (( page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL){
                ret = -E_NO_MEM;
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off , la += PGSIZE;
            if (end < la)
                size -= la - end;
            // 每次读取size大小的块，直至全部读完
            if (( ret = load_icode_read(fd,page2kva(page) + off, size, offset)) != 0)
                goto bad_cleanup_mmap;
            start += size, offset += size;

            // 建立bss段
            end = ph->p_va + ph->p_memsz;

            if (start < la){
                if (start == end)
                    continue;
                off = start + PGSIZE - la, size = PGSIZE - off;
                if (end < la)
                    size -= la - end;
                memset(page2kva(page) + off, 0, size);
                start += size;
                assert((end < la && start == end) || (end >= la && start == la))
            }
            while (start < end){
                if ((page = pgdir_alloc_page(mm->pgdir,la,perm)) == NULL){
                    ret = -E_NO_MEM;
                    goto bad_cleanup_mmap;
                }
                off = start - la, size = PGSIZE - off, la += PGSIZE;
                if (end < la)
                    size -= la - end;
                // 每次操作size大小的块
                memset(page2kva(page) + off, 0 ,size);
                start += size;
            }
        }
        sysfile_close(fd); // 关闭文件，加载程序结束

        // 4.建立相应的虚拟内存映射表
        vm_flags = VM_READ | VM_WRITE | VM_STACK;
        if (( ret = mm_map (mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
            goto bad_cleanup_mmap;
        assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
        assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
        assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
        assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
        // 5.设置用户栈
        mm_count_inc(mm);
        current->mm = mm;
        current->cr3 = PADDR(mm->pgdir);
        lcr3(PADDR(mm->pgdir));

        // 6.处理用户栈中传入的参数，其中argc对应参数个数，uargv[]对应参数的具体内容的地址
        //  说实话，这里有点绕，就相当于
        //    char **arg = (char **)(USTACKTOP - sizeof(char *) * (argc + 1));
        //    arg[0] = argc;
        //    int i;
        //    for (i = 1; i <= argc; i++) {
        //        arg[i] = kargv[i];
        uint32_t argv_size =0,i;
        for (i = 0; i < argc; i ++)
            argv_size += strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1) + 1;
        uintptr_t stacktop = USTACKTOP - (argv_size/sizeof(long)+1)*sizeof(long);
        char** uargv=(char **)(stacktop  - argc * sizeof(char *)); //栈顶减去 sizeof(char)*参数个数

        argv_size = 0;
        for (i = 0; i < argc; i++){ // 将所有参数取出来放置uargv
            uargv[i] = strcpy((char *) (stacktop + argv_size),kargv[i]);
            argv_size += strnlen(kargv[i],EXEC_MAX_ARG_LEN +1) +1;
        }

        stacktop = (uintptr_t)uargv - sizeof(int); //计算当前用户栈顶
        *(int *)stacktop = argc;
        // 7.设置进程的中断帧
        struct trapframe *tf = current->tf;
        memset(tf, 0, sizeof(struct trapframe));//初始化tf，设置中断帧
        tf->tf_cs = USER_CS;
        tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
        tf->tf_esp = stacktop;
        tf->tf_eip = elf->e_entry;
        tf->tf_eflags = FL_IF;
        ret = 0;
        //(8)错误处理部分
out:
        return ret;           //返回
bad_cleanup_mmap:
        exit_mmap(mm);
bad_elf_cleanup_pgdir:
        put_pgdir(mm);
bad_pgdir_cleanup_mm:
        mm_destroy(mm);
bad_mm:
        goto out;
    }
}
```


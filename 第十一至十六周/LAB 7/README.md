![image-20200823133644823](C:\Users\zhz\AppData\Roaming\Typora\typora-user-images\image-20200823133644823.png)

此实验算是对于进程运行的三状态的一次完美实现，下述词汇中，阻塞就代表进程的阻塞状态，唤醒就代表进程进入了就绪状态。

## 练习1: 理解内核级信号量的实现和基于内核级信号量的哲学家就餐问题

完成练习0后，建议大家比较一下（可用meld等文件diff比较软件）个人完成的lab6和练习0完成后的刚修改的lab7之间的区别，分析了解lab7采用信号量的执行过程。执行`make grade`，大部分测试用例应该通过。

请在实验报告中给出内核级信号量的设计描述，并说明其大致执行流程。

请在实验报告中给出给用户态进程/线程提供信号量机制的设计方案，并比较说明给内核级提供信号量机制的异同。

#### 1 描述内核级信号量的设计及执行流程

信号量是一种同步互斥机制的实现，普遍存在于现在的各种操作系统内核里。相对于spinlock 的应用对象，信号量的应用对象是在临界区中运行的时间较长的进程。等待信号量的进程需要睡眠来减少占用 CPU 的开销。

```c
struct semaphore {
int count;
queueType queue;
};
void semWait(semaphore s)
{
s.count--;
if (s.count < 0) {
/* place this process in s.queue */;
/* block this process */;
}
}
void semSignal(semaphore s)
{
s.count++;
if (s.count<= 0) {
/* remove a process P from s.queue */;
/* place process P on ready list */;
}
}
```

当多个进程可以进行互斥或同步合作时，一个进程会由于无法满足信号量设置的某条件而在某一位置停止，直到它接收到一个特定的信号（表明条件满足了）。为了发信号，就需要一个称作信号量的特殊变量。在理论中，通过信号量的P，V操作来进行互斥操作。每类资源设置一个信号量，其初值为1。P操作执行原语semWait(s)，通过信号量s接收信号；V操作执行原语semSignal(s)，通过信号量s传送信号。如果相应的信号仍然没有发送，则进程被阻塞或睡眠，直到发送完为止。

1. 信号量的结构体定义如下，由共享变量value和双向链表结构的等待队列组成

   共享变量value在此处提供一个信号量是否可获得，对应于视频中理论里的value，在value>0时，表示当前无进程在同步互斥运行，此进程可以运行。value<=0，表示当前有进程在同步互斥，此进程需加入等待队列，等待当前进程运行完毕。

   ```c
   typedef struct {
       int value;
       wait_queue_t wait_queue;
   } semaphore_t;
   
   typedef struct {
       list_entry_t wait_head;
   } wait_queue_t;
   ```

2. 信号量的初始化，将wait链表初始化为空闲链表

   ```c
   void
   sem_init(semaphore_t *sem, int value) {
       sem->value = value;
       wait_queue_init(&(sem->wait_queue));
   }
   ```

3. 等待队列的每个元素都是wait_t结构，proc为当前等待元素对应的进程，wait_queue标识当前等待元素所在的等待队列，wait_link建立当前等待元素与等待队列的链接

   ```c
   typedef struct {
       struct proc_struct *proc;
       uint32_t wakeup_flags;
       wait_queue_t *wait_queue;
       list_entry_t wait_link;
   } wait_t;
   ```

4. 作为同步互斥操作的底层支撑，一共有两个函数提供此接口

   + P操作函数down(semaphore_t *sem)

     ```c
     static __noinline uint32_t __down(semaphore_t *sem, uint32_t wait_state) {
         bool intr_flag;
         local_intr_save(intr_flag);  // 关闭中断
         if (sem->value > 0) {   // 获取信号量
             sem->value --;
             local_intr_restore(intr_flag);  // 开中断
             return 0;
         }
         wait_t __wait, *wait = &__wait;
         wait_current_set(&(sem->wait_queue), wait, wait_state); // 将当前进程加入等待队列
         local_intr_restore(intr_flag); // 开中断
     
         schedule(); // 进行调度
     
         local_intr_save(intr_flag); // 被唤醒，关中断
         wait_current_del(&(sem->wait_queue), wait); // 将当前进程移除等待队列
         local_intr_restore(intr_flag); // 开中断
     
         if (wait->wakeup_flags != wait_state) {
             return wait->wakeup_flags;
         }
         return 0;
     }
     ```

   - __up(semaphore_t *sem, uint32_t wait_state)

     ```c
     static __noinline void __up(semaphore_t *sem, uint32_t wait_state) {
         bool intr_flag;
         local_intr_save(intr_flag); // 关中断
         {
             wait_t *wait;
             // 如果当前等待队列里无等待进程，则value ++
             if ((wait = wait_queue_first(&(sem->wait_queue))) == NULL) {
                 sem->value ++;
             }
             else {
                 // 否则唤醒等待队列中的第一个等待进程并将其从等待队列中删除
                 assert(wait->proc->wait_state == wait_state); // 有进程等待
                 wakeup_wait(&(sem->wait_queue), wait, wait_state, 1);
             }
         }
         local_intr_restore(intr_flag); // 开中断
     }
     ```

     对照信号量的原理性描述和具体实现，可以发现二者在流程上基本一致，只是具体实现采用了关中断的方式保证了对共享资
     源的互斥访问，通过等待队列让无法获得信号量的进程睡眠等待。另外，我们可以看出信号量的计数器value具有有如下性
     质：
      value>0，表示共享资源的空闲数
      vlaue<0，表示该信号量的等待队列里的进程数
      value=0，表示等待队列为空

#### 2.请在实验报告中给出给用户态进程/线程提供信号量机制的设计方案，并比较说明给内核级提供信号量机制的异同

用户态进程/线程的信号量机制方案可以说和内核级信号量机制方案相差无几。同样是包含value和wait_quenu的数据结构，通过`__up`和`__down`两个函数来实现同步互斥操作。

不同点在于，用户态的信号量需要进入内核态实现系统调用

## 练习2: 完成内核级条件变量和基于内核级条件变量的哲学家就餐问题

### 管程和条件变量

引入了管程是为了将对共享资源的所有访问及其所需要的同步操作集中并**封装**起来。Hansan为管程所下的定义：“一个管程定义了一个数据结构和能为并发进程所执行（在该数据结构上）的一组操作，这组操作能同步进程和改变管程中的数据”。有上述定义可知，管程由四部分组成：

+ 管程内部的共享变量
+ 管程内部的条件变量
+ 管程内部并发执行的进程
+ 对局部于管程内部的共享数据设置初始值的语句。

局限在管程中的数据结构，只能被局限在管程的操作过程所访问，任何管程之外的操作过程都不能访问它；另一方面，局限在管程中的操作过程也主要访问管程内的数据结构。由此可见，管程相当于一个隔离区，它把共享变量和对它进行操作的若干个过程围了起来，所有进程要访问临界资源时，都必须经过管程才能进入，而管程每次只允许一个进程进入管程，从而需要确保进程之间互斥。

简单来说就是 管程是为了解决临界区内pv操作的配对的麻烦的 并发编程 使用信号量也pv必须是配对出现的 如果出现不匹配的情况就会出现错误

### 管程的数据结构

```c++
typedef struct monitor{
    semaphore_t mutex;     // 二值信号量，只允许一个进程进入管程，初始化为1
    semaphore_t next;       //配合cv，用于进程同步操作的信号量
    int next_count;         // 睡眠的进程数量
    condvar_t *cv;          // 条件变量cv
} monitor_t;  123456
```

管程中的成员变量mutex是一个二值信号量，是实现每次只允许一个进程进入管程的关键元素，确保了互斥访问性质。管程中的条件变量cv通过执行wait_cv，会使得等待某个条件C为真的进程能够离开管程并睡眠，且让其他进程进入管程继续执行；而进入管程的某进程设置条件C为真并执行signal_cv时，能够让等待某个条件C为真的睡眠进程被唤醒，从而继续进入管程中执行。管程中的成员变量信号量next和整形变量next_count是配合进程对条件变量cv的操作而设置的，这是由于发出signal_cv的进程A会唤醒睡眠进程B，进程B执行会导致进程A睡眠，直到进程B离开管程，进程A才能继续执行，这个同步过程是通过信号量next完成的；而next_count表示了由于发出singal_cv而睡眠的进程个数。

### condvar_t的定义

```c++
typedef struct condvar{
    semaphore_t sem; //用于发出wait_cv操作的等待某个条件C为真的进程睡眠
    int count;       // 在这个条件变量上的睡眠进程的个数
    monitor_t * owner; // 此条件变量的宿主管程
} condvar_t;12345
```

条件变量的定义中也包含了一系列的成员变量，信号量sem用于让发出wait_cv操作的等待某个条件C为真的进程睡眠，而让发出signal_cv操作的进程通过这个sem来唤醒睡眠的进程。count表示等在这个条件变量上的睡眠进程的个数。owner表示此条件变量的宿主是哪个管程。

### 条件变量（CV）

条件变量主要的操作有两个：wait和signal。wait用于进程因无法获取所需的资源时而将自己堵塞，signal用于另一个进程释放或生成相关资源后通知之前处于wait状态的进程而解除堵塞。

**cond_wait**的实现如下所示。首先将count加1，表示自己将要等待条件变量。然后判断管程的next_count是否大于0.大致分析一下：如果next_count大于0，说明是其他进程执行signal操作而将自己唤醒、并让出CPU给自己执行的，因此这里需要对管程的next信号量执行up操作，把发布signal信号的进程唤醒，不然对方将一直堵塞。如果next_count不大于0，说明没人因发布signal信号而堵塞，这时只需对管程的mutex执行up操作而退出临界区。接着对sem执行down操作，堵塞自己，让出CPU给其他进程。等到其他进程发布signal信号而唤醒本进程时，再将count减1，表示自己不再等待条件变量。

```c
void
cond_wait (condvar_t *cvp) {
    //LAB7 EXERCISE1: YOUR CODE
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
   cvp->count ++; // 因为当前进程未满足条件变量，故需要沉睡
   // 管程的next_count>0，说明是其他进程执行signal操作将自己唤醒
   if (cvp->owner->next_count > 0){
       up(&(cvp->owner->next)); // 将发布signal信号的进程唤醒
   }
   else{
       up(&(cvp->owner->mutex)); // 对管程的mutex唤醒，退出该进程的临界区
   }
   down(&cvp->sem); // 堵塞自己
   cvp->count --; // 表示自己不再等待条件变量

    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
}
```

**cond_signal**的实现如下所示。首先判断count是否大于0，若否则说明没有进程在等待条件变量，因此不作任何处理。若是，则说明有进程在等待条件变量，首先将管程的next_count加1，表示自己由于发布signal给其他进程解堵塞而将自己堵塞，然后对sem执行up操作，从而把之前等待信号量sem的进程唤醒，然后对管程的next执行down操作，从而将自己堵塞。等到其他进程唤醒本进程后，在将管程的next_count减1，表示自己不再等待next信号量。

```c
void 
cond_signal (condvar_t *cvp) {
   //LAB7 EXERCISE1: YOUR CODE
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
  if (cvp->count>0){ // 当前存在执行cond_wait而沉睡的进程
      cvp->owner->next_count ++; // 睡眠的进程总个数+1
      up(&(cvp->sem)); // 唤醒等待在cv.sem上睡眠的进程
      down(&(cvp->owner->next)); // 自己进入睡眠
      cvp->owner->next_count --; // 自己被唤醒，睡眠的进程数-1
  }

   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
}
```



### 用管程机制（基于条件变量）解决哲学家就餐问题

+ 内核线程initproc调用check_sync检查使用管程来解决哲学家就餐问题的方案。check_sync首先调用monitor_init初始化管程，然后调用kernel_thread创建5个内核线程，分别对应5位哲学家，并先将5位哲学家的state初始化为THINKING。此时无人占用叉子，RUNNABLE队列rq的元素依次为0,1,2,3,4，timer为空。（进程有三种状态，运行，就绪，阻塞。这里的RUNNABLE队列个人理解指的就是从运行队列变为就绪队列）

+ 5个哲学家线程依次执行philosopher_using_condvar，打印自己的ID，然后开始思考（实际上是调用do_sleep进行延时）。此时无人占用叉子，rq为空，timer依次是0,1,2,3,4.

  ```c
  void check_sync(void){
  
      int i;
  
      //check semaphore
      sem_init(&mutex, 1);
      for(i=0;i<N;i++){
          sem_init(&s[i], 0);
          int pid = kernel_thread(philosopher_using_semaphore, (void *)i, 0);
          // philosopher_using_semaphore函数中也存在do_sleep，个人猜测对应于第一条，初始化五个内核线程，并将它们进行排序区分
          if (pid <= 0) {
              panic("create No.%d philosopher_using_semaphore failed.\n");
          }
          philosopher_proc_sema[i] = find_proc(pid);
          set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
      }
  
      //check condition variable
      monitor_init(&mt, N); // 对管程初始化
      for(i=0;i<N;i++){
          state_condvar[i]=THINKING;
          int pid = kernel_thread(philosopher_using_condvar, (void *)i, 0); // 为五个哲学家创建内核线程
          if (pid <= 0) {
              panic("create No.%d philosopher_using_condvar failed.\n");
          }
          philosopher_proc_condvar[i] = find_proc(pid);
          set_proc_name(philosopher_proc_condvar[i], "philosopher_condvar_proc");
      }
  }
  
  int philosopher_using_condvar(void * arg) { /* arg is the No. of philosopher 0~N-1*/
    
      int i, iter=0;
      i=(int)arg;
      cprintf("I am No.%d philosopher_condvar\n",i);
      while(iter++<TIMES)
      { /* iterate*/
          cprintf("Iter %d, No.%d philosopher_condvar is thinking\n",iter,i); /* thinking*/
          do_sleep(SLEEP_TIME); // sleep_time = 10，这里是不是就开始出现时间轴了？
          phi_take_forks_condvar(i); 
          /* need two forks, maybe blocked */
          cprintf("Iter %d, No.%d philosopher_condvar is eating\n",iter,i); /* eating*/
          do_sleep(SLEEP_TIME);
          phi_put_forks_condvar(i); 
          /* return two forks back*/
      }
      cprintf("No.%d philosopher_condvar quit\n",i);
      return 0;    
  }
  ```

+ 哲学家0的延时最先结束，调用phi_take_forks_condvar试图拿起2把叉子就餐，整个过程如下：对mtp->mutex执行down操作进入临界区（以保证互斥执行此函数），将自己的state设置为HUNGRY，调用phi_test_condvar拿到2把叉子，将自己的state改为EATING，调用cond_signal唤醒之前由于执行cond_wait而堵塞的进程（由于没有，此处啥也没做）。然后对mtp->mutex执行up操作而离开临界区，开始吃饭（实际上是调用do_sleep来延时）。此时哲学家0占用叉子，rq为空，timer是1,2,3,4,0.

  ```c
  void phi_take_forks_condvar(int i) {
       down(&(mtp->mutex)); // 进入临界区
          state_condvar[i] = HUNGRY; // 记录哲学家i是否饥饿
          phi_test_condvar(i); // 试图拿到叉子
          if (state_condvar[i] != EATING){
              cprintf("phi_take_forks_condvar:%d didn't get fork and will wait\n",i);
              cond_wait(&mtp->cv[i]); // 未能成功拿到两把叉子就进入沉睡
          }
          if (mtp->next_count > 0) // 如果存在沉睡的进程就将其唤醒
              up(&(mtp->next));
          else
              up(&(mtp->mutex));
  
  }
  ```

+ 接着哲学家1延时结束，同样调用phi_take_forks_condvar试图拿起2把叉子就餐，但由于左边的叉子正在被哲学家0占用，哲学家1只能调用cond_wait进行等待。具体而言包括3步：将mtp->cv[1]->count加1，表示自己要等待该条件变量，然后对mtp->mutex执行up操作而离开临界区，最后对mtp->cv[1]->sem执行down操作而堵塞。此时哲学家0占用叉子，rq为空，timer是2,3,4,0.

+ 哲学家2的执行过程与哲学家0相同，哲学家3、4的执行过程和哲学家1相同。最终，哲学家0和2占用叉子，rq为空，timer为0,2。

+ 哲学家0延时结束，调用phi_put_forks_condvar同时放下2把叉子。首先对mtp->mutex执行down操作而进入临界区，将自己的state修改为THINKING，然后调用phi_test_condvar检查左右的哲学家状态。首先检查到左边的哲学家4满足就餐条件，于是将哲学家4的state修改为EATING，并对mtp->cv[4]执行cond_signal以唤醒哲学家4.具体而言包括3步：将mtp->next_count加1，表示唤醒哲学家4后自己要进入等待状态，然后对mtp->cv[4]->sem执行up操作，这将唤醒哲学家4，最后对mtp->next执行down操作而堵塞（阻塞自身）。这时哲学家2占用叉子，rq为4，timer为2.

+ 哲学家4被唤醒后，退出cond_wait，对mtp->next执行up操作，从而将哲学家0唤醒。然后哲学家4开始吃饭。（这里可以看到管程的“临时退出临界区”的特点：上一步中哲学家0进入临界区，发现哲学家4满足就餐条件后，将其唤醒，让哲学家4临时进入临界区吃饭，最后哲学家4再把哲学家0唤醒，让哲学家0继续执行。）此时哲学家2和4占用叉子，rq为0，timer为2,4.

+ 哲学家0继续检查右边的哲学家1，发现其不满足就餐条件，不作处理，然后对mtp->mutex执行up操作而退出临界区。最后哲学家0进入下一轮的思考。此时哲学家2和4占用叉子，rq为空，timer为2,4,0.

+ 哲学家2延时结束，调用phi_put_forks_condvar同时放下2把叉子。其执行流程与步骤6类似，只是哲学家2唤醒的是哲学家1.此时哲学家4占用叉子，rq为1，timer为4,0.

+ 哲学家1被唤醒后的执行流程与步骤7类似：退出cond_wait，对mtp->next执行up操作，从而将哲学家2唤醒。然后哲学家1开始吃饭。此时哲学家1和4占用叉子，rq为2，timer为4,0,1.

+ 哲学家2被唤醒后的执行流程与步骤8类似：继续检查出右边的哲学家3，发现其不满足就餐条件，不作处理，然后对mtp->mutex执行up操作而退出临界区。最后哲学家2进入下一轮的思考。此时哲学家1和4占用叉子，rq为空，timer为4,0,1.

+ 哲学家4延时结束，调用phi_put_forks_condvar同时放下2把叉子，其执行流程与步骤6类似：首先检查到左边的哲学家3满足就餐条件，于是将其唤醒，并将自己堵塞。此时哲学家1占用叉子，rq为3，timer为0,1.

+ 哲学家3被唤醒后的执行流程与步骤7类似：退出cond_wait，对mtp->next执行up操作，从而将哲学家4唤醒。然后哲学家3开始吃饭。此时哲学家1和3占用叉子，rq为4，timer为0,1,3.
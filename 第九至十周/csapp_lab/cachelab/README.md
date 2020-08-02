模拟高速缓存cache的实现。

### **Cache结构体**

该lab中，cache的结构被设计为

```c
struct sCache
{
    int vaild; //是否空闲
    int tag; //标记位
    int count; //访问计数
};
```

+ vaild代表该缓存行是否被占用，也就是是否有数据存入，被占用就设置为1反之为0。
+ tag代表该存放的数据是主存储器的哪一组群，如下图

![image-20200731200146283](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200731200146283.png)

+ count就是hit的命中次数

同时，还对Cache的排列形成一个矩阵,形成了如下图的一个矩阵结构

```c
#*define* *IDX*(m,n,E) m *E +n //第m组 第n行，E为每组行数
Cache *cache = (Cache *) malloc(16 * s_pow * E); //表示缓存的结构
```

![image-20200731200736958](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200731200736958.png)

### 输入处理

做到命令行输入的解析

### **Cache**的模拟

+ 输入数据指定需要访问的地址寄存器
+ 分析输入的地址，并判断是否命中
+ 如果命中，则hits++，并更新LRU值
+ 如果不命中就先判断是否有空闲缓存块，无空闲块就启用LRU算法
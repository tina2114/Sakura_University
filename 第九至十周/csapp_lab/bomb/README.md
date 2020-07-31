### phase_1

一开始会有一个输入，那么就先输入一个'1'来进行测试。

gdb动调，会发现来到了

![image-20200719170722110](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719170722110.png)

进入strings_not_equal来查看

可以观察到，输入的'1'原本在rdi的位置，字符串在rsi的位置，然后依次被赋给了rbx和rbp，进入string_length函数

![image-20200719171009251](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719171009251.png)

此处据调试就是该关卡的关键地方了，此时我们输入的是'1'

![image-20200719171742091](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719171742091.png)

此时存在一个cmp r12d, eax。据分析，eax就是它本身的字符串，r12d就是我们输入的字符串长度，那这关就解决了。

![image-20200719171851532](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719171851532.png)

复制它的字符串，通关~

Border relations with Canada have never been better.

### phase_2

此处的__isoc99_sscanf@plt函数就是对你输入的内容格式进行检测，不通过就触发炸弹

![image-20200719175212224](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719175212224.png)

此处通过format的'%d %d %d %d %d %d'就可以判断内容格式是数字空格数字空格这样，一共六个数字。

在通过这层检测后，就来到了下面的循环检测，此处检测的是数字之间的关系

![image-20200719182309126](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719182309126.png)

0x400f17至0x400f1e就是关键地方了，你输入的内容储存在栈中，通过mov一个个取出来赋给eax，eax*2，再与栈中下一个数字比较。

总结来说，就是一共六个数字，依次的倍数为2的关系。

1 2 4 8 16 32

### phase_3

此处依然存在一个输入格式，数字空格数字空格

![image-20200719194340202](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719194340202.png)

然后会对你的第一个输入的数字进行判断，是否超过7，<7的话就继续执行。

第一个数字在1~6间，每个都对第二个输入的数字存在一个设定值，不同就bomb。

主要是这儿，也就是对你输入的第二个数字进行比对。此处第一个数字是1

![image-20200719194738668](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719194738668.png)

故此，就是1 311

### phase_4

同理，存在与phase_3相同的判断

![image-20200719195426895](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719195426895.png)

接着此处存在一个func4函数，对你的第一个数字进行判断

![image-20200719195922240](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719195922240.png)

此处借用了sar(算术右移)，eax也就是传入的edx，循环递归，得7，3，1

![image-20200719200007867](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719200007867.png)

并用跳转使得，第一个数小于7时不断递归且 `%ecx`小于等于第一个数，而跳转后即在下面的代码中会要求 `%ecx` 大于等于第一个数，否则递归，递归过程会设置eax使得其不为 0 ，所以只有当第一数等于 `%ecx` 时即 1 ， 3 , 7 时才能使最后返回值为 0 

此处判断第二个数字是否为0

![image-20200719200333969](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719200333969.png)

故此，7 0

### parse_5

首先会存在一个对你输入的字符串长度的判断，此处判断是length = 6

![image-20200719201246313](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719201246313.png)

此处就是将内容放到一个数组，接着每个进行&0xF操作

![image-20200719201414994](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200719201414994.png)

操作完后，以此四位为偏移量访问内存中的数据，将数据存到栈上。

也就是说，六位字符的ascll码的第二位必须分别是9,F,E,5,6,7

故此，ionefg

### parse_6

刚开始也可以说是同理，需要输入6个数字。

接下来就会进入一个双重while循环，外层要求这六个数字每个都不能>6，且在1-6的范围。内层要求每个数字不能相同。

接着是a[i]都变为7-a[i]，也就是反着来。

然后进入一个链表，链表中链接起六个设定值，分别与进行处理后的数字存在映射，且需要从大到小进行排序。

| 输入值 | 所得node |
| ------ | -------- |
| 6      | 332      |
| 5      | 168      |
| 4      | 924      |
| 3      | 691      |
| 2      | 477      |
| 1      | 433      |

故此，输入4 3 2 1 6 5
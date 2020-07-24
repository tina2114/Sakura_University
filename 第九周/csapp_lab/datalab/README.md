### bitXor

x^y，只用~，&

离散真值表

```c++
int bitXor(int x, int y) {
   return ~(~x&~y)&~(x&y);
}
```

### tmin

求二进制补码最小值

```c++
int tmin(void) {
  return 1<<31;
}
```

### isTmax

判断x是否为最大的补码，是返回0，不是返回1

```c++
int isTmax(int x) {
  return !(x^(0x80000000-1));
}
```

### all0ddBits

判断二进制奇数位是否全为1

先与0xAAAAAAAA进行'&'，将偶数位全置零，再'^'0xAAAAAAAA，检测奇数位是否全为1

```c++
int allOddBits(int x) {
    int i = 0xAAAAAAAA;
    return !((x&i)^i);
}
```

### negate

取反

```c++
int negate(int x) {
    return ~x+1;
}
```

### isAsciiDigit

判断x是否在[0x30,0x39]间

0<=x-0x30 ，x-0x39<=0

即x减去两边边界，取符号位。

0x30<=x<=0x39，左边符号位为0，右边为1

x<0x30，两边符号位皆为1

x>0x39，两边符号位皆为0

故此，!左边，是为了防止第二种情况return 1的发生

```c++
int isAsciiDigit(int x) {
    return (!((x+~0x30+1)>>31))&((x+~0x39+1)>>31);
}
```

### conditional

三元运算符，x为0输出z，不为0输出y

得(a&y)|(b&z)

当x为0时，a=0x0，b=0xFFFF FFFF，而当x为非0值时，a=0xFFFF FFFF，b=0x0。

a=!x+~1+1，b=~!x+1

```c++
int conditional(int x, int y, int z) {
    return ((!x+~1+1)&y)|((~!x+1)&z);
}
```

### isLessOrEqual

判断是否x <= y

左边判断符号位相异，x<0才成立
右边判断符号位相同，y-x符号位为0才成立

```c++
int isLessOrEqual(int x, int y) {
    int a=x>>31; //x符号位
    int b=y>>31;    //y符号位
    int c=a+b;  //0，两个正，1，一正一负，2，两负
    int d=((y+~x+1)>>31)&1; //y-x，比较二者大小，0 x<=y,1 x>=y
    return (c&(a&1))|((~c)&!d);
}
```

### logicalNeg

实现!x，非0！后为0，0！后为1

这题其实只用分析符号位的变化即可

正数符号位为0，！后return 0,即直接>>31就可
负数符号位为1，！后return 0,即取反再>>31就可
 ~x+1，取其相反数，符号位相反

但存在两种情况，取相反，符号位相同

1. x=0x0   
2. x=0x80000000
  需去除第二种情况，用到~x&~(~x+1)

```c++
int logicalNeg(int x) {
    return ((~x&~(~x+1))>>31)&1;
}
```

### howManyBits

算出二进制中最高位

利用二分法，负数直接取反

```c++
int howManyBits(int x) {
    int binary16,binary8,binary4,binary2,binary1,binary0;
    int sign=x>>31;
    // 右边为正数，负数为左右的|
    x = (sign&~x)|(~sign&x); //正不变，负数取反

    binary16 = (!!(x>>16))<<4; //高十六位是否有1
    x = x>>binary16; //有则右移16位
    binary8 = (!!(x>>8))<<3;
    x = x>>binary8;
    binary4 = (!!(x>>4))<<2;
    x = x>>binary4;
    binary2 = (!!(x>>2))<<1;
    x = x>>binary2;
    binary1 = (!!(x>>1));
    x = x>>binary1;
    binary0 =x;
  return binary0+binary1+binary2+binary4+binary8+binary16+1;
}
```

### float

#### 浮点数

**说明**

在IEEE标准中，浮点数在内存中的表示是将特定长度的连续字节的所有二进制位按特定长度划分为符号域(s)，指数域(e)和尾数域(m)三个连续域。

**float**

float类型在内存中占用的位数为: 1+8+23=32bits

**double**

1+11+52=64bits



第一位s代表符号为，1代表负数，0代表正数。

第二个域是指数域，对于单精度float类型，指数域有８位，可以表示　0-255个指数值。但是，指数可以表示为正或负，为了处理这种情况，实际指数值还需要减去一个偏差值为-127的偏差(Bias)。例如，float中指数域的值为64，则表示实际指数值为-63。

第三个域为尾数域，对于单精度float类型，尾数域有23位。

第二个域中的指数值则规定了小数点在尾数串中的位置，默认情况下小数点位于尾数串首位之前。　

例如一个单精度尾数域中的值为: 00001001000101010101000，指数值为　-1,则该float数即为：.000001001000101010101000,如果为+1，则该float 数值为:0.0001001000101010101000。



#### floatScale2

2*浮点数

如果指数+1之后为指数为255则返回原符号无穷大，否则返回指数+1之后的原符号数。

```c++
unsigned floatScale2(unsigned uf) {
    int exp = (uf>>23) &0xff; // 8位阶码
    int rtexp = exp+1;
    if(!exp) // exp=0
        return (uf&0xf0000000) + ((uf&0x7fffff)<<1);
    else if(!(exp^0xff))
        return uf;
    else if(rtexp&(1<<8))
        return ((uf>>31)<<31) + (0xff<<23);
    else
        return (uf&(0x807fffff)) + (rtexp<<23);
}
```

#### floatFloat2Int

浮点数转整数

```c++
int floatFloat2Int(unsigned uf) {
    int e = (uf >> 23) & 0xff; //阶码
    int f = uf & 0x7fffff;    //尾码
    int tag = uf & 0x80000000; //符号位
    if (e<=126) //小于0
        return 0;
    else if (e>157) //上溢,因为<<31以上会将符号位覆盖
        return 0x80000000;
    else
    {
        int s = e - 127;
        f = f + 0x800000;
        if (s >= 23)
        {
            int r = f << (s-23);
            if (tag)
                return -r;
            else
                return r;
        }
        else
        {
            int r = (f >> (23 - s));
            if(tag)
                return -r;
            else
                return r;
        }
    }
}
```

#### floatPower2

求2的x次方

```c++
unsigned floatPower2(int x) {
    unsigned INF = 0xff << 23; // 阶码全1
    int e = 127 + x;    // 得到阶码
    if (x < 0) // 阶数小于0直接返回0
        return 0;
    if (e >= 255) // 阶码>=255直接返回INF
        return INF;
    return e << 23;
    // 直接将阶码左移23位，尾数全0，规格化时尾数隐藏有1个1作为底数
}
```
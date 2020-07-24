首先呢，是定义了FLEX的版本号

![image-20200615172813321](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615172813321.png)

针对不同平台，不同编译器的问题进行处理

![image-20200615173017641](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615173017641.png)

定义了在不同C标准下的各种整数类型以供后续使用。这其中为了防止类型被用户代码冲突，此处typedef了一些类型

![image-20200615173050584](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615173050584.png)

而后定义了buffer的结构

##### #buffer

![image-20200615174633782](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615174633782.png)

![image-20200615174702525](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615174702525.png)



在action匹配前的工作

![image-20200615174954410](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615174954410.png)



##### #input

虽然DFA在状态转移的过程中一次前进一个字符，但是为了提高IO效率，实际从文件读取的时候一般是批量往缓冲区读入的。如果有需要微调这个读入策略的需求，可以通过定义`YY_INPUT`宏来实现。当然，在此之前还会依据上面buffer结构中的yy_is_interactive来判断输入源。

此处为从文件中读取

![image-20200615175220910](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615175220910.png)

此处为从交互界面中读取

![image-20200615175511099](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615175511099.png)

#### DFSA分析

##### #DFA状态转移表结构分析

首先给出我们的test.l。

```cool
%%
%%
```

也就是空编译状态，我们选择`flex test.l`进行默认的编译状态，会看到如下的状态表

```
static yyconst flex_int16_t yy_accept[6]
static yyconst YY_CHAR yy_ec[256]
static yyconst YY_CHAR yy_meta[2]
static yyconst flex_uint16_t yy_base[7]
static yyconst flex_int16_t yy_def[7]
static yyconst flex_uint16_t yy_nxt[5]
static yyconst flex_int16_t yy_chk[5]
```

此处是经过压缩的表信息，默认选项中，flex会输出压缩后的状态转移表，因为完整版本的矩阵是Nx128大小（其中N是自动机的状态数，128则是字符集大小），如果不经压缩的话，会带来不必要的空间开销。



因此，为了输出完整版表，我们在调用flex的时候需要增加`-Cf`参数。

```
flex -Cf test.l
```

就会得到如下的表，详情可以参考https://pastebin.com/VYqCwCh5

```
static yyconst flex_int16_t yy_nxt[][128];
```

同时，使用 `-vC`能够显示DFA的分析数据

![image-20200615191632109](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615191632109.png)

这里使用的是空编译的文件，可以发现，初始状态下就存在了6个NFA的状态和4个DFA的状态。

此处不讨论NFA状态，因为flex会把规则转换为NFA，再转换为DFA，中间会有状态化简。

具体转化规则如下:

1. nfa状态机起始状态, 在flex中就是scset和scbol.

  2. 使用epsclosure函数找出所有nfa通过epsilon可到达的状态.

  3. 使用snstods把上述的nfa集合生成一个新的dfa状态或者返回相同的旧的dfa状态

  4. 扫描dfa状态集中的每一个的状态, 使用sympartition区分出dfa的转换字符

  5. 使用symfollowset收集dfa状态的相应输出字符的nfa状态集合

  6. 在使用epsclosure函数找出上述集合中所有nfa通过epsilon可到达的状态.

  7. 使用snstods把上述的nfa集合生成一个新的dfa状态或者返回相同的旧的dfa状态

  8. 使用dfa状态和输出字符集以及输出状态集生成表格.
     base为相应dfa状态的字符集起始
     nxt为字符集转换表
     chk为检查表
     def为默认转换表, 即输入字符不在字符集转换表中时,dfa如何转.

   9. 重复步骤4.

        

这里的四个基础DFA状态分别是 开始状态(start) , 接收状态(accept) , 错误状态(error) , 停机状态。

前三个状态都好理解，而第四个停机状态的含义是，一旦状态机到达这个状态就“死”了，它再也不能离开这个状态。

举个例子

![image-20200615194803225](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615194803225.png)

用`flex -vC test.l`编译后有8个DFA，也就基础四个加上`a(b|c)d*e+`规则中的4个状态，产生了如下图示

![image-20200615195007494](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615195007494.png)

以及如下选择表

![image-20200615195035696](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20200615195035696.png)



在状态1的时候，如果遇到(b|c)以外的字符，就全部跳到停机状态。这意味着在状态1，接收这些未定义的字符，会导致DFA死掉。

##### #DFA工作流程分析

接下来就是scanner的主入口

```
YY_DECL
{
    register yy_state_type yy_current_state;
    register char *yy_cp, *yy_bp;
    register int yy_act;

    if ( !(yy_init) )
        {
        (yy_init) = 1;

        if ( ! (yy_start) )
            (yy_start) = 1; /* 定义起始状态 */

        if ( ! yyin )
            yyin = stdin;   /* 定义输入文件 */

        if ( ! yyout )
            yyout = stdout; /* 定义输出文件 */

        if ( ! YY_CURRENT_BUFFER ) { /* 提供对于缓冲区的微调功能 */
            yyensure_buffer_stack ();
            YY_CURRENT_BUFFER_LVALUE =
                yy_create_buffer(yyin,YY_BUF_SIZE );
        }

    {
    while ( 1 )     /* 主循环，直至读取到EOF */
        {
        // 下面这些与字符指针相关的地方，都是在提供yytext的功能
        // 即当匹配成功后能够取出匹配到的字符串
        yy_cp = (yy_c_buf_p);

        /* Support of yytext. */
        *yy_cp = (yy_hold_char);

        /* yy_bp points to the position in yy_ch_buf of the start of
         * the current run.
         */
        yy_bp = yy_cp;

        yy_current_state = (yy_start);
yy_match:
        /* 在这里不断进行状态转移，直至无法继续转移 */
        /* 注意YY_SC_TO_UI是一个宏，功能是安全地将字符转换为对应的无符号整型 */
        /* 本质上其实就是在图中，根据当前状态，以及下一个字符，来进行转移 */
        while ( (yy_current_state = yy_nxt[yy_current_state][ YY_SC_TO_UI(*yy_cp) ]) > 0 )
            {
            if ( yy_accept[yy_current_state] )
                {
                (yy_last_accepting_state) = yy_current_state;
                (yy_last_accepting_cpos) = yy_cp;
                }

            ++yy_cp;
            }

        yy_current_state = -yy_current_state;

yy_find_action:
        /* 然后检查是否停止在了接受状态 */
        yy_act = yy_accept[yy_current_state];

        YY_DO_BEFORE_ACTION;

do_action:  {...} //这里主要是处理读取到EOF的情况

case 1: /* 由此可见，在yy_accept中，值为1的就是接受状态，其他状态都不合法 */
{return true;}
    YY_BREAK
case 2:
{return false;}
    YY_BREAK
case 3:
ECHO;
    YY_BREAK
case YY_STATE_EOF(INITIAL):
    yyterminate();

    case YY_END_OF_BUFFER:

    default:
        YY_FATAL_ERROR(
            "fatal flex scanner internal error--no action found" );
    } /* end of action switch */
        } /* end of scanning one token */
    } /* end of user's declarations */
} /* end of yylex */
```

其DFA的伪代码可以抽象成

```
state= 0; 
get next input character
while (not end of input) {
    depending on current state and input character
        match: /* input expected */
            calculate new state; get next input character
        accept: /* current pattern completely matched */
            state= 0; perform action corresponding to pattern
        error: /* input unexpected */
            state= 0; echo 1st character input after last accept or error;
            reset input to 2nd character input after last accept or error;
}
```

总结一下，也就是从start状态，通过匹配每个读入的字符结合转移表来跳转状态，然后在无法转移或者字符已经读完的时候，判断一下是否停在了接收状态，然后进行对应的用户定义的代码规则

##### 状态转移矩阵的压缩

上文中已经提到，如果不加`-Cf`参数，flex会生成压缩版本的状态转移矩阵。

```
yyconst flex_int16_t yy_accept[10]
yyconst YY_CHAR yy_ec[256]
yyconst YY_CHAR yy_meta[7]
yyconst flex_uint16_t yy_base[12]
yyconst flex_int16_t yy_def[12]
yyconst flex_uint16_t yy_nxt[19]
yyconst flex_int16_t yy_chk[19]
```

此时的状态转移循环如下所示：

```
yy_current_state = (yy_start);
yy_match:
do
    {
    register YY_CHAR yy_c = yy_ec[YY_SC_TO_UI(*yy_cp)] ;
    // 这个if语句就不影响状态转移，只是为了记录状态
    if ( yy_accept[yy_current_state] )
        {
        (yy_last_accepting_state) = yy_current_state;
        (yy_last_accepting_cpos) = yy_cp;
        }
    while ( yy_chk[yy_base[yy_current_state] + yy_c] != yy_current_state )
        {
        yy_current_state = (int) yy_def[yy_current_state];
        // 注意这个22是Magic Number，是会发生变化的
        if ( yy_current_state >= 22 )
            yy_c = yy_meta[(unsigned int) yy_c];
        }
    yy_current_state = yy_nxt[yy_base[yy_current_state] + (unsigned int) yy_c];
    ++yy_cp;
    }
// 这个43也是Magic Number
while ( yy_base[yy_current_state] != 43 );
```

#### 总结

flex最核心的就是yylex()函数，自动从输入文件读入数据，进行匹配，并返回对应token。不断的循环调用yylex()来匹配输入流来实现`规则->行为`的模式。通过压缩表信息来达到优化的效果。



#### reference

http://www.cs.man.ac.uk/~pjj/cs211/ho/node6.html

https://www.cnblogs.com/ninputer/archive/2011/06/12/2078671.html

https://blog.finaltheory.me/research/Flex-Tricks.html

https://blog.csdn.net/joans123/article/details/7429948
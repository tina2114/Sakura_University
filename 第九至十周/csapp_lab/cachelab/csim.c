#include "cachelab.h"
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define IDX(m,n,E) m *E +n  // 第m组 第n列，E为每组行数
#define MAXSIZE 30
char input[MAXSIZE]; // 保存每行的字符串
int hit_count =0, miss_count=0, eviction_count =0;
int debug=0; //参数v的标记

// 一个缓存行的结构
struct sCache
{
    int vaild; //是否空闲
    int tag; //标记位
    int count; //访问计数
};
typedef struct sCache Cache;

// 16进制转10进制
int hextodec(int c);

//缓存加载
void load(int count, unsigned int setindex, unsigned int tag,
          unsigned int offset, unsigned int size, double s_pow,
          unsigned int E, double b_pow, Cache *cache);

int main(int argc, char *argv[])
{
    const char *str = "";
    int opt = 0; //保存参数
    unsigned int s = 0, E = 0, b = 0; //组的位置，每组行数，和块数目的位数
    double  s_pow = 0, b_pow = 0; // 组数 块数
    char *t = ""; //trace文件

    // getop:每次检查一个命令行参数
    while ((opt = getopt(argc,argv,"hvs:E:-b:-t"))!=-1)
    {
        switch (opt)
        {
            case 's':
                s = atoi(optarg);
                s_pow = 1 << s; //组数
                break;
            case 'E':
                E = atoi(optarg); //每组行数
                break;
            case 'b':
                b = atoi(optarg);
                b_pow = 1 << b; //每行块数
                break;
            case 't':
                t = optarg; // trace文件
                break;
            case 'v':
                debug = 1; // v标记
                break;
            case 'h':
                printf("%s",str); //help信息
                return 0;
                break;
            default: // '?'
                fprintf(stderr,"Usage: %s [-hv] -s <num> -E<num> -b <num> -t >file>\n",argv[0]);
                exit(EXIT_FAILURE);
        }
    }

    Cache *cache = (Cache *) malloc(16 * s_pow * E); //表示缓存的结构
    for (int i =0; i < s_pow * E ; i++)
    {
        //init
        cache[i].vaild = 0;
        cache[i].tag = 0;
        cache[i].count = 0;
    }
    FILE *fp = fopen(t,"r"); //以只读打开trace文件
    int count = 0; //每次访问缓存时更新缓存行的计数

    // 分析 trace 文件的每一行
    while (fgets(input,MAXSIZE,fp))
    {
        int op = 0; //访问缓存的次数
        unsigned int offset = 0, tag = 0,
                setindex = 0; //缓存行的块索引，tag标记,组号
        char c;
        int cflag = 0; //是否有逗号的标记
        unsigned int address = 0, size = 0; //访问缓存的地址和大小
        count++;

        for (int i = 0; (c = input[i]) && (c != '\n'); i++)
        {
            if (c == ' '){
                continue; //跳过空格
            }else if (c == 'I'){
                op = 0; // 指令加载时不访问缓存
            }else if (c == 'L'){
                op = 1; // 数据加载时访问缓存一次
            }else if (c == 'S'){
                op = 1; // 数据存储时访问缓存一次
            }else if (c == 'M'){
                op = 2; // 数据修改时访问缓存两次,一次加载和一次缓存
            }else {
                // 是否有逗号
                if (cflag){
                    size = hextodec(c); //有逗号时接下来的字符为size
                }
                else{
                    address = 16 * address + hextodec(c); //无逗号时接下来的字符为address
                }
            }
        }
        // 从address取出offset
        for (int i = 0; i < b ; i++)
        {
            offset = offset * 2 + address % 2;
            address >>= 1;
        }
        // 从address 取出setindex
        for (int i = 0; i<s; i++)
        {
            setindex = setindex * 2 + address % 2;
            address >>=1;
        }
        // 从address 取出tag
        tag = address;

        //根据次数访问缓存
        if (debug && op != 0)
        {
            printf("\ns",input);
        }
        if (op == 1)
        {
            Load(count, setindex,tag,offset,size,s_pow,E,b_pow,cache);
        }
        if (op == 2)
        {
            Load(count, setindex,tag,offset,size,s_pow,E,b_pow,cache);
            hit_count++;
            if(debug){
                printf("hit");
            }
        }
    }
    free(cache);
    fclose(fp);
    // optind 记录处理的参数总数
    if (optind > argc){
        fprintf(stderr,"Expected argument after options\n");
        exit(EXIT_FAILURE);
    }
    if (debug){
        printf("\n");
    }
    printSummary(hit_count,miss_count,eviction_count);
    return 0;
}

/* 将 16 进制转为 10 进制数 */
int hextodec(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    }
    if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10;
    }
    return 0;
}

// 缓存加载
void Load(int count, unsigned int setindex, unsigned int tag,
          unsigned int offset, unsigned int size, double s_pow, unsigned int E,
          double b_pow, Cache *cache)
{
    // 根据所得到组号 setindex , 标记位 tag, 与 cache 数组中的 tag 比较，如果存在该 tag
    // 的缓存行就 hit
    for (int i = 0; i < E; i++) {
        if (cache[IDX(setindex, i, E)].vaild && tag == cache[IDX(setindex, i, E)].tag) {
            cache[IDX(setindex,i,E)].count = count;
            hit_count++;
            if (debug){
                printf("hit");
            }
            return;
        }
    }

    // 缓存不命中，且cache存在空闲行，选择一个空闲行保存tag
    miss_count++;
    if (debug){
        printf("miss");
    }
    for (int i = 0; i < E; i++){
        if (!cache[IDX(setindex,i,E)].vaild){
            cache[IDX(setindex,i,E)].tag = tag;
            cache[IDX(setindex,i,E)].count = count;
            cache[IDX(setindex,i,E)].vaild = 1;
            return;
        }
    }

    // 缓存行已满，此处使用LRU算法，通过循环找出最不常用的那行
    int mix_index = 0, mix_count = 1000000000;
    for (int i = 0; i < E; i++){
        if (cache[IDX(setindex,i,E)].count < mix_count){
            mix_count = cache[IDX(setindex,i,E)].count;
            mix_index = i;
        }
    }

    eviction_count++;
    if (debug) {
        printf(" eviction");
    }

    cache[IDX(setindex, mix_index, E)].tag = tag;
    cache[IDX(setindex, mix_index, E)].count = count;
    cache[IDX(setindex, mix_index, E)].vaild = 1;

    return;
}




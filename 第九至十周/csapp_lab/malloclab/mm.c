/*
 * mm-naive.c - The fastest, least memory-efficient malloc package.
 * 
 * In this naive approach, a block is allocated by simply incrementing
 * the brk pointer.  A block is pure payload. There are no headers or
 * footers.  Blocks are never coalesced or reused. Realloc is
 * implemented directly using mm_malloc and mm_free.
 *
 * NOTE TO STUDENTS: Replace this header comment with your own header
 * comment that gives a high level description of your solution.
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>

#include "mm.h"
#include "memlib.h"

/*********************************************************
 * NOTE TO STUDENTS: Before you do anything else, please
 * provide your team information in the following struct.
 ********************************************************/
team_t team = {
    /* Team name */
    "ateam",
    /* First member's full name */
    "Harry Bovik",
    /* First member's email address */
    "bovik@cs.cmu.edu",
    /* Second member's full name (leave blank if none) */
    "",
    /* Second member's email address (leave blank if none) */
    ""
};
char * heap_listp;
/* single word (4) or double word (8) alignment */
#define ALIGNMENT 8

/* rounds up to the nearest multiple of ALIGNMENT */
// 与8bit对齐
#define ALIGN(size) (((size) + (ALIGNMENT-1)) & ~0x7)


#define SIZE_T_SIZE (ALIGN(sizeof(size_t)))
#define WSIZE 4
#define DSIZE 8
#define CHUNKSIZE (1<<12)  // 0x40000
#define MAX(x.y) ((x)>(y)?(x):(y))

// 将大小和分配的位打包成一个字
#define PACK(size,alloc) ((size) | (alloc))

// 在地址处读写一个单词
#define GET(p) (*(unsigned int *) (p))
#define PUT(p,val) (*(unsigned int *)(p) = (val))

// 在地址处读取size和alloc(也就是size位和flag位)
#define GET_SIZE(p) ((GET(p) & ~0x7))
#define GET_ALLOC(p) (GET(p) & 0x1)

// 获取堆块的头部和尾部
#define HDRP(bp) ((char *)(bp) - WSIZE)
#define FTRP(bp) ((char *)(bp) + GET_SIZE(HDRP(bp)) - DSIZE)

// 获取下一个和上一个堆块的地址
#define NEXT_BLKP(bp) ((char *)(bp) + GET_SIZE(((char *) (bp) - WSIZE)))
#define PREV_BLKP(bp) ((char *)(bp) - GET_SIZE(((char *) (bp) - DSIZE)))

//获取块中记录的fd和bk
#define PREV_LINKED_BLKP(bp) ((char *)(bp))
#define NEXT_LINKED_BLKP(bp) ((char *)(bp)+WSIZE)
/* 
 * mm_init - initialize the malloc package.
 */
// 初始化空闲链表
int mm_init(void)
{
    if (heap_listp = mem_sbrk(14 * WSIZE) == (void *)-1) return -1;
    PUT(heap_listp,0); // heap_listp = 0
    PUT(heap_listp + (1*WSIZE),NULL); // 8-16
    PUT(heap_listp + (2*WSIZE),NULL); // 16-32
    PUT(heap_listp + (3*WSIZE),NULL); // 32-64
    PUT(heap_listp + (4*WSIZE),NULL); // 64-128
    PUT(heap_listp + (5*WSIZE),NULL); // 128-256
    PUT(heap_listp + (6*WSIZE),NULL); // 256-512
    PUT(heap_listp + (7*WSIZE),NULL); // 512-1024
    PUT(heap_listp + (8*WSIZE),NULL); // 1024-2048
    PUT(heap_listp + (9*WSIZE),NULL); // 2048-4096
    PUT(heap_listp + (10*WSIZE),NULL); // 4096..

    PUT(heap_listp + (11*WSIZE),PACK(DSIZE,1));
    PUT(heap_listp + (12*WSIZE),PACK(DSIZE,1));
    PUT(heap_listp + (13*WSIZE),PACK(0,1));
    list_table = heap_listp;
    heap_listp += (12*WSIZE);
    //扩展4096字节空间
    if (extend_heap(CHUNKSIZE/WSIZE) == NULL)
        return -1;
    return 0;
}


static void *extend_heap(size_t words){
    char *bp
    size_t size;

    size = (words % 2)?(words+1)*WSIZE:words*WSIZE; // 维持偶数块
    if ((long)(bp = mem_sbrk(size)) == -1) return NULL;

    PUT(HDRP(bp),PACK(size,0)); // 4096字节的空间大小
    PUT(FTRP(bp),PACK(size,0));
    PUT(HDRP(NEXT_BLKP(bp)),PACK(0,1)); // 结尾块
    PUT(PREV_LINKED_BLKP(bp),NULL); // 将fd和bk清0
    PUT(NEXT_LINKED_BLKP(bp),NULL);

    return immediate_coalesce(bp);
}

static void place(void *bp, size_t asize){
    size_t csize = GET_SIZE(HDRP(bp)); //获取匹配的空闲块size

    if ((csize - asize) >= (2*DSIZE)){
        PUT(HDRP(bp),PACK(asize,1));
        PUT(FTRP(bp),PACK(asize,1));
        // 空闲块分割，重新规划size
        bp = NEXT_BLKP(bp);
        PUT(HDRP(bp),PACK(csize-asize,0));
        PUT(FTRP(bp),PACK(csize-asize,0));
        PUT(PREV_LINKED_BLKP(bp),NULL);
        PUT(NEXT_LINKED_BLKP(bp),NULL);
        add_block(bp,csize-asize);
    }
    else {
        delete_block(bp,GET_SIZE(HDRP(bp)));
        PUT(HDRP(bp),PACK(csize,1));
        PUT(FTRP(bp),PACK(csize,1));
    }
}

void *first_fit(size_t asize){
    int index = Index(asize);
    for(;index<=10; index++){
        char *st = GET(list_table+(index*WSIZE)); // 获取第index个链表地址
        while(st!=NULL){ //若该链表的size符合要求就返回该链表地址，否则搜索下一个更大的链表
            if (GET_SIZE(HDRP(st)) >= asize) return st;
            st = GET(NEXT_LINKED_BLKP(st));
        }
    }
}

int Index(size_t asize){
    int ret=0;
    if (asize>=4096) return 10;
    // 循环二分一个堆块，ret是一个计数器，记录获取的空闲块在第几个链表中
    while (asize){
        asize/=2;
        ret++;
    }
    return ret-3;
}

void add_block(void *bp,size_t asize){
    int index = Index(asize);
    // 如果该链表为空，那么该链表和该块就形成一个双向链表
    if (GET(list_table+(index*WSIZE))==NULL){
        PUT(list_table+(index*WSIZE),bp); // list_table+(index*WSIZE).next->bp
        PUT(PREV_LINKED_BLKP(bp),list_table+(index*WSIZE)); // bp.prev->list_table+(index*WSIZE)
    }
    else{
        char *pre = list_table+(index*WSIZE);
        char *st = GET(pre);
        // 一直找到该链表尾
        while (st!=NULL && st<bp){
            pre = st;
            st = GET(NEXT_LINKED_BLKP(st));
        }
        // 如果pre不是链表将bp插入pre和st之间，注意，这里留下了st的bk指针未设置
        if (pre != list_table+(index*WSIZE)){
            PUT(PREV_LINKED_BLKP(bp),pre);
            PUT(NEXT_LINKED_BLKP(bp),st);
            PUT(NEXT_LINKED_BLKP(pre),bp);
        }
        else{
            PUT(PREV_LINKED_BLKP(bp).pre);
            PUT(NEXT_LINKED_BLKP(bp),st);
            PUT(pre,bp);
        }
        // 设置st的bk指针
        if (st != NULL) PUT(PREV_LINKED_BLKP(st),bp);
    }
}

void delete_block(void *bp,size_t asize){
    int index = Index(asize);
    char *prev = GET(PREV_LINKED_BLKP(bp));
    char *next = GET(NEXT_LINKED_BLKP(bp));
    // 如果该块的prev就指向链表，则让链表越过此块指向下一块
    if (prev == list_table+(index*WSIZE)){
        PUT(prev,next);
    }
    // 否则直接让前一块的fd越过此块，指向下一块
    else{
        PUT(NEXT_LINKED_BLKP(prev),next);
    }
    // 如果后一块存在则让后一块的bk越过此块，指向前一块
    if (next != NULL){
        PUT(PREV_LINKED_BLKP(next),prev);
    }
}

void *immediate_coalesce(void *bp){
    size_t prev_alloc = GET_ALLOC(FTRP(PREV_BLKP(bp)));
    size_t next_alloc = GET_ALLOC(HDRP(NEXT_BLKP(bp)));
    size_t size = GET_SIZE(HDRP(bp));

    // 前后块都是使用状态，直接将这个空闲块加入链表
    if (prev_alloc && next_alloc){
        add_block(bp,GET_SIZE(HDRP(bp)));
        return bp;
    }
    // 后一块是空闲块，将后一块从链表中取出并合并再加入链表
    else if (prev_alloc && !next_alloc){
        delete_block(NEXT_BLKP(bp),GET_SIZE(HDRP(NEXT_BLKP(bp))));
        size += GET_SIZE(HDRP(NEXT_BLKP(bp)));
        PUT(HDRP(bp),PACK(size,0));
        PUT(FTRP(bp),PACK(size,0));
        PUT(PREV_LINKED_BLKP(bp),NULL);
        PUT(NEXT_LINKED_BLKP(bp),NULL);
        add_block(bp,size);
    }
    // // 前一块是空闲块，将前一块从链表中取出并合并再加入链表
    else if (!prev_alloc && next_alloc){
        delete_block(PREV_BLKP(bp), GET_SIZE(HDRP(PREV_BLKP(bp))));
        size += GET_SIZE(HDRP(PREV_BLKP(bp)));
        PUT(FTRP(bp), PACK(size, 0));
        PUT(HDRP(PREV_BLKP(bp)), PACK(size, 0));
        bp = PREV_BLKP(bp);
        PUT(PREV_LINKED_BLKP(bp), NULL);
        PUT(NEXT_LINKED_BLKP(bp), NULL);
        add_block(bp, size);
    }
        // 前后都是空闲块，从链表中取出并合并再加入链表
    else{
        delete_block(PREV_BLKP(bp),GET_SIZE(HDRP(PREV_BLKP(bp))));
        delete_block(NEXT_BLKP(bp),GET_SIZE(HDRP(NEXT_BLKP(bp))));
        size += GET_SIZE(HDRP(PREV_BLKP(bp))) + GET_SIZE(FTRP(NEXT_BLKP(bp)));
        PUT(HDRP(PREV_BLKP(bp)),PACK(size,0));
        PUT(HDRP(NEXT_BLKP(bp)),PACK(size,0));
        bp = PREV_BLKP(bp);
        PUT(PREV_LINKED_BLKP(bp),NULL);
        PUT(NEXT_LINKED_BLKP(bp),NULL);
        add_block(bp,size);
    }
    return bp;
}

/* 
 * mm_malloc - Allocate a block by incrementing the brk pointer.
 *     Always allocate a block whose size is a multiple of the alignment.
 */
void *mm_malloc(size_t size)
{
    size_t asize;           //调整堆块大小，为头和尾留空间
    size_t extendsize;      //空闲堆无合适大小，拓展堆
    char *bp;

    if (size == 0)
        return NULL;
    if (size <= DSIZE)
        asize = 2*DSIZE;
    else
        // 向上舍入最接近8的整数倍
        asize = DSIZE * ((size + (DSIZE) + (DSIZE-1)) / DSIZE);

    // 搜索空闲块，若匹配则分割
    if ((bp = first_fit(asize)) != NULL){
        place(bp,asize);
        return bp;
    }

    extendsize = MAX(asize, CHUNKSIZE);
    if ((bp = extend_heap(extendsize/WSIZE)) == NULL)
        return NULL;
    place(bp, asize);
    return bp;
}

/*
 * mm_free - Freeing a block does nothing.
 */
void mm_free(void *ptr)
{
    if(ptr == NULL)
        return;
    size_t size = GET_SIZE(HDRP(bp));

    PUT(HDRP(bp),PACK(size,0)); // flag位置0
    PUT(FTRP(bp),PACK(size,0));
    PUT(PREV_LINKED_BLKP(ptr),NULL);
    PUT(NEXT_LINKED_BLKP(ptr),NULL);
    immediate_coalesce(ptr);
}

/*
 * mm_realloc - Implemented simply in terms of mm_malloc and mm_free
 * 调整块
 */
void *mm_realloc(void *ptr, size_t size)
{
    if(ptr == NULL){
        return mm_malloc(size);
    }
    if(size == 0){
        mm_free(ptr);
        return NULL;
    }

    size_t asize;
    if (size <= DSIZE) asize = 2 * DSIZE;
    else asize = DSIZE * ((size + (DSIZE) + (DSIZE-1))/DSIZE);

    size_t oldsize = GET_SIZE(HDRP(ptr));
    // 分割空闲块
    if (oldsize > asize) {
        if (oldsize - asize >= 2 * DSIZE) {
            PUT(HDRP(ptr), PACK(asize, 1));
            PUT(FTRP(ptr), PACK(asize, 1));
            void *bp = ptr;
            bp = NEXT_BLKP(bp);
            PUT(HDRP(bp), PACK(oldsize - asize, 0));
            PUT(FTRP(bp), PACK(oldsize - asize, 0));
            PUT(PREV_LINKED_BLKP(bp), NULL);
            PUT(NEXT_LINKED_BLKP(bp), NULL);

            immediate_coalesce(bp);
        } else {
            PUT(HDRP(ptr), PACK(oldsize, 1));
            PUT(FTRP(ptr), PACK(oldsize, 1));
        }
        return ptr;
    }
    else{
        // 获取下一块flag
        size_t next_alloc = GET_ALLOC(HDRP(NEXT_BLKP(ptr)));
        // 下一块是空闲块，合并
        if (!next_alloc && GET_SIZE(HDRP(NEXT_BLKP(ptr))) + oldsize >= asize){
            delete_block(NEXT_BLKP(ptr), GET_SIZE(HDRP(NEXT_BLKP(ptr))));
            size_t ssize = GET_SIZE(HDRP(NEXT_BLKP(ptr))) + oldsize;
            size_t last = ssize - asize;
            if (last >= 2*DSIZE){
                PUT(HDRP(ptr),PACK(asize,1));
                PUT(FTRP(ptr),PACK(asize,1));
                char *bp = NEXT_BLKP(ptr);
                PUT(HDRP(bp),PACK(last,0));
                PUT(FTRP(bp),PACK(last,0));
                PUT(NEXT_LINKED_BLKP(bp),NULL);
                PUT(PREV_LINKED_BLKP(bp),NULL);
                add_block(bp,last);
            }
            else{
                PUT(HDRP(ptr),PACK(ssize,1));
                PUT(FTRP(ptr),PACK(ssize,1));
            }
            return ptr;
        }
        // 下一块不是空闲块，就向系统申请内存，旧块的内容copy至新块
        else{
            char *newptr = mm_malloc(asize);
            if (newptr == NULL) return NULL;
            memcpy(newptr,ptr,oldsize-DSIZE);
            mm_free(ptr);
            return newptr;
        }
    }
}















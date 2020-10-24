//
// Created by zhz on 2020/9/30.
//
#include "shape.h"
#include <assert.h>

// Shape 的虚函数
static uint32_t Shape_area_(Shape const * const me);
static void Shape_draw_(Shape const * const me);

// 构造函数
void Shape_ctor(Shape * const me, int16_t x, int16_t y)
{
    // Shape 类的虚表
    static struct ShapeVtbl const vtbl ={
        &Shape_area_,
        &Shape_draw_
    };
    me->vptr = &vtbl; // 重载vtbl，使得虚表指针指向Shape自己的vtbl
    me->x = x;
    me->y = y;
}

void Shape_move(Shape * const me, int16_t dx, int16_t dy)
{
    me->x += dx;
    me->y += dy;
}

// 获取x.y
int16_t Shape_getX(Shape const * const me)
{
    return me->x;
}

int16_t Shape_getY(Shape const * const me)
{
    return me->y;
}

// Shape 类的虚函数实现
static uint32_t Shape_area_(Shape const * const me)
{
    assert(0); // 类似纯虚函数(这里不是很懂，这不是直接报错？）
    return 0; // 避免警告（不懂）
}

static void Shape_draw_(Shape const * const me)
{
    assert(0); // 虚函数不能被调用
}

// 这里寻找最大的形状
Shape const *largestShape(Shape const *shapes[],uint32_t nShapes)
{
    Shape const *s = (Shape *)0;
    uint32_t max = 0;
    uint32_t i;
    for (i = 0; i < nShapes; ++i)
    {
        uint32_t area = Shape_area(shapes[i]); // 虚函数调用
        if (area > max)
        {
            max = area;
            s = shapes[i];
        }
    }
    return s;
}

void drawAllShapes(Shape const *shapes[],uint32_t nShapes)
{
    uint32_t i;
    for (i = 0; i < nShapes; ++i)
    {
        Shape_draw(shapes[i]);
    }
}
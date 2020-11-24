//
// Created by zhz on 2020/9/30.
//
#include "rectangle.h"
#include <stdio.h>
// Rectangle 虚函数
static uint32_t Rectangle_area_(Shape const * const me);
static void Rectangle_draw_(Shape const * const me);

// 构造函数
void Rectangle_ctor(Rectangle * const me, int16_t x, int16_t y , uint16_t height)
{
    static struct ShapeVtbl const vtbl ={
        &Rectangle_area_,
        &Rectangle_draw_
    };
    Shape_ctor(&me->super,x,y);
    me->super.vptr = &vtbl; // 重载vptr，使得vtpr指向Rectangle自己的vtbl
    me->height = height;
}

static uint32_t Rectangle_area_(Shape const * const me)
{
    Rectangle const * const me_ = (Rectangle const *)me; //将父类转换为子类
    return (uint32_t)me_->super.x * (uint32_t)me_->height;
}

static void Rectangle_draw_(Shape const * const me)
{
    Rectangle const * const me_ = (Rectangle const *)me;
    printf("Rectangle_draw_(x=%d,y=%d,height=%d)\n",Shape_getX(me),Shape_getY(me),me_->height);
}


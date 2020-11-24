//
// Created by zhz on 2020/9/30.
//

#ifndef TEST_SHAPE_H
#define TEST_SHAPE_H

#include <stdint.h>

// Shape 的属性，这里是长和宽
typedef struct {
    // 这里增加了Shape的虚表
    struct ShapeVtbl const *vptr;
    int16_t x;
    int16_t y;
} Shape;

// 设立Shape的虚表
struct ShapeVtbl {
    uint32_t (*area) (Shape const * const me);
    void (*draw) (Shape const * const me);
};

// Shape的操作函数，接口函数
// Shape长宽的定义
void Shape_ctor(Shape * const me, int16_t x, int16_t y);
// Shape长宽的改变
void Shape_move(Shape * const me, int16_t dx, int16_t dy);
// 获取x
int16_t Shape_getX(Shape const * const me);
// 获取y
int16_t Shape_getY(Shape const * const me);
#endif //TEST_SHAPE_H

static inline uint32_t Shape_area(Shape const * const me){
    return (*me->vptr->area)(me);
}

static inline void Shape_draw(Shape const * const me){
    return (*me->vptr->draw) (me);
}

Shape const *largestShape(Shape const *shapes[],uint32_t nShapes);
void drawAllShapes(Shape const *shapes[],uint32_t nShapes);
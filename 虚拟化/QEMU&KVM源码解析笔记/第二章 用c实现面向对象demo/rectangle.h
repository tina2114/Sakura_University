//
// Created by zhz on 2020/9/30.
//

#ifndef TEST_RECTANGLE_H
#define TEST_RECTANGLE_H

#include "shape.h"

// 长方体的属性
typedef struct {
    Shape super; // 继承Shape

    // 长方体的高
    uint16_t height;
}Rectangle;

void Rectangle_ctor(Rectangle * const me, int16_t x, int16_t y , uint16_t height);

#endif //TEST_RECTANGLE_H

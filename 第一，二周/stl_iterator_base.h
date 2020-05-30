//
// Created by zhz on 2020/5/25.
//

#ifndef CLION_STL_STL_ITERATOR_BASE_H
#define CLION_STL_STL_ITERATOR_BASE_H
#pragma once
#ifndef ZHZ_STL_STL_INTERNAL_ITERATOR_BASE_H
#define ZHZ_STL_STL_INTERNAL_ITERATOR_BASE_H

#include <stddef.h>
#include "stl_config.h"

__STL_BEGIN_NAMESPACE
//只写，只允许一次，执行完后指针往后移动，支持操作：++p,p++,!=,==,=*p,p->；
    struct input_iterator_tag {
    };
//只读，只允许一次，执行完后指针往后移动，支持操作：++p,p++；
    struct output_iterator_tag {
    };
//forward_iterator_tag public继承input_iterator_tag
//forward_list，unordered_set，unordered_map，unordered_multiset，unordered_multimap是单向连续性空间，不支持随机访问，使用的是forward_iterator_tag
    struct forward_iterator_tag : public input_iterator_tag {
    };
//双向，++/--
//list，set，map，multiset，multimap，都是关联性容器，不支持随机访问，使用的是bidirectional_iterator_tag
    struct bidirectional_iterator_tag : public forward_iterator_tag {
    };
//+=, -=
//因为Array，Vector，Deque这三种容器支持随机访问，是连续空间（deque模仿出连续的假象），使用的是random_access_iterator_tag
    struct random_access_iterator_tag : public bidirectional_iterator_tag {
    };
//类似于特化的一种吗？为了效率？ ->好像是的，不同的iterator类型对于算法的影响是非常大的，如果是非连续空间，就只能用迭代方式，所以要得到最优的迭代器。

//input_iterator的重命名
    template<class _Tp, class _Distance>
    struct input_iterator {
        typedef input_iterator_tag iterator_category;
        typedef _Tp value_type;//操作对象类型
        typedef _Distance difference_type;
        typedef _Tp* pointer;
        typedef _Tp& reference;
    };
    struct output_iterator {
        typedef output_iterator_tag iterator_category;
        typedef void value_type;
        typedef void difference_type;
        typedef void pointer;
        typedef void reference;
    };
    template<class _Tp, class _Distance>
    struct forward_iterator {
        typedef forward_iterator_tag iterator_category;
        typedef _Tp value_type;
        typedef _Distance difference_type;
        typedef _Tp* pointer;
        typedef _Tp& reference;
    };
    template<class _Tp, class _Distance>
    struct bidirectional_iterator {
        typedef bidirectional_iterator_tag iterator_category;
        typedef _Tp value_type;
        typedef _Distance difference_type;
        typedef _Tp* pointer;
        typedef _Tp& reference;
    };
    template<class _Tp, class _Distance>
    struct random_access_iterator {
        typedef random_access_iterator_tag iterator_category;
        typedef _Tp value_type;
        typedef _Distance difference_type;
        typedef _Tp* pointer;
        typedef _Tp& reference;
    };
    template<class _Category, class _Tp, class _Distance = ptrdiff_t, class _Pointer = _Tp*, class _Reference = _Tp&>
    struct iterator {
        typedef _Category iterator_category;
        typedef _Tp value_type;
        typedef _Distance difference_type;
        typedef _Pointer pointer;
        typedef _Reference reference;
    };

    template<class _Iterator>
    struct iterator_traits {
        typedef typename _Iterator::iterator_categroy iterator_category;
        typedef typename _Iterator::value_type value_type;
        typedef typename _Iterator::difference_type difference_type;
        typedef typename _Iterator::pointer pointer;
        typedef typename _Iterator::reference reference;
    };
//对于指针类型的偏特化
    template<class _Tp>
    struct iterator_traits<_Tp*> {
        typedef random_access_iterator_tag iterator_category;
        typedef _Tp value_type;
        typedef ptrdiff_t difference_type;
        typedef _Tp* pointer;
        typedef _Tp& reference;
    };

    template<class _Tp>
    struct iterator_traits<const _Tp*> {
        typedef random_access_iterator_tag iterator_category;
        typedef _Tp value_type;
        typedef ptrdiff_t difference_type;
        typedef const _Tp* pointer;
        typedef const _Tp& reference;
    };

    template<class _Iter>
    inline typename iterator_traits<_Iter>::iterator_category __iterator_category(const _Iter&) {
        typedef typename iterator_traits<_Iter>::iterator_category _Category;
        return _Category();
    }

    template<class _Iter>
    inline typename iterator_traits<_Iter>::iterator_category iterator_category(const _Iter& __i) {
        return __iterator_category(__i);
    }


    template<class _Iter>
    inline typename iterator_traits<_Iter>::difference_type* __distance_type(const _Iter&) {
        return static_cast<typename iterator_traits<_Iter>::difference_type*>(0);
    }

    template<class _Iter>
    inline typename iterator_traits<_Iter>::difference_type* distance_type(const _Iter& __i) {
        return __distance_type(__i);
    }

    template<class _Iter>
    inline typename iterator_traits<_Iter>::value_type* __value_type(const _Iter&) {
        return static_cast<typename iterator_traits<_Iter>::value_type*>(0);
    }

    template<class _Iter>
    inline typename iterator_traits<_Iter>::value_type* value_type(const _Iter& __i) {
        return __value_type(__i);
    }

#define __ITERATOR_CATEGORY(__i) __iterator_category(__i)
#define __DISTANCE_TYPE(__i)     __distance_type(__i)
#define __VALUE_TYPE(__i)        __value_type(__i)

//计算非连续的距离
    template<class _InputIterator, class _Distance>
    inline void __distance(_InputIterator __first, _InputIterator __last, _Distance& __n, input_iterator_tag) {
        while (__first != __last) {
            ++__first;
            ++__n;
        }
    }

//计算连续的距离
    template<class _RandomAccessIterator, class _Distance>
    inline void __distance(_RandomAccessIterator __first, _RandomAccessIterator __last, _Distance& __n,
                           random_access_iterator_tag) {
        __n += __last - __first;
    }

//根据类型判断是调用连续的计算，还是非连续的计算
    template<class _InputIterator, class _Distance>
    inline void distance(_InputIterator __first, _InputIterator __last, _Distance& __n) {
        __distance(__first, __last, __n, iterator_category(__first));
    }

#ifdef __STL_CLASS_PARTIAL_SPECIALIZATION

    template<class _InputIterator>
inline typename iterator_traits<_InputIterator>::difference_type
__distance(_InputIterator __first, _InputIterator __last, input_iterator_tag) {
    typename iterator_traits<_InputIterator>::difference_type __n = 0;
    while (__first != __last) {
        ++__first;
        ++__n;
    }
    return __n;
}

//计算连续的距离
template<class _RandomAccessIterator>
inline typename iterator_traits<_RandomAccessIterator>::difference_type
__distance(_RandomAccessIterator __first, _RandomAccessIterator __last, random_access_iterator_tag) {
    return __last - __first;
}

//调用上述的函数进行非连续的距离计算
template<class _InputIterator>
inline typename iterator_traits<_InputIterator>::difference_type
distance(_InputIterator __first, _InputIterator __last) {
    typedef typename iterator_traits<_InputIterator>::iterator_category _Category;
    __distance(__first, __last, _Category());
}

#endif /* __STL_CLASS_PARTIAL_SPECIALIZATION */

//将inputIterator的指针向前移动
    template<class _InputIterator, class _Distance>
    inline void __advance(_InputIterator& __i, _Distance __n, input_iterator_tag) {
        while (__n--) {
            ++__i;
        }
    }

//如果距离n>0，就向前移动指针，如果距离n<=0，就向后移动指针,应该是针对非连续
    template<class _BidirectionalIterator, class _Distance>
    inline void __advance(_BidirectionalIterator& __i, _Distance __n, bidirectional_iterator_tag) {
        if (__n > 0) {
            while (__n--) {
                ++__i;
            }
        }
        else {
            while (__n++) {
                --__i;
            }
        }
    }

//针对连续的，直接加__n的距离
    template<class _RandomAccessIterator, class _Distance>
    inline void __advance(_RandomAccessIterator& __i, _Distance __n, random_access_iterator_tag) {
        __i += __n;
    }

    template<class _InputAccessIterator, class _Distance>
    inline void advance(_InputAccessIterator& __i, _Distance __n) {
        __advance(__i, __n, __iterator_category(__i));
    }
__STL_END_NAMESPACE

#endif // !ZHZ_STL_STL_INTERNAL_ITERATOR_BASE_H

#endif //CLION_STL_STL_ITERATOR_BASE_H

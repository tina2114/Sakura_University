//
// Created by zhz on 2020/5/25.
//

#ifndef CLION_STL_STL_CONSTRUCT_H
#define CLION_STL_STL_CONSTRUCT_H
#pragma once
//Construct.h文件负责的是我们容器的构造和析构，往上是为容器提供内存和销毁容器的接口，往下和内存分配挂钩

#ifndef ZHZ_STL_STL_INTERNAL_CONSTRUCT_H
#define ZHZ_STL_STL_INTERNAL_CONSTRUCT_H

#include <new.h>
#include "stl_config.h"
#include "type_traits.h"
#include "stl_iterator_base.h"

__STL_BEGIN_NAMESPACE

    template <class _T1, class _T2>
    inline void _Construct(_T1* __p, const _T2& __value)
    {
        new ((void*)__p)_T1(__value);
    }

    template <class _T1>
    inline void _Construct(_T1* __p)
    {
        new ((void*)__p) _T1();
    }
//析构
    template <class _Tp>
    inline void _Destroy(_Tp* __pointer)
    {
        __pointer->~_Tp();
    }

//ForwardIterator类型的析构
//forward_list，unordered_set，unordered_map，unordered_multiset，unordered_multimap是单向连续性空间，不支持随机访问，使用的是forward_iterator_tag
    template <class _ForwardIterator>
    void __destroy_aux ( _ForwardIterator __first, _ForwardIterator __last, __false_type)
    {
        for (; __first != __last; ++__first)
            destroy(&*__first);
    }

    template<class _ForwardIterator, class _Tp>
    inline void __destroy(_ForwardIterator __first, _ForwardIterator __last, _Tp*) {
        typedef typename __type_traits<_Tp>::has_trivial_destructor _Trivial_destructor;
        __destroy_aux(__first, __last, _Trivial_destructor());
    }


    template <class _ForwardIterator>
    inline void _Destroy(_ForwardIterator __first, _ForwardIterator __last)
    {
        __destroy(__first, __last, __VALUE_TYPE(__first));
    }

    inline void _Destroy(char*, char*) {}
    inline void _Destroy(int*, int*) {}
    inline void _Destroy(long*, long*) {}
    inline void _Destroy(float*, float*) {}
    inline void _Destroy(double*, double*) {}
#ifdef __STL_HAS_WCHAR_T
    inline void _Destroy(wchar_t*, wchar_t*)
{
}
#endif //__STL_HAS_WCHAR_T


// ----------------------------------------------------------
// Old names from the HP STL

//new ((void*)__p)_T1(__value);
    template <class _T1, class _T2>
    inline void construct(_T1* __p, const _T2& __value)
    {
        _Construct(__p, __value);
    }

//new ((void*)__p) _T1();
    template <class _T1>
    inline void construct(_T1* __p)
    {
        _Construct(__p);
    }

//__pointer->~_Tp();
    template <class _Tp>
    inline void destroy(_Tp* __pointer)
    {
        _Destroy(__pointer);
    }

//__destroy(__first, __last, __VALUE_TYPE(__first));
    template <class _ForwardIterator>
    inline void destroy(_ForwardIterator __first, _ForwardIterator __last)
    {
        _Destroy(__first, __last);
    }

__STL_END_NAMESPACE

#endif // !ZHZ_STL_STL_INTERNAL_CONSTRUCT_H

#endif //CLION_STL_STL_CONSTRUCT_H

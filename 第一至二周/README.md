# 傻哭拉大学的第一，二周学习生涯(SGI_STL的学习)

## 整体认识STL

STL是C++标准库的一部分，占据了大部分的比例。STL借助模板把常用的数据结构及其算法都实现了一遍，且做到了数据结构和算法的分离。

(1) STL一共有六大组件:

1. 容器(container)

   容器可以分为序列容器(array（c++11)、vector、deque、List 和 Forward_List ) 和关联式容器(set / multiSet、 map / multiMap、 unordered set / multiSet、 unordered-map/multiMap)

   ![preview](https://pic4.zhimg.com/v2-80e642bb33688e6710bbe0a09cf00aab_r.jpg)

2. 算法(algorithm)

   STL常见的算法有sort，search，copy，erase，for_each，unique。可以看作是一种function template(函数模板)

3. 迭代器(iterator)

   迭代器是连接算法和容器的方法，是一种广义的指针，使得算法能够独立于容器进行设计。

4. 仿函数(functor)

   搭配STL算法使用，泛化算法的操作

5. 配置器(allocator)

   为容器提供空间配置和释放，对象构造和析构的服务，也是一个class template。

6. 配接器(adapter)

   将一种容器修饰为功能不同的另一种容器。例如deque，在此基础上禁用一些deque的功能实现队列和栈，这就是一种配接器。

(2) 学习中的一些参考资料:

https://www.kancloud.cn/digest/stl-sources/177265

https://blog.csdn.net/qq_34777600/article/details/80427463

### 序列容器(vector)

先从总体来认识，vector是一种动态的容器。其内部结构如图所示，是一种左闭右开的形式。

![](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/QQ图片20200528205930.png)

其中一共存在三个指针，分别是_M_start(指向容器内存的开头)，_M_finish(指向容器中数据存放的末尾)，_M_end_of_storage(指向容器最大储存容量的末尾)。

每次往容器中存放数据，_M_finish就会向后移动，而一旦_M_finish == _M_end_of_storage。就会触发容器扩充机制，该容器的_M_end_of_storage就会扩展一倍。例如，该容器现有容量为4(也就是_M_of_storage为4)，一旦储存满了，_M_of_storage就会变成8。并且，这种扩展并不是在原有的内存地址进行扩展，而是在内存中另寻一处容量为该内存两倍的地址，将容器整个copy过去。

#### vector容器的数据结构

```c++
//这里获取容器的开头，末尾和最大指针
        _Vector_base(size_t __n, const _Alloc&)
                : _M_start(0), _M_finish(0), _M_end_of_storage(0) {
            _M_start = _M_allocate(__n);
            _M_finish = _M_start;
            _M_end_of_storage = _M_start + __n;
        }
		~_Vector_base() { _M_deallocate(_M_start, _M_end_of_storage - _M_start); }

		 _Tp* _M_allocate(size_t __n) {
            return _M_data_allocator::allocate(__n);
            //return 0 == __n ? 0 : (__Tp*)__Alloc::allocate(__n * sizeof(_Tp));
            //相当于判断，传进来的是否是0，是0就返回0，不是就返回 __n * sizeof(_Tp)
        }

        //指定deallocate的头指针，以及需要的size
        void _M_deallocate(_Tp* __p, size_t __n) {
            _M_data_allocator::deallocate(__p, __n);
        }
```



#### vector的构造函数，析构函数等设计

```c++
//默认的构造函数
explicit vector(const allocator_type& __a = allocator_type()) : _Base(__a) {}

//进行不同情况的拷贝构造
		vector(size_type __n, const _Tp& __value, const allocator_type& __a = allocator_type()) : _Base(__n, __a) {
        //直接进行区域的替换，从地址M_start开始连续填充n个初始值为value的元素
        _M_finish = uninitialized_fill_n(_M_start, __n, __value);
        }

        explicit vector(size_type __n)
                : _Base(__n, allocator_type()) {
            _M_finish = uninitialized_fill_n(_M_start, __n, _Tp());
        }

		//将begin()元素的内容copy到_M_start
        vector(const vector<_Tp, _Alloc>& __x) : _Base(__x.size(), __x.get_allocator()) {
            _M_finish = uninitialized_copy(__x.begin(), __x.end(), _M_start);
        }
		
		template<class _InputIterator>
        vector(_InputIterator __first, _InputIterator __last, const allocator_type& __a = allocator_type()) : _Base(__a) {
            typedef typename _Is_integer<_InputIterator>::_Integral _Integral;
            //判断输入是否为integer
            _M_initialize_aux(__first, __last, _Integral());
        }
		//若输入是integer，则执行此处
		template<class _Integer>
        void _M_initialize_aux(_Integer __n, _Integer __value, __true_type) {
            _M_start = _M_allocate(__n);
            _M_end_of_storage = _M_start + __n;
            _M_finish = uninitialized_fill_n(_M_start, __n, __value);
        }
		//若不是integer，则调用traits判断迭代器类型
        template<class _InputIterator>
        void _M_initialize_aux(_InputIterator __first, _InputIterator __last, __false_type) {
            _M_range_initialize(__first, __last, __ITERATOR_CATEGORY(__first));
        }
//析构函数
~vector() {
            destroy(_M_start, _M_finish);
        }
```



#### vector的成员函数

```c++
//往容器末尾压入元素
void push_back(const _Tp& __value) {
            if (_M_finish != _M_end_of_storage) {
                construct(_M_finish, __value);
                ++_M_finish;
            }
            else {
                _M_insert_aux(end(), __value);
            }
        }

//swap，交换容器内容，交换迭代器所指的地址
void swap(vector<_Tp, _Alloc>& __x) {
            if (this != &__x) {
                zhz_stl::swap(_M_start, __x._M_start);
                zhz_stl::swap(_M_finish, __x._M_finish);
                zhz_stl::swap(_M_end_of_storage, __x._M_end_of_storage);
            }
        }  
//插入
iterator insert(iterator __position, const _Tp& __x) {
            size_type __n = __position - begin();
            //插入需要分成多种情况考虑
            //第一种是插入到vector的末位
            if (_M_finish != _M_end_of_storage && __position == end()) {
                construct(_M_finish, __x);
                ++_M_finish;
            }
                //插入到其他位置
            else {
                _M_insert_aux(__position, __x);
            }
            return begin() + __n;
        }
		
        template<class _InputIterator>
        void insert(iterator __pos, _InputIterator __first, _InputIterator __last) {
            typedef typename _Is_integer<_InputIterator>::_Integral _Integral;
            _M_insert_dispatch(__pos, __first, __last, _Integral());
        }
		//判断输入的是否的integer，是就执行此处
        template<class _Integer>
        void _M_insert_dispatch(iterator __pos, _Integer __n, _Integer __val, __true_type) {
            _M_fill_insert(__pos, (size_type)__n, (_Tp)__val);
        }
		//判断输入的是否的integer，不是就执行此处
        template<class _InputIterator>
        void _M_insert_dispatch(iterator __pos, _InputIterator __first, _InputIterator __last, __false_type) {
            _M_range_insert(__pos, __first, __last, __ITERATOR_CATEGORY(__first));
        }
		//在pos位置连续插入n个初始值为x的元素
        void insert(iterator __pos, size_type __n, const _Tp& __x) {
            _M_fill_insert(__pos, __n, __x);
        }

        void _M_fill_insert(iterator __pos, size_type __n, const _Tp& __x);
//删除容器中最后一个元素
void pop_back() {
            --_M_finish;
            destroy(_M_finish);
        }
//删除容器中指定位置的元素
iterator erase(iterator __position) {
            //如果position后面还有元素，需要拷贝;如果position是最后一个元素，则后面没有元素，直接destroy即可
            if (__position + 1 != end()) {
                copy(__position + 1, _M_finish, __position);
            }
            //容器左闭右开，没错，_M_finish指的是末尾的后一位
            --_M_finish;
            destroy(_M_finish);
            return __position;
        }

        //destroy一块区域
        iterator erase(iterator __first, iterator __last) {
            iterator __i = copy(__last, _M_finish, __first);
            destroy(__i, _M_finish);
            _M_finish = _M_finish - (__last - __first);
            return __first;
        }
//改变容器中可存储的元素个数，并不会分配新的空间
void resize(size_type __new_size, const _Tp& __x) {
            if (__new_size < size()) {//若调整后的内存空间比原来的小
                erase(begin() + __new_size, end());//删除多余的元素
            }
            else {
                insert(end(), __new_size - size(), __x);//将比原来空间多出的内存都赋予初值x
            }
        }

        void resize(size_type __new_size) {
            resize(__new_size, _Tp());
        }
//删除容器内所有元素
void clear() {
            erase(begin(), end());
        }
```


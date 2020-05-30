## 漏洞

### 1

![](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/QQ图片20200529190422.png)

溯源到的

![](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/QQ图片20200529190522.png)

好像没对first和last进行检测，是否first真的在last前面，所以......是否有可能越界删除？

poc，唔唔唔，对不起，这周实验课一堆，万分抱歉，周末补上。

### 2

![](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/QQ图片20200529190756.png)

好像没考虑迭代器越界的情况，如果你的迭代器被迭代到_M_finish后面……….好像会直接执行插入到其他位置。

![](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/QQ图片20200529190858.png)

然后,你的last – first会直接成负数，整数溢出？_Num极大，如果先在容器里构造好payload，设置好_Num，好像可以进行任意地址写？

poc，唔唔唔，对不起，这周实验课一堆，万分抱歉，周末补上



## 作业

```c++
#include <iostream>
#include <cstdlib>
#include <cstring>
using namespace std;
class Element {
private:
    int number;
public:
    Element() :number(0) {
        cout << "ctor" << endl;
    }
    Element(int num) :number(num) {
        cout << "ctor" << endl;
    }
    Element(const Element& e) :number(e.number) {
        cout << "copy ctor" << endl;
    }
    Element(Element&& e) :number(e.number) {
        cout << "right value ctor" << endl;
    }
    ~Element() {
        cout << "dtor" << endl;
    }
    void operator=(const Element& item) {
        number = item.number;
    }
    bool operator==(const Element& item) {
        return (number == item.number);
    }
    void operator()() {
        cout << number;
    }
    int GetNumber() {
        return number;
    }
};
template<typename T>
class Vector {
private:
    T* items;
    int count;
public:
    Vector() :count{ 0 }, items{ nullptr } {

    }
    Vector(const Vector& vector) :count{ vector.count } {
        items = static_cast<T*>(malloc(sizeof(T) * count));
        memcpy(items, vector.items, sizeof(T) * count);
    }
    Vector(Vector&& vector) :count{ vector.count }, items{ vector.items } {
        items = nullptr;
        count = 0;
    }
    ~Vector() {
        Clear();
    }
    T& operator[](int index) {
        if (index < 0 || index >= count) {
            cout << "invalid index" << endl;
            return items[0];
        }
        return items[index];
    }
    int returnCount() {
        return count;
    }
    void Clear() {
        auto __first = items;
        auto __end = items + count;
        for (; __first != __end; __first++)
        {
            __first->~T();//first指向那个类，调用那个类的析构函数
        }
        count = 0;
        free(items);//防止uaf
        items = nullptr;//防止uaf
    }

    //在内存块中另找一块位置，容量为sizeof(T) * (count+1)
    //将原本内存块中的内容copy过去，并将item插入最后一位，清除原内存块的内容
    void Add(const T& item) {
        T* new_items = static_cast<T*>(malloc(sizeof(T) * (count + 1)));//因为是插入，所以需要多开辟一个空间
            if (!new_items)
                return;
        for (int i = 0; i < count; i++)
        {
            new (new_items + i) T(std::move(*(items + i)));
        }
        new (new_items + count) T(std::move(item)); //插入item
        Clear();
        count = count + 1;
        items = new_items;
    }
    bool Insert(const T& item, int index) {
        if (index > count || index <0)
            return false;
        else
        {
            T* new_items = static_cast<T*>(malloc(sizeof(T) * (count + 1)));
                if (!new_items)
                    return false;
            for (int i = 0; i < index; i++)
                new (new_items + i) T(std::move(*(items + i)));
            new (new_items + index) T(std::move(item));
            for (int i = index+1;i<count+1;i++)
                new (new_items + i) T(std::move(*(items + i)));
            Clear();
            items = new_items;
            count = count + 1;
            return true;
        }
    }
    bool Remove(int index) {
        if (index >= count || index < 0)
            return false;
        else
        {
            T* new_items = static_cast<T*>(malloc(sizeof(T) * (count - 1)));
                if (!new_items)
                    return false;
            for (int i = 0; i < count; i++)
            {   
                if (i == index)
                    continue;
                new (new_items + i) T(std::move(*(items+ i)));
            }
            Clear();
            items = new_items;
            count = count + 1;
            return true;
        }
    }
    int Contains(const T& item) {
        int i;
        for ( i = 0; i < count; i++)
        {
            if (*(items + i) == item)
                return i;
        }
        return -1;
    }
};
template<typename T>
void PrintVector(Vector<T>& v) {
    int count = v.returnCount();
    for (int i = 0; i < count; i++)
    {
        v[i]();
        cout << " ";
    }
    cout << endl;
}
int main() {
    Vector<Element>v;
    for (int i = 0; i < 4; i++) {
        Element e(i);
        v.Add(e);
    }
    PrintVector(v);
    Element e2(4);
    if (!v.Insert(e2, 10))
    {
        v.Insert(e2, 2);
    }
    PrintVector(v);
    if (!v.Remove(10))
    {
        v.Remove(2);
    }
    PrintVector(v);
    Element e3(1), e4(10);
    cout << v.Contains(e3) << endl;
    cout << v.Contains(e4) << endl;
    Vector<Element>v2(v);
    Vector<Element>v3(move(v2));
    PrintVector(v3);
    v2.Add(e3);
    PrintVector(v2);
    return 0;
}
```


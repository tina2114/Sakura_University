大概就是vector的erase源码那写的不当，deal的是_M_finish，所以一旦出现vector元素只有两个，而且还是指针的时候，直接把最后一个元素free了，后进行了copy，此时进行的是浅拷贝，又把指针复制到了第一个，再次进行free，造成了double free。

erase源码

![](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/QQ图片20200530162822.png)

继续溯源copy之后

![](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/QQ图片20200530163029.png)

这里如果在容器内的元素是指针，按这种方式，会进行浅拷贝。
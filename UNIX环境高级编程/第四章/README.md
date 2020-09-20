#### 文件时间

对于每个文件维护3个时间字段

|  字段   |          说明           |     例子     | ls选项 |
| :-----: | :---------------------: | :----------: | ------ |
| st_atim | 文件数据的最后访问时间  |     read     | -u     |
| st_mtim | 文件数据的最后修改时间  |    write     | 默认   |
| st_ctim | i节点状态的最后更改时间 | chmod，chown | -c     |

改变文件的访问和修改时间函数

```c
int futimens(int fd, const struct timespec times[2])
int utimensat(int fd, const char *path, const struct timespec times[2], int flag)
```

times数组的第一个元素包含访问时间，第二元素包含修改时间，时间值为日历时间即(1970.1.1 00:00:00)，如果times参数是一个空指针，则访问时间和修改时间两者都设置为当前时间。
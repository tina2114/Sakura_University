在unix环境高级编程中的gcc编译，靠普通的`gcc test.c`是无法编译成功的，因为虽然在程序中引用了，但gcc编译时需要自己指定引用的外部库，printf这些是系统的库，已经在环境变量里指定了，不需要我们指定。故此，编译时需要

```
gcc filename.c -lapue
```


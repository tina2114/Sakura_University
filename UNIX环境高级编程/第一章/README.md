#### 1.6.3.c

```c
#include "apue.h"

#include <sys/wait.h>

int main(int argc, char *argv[]) {
    char buf[MAXLINE];  // apue.h 中定义 #define	MAXLINE	4096
    pid_t pid;
    int status;

    printf("%% ");
    while (fgets(buf, MAXLINE, stdin) != NULL) {
        if (buf[strlen(buf) - 1] == '\n')
            buf[strlen(buf) - 1] = 0;

        if ((pid = fork()) < 0) {
            err_sys("fork error");
        } else if (pid == 0) {
            execlp(buf, buf, (char *) 0);
            err_ret("couldn't execute: %s", buf);
            exit(127);
        }

        if ((pid = waitpid(pid, &status, 0)) < 0)
            err_sys("waitpid error");
        printf("%% ");
    }
    exit(0);
}
```

**execlp函数**

函数说明：

execlp()会从PATH 环境变量所指的目录中查找符合参数file的文件名，找到后便执行该文件，然后将第二个以后的参数当做该文件的argv[0]、argv[1]……，最后一个参数必须用空[指针](https://baike.baidu.com/item/指针)(NULL)作结束。如果用常数0来表示一个空指针，则必须将它强制转换为一个字符指针，否则它将解释为整形参数，如果一个整形数的长度与char * 的长度不同，那么exec函数的[实际参数](https://baike.baidu.com/item/实际参数)就将出错。如果[函数调用](https://baike.baidu.com/item/函数调用)成功,进程自己的执行代码就会变成加载程序的代码,execlp()后边的代码也就不会执行了.

返回值：

如果执行成功则函数不会返回，执行失败则直接返回-1，失败原因存于errno 中。

[错误代码](https://baike.baidu.com/item/错误代码) 参考execve()。

范例：

/* 执行ls -al /etc/passwd execlp()会依PATH [变量](https://baike.baidu.com/item/变量)中的/bin找到/bin/ls */

\#include<unistd.h>

main()

{

execlp(“ls”,”ls”,”-al”,”/etc/passwd”,(char *)0);

}

执行：

-rw-r--r-- 1 root root 705 Sep 3 13 :52 /etc/passwd

----------------------------------------------------------------------------------------------------------------------------------------------

在子进程中，调用execlp以执行从标准输入读入的命令。这就用新的程序文件替换了子进程原先执行的程序文件。fork和跟随其后的exec两者的组合就是某些操作系统所称的产生（spawn）一个新进程。在UNIX系统中，这两部分分离成两个独立的函数。
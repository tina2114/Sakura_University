一个简单的时间获取的service程序

```c
#include <stdio.h>
#include <time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <string.h>

#define MAXLINE 4096
#define LISTENQ 1024

typedef struct sockaddr SA;
int main(int argc, char *argv[])
{
    // 定义监听文件符和链接文件符
    int listenfd,connfd;
    // 定义网络地址结构体
    struct sockaddr_in servaddr;
    // 定义缓冲区
    char buff[MAXLINE];
    // 定义计时时钟
    time_t ticks;

    // 创建一个TCP的IPv4网络链接;SOCK_DGRAM表示UDP
    listenfd = socket(AF_INET,SOCK_STREAM,0);
    // 初始化网络地址结构体
    bzero(&servaddr,sizeof(servaddr));
    // 初始化参数
    servaddr.sin_family = AF_INET; /* 设置网络协议 */
    servaddr.sin_addr.s_addr = htonl(INADDR_ANY); /* 设置ip地址 */
    servaddr.sin_port = htons(13) /* port = 13 */
    // 将socket和servaddr链接起来，监听端口
    bind(listenfd,(SA*)&servaddr,sizeof(servaddr));
    // 将套接字转化为监听套接字
    listen(listenfd,LISTENQ);
    
    for ( ; ; ) {
        //针对客户端接受的链接套接字,注意下面的代码到accept之后才能执行
		connfd = Accept(listenfd, (SA *) NULL, NULL);

    	ticks = time(NULL);
    	snprintf(buff, sizeof(buff), "%.24s\r\n", ctime(&ticks));
    	Write(connfd, buff, strlen(buff));

		Close(connfd);
	}
    
}
```

一个简单的时间获取的client程序

```c
#include	"unp.h"

int
main(int argc, char **argv)
{
	int					sockfd, n, total;
	char				recvline[MAXLINE + 1];
	struct sockaddr_in	servaddr;

	if (argc != 2)
		err_quit("usage: a.out <IPaddress>");

	if ( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
		err_sys("socket error");

	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_port   = htons(9999);	/* daytime server */
	if (inet_pton(AF_INET, argv[1], &servaddr.sin_addr) <= 0)
		err_quit("inet_pton error for %s", argv[1]);

	if (connect(sockfd, (SA *) &servaddr, sizeof(servaddr)) < 0)
		err_sys("connect error");

	while ( (n = read(sockfd, recvline, MAXLINE)) > 0) {
		recvline[n] = 0;	/* null terminate */
		total += 1;
		if (fputs(recvline, stdout) == EOF)
			err_sys("fputs error");
	}
	if (n < 0)
		err_sys("read error");
	
	printf("cylic:%d\n",total);
	exit(0);
}
```

### 课后习题

1.3 把daytimetcpcil.c中socket的参数改为9999，编译并运行，结果：

```
zhz@ubuntu:~/network/unpv13e/intro$ ./daytimetcpcli 127.0.0.1
socket error: Address family not supported by protocol
```

man errno

```
EAFNOSUPPORT    Address family not supported (POSIX.1)
```

1.4 给cli加一个计数器，返回read大于零的次数。

修改的代码：

```c
	while ( (n = read(sockfd, recvline, MAXLINE)) > 0) {
		recvline[n] = 0;	/* null terminate */
		total += 1;
		if (fputs(recvline, stdout) == EOF)
			err_sys("fputs error");
	}
```

结果：

```
zhz@ubuntu:~/network/unpv13e/intro$ ./daytimetcpcli 127.0.0.1
Tue Mar 16 08:09:04 2021
cylic:1
```

1.5 把write改成循环调用，每次写出结果字符串的一个字节，client计数器输出为多少？

修改的代码：

```c
	do
	{
		Write(connfd, buff+n, 1);
		n += 1;
	}
	while(n < strlen(buff));

		Close(connfd);
	}
```

结果:

```c
zhz@ubuntu:~/network/unpv13e/intro$ ./daytimetcpcli 127.0.0.1
Tue Mar 16 08:09:04 2021
cylic:1
```

¿ 怎么感觉不对，后来查看了书上的课后解析

![image-20210316232312738](https://gitee.com/zhzzhz/blog_warehouse/raw/master/img/image-20210316232312738.png)
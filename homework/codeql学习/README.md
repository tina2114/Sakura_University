本文很大程度上参考了https://zhuanlan.zhihu.com/p/137569940

## 配置codeql环境

1. 下载vscode

2. 在vscode中安装CodeQL插件

3. Clone该项目

   ```bash
   git clone --recursive https://github.com/github/vscode-codeql-starter/
   ```

4. 在 VSCode 菜单中点击 `File > Open Workspace` 选择 `vscode-codeql-starter/vscode-codeql-starter.code-workspace` 这个文件来打开这个工作区。
5. 下载uboot CodeQL数据库
6. 使用 VSCode 快捷键 "ctrl + shift + p" 进入命令模式，输入 "codeql choose database" 看到相应的选项后，点击就可以添加上前面解压的 uboot codeql 数据库。
7. 在前面打开工作区 VSCode 中使用 `File -> Add Folder to Workspace` 添加前面机器人新建的项目文件夹到当前工作区。（也就是codeql-uboot ）

## 实验环节

实验一二略去不提，就是上述的环境配置

### 实验三

让我们查找源码中名字为strlen的函数

```
import cpp

from Function f
where f.getName() = "strlen"
select f, "a function named strlen"
```

### 实验四

类似的，查找名字为memcpy的函数

```
import cpp
from Function f
where f.getName() = "memcpy"
select f,"a function named strlen"
```

### 实验五

查找名为"ntohs","ntohl","ntohll"的宏

```
import cpp
// Macro 定义宏定义
from Macro f
where f.getName() in ["ntohs","ntohl","ntohll"]
select f,"Macro named ntohs"
```

### 实验六

查找哪些函数调用了memcpy函数，这里两种写法，这里直接运用了第二种混合简化的写法

```
// 搜寻哪些函数调用了这个memcpy函数
//   import cpp
//   from Function f,FunctionCall c
//   where c.getTarget() = f and f.getName() = "memcpy"
//   select c,f
import cpp
from FunctionCall c
where c.getTarget().getName() = "memcpy"
select c
```

### 实验七
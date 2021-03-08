VMware SVGA是一类虚拟化视频设备

对于VMware SVGA II 设备，有一组I/O端口（15个端口）和两个MMIO地址空间。

两个MMIO存储区域有特地的用途：

+ 较大的一个是帧缓冲区。它是存储像素的存储区域，通常一个像素存储为4个字节
+ 较小的是SVGA FIFO。Guest可以在FIFO中存储视频命令，Host将依次读取和解释这些命令


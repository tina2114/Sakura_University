ELF文件结构

```C
struct Elf64_Ehdr {
   unsigned char e_ident[EI_NIDENT];
   Elf64_Half e_type;	// 目标文件类型
   Elf64_Half e_machine;	// 目标文件的体系结构类型
   Elf64_Word e_version;	// 目标文件版本
   Elf64_Addr e_entry;	// 程序入口的虚拟地址
   Elf64_Off e_phoff;	// 程序头表的偏移量
   Elf64_Off e_shoff;	// 节区头表的偏移量
   Elf64_Word e_flags;	// 与文件相关的处理器的标志
   Elf64_Half e_ehsize;	// ELF头部的大小
   Elf64_Half e_phentsize;	// 程序头表的表项大小
   Elf64_Half e_phnum;	// 程序头表的表项数目
   Elf64_Half e_shentsize;	// 节头表的表项大小
   Elf64_Half e_shnum;	// 节头表的表项数目
   Elf64_Half e_shstrndx;	// 节头表中与节名称字符串相关的表项的索引

 struct Elf32_Ehdr {
   unsigned char e_ident[EI_NIDENT]; // ELF Identification bytes
   Elf32_Half e_type;                // Type of file (see ET_* below)
   Elf32_Half e_machine;   // Required architecture for this file (see EM_*)
   Elf32_Word e_version;   // Must be equal to 1
   Elf32_Addr e_entry;     // Address to jump to in order to start program
   Elf32_Off e_phoff;      // Program header table's file offset, in bytes
   Elf32_Off e_shoff;      // Section header table's file offset, in bytes
   Elf32_Word e_flags;     // Processor-specific flags
   Elf32_Half e_ehsize;    // Size of ELF header, in bytes
   Elf32_Half e_phentsize; // Size of an entry in the program header table
   Elf32_Half e_phnum;     // Number of entries in the program header table
   Elf32_Half e_shentsize; // Size of an entry in the section header table
   Elf32_Half e_shnum;     // Number of entries in the section header table
   Elf32_Half e_shstrndx;  // Sect hdr table index of sect name string table
```


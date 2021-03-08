### SVGA FIFO

VirtualBox模拟了**VMware虚拟SVGA**设备

SVGA FIFO是host和guest之间共享的MMIO区域，其由两部分组成，第一部分由寄存器FIFO组成，它保存关于设备的信息；第二部分由guest os写入并被host 进程清除的FIFO数据组成。每个SVGA命令由该结构体组成：

```c
typedef
struct {
   uint32_t               id; duplicate
   uint32_t               size;
} SVGA3dCmdHeader;
```





一些数据结构

```c
typedef struct VBOXSCSI
{
    /** The identify register. */
    uint8_t              regIdentify;
    /** The target device. */
    uint8_t              uTargetDevice;
    /** Transfer direction. */
    uint8_t              uTxDir;
    /** The size of the CDB we are issuing. */
    uint8_t              cbCDB;
    /** The command to issue. */
    uint8_t              abCDB[VBOXSCSI_CDB_SIZE_MAX + 4];
    /** Current position in the array. */
    uint8_t              iCDB;

#if HC_ARCH_BITS == 64
    uint32_t             Alignment0;
#endif

    /** Pointer to the buffer holding the data. */
    R3PTRTYPE(uint8_t *) pbBuf;
    /** Size of the buffer in bytes. */
    uint32_t             cbBuf;
    /** The number of bytes left to read/write in the
     *  buffer.  It is decremented when the guest (BIOS) accesses
     *  the buffer data. */
    uint32_t             cbBufLeft;
    /** Current position in the buffer (offBuf if you like). */
    uint32_t             iBuf;
    /** The result code of last operation. */
    int32_t              rcCompletion;
    /** Flag whether a request is pending. */
    volatile bool        fBusy;
    /** The state we are in when fetching a command from the BIOS. */
    VBOXSCSISTATE        enmState;
    /** Critical section protecting the device state. */
    RTCRITSECT           CritSect;
} VBOXSCSI, *PVBOXSCSI;

typedef struct VGASTATER3
{
    R3PTRTYPE(uint8_t *)        pbVRam;
    R3PTRTYPE(FNGETBPP *)       get_bpp;
    R3PTRTYPE(FNGETOFFSETS *)   get_offsets;
    R3PTRTYPE(FNGETRESOLUTION *) get_resolution;
    R3PTRTYPE(FNRGBTOPIXEL *)   rgb_to_pixel;
    R3PTRTYPE(FNCURSORINVALIDATE *) cursor_invalidate;
    R3PTRTYPE(FNCURSORDRAWLINE *) cursor_draw_line;

    /** Pointer to the device instance.
     * @note Only for getting our bearings in interface methods.  */
    PPDMDEVINSR3                pDevIns;
#ifdef VBOX_WITH_HGSMI
    R3PTRTYPE(PHGSMIINSTANCE)   pHGSMI;
#endif
#ifdef VBOX_WITH_VDMA
    R3PTRTYPE(PVBOXVDMAHOST)    pVdma;
#endif

    /** LUN\#0: The display port base interface. */
    PDMIBASE                    IBase;
    /** LUN\#0: The display port interface. */
    PDMIDISPLAYPORT             IPort;
#ifdef VBOX_WITH_HGSMI
    /** LUN\#0: VBVA callbacks interface */
    PDMIDISPLAYVBVACALLBACKS    IVBVACallbacks;
#endif
    /** Status LUN: Leds interface. */
    PDMILEDPORTS                ILeds;

    /** Pointer to base interface of the driver. */
    R3PTRTYPE(PPDMIBASE)        pDrvBase;
    /** Pointer to display connector interface of the driver. */
    R3PTRTYPE(PPDMIDISPLAYCONNECTOR) pDrv;

    /** Status LUN: Partner of ILeds. */
    R3PTRTYPE(PPDMILEDCONNECTORS) pLedsConnector;

#ifdef VBOX_WITH_VMSVGA
    /** The VMSVGA ring-3 state. */
    VMSVGASTATER3               svga;
#endif

    /** The VGA BIOS ROM data. */
    R3PTRTYPE(uint8_t *)        pbVgaBios;
    /** The size of the VGA BIOS ROM. */
    uint64_t                    cbVgaBios;
    /** The name of the VGA BIOS ROM file. */
    R3PTRTYPE(char *)           pszVgaBiosFile;

    /** @name Logo data
     * @{ */
    /** Current logo data offset. */
    uint32_t                    offLogoData;
    /** The size of the BIOS logo data. */
    uint32_t                    cbLogo;
    /** Current logo command. */
    uint16_t                    LogoCommand;
    /** Bitmap width. */
    uint16_t                    cxLogo;
    /** Bitmap height. */
    uint16_t                    cyLogo;
    /** Bitmap planes. */
    uint16_t                    cLogoPlanes;
    /** Bitmap depth. */
    uint16_t                    cLogoBits;
    /** Bitmap compression. */
    uint16_t                    LogoCompression;
    /** Bitmap colors used. */
    uint16_t                    cLogoUsedColors;
    /** Palette size. */
    uint16_t                    cLogoPalEntries;
    /** Clear screen flag. */
    uint8_t                     fLogoClearScreen;
    bool                        fBootMenuInverse;
    uint8_t                     Padding8[6];
    /** Palette data. */
    uint32_t                    au32LogoPalette[256];
    /** The BIOS logo data. */
    R3PTRTYPE(uint8_t *)        pbLogo;
    /** The name of the logo file. */
    R3PTRTYPE(char *)           pszLogoFile;
    /** Bitmap image data. */
    R3PTRTYPE(uint8_t *)        pbLogoBitmap;
    /** @} */

    /** @name VBE extra data (modes)
     * @{ */
    /** The VBE BIOS extra data. */
    R3PTRTYPE(uint8_t *)        pbVBEExtraData;
    /** The size of the VBE BIOS extra data. */
    uint16_t                    cbVBEExtraData;
    /** The VBE BIOS current memory address. */
    uint16_t                    u16VBEExtraAddress;
    uint16_t                    Padding7[2];
    /** @} */

} VGASTATER3;
```

vboxscsiWriteRegister函数的情况如下：

+ iRegister为0x00时：

  - enmState为no_command，为设备赋值，enmState赋值为READ_TXDIR

  - enmState为READ_TXDIR时，如果val不是读或写就重置状态，否则就将val的值写入uTxDir确定读写状态，enmState赋值为CDF_SIZE_BUFHI

  - enmState为CDF_SIZE_BUFHI时，将val & 0x0F后赋值给cbCDB，并将(val & 0xF0) << 12赋值给cbbuf，enmState赋值为READ_BUFFER_SIZE_LSB

  - enmState为READ_BUFFER_SIZE_LSB时，(uint32_t) cbBuf |= (uint8_t) val，enmState赋值为READ_BUFFER_SIZE_MID

  - enmState为READ_BUFFER_SIZE_MID时，(uint32_t) cbBuf |= (uint16_t) val << 8，enmState赋值为READ_COMMAND

  - enmState为READ_COMMAND时，为要发送的地址填入val数据，如果数组当前指向的位置等于正在发送的大小，enmState赋值为COMMAND_READY，cbBufLeft = cbBuf（也就是将缓冲区中剩余可读取/写入的字节赋值为一开始输入的val）

    如果uTxDir == TO_DEVICE也就是要往设备里写数据，那么会根据你的cbBuf来进行alloc

    否则就是读设备的数据，fBusy == true

+ iRegister为0x01时：

  - 如果enmState != COMMAND_READY，重置设备
    - 如果缓冲区中剩余的可读写字节 > 0，就进行写入。

+ iRegister为0x02时：

  - regIdentity = uval

+ iRegister为0x03时：

  - 重置设备



vmsvgaIOWrite函数情况如下：

+ offport为0时，pThis->svga.u32IndexReg = u32；

+ offport为1时，进入writeport，进行写操作

vmsvgaWritePort函数情况如下：

​	先进行 idxReg = pThis->svga.u32IndexReg，然后根据idxReg来确定分支

+ 当idxReg为0时，如果val == (0x900000UL << 8 | (0))   |   val == (0x900000UL << 8 | (1))  |  (0x900000UL << 8 | (2))  ， 进行赋值 u32SVGAId = u32
+ 当idxReg为1时， (u32 & 1) && svga.fEnabled == false时，将pThisCC->pbVRam 复制到  pThisCC->svga.pbVgaFrameBufferR3
  + 接着将fEnabled赋值为val
+ 当idxReg为2时，




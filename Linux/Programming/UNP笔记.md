# UNP 笔记
## 1. 基础知识
  * ### TCP基础知识
    * 五元组可以唯一确定一个会话: 源IP地址、目的IP地址、源端口号、目的端口号、协议号
    * 四元组可以唯一确定一个TCP连接: 源IP地址、目的IP地址、源端口号、目的端口号
    * 端口号
      * 0~1023为保留端口(分配使用这些端口的程序必须以root用户权限启动)，由IANA负责分配和控制。
      * 1024～49151为用户可使用的端口范围，这些端口不受IANA控制，不过由IANA登记并提供使用情况清单。
      * 49152-65535为动态端口(临时端口)范围。
    * 缓冲区大小及限制
      * 无需分片即能穿才路径的最大传输单位，在两个主机之间的路径中最小的MTU称为路径的MTU(Path MTU)。
      * SYN分节上的MSS目的是告诉对端其重组缓冲区大小的实际值，从而试图避免分片，MSS = MTU - IP Header - TCP Header。
      * 当IP数据包从某个接口输出时，如果大小超过链路MTU，IPv4和IPv6将对IP数据包进行分片。IPv6禁止中间节点设备分片，分片只能在两端主机进行。IPv4主机和中间节点设备都可对IP数据包进行分片，可通过设置IP头部的DF位防止主机和中间节点设备对IP数据包分片
      * MSS协商
        ![image](https://github.com/ManyyWu/Notes/blob/master/image/mss.png)
      * TCP输出
        ![image](https://github.com/ManyyWu/Notes/blob/master/image/tcp_out.png)
      * UDP输出
        ![image](https://github.com/ManyyWu/Notes/blob/master/image/udp_out.png)
  * ### TCP三次握手和四次挥手
    ![image](https://github.com/ManyyWu/Notes/blob/master/image/tcp_connect_and_close.png)
  * ### TCP状态转换
    ![image](https://github.com/ManyyWu/Notes/blob/master/image/tcp_status_convert.png)
  * ### TCP连接过程
    ![image](https://github.com/ManyyWu/Notes/blob/master/image/tcp_cs.png)
## 2. 函数定义
  * ### 套接字地址结构
    * #### IPv4套接字结构
      ```C
      #include <netinet/in.h>
      struct in_addr {
          in_addr_t s_addr;
      };
      struct sockaddr_in {
          uint8_t        sin_len;     /* length of structure (16) */
          sa_family_t    sin_family;  /* AF_INET */
          in_port_t      sin_port;    /* 16-bit TCP or UDP port number */
                                      /* network byte ordered */
          struct in_addr sin_addr;    /* 32-bit IPv4 address */
                                      /* network byte ordered */
          char           sin_zero[8]; /* unused */
      };
      ```
    * #### IPv6套接字结构
      ```C
      #include <netinet/in.h>
      struct in6_addr {
      union {
          uint8_t    u6_addr8[16]; /* 128-bit IPv6 address */
                                   /* network byte ordered */
      };
      #define SIN6_LEN             /* required for compile-time tests */
      struct sockaddr_in6 {
          uint8_t         sin6_len;      /* length of this struct (28) */
          sa_family_t     sin6_family;   /* AF_INET6 */
          in_port_t       sin6_port;     /* transport layer port# */
                                         /* network byte ordered */
          uint32_t        sin6_flowinfo; /* IPv6 information, undefined */
          struct in6_addr sin6_addr;     /* IPv6 address */
                                         /* network byte ordered */
          uint32_t        sin6_scope_id; /* set of interfaces for a scope */
      };
      ```
    * #### 通用套接字结构sockaddr_storage，足以容纳系统支持的任何套接字地址结构
      ```C
      #include <netinet/in.h>
      struct sockaddr_storage {
          uint8_t        ss_len;    /* length of struct  */
          sa_family_t    ss_family; /* address family, AF_xxx value */
      /* implemetation-dependent elemetns to provide:
       *  a) aligenment sufficient to fullfill the aligenment requirements of
       *     all socket address types that the system supports.
       *  b) enough storage to hold any type of socket address that the
       *     system supports.
       */
      };
      ```
    * #### 通用套接字结构sockaddr
      ```C
      #include <sys/socket.h>
      struct sockaddr {
          uint8_t     sa_len;      /* total length */
          sa_family_t sa_family;   /* address family: AF_xxx value */
          char        sa_data[14]; /* protocol-specific address */
      };
      ```
    * #### 字节序转换函数
      ```C
      #include <netinet/in.h>
      uint16_t htons (uint16_t host16bitvalue);
      uint32_t htons (uint32_t host32bitvalue);
      uint16_t htons (uint16_t net16bitvalue);
      uint32_t htons (uint32_t net32bitvalue);
      ```
      * **其中h代表host，n代表network，s代表short，l代表long。**
    * #### 字节操作函数
      * Berkeley函数
      ```C
      #include <strings.h>
      void bzero (void *dest, size_t nbytes);
      void bcopy (const void *src, void *dest, size_t nbytes);
      int  bcmp  (const void *ptr1, const void *ptr2, size_t nbytes);
      /* 返回：若相等则为0，否则为非0 */
      ```
      * ANSI C函数
      ```C
      #include <string.h>
      void *memset (void *dest, int c, size_t len);
      void *memcpy (void *dest, const void * src, size_t nbytes);
      int   memcmp (const void *ptr1, const void *ptr2, size_t nbytes);
      /* 返回：若相等则为0，>0或<0 */
      ```
    * #### IPv4地址转换函数
      ```C
      #include <arpa/inet.h>
      int       inet_aton (const char *strptr, struct in_addr *addrptr);
      /* 返回：若字符串有效则为1，否则为0 */
      in_addr_t inet_addr (const char *strptr);
      /* 返回：若字符串有效则为32位二进制网络字节序的IPv4地址，否则为INADDR_NONE */
      char *    inet_ntoa (struct in_addr inaddr);
      /* 返回：指向一个点分十进制数串的指针 */
      ```
      * **a代表点分十进制数串，n代表网络字节序二进制值。**
      * **对于inet_addr()，INADDR_NONE为32位值0xffffffff，当strptr为"255.255.255.255"时，inet_addr()返回INADDR_NONE，因此该函数不能用来处理地址"255.255.255.255"，如今inet_addr()已弃用，最好使用新的inet_aton()。**
    * #### 适用于Ipv4和IPv6的地址转换函数
      ```C
      #include <arpa/inet.h>
      int         inet_pton (int family, const char *strptr, void *addrptr);
      /* 返回：若成功则返回1，若输入不是有效的表达式格式则返回0，若出错则为-1 */
      const char *inet_ntop (int family, const char *addrptr, char *strptr, size_t len);
      /* 返回：若成功则为指向结果的指针，若出错则为NULL */
      ```
      * 对于IPv4，family为AF_INET， 对于IPv6，family为AF_INET6。
      * 如果不被支持的地址族作为family参数，这两个函数就都返回-1，并将errno置为EAFNOSUPPORT。
      * 如果len太小，那么返回NULL，并置errno为ENOSPC。
      * inet_ntop()的参数strptr不可为NULL。
  * ### TCP套接字编程
    * #### socket()
      ```C
      #include <sys/socket.h>
      int socket (int family, int type, int protocol);
      /* 返回：若成功则为非负描述符，若出错则为-1 */
      ```
      * family指明协议族，type指明套接字类型，protocol指明具体协议，0表示默认值。
      * socket()的family常值
        |family|说明|
        |----|----|
        |AF_INET|IPv4协议|
        |AF_INET6|IPv6协议|
        |AF_LOCL|Unix域协议|
        |AF_ROUTE|路由套接字|
        |AF_KEY|密钥套接字|
      * socket()的type常值
        |type|说明|
        |----|----|
        |SOCK_STREAM|字节流套接字|
        |SOCK_DGRAM|数据报套接字|
        |SOCK_SEQPACKET|有序分组套接字|
        |SOCK_RAW|原始套接字|
      * socket()的protocol常值
        |protocol|说明|
        |----|----|
        |IPPROTO_TCP|TCP传输协议|
        |IPPROTO_DUP|UDP传输协议|
        |IPPROTO_SCTP|SCTP传输协议|
      * socket()中family和type的组合
        ||AF_INET|AF_INET6|AF_LOCOL|AF_ROUTE|AF_KEY|
        |----|----|----|----|----|----|
        |SOCK_STREAM|TCP/SCTP|TCP/SCTP|是|||
        |SOCK_DGRAM|UDP|UDP|是|||
        |SOCK_SEQPACKET|SCTP|SCTP|是|||
        |SOCK_RAW|IPv4|IPv6||是|是|
    * #### connect()
      ```C
      #include <sys/socket.h>
      int connect (int sockfd, const struct sockaddr *servaddr, socklen_t addrlen);
      /* 返回：若成功则为0，若出错则为-1 */
      ```
      * sockfd为socket()返回的套接字描述符，servaddr指向服务器地址结构(该结构是包含协议服务器IP地址、服务器端口号的三元组)，addrlen为地址结构的大小。
      * connect()出错的几种情况
         |errno|原因|
         |----|----|
         |ETIMEDOUT|客户端未收到SYN分节，连接超时。|
         |ECONNREFUSED|服务器对客户端响应RST，表明服务器没有监听指定端口，这是一个硬错误。|
         |EHOSTUNREACH|客户端发出的SYN在中间某个路由器上引发一个"destination unreachable"的ICMP错误，这是一个软错误。|
         |ENETUNREACH|同EHOSTUNREACH。|
         ***connect()失败则表示该套接字不可再用，必须关闭，不能再对该套接字再次调用connect()***
    * #### bind()
      ```C
      #include <sys/socket.h>
      int bind (int sockfd, const struct sockaddr *myaddr, socklen_t addrlen);
      /* 返回：若成功则为0，若出错则为-1 */
      ```
      * sockfd为监听套接字，myaddr指向监听地址结构，addrlen为地址结构的大小。
      * bind()返回的常见错误是EADDRINUSE，可使用SO_REUSEADDR和SO_REUSEPORT这两个套接字选项设置地址重用和端口重用。
      * bind()不同的IP地址和端口号组合产生的结果
         |IP地址|端口|结果|
         |----|----|----|
         |通配地址|0|内核选择IP和端口|
         |通配地址|非0|内核选择IP，进程指定端口|
         |本地IP地址|0|进程指定IP，内核选择端口|
         |本地IP地址|非0|进程指定IP和端口|
      * 对于IPv4，监听端口号通常指定为INADDR_ANY，其值一般为0。对于IPv6，监听端口通常指定为in6addr_any，其值为常值IN6ADDR_ANY_INIT。
        ```C
        #include <netinet/in.h>
        #define INADDR_ANY (u_int32_t)0x00000000
        extern const struct in6_addr in6addr_any 
        ```
      * 如果让内核为套接字选择一个临时端口号，函数bind()并不返回所选择的值。必须调用getsockname()获取协议地址和端口号。
## 3. TCP异常处理
  * ### 收到RST的几种情况
     |条件|errno|处理方法|
     |----|----|----|
     |目的地为某端口的SYN到达，然而该端口上没有正在监听的服务器|||
     |TCP想取消一个已有连接|||
     |TCP接收到一个根本不存在的连接上的分节|||
  * ### ICMP错误
     |条件|errno|处理方法|
     |----|----|----|
     ||||
  * ### 进程一端退出(exit、C-c、异常终止)
    * 进程退出等同于主动关闭调用close()，内核会关闭所有文件描述符，触发FIN分节发送(如果设置了SO_LINGER的l_onoff = 1则发送RST分节)。
    * FIN分节处理: 另一端read()返回0表示对端关闭。
    * RST分节处理: 另一端read()返回-1并设置errno = ECONNRESET，收到RST后调用send()则导致进程接收SIGPIPE信号，该信号默认终止进程。[详解](#SIGPIPE信号)
  * ### 对端主机崩溃(非主动关闭)、中间路由不通
     当对端主机崩溃，TCP会对数据进行重传，内核发送缓冲区中数据不断增加，超时时段内，只要内核发送缓冲区未满，write()就不会返回错误，超时返回ETIMEDOUT错误。
     处理方法:
     1. 使用KEEP_ALIVE心跳机制
     2. 应用层实现心跳机制
     如果某个中间路由器判定服务器主机已不可达，从而响应一个“目的不可达的消息”，read()返回的错误是EHOSTUNREACH或ENETUNREACH。
  * ### 服务器崩溃重启
     当服务器崩溃重启后，原来的TCP连接信息已丢失，对后续接收的客户端以RST响应，导致read()返回ECONNRESET错误
## 4. 重点
  * ### 服务端关闭连接不进入TIME_WAIT的方法
    1. 客户端主动关闭连接。
    2. 服务端设置SO_LINGER的l_onoff = 1使用RST方式关闭连接。
    3. 服务端使用SO_REUSERPORT选项允许端口重用。
  * ### close()和shutdown()的区别
    * 调用close()把描述符引用数减1，仅在引用数为0时才关闭套接字，而调用shutdown()不管引用计数直接触发TCP的正常终止序列。
    * 调用close()直接终止两个方向的数据传输，而shutdown()可以只关闭读半部或写半部的连接，此时仍可以进行写或读操作。如图所示:
      ![image](https://github.com/ManyyWu/Notes/blob/master/image/tcp_shutdown.png)
  * ### connect()
    * 当connect()失败则该套接字不可再用，必须关闭，不能再对该套接字再次调用connect()函数。
  * ### SIGCHLD信号处理函数中调用wait()和waitpid()
    * 在SIGCHLD信号处理函数中，应该使用waitpid()函数。如图:
      ![image](https://github.com/ManyyWu/Notes/blob/master/image/wait_and_waitpid.png)
    * 如果使用wait()函数，若5个SIGCHLD同时传递给父进程，该信号处理函数可能只被执行一次，导至留下4个僵死进程。
    正确的写法应为:
      ```C
      void
      sig_chld (int signo)
      {
          pid_t pid;
          int stat;
          while ((pid = waitpid(-1, &stat, WNOHANG)) > 0)
              printf("child %d terminated, err_code: %d\n", pid, stat);
          return;
      }
      /*
      * 其中WNOHANG选项告知内核在没有已终止的子进程时不要阻塞。
      */
      ```
  * ### SIGPIPE信号
    * 当一个进程向某个已收到RST的套接字进行写操作时，内核向该进程发出SIGPIPE信号(该信号默认是终止进程)，write()函数将返回EPIPE错误。
    * 结合TCP的"四次握手"关闭，TCP是全双工的信道，TCP连接两端的两个端点各负责一条。当对端调用close()时，虽然本意是关闭整个两条信道，但本端只是收到FIN分节，按照TCP协议的语义，表示对端只是关闭了其所负责的那一条单工信道，仍然可以继续接收数据。也就是说，因为TCP协议的限制，本无法获知对端的socket是调用了close()还是shutdown()。本端收到FIN分节之后，如果没有调用read()，则无法知道连接是否已关闭。此时仍向对端发送数据，第一次调用write()，write()仅把数据拷贝到发送缓冲区，并不会返回错误，但对端收到数据后会返回RST。第二次调用write()时便会触发SIGPIPE信号。
    * 写一个已接收FIN的套接字不成问题，但写一个已接收RST的套接字则是一个错误。
    * 处理方法:
      * 如果在出错时要进行特殊措施(如写日志)，可捕获SIGPIPE信号。如果同时使用多个套接字，该信号无法判断是哪个套接字出错，如果确实需要判断，则需要在信号返回之后，在write()返回处判断出错的套接字。
      * 如果没有特殊措施，直接忽略该信号
  * ### select()限制问题
    * select()限定的fd最大值是FD_SETSIZE(Linux中默认为1024), Linux默认允许进程打开文件的最大数量也是1024
## 4. 文字格式规范
  * 中文主导用中文'**，**'; 英文主导用英文'**,**'，且'**,**'后加一个空格。
  * 中文主导句尾加'**。**'; 英文主导句尾加'**.**'。
  * 括号统一用英文'**()**'。
  * 不使用**TAB**。
  * 代码缩进**4**个空格。
  * 统一使用英文分号'**;**'。
  * "函数"使用"**()**"代替。
## 5. Markdown教程
  * 页内跳转
     `[Hello World](#hello-world)`，空格使用"**-**"代替，标题中英文使用小写。

## Test
  * https://my.oschina.net/shelllife/blog/178090
  * https://blog.csdn.net/fangwei1235/article/details/6753661

# Shadowsocks 原理及源码分析
Shadowsocks（简称SS）是一种基于Socks5代理方式的加密传输协议，也可以指实现这个协议的各种开发包。当前包使用Python、C、C++、C#、Go语言等编程语言开发，大部分主要实现（iOS平台的除外）采用Apache许可证、GPL、MIT许可证等多种自由软件许可协议开放源代码。Shadowsocks分为服务器端和客户端，在使用之前，需要先将服务器端程序部署到服务器上面，然后通过客户端连接并创建本地代理。
在中国大陆，本工具广泛用于突破防火长城（GFW），以浏览被封锁、遮蔽或干扰的内容。2015年8月22日，Shadowsocks原作者Clowwindy称受到了中国政府的压力，宣布停止维护此计划（项目）并移除其个人页面所存储的源代码。
为了避免关键词过滤，网民会根据谐音将ShadowsocksR称为“酸酸乳”（SSR），将Shadowsocks称为“酸酸”（SS）。
* [Shadowsocks Wiki](https://zh.wikipedia.org/wiki/Shadowsocks)
* [Github Projects](https://github.com/shadowsocks)
## 1. ss-local、ss-redir、ss-tunnel、ss-server四者的区别：
__原文地址：http://ppya.ml/archives/138__
* ss-server：
ss-server是shadowsocks的服务端。
* ss-local：
ss-local是一个本地运行的socks5客户端，提供socks5代理的程序 。
注意：这个socks5代理和http代理在概念上没有什么两样，只不过对于http代理，目前绝大多数的软件和系统都完美的支持了。你可以随便找个软件，都可以找到一个http_proxy的代理选项，windows和linux系统也都支持http代理，但是对于socks5代理，目前只有部分浏览器支持和少数软件支持，最典型的就是浏览器，可以直接使用此种代理。不过，我们可以在我们的应用软件和socks5代理（也就是ss-local）之间再添加一层代理，那这层代理的作用是什么呢？很简单，就是使用类似privoxy这样的代理软件，将来自应用程序的普通http代理转发到提供socks5代理的ss-local上，这样我们就可以在应用软件上使用http代理，将其proxy_server设置为privoxy的地址和端口，然后再配置privoxy将其转发至ss-local。
* ss-redir：
ss-redir也是在本地运行的程序，不过它可以提供透明代理。
先解释一下ss-redir的透明代理：
首先通过iptables将本机的数据包全部重定向至ss-redir的监听地址，当上层应用发出数据包后被iptables重定向至ss-redir，ss-redir将数据包原原本本的打包好并加密，通过与ss服务器建立的ss通道，将其发送至ss服务器。ss-server接收到此包，先解密，然后根据数据包中的目标ip地址，将其发送至目标服务器，目标服务器做出应答后，将应答数据返回给ss-server，然后ss-server通过ss通道，将其传回ss-redir，最后ss-redir返回上层应用。从上面可以看出，发出的数据包的目标ip地址和端口port始终没有变，始终还是上层应用指定的目标ip和端口port。
* ss-tunnel：
这个和ssh的本地端口转发颇为相似，首先ss-tunnel在本地监听一个端口（假设为127.0.0.1:1053），那么发往127.0.0.1:1053的数据包，ss-tunnel会通过与ss服务器建立的ss通道，将其发往ss服务器，ss服务器根据ss-tunnel设置的远程地址和端口（比如8.8.8.8:53），将数据包发往8.8.8.8:53，8.8.8.8:53响应后，返回数据给ss服务器，ss服务器再将它返回给ss-tunnel，最后ss-tunnel将其返回给上层应用。对比ss-redir，ss-tunnel的目标地址其实是发生了改变的，开始的目的地址是127.0.0.1:1053，然后经过ss-tunnel发往ss服务器后，目的地址变为了8.8.8.8:53，然后再将此数据包发给8.8.8.8，最后返回。
* ss-local和ss-redir优缺点对比
ss-local配合privoxy可以做到shell终端方式的http、https代理，再配合gfw.action，可以只代理被墙的网站，而其他正常的网站走直连。最主要的一点是：ss-local不存在dns污染问题，因为dns默认是远程解析，即ss服务器帮你解析dns。
而ss-redir配合iptables、ipset，也能做到只代理国外的地址，大陆的直连。并且，不只是支持http、https这两种协议的代理，理论能够代理所有TCP、UDP的流量。不过，ss-redir相比ss-local的缺点是，ss-redir需要额外解决dns污染问题。
* 再谈谈dns污染问题如何解决
第一种：ss-redir转发tcp、udp流量(包括dns)，这时系统dns设置为8.8.8.8等国外公共dns，dns查询走ss通道，由于dns还是走的udp(非明文)，在某些网络环境下udp丢包会较严重(比如我大电信)。
第二种：ss-redir转发tcp、udp流量(除了dns)，用ss-tunnel来建立udp转发，将dns通过ss通道，转发至8.8.8.8:53等上游公共dns，此时的dns解析依旧是udp方式(非明文)，某些网络环境下udp丢包会较严重(系统dns设置为127.0.0.1)。
第三种：ss-redir转发tcp、udp流量(除了dns)，通过pdnsd之类的软件，将udp/53方式的dns查询转换为tcp方式，然后再将该tcp方式的dns查询数据通过ss-redir的tcp转发，将其发送至目标dns服务器，完成解析(系统dns设置为127.0.0.1)。
第四种：ss-redir转发tcp、udp流量(除了dns)，通过dnscrypt之类的软件，将udp明文方式的dns查询加密，然后再发送给支持该加密方式的上游公共dns服务器，完成解析，这种udp方式的dns查询和传统的明文方式查询的区别，就如同http和https的区别(系统dns设置为127.0.0.1)。
具体选择哪种方式，随你自己，求速度就用udp方式查询dns，注意该udp方式的dns查询是加密了的哦，不是普通的udp/53明文方式，明文方式已经被gfw玩坏了，只能使用加密的！不过某些网络下，udp丢包较严重，还有一点注意，如果是通过ss转发udp的dns，记得检查ss服务商有没有开启udp转发，一般付费的服务商都是带有udp转发的，免费的话就少了。如果你不是那么的追求速度，而是想保障dns的查询可靠度，那么就选择tcp方式的dns查询吧！
## 2. 安装与配置
__[Archlinux Wiki](https://wiki.archlinux.org/index.php/Shadowsocks_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))__
## 3. 源代码分析

> * ### ss-local
>>
> * ### ss-server
>>
## 其他
* [ss/ssr/v2ray/socks5 透明代理](https://www.zfl9.com/ss-redir.html)
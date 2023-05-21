# skynet

## 目录结构
  * 3rd：第三方代码
  * lualib：lua库
  * lualib-src：lua调用的c库
  * service：lua服务
  * service-src：c库
  * skynet-src：主程序代码
  * client-src：客户端测试代码
  * examples：示例
  * test：测试代码

## 编译、启动
  $sudoapt-getinstallautoconflibreadline-dev
  $cdskynet && makelinux
  $cpexamples/conf . && cpexamples/conf.path .
  $./skynetconf

## 配置
  * 必要配置项
    * thread：启动多少个工作线程。通常不要将它配置超过你实际拥有的CPU核心数。
    * bootstrap：skynet启动的第一个服务以及其启动参数。默认配置为snluabootstrap，即启动一个名为bootstrap的lua服务。通常指的是service/bootstrap.lua这段代码。
    * cpath：用C编写的服务模块的位置，通常指cservice下那些.so文件。如果你的系统的动态库不是以.so为后缀，需要做相应的修改。这个路径可以配置多项，以;分割。
  * bootstrap配置项
    * logger：它决定了skynet内建的skynet_error这个CAPI将信息输出到什么文件中。如果logger配置为nil，将输出到标准输出。你可以配置一个文件名来将信息记录在特定文件中。
    * logservice：默认为 "logger" ，你可以配置为你定制的log服务（比如加上时间戳等更多信息）。可以参考service_logger.c来实现它。注：如果你希望用lua来编写这个服务，可以在这里填写snlua，然后在logger配置具体的lua服务的名字。在examples目录下，有config.userlog这个范例可供参考。
    * logpath：配置一个路径，当你运行时为一个服务打开log时，这个服务所有的输入消息都会被记录在这个目录下，文件名为服务地址。
    * standalone：如果把这个skynet进程作为主进程启动（skynet可以由分布在多台机器上的多个进程构成网络），那么需要配置standalone这一项，表示这个进程是主节点，它需要开启一个控制中心，监听一个端口，让其它节点接入。
    * master：指定skynet控制中心的地址和端口，如果你配置了standalone项，那么这一项通常和standalone相同。
    * address：当前skynet节点的地址和端口，方便其它节点和它组网。注：即使你只使用一个节点，也需要开启控制中心，并额外配置这个节点的地址和端口。
    * harbor：可以是 1-255 间的任意整数。一个skynet网络最多支持 255 个节点。每个节点有必须有一个唯一的编号。
    如果harbor为 0 ，skynet工作在单节点模式下。此时master和address以及standalone都不必设置。
    * start：这是bootstrap最后一个环节将启动的lua服务，也就是你定制的skynet节点的主程序。默认为main，即启动main.lua这个脚本。这个lua服务的路径由下面的luaservice指定。
  * 集群服务用到的配置项
    * cluster它决定了集群配置文件的路径。
  * snlua配置项
    * lualoader：用哪一段lua代码加载lua服务。通常配置为lualib/loader.lua，再由这段代码解析服务名称，进一步加载lua代码。snlua会将下面几个配置项取出，放在初始化好的lua虚拟机的全局变量中。具体可参考实现。
    * SERVICE_NAME第一个参数，通常是服务名。
    * LUA_PATH：config文件中配置的lua_path。
    * LUA_CPATH：config文件中配置的lua_cpath。
    * LUA_PRELOAD：config文件中配置的preload。
    * LUA_SERVICE：config文件中配置的luaservice。
    * luaservice：lua服务代码所在的位置。可以配置多项，以 ; 分割。 如果在创建lua服务时，以一个目录而不是单个文件提供，最终找到的路径还会被添加到package.path中。比如，在编写lua服务时，有时候会希望把该服务用到的库也放到同一个目录下。
    * lua_path：将添加到package.path中的路径，供require调用。
    * lua_cpath：将添加到package.cpath中的路径，供require调用。
    * preload：在设置完package中的路径后，加载lua服务代码前，loader会尝试先运行一个preload制定的脚本，默认为空。
    * snax：用snax框架编写的服务的查找路径。
    * profile：默认为true, 可以用来统计每个服务使用了多少cpu时间。在DebugConsole中可以查看。会对性能造成微弱的影响，设置为false可以关闭这个统计。
  * 另外，你也可以把一些配置选项配置在环境变量中。比如，你可以把 thread 配置在 SKYNET_THREAD 这个环境变量里。你可以在 config 文件中写：  
    ``thread=$SKYNET_THREAD``  
    这样，在 skynet 启动时，就会用 SKYNET_THREAD 这个环境变量的值替换掉 config 中的 $SKYNET_THREAD 了。

# 待看
[sproto库](https://gowa.club/Lua/Skynet/skynet%E4%B8%AD%E6%9C%8D%E5%8A%A1%E5%88%86%E6%9E%90(wathchdog,gate,snxa.gateserver).html)
[skynet中的watchdog gate gateserver agent之间关系的理解](https://blog.csdn.net/hp_cpp/article/details/107364207)
[4种线程](https://blog.csdn.net/weixin_37590253/category_10550634.html)
# 待看

## 链接：
  * [skynet服务端框架研究](http://forthxu.com/blog/skynet.html)
  * [skynet服务器框架解读](https://blog.csdn.net/linshuhe1/category_9268978.html)


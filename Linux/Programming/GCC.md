# GCC
## 生成目标文件
    $gcc -o test.o -c test.c
    或
    $gcc -c test.c
## 生成静态库
    $ar -src test.a test.o
## 生成动态库
    $gcc -fPIC -shared -o libtest.so test.o
    或
    $gcc -fPIC -shared -o libtest.so test.o
## 链接静态库
    $gcc -o test main.c path/libtest.a
## 链接动态库(从/usr/lib搜索)
    $gcc -o test main.c path/libtest.so
    或
    $gcc -o test main.c -L path -ltest
## 链接动态库(从当前目录搜索)
  * 方法1:  
    $gcc -o test main.c -L path -ltest -Wl,-rpath=./
  * 方法2:  
    $gcc -o test main.c -L $(prefix)/lib -ltest -Wl,-rpath=$(prefix)/lib  
    将链接库的目录添加到/etc/ld.so.conf文件中或者添加到/etc/ld.so.conf.d/*.conf中，然后使用ldconfig进行更新，进行动态链接库的运行时动态绑定
  * 方法3:  
    在环境变量 LD_LIBRARY_PATH 中指明库的搜索路径
## 找不到.so时添加查找路径
    $sudo echo "/usr/local/lib" >> /etc/ld.so.conf
    $sudo /sbin/ldconfig
## 预处理宏信息
    在CFLAGS参数后添加-g3 -gdwarf-2

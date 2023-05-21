# Shell

## 快捷键
  * emacs模式 `$set -o emacs`
    * CTRL-A        将光标移到行首（在命令行下）
    * CTRL-B        退格 (非破坏性的)，这个只是将光标位置往回移动一个位置
    * CTRL-C        中断，终结一个前台作业
    * CTRL-D        删除在光标下的字符
    * CTRL-E        将光标移动到行尾（在命令行下）
    * CTRL-F        将光标向前移动一个字符（在命令行下）
    * CTRL-G        BEL。在一些老式打印机终端上，这会引发一个响铃。在xterm终端上可能是哔的一声
    * CTRL-H        擦除(Rubout)(破坏性的退格)。在光标往回移动的时候，同时擦除光标前的一个字符
    * CTRL-I        水平制表符
    * CTRL-J        新行(换行[line feed]并到行首)。在脚本中，也可能表示为八进制形式(‘/012′)或十六进制形式(‘/x0a’)
    * CTRL-K        垂直制表符(Vertical tab)。在控制台或 xterm 窗口输入文本时，CTRL-K会删除从光标所在处到行尾的所有字符
    * CTRL-L        清屏
    * CTRL-M        回车(Carriage return)
    * CTRL-N        擦除从history缓冲区召回的一行文本（在命令行下）。如果当前输入是历史记录中选择的时候，这个是从这个历史记录开始，每按一次，是更接近的一条命令
    * CTRL-O        产生一个新行（在命令行下）
    * CTRL-P        从history缓冲区召回上一次的命令（在命令行下）。此快捷键召回的顺序是由近及远的召回，即按一次，召回的是前一次的命令，再按一次，是召回上一次之前的命令，这和CTRL-N都是以当前的输入为起点，但是两个命令操作刚好相反，CTRL-N是从起点开始由远及近（如果起点是历史命令的话）
    * CTRL-Q        Resume (XON)。恢复/解冻，这个命令是恢复终端的stdin用的，可参见CTRL-S
    * CTRL-R        回溯搜索(Backwards search)history缓冲区内的文本（在命令行下）。注意：按下之后，提示符会变成(reverse-i-search)”:输入的搜索内容出现在单引号内，同时冒号后面出现最近最匹配的历史命令
    * CTRL-S        Suspend(XOFF)，挂起。这个是冻结终端的stdin。要恢复可以按CTRL-Q
    * CTRL-T        交换光标位置与光标的前一个位置的字符内容（在命令行下）。比如：echo $var;，假设光标在a上，那么，按下C-T之后，v和a将会交换位置：echo $avr;
    * CTRL-U        擦除从光标位置开始到行首的所有字符内容。在某些设置下，CTRL-U会不以光标位置为参考而删除整行的输入
    * CTRL-V        在输入文本的时候，按下C-V之后，可以插入控制字符。比如：echo -e '/x0a’;和echo <CTRL-V><CTRL-J>;这两种效果一样。这点功能在文本编辑器内非常有效
    * CTRL-W        当在控制台或一个xterm窗口敲入文本时， CTRL-W 会删除从在光标处往后（回）的第一个空白符之间的内容。在某些设置里， CTRL-W 删除光标往后（回）到第一个非文字和数字之间的字符
    * CTRL-X        在某些文字处理程序中，这个控制字符将会剪切高亮的文本并且将它复制到剪贴板中
    * CTRL-Y        将之前已经清除的文本粘贴回来（主要针对CTRL-U或CTRL-W）
    * CTRL-Z        暂停一个前台的作业；在某些文本处理程序中也作为替换操作；在MSDOS文件系统中作为EOF（End-of-file)字符
    * CTRL-/        退出。和CTRL-C差不多，也可能dump一个”core”文件到你的工作目录下(这个文件可能对你没用)
    * CTRL-/        撤消操作，Undo
    * CTRL-_        撤消操作
    * CTRL-xx       在行首和光标两个位置间进行切换，此处是两个”x”字符
    * ALT-B         光标往回跳一个词，词以非字母为界(跳动到当前光标所在词的开头)
    * ALT-F         光标往前跳一个词(移动到光标所在词的末尾)
    * ALT-D         删除光标所在位置到光标所在词的结尾位置的所有内容(如果光标是在词开头，则删除整个词)
    * ALT-BASKSPACE 删除光标所在位置到词开头的所有内容
    * ALT-C         将光标所在位置的字母转为大写(如果光标在一个词的起始位置或之前，则词首字母大写)
    * ALT-U         将光标所在位置到词尾的所有字母转为大写
    * ALT-L         将光标位置到词尾的所有字母转为小写
    * ALT-R         取消所有变更，并将当前行恢复到在历史记录中的原始状态(前提是当前命令是从历史记录中来的，如果是手动输入，则会清空行)
    * ALT-T         当光标两侧都存在词的时候，交换光标两侧词的位置。如：abc <ALT-T>bcd -> bcd abc
    * ALT-.         使用前一次命令的最后一个词(命令本身也是一个词，参见后一篇的Bang命令中的词指示符概念)
    * ALT-_         同ALT-.
    * ALT-数值      这个数值可以是正或者是负，这个键单独没有作用，必须后面再接其他内容，如果后面是字符，则表示重复次数。如：[ALT-10，k]则光标位置会插入10个k字符(负值在这种情况下无效)；如果后面接的是命令，则数字会影响后面命令的执行结果，如：[ALT--10，CTRL-D]则向CTRL-D默认方向相反(负数)的方向执行10次操作
    * ALT-<         移动到历史记录中的第一行命令
    * ALT->         移动到历史的最后一行，即当前正在输入的行(没有输入的情况下为空)
    * ALT-P         从当前行开始向前搜索，有必要则向”上”移动，移动时，使用非增量搜索查找用户提供的字符串
    * ALT-N         从当前行开始向后搜索，如果有必要向”下”移动，移动时，使用非增量搜索查找用户提供的字符串
    * ALT-CTRL-Y    在标志点上插入前一个命令的第一个参数(一般是前一行的第二个词)。如果有参数n，则插入前一个命令的第n个词(前一行的词编号从0开始，见历史扩展)。负的参数将插入冲前一个命令的结尾开始的第n个词。参数n通过M-No.的方式传递，如：[ALT-0，ALT-CTRL-Y]插入前一个命令的第0个词(命令本身)
    * ALT-Y         轮询到删除环，并复制新的顶端文本。只能在yank[CTRL-Y]或者yank-pop[M-Y]之后使用这个命令
    * ALT-?         列出能够补全标志点前的条目
    * ALT-*         把能够补全[ALT-?]命令能生成的所有文本条目插入到标志点前
    * ALT-/         试图对标志点前的文本进行文件名补全。[CTRL-X，/]把标志点前的文本当成文件名并列出可以补全的条目
    * ALT-~         把标志点前的文本当成用户名并试图进行补全。[CTRL-X，~]列出可以作为用户名补全标志点前的条目
    * ALT-$         把标志点前的文本当成Shell变量并试图进行补全。[CTRL-X，$]列出可以作为变量补全标志点前的条目
    * ALT-@         把标志点前的文本当成主机名并试图进行补全。[CTRL-X，@]列出可以作为主机补全标志点前的条目
    * ALT-!         把标志点前的文本当成命令名并试图进行补全。进行命令名补全时会依次使用别名、保留字、Shell函数、shell内部命令，最后是可执行文件名。[CTRL-X，!]把标志点前的文本当成命令名并列出可补全的条目
    * ALT-TAB       把标志点前的文本与历史记录中的文本进行比较以寻找匹配的并试图进行补全
    * ALT-{         进行文件名补全，把可以补全的条目列表放在大括号之间，让shell可以使用
  * vi模式 `$set -o vi`

## 符号
  * 字符串必须加引号
  * 单引号内的内容原样输出, `echo '$var'` 输出为`$var`
  * =用作同赋值时两边没有空格
  * =用作判断时两边有空格
  * !用非逻辑时后面有空格
  * \`cmd\`与$(cmd)作用相同, 但\`\`内\需要转义,$(cmd)并不是所有shell都支持
  * $var与${var}并没有区别，但是用${cmd}会比较精确的界定变量名称的范围
  * ${}内不能有$, 需要换成!, 如${!#}表示脚本最后一个参数

## 整数、字符串运算
    expr 1 + 5   # 运算符左右的空格不能省, 特殊特号需要转义, 有很多缺点, 不要使用
    $[ 1 + 5 ]   # 运算符左右的空格不能省, 特殊符号不需要转义
    $(( 1 + 5 )) # c语言风格
    ARG1 | ARG2
    ARG1 & ARG2
    ARG1 < ARG2
    ARG1 > ARG2
    ARG1 <= ARG2
    ARG1 >= ARG2
    ARG1 = ARG2
    ARG1 != ARG2
    ARG1 + ARG2
    ARG1 - ARG2
    ARG1 * ARG2
    ARG1 / ARG2
    ARG1 % ARG2
    <STRING> : <REGEXP> 或 match <STRING> <REGEXP> 匹配时返回1/0
    substr <STRING> <POS> <LEN>                    获取子串
    index <STRING> <SUBSTR>                        查找字串
    length <STRING>                                获取长度
    + TOKEN                                        将TOKEN解释成字符串, 即使是关键字
    (expression)                                   返回表达式的值
## 浮点数运算

## 条件语句
### if-then
```Shell
if command; then # command返回0时then部分被执行, for/while同, until相反
  do-something
fi
```
```Shell
#!/bin/bash

if [ $# -ne 1 ]; then
  echo invalid parameters.
  exit 1
fi

file=$1

! [ -e $file ] && echo $file isn\'t exist. && exit 1

if [ -d $file ]; then
  echo $file is a directory.
elif [ -f $file ]; then
  echo $file is a file.
else
  echo "unknown type."
fi

exit 0
```
### 条件测试
```Shell
if [ 1 -eq 0 ]; then # 条件成立时then部分被执行, []必须有空格
  do-something
fi
# 或
if test 1 -eq 0; then
  do-something
fi
# 或
if (( 1 > 0 )); then
  do-something
fi
# 整数比较: -eq -ge -gt -le -lt -ne
# 字符串比较: = != < > -n:长度是否大于0 -z:是否为空串, ><需要转义
```
### 逻辑测试
    & | !
### 文件测试
    -e              存在
    -d              目录
    -f              文件
    -s              存在且非空
    -r              可读
    -w              可写
    -x              可执行
    -O              当前用户所有
    -G              默认组与当前用户相同
    file1 -nt file2 file1比file2新
    file1 -ot file2 file1比file2旧
### 表达式
    (( expression ))
    [[ expression ]]  posix的扩展，支持正则表达式[[ str =~ REGEXP ]]
    ++ -- ! ~ << >> & | && || 
    **: 幂运算
### case
```Shell
case $val in
1 | 2)
  do-something;;
3)
  do-something;;
*)
  do-something;;
esac
```

## 循环
### 循环
```Shell
# Shell风格:
IFS_OLD=$IFS
IFS=' \t' # 环境变量可以自定义分隔符, 默认为空格和tab
for i in 'ls'; do
  if [ -e $i ]; then
    file $i
  fi
done
IFS=$IFS_OLD

i=0
while [ $i -lt 10 ]; do
  echo $i
  i=$[$i + 1]
done

# until与while相反
# break n, n默认为1, 表示几层
# continue n, n默认为1, 表示几层

# C语言风格:
for (( i=0, j=9; i < 10 && j >= 0; ++i, --j )); do
  echo $i, $j
done

i=0
while (( i < 10 )); do
  echo $i
  (( i++ ))
done
```

## 程序参数
    $#        参数个数
    $0        脚本路径
    ${1}-${n} 参数
    $*        单个字符串形式传递所有参数
    $$        脚本进程id
    $!        后台支行的最后一个进程的id
    $@        $*与$@相同, '$*'为一个字符串, '$@'为多个字符串
    $-        当前shell选项
    $?        最后执行命令的返回值, 0表示成功
    
    ${@: -1}  最后一个参数, 注意空格
    ${!#}     最后一个参数
    
    shift     shift命令将所有参数左移一位
    
```Shell
# 参数处理
i=1
set `getopt -q a:b:cd "$@"` # -q用来忽略错误
while [ -n "$1" ]; do
  opt="$1"
  case $opt in
  -a | b)
    shift
    echo option $i: $opt $1;;
  -c | d)
    echo option $i: $1;;
  *)
    echo option $i: $opt;;
  esac
  shift
  (( i++ ))
done
# 以上代码有问题, getopt不擅长处理带有空格的参数, 应使用getopts代替
# 以下代码能正确获取-开头的参数
i=1
while getopts :a:b:cd opt; do # 最前面的:用来忽略错误
  case "$opt" in
  a | b)
    echo option $i: -$opt $OPTARG;; # OPTARG为当前参数值
  c | d)
    echo option $i: -$opt;;
  *)
    echo invalid option $i: -$opt;;
  esac
  (( i++ ))
done
```

## 输入输出
### 输入
```Shell
read -p ">" answer                        # 输入内容写入answer环境变量中, 不指定默认写入REPLY
read -s -p "Enter your password: " passwd # -s关闭回显
```
### 重定向
```Shell
echo "hello world" 2>err 1>out
echo "hello world" &>out       # STDERR和STDOUT重定向到同一个文件
echo "hello world" 1>&2        # 输出重定向到STDOUT
exec &>out                     # 永久重定向
exec 0<in                      # 从文件获取输入
echo "hello world" | tee out   # 同时输出到STDOUT和文件
```

## 信号
```Shell
trap -p 显示当前捕获的信号
trap -l 显示信号值对照表
trap - SIGINT 移除信号捕获
trap "command" SIGINT SIGTERM 信号触发时调用command
```

## 数组
```Shell
# 索引从0开始
# 获取数组长度
${#数组名[*]} 或 ${#数组名[@]}
# 获取元素
${数组名[索引值]}
# 删除数组
unset 数组名
# 删除元素
unset 数组名[索引值]
# 切片
${数组名[*]:起始位置:长度} 或 ${数组名[@]:起始位置:长度}
# 获取所有元素
${数组名[*]} 或 ${数组名[@]}
# 获取所有索引
${!数组名[*]} 或 ${!数组名[@]}
# 复制数组
temp=(${数组名[@]})

示例:
array=(1 2 3 4 5 6 7 8 9 10)
echo "array=${array[@]}"
echo "length:${#array[@]}"

function test {
  local temp=(`echo "$@"`)
  local result
  for (( i = 0; i < ${#temp[@]}; ++i )); do
    (( result[$i] = ${temp[$i]} * $2 ))
  done
  echo "${result[@]}"
  return 0
}

p1="${array[@]}"
str=`test "$p1" 10` # 不能直接传"${array[@]}"
echo result:$str
```

## 图形化
[文档](http://www.ttlsa.com/linux-command/linux-dialog-shell/)

## awk

## sed

### 参数
    -e 执行多个命令, 回车或分号分隔
    -f 从文件读取多个命令
    https://www.yiibai.com/sed
    https://www.twle.cn/c/yufei/sed/sed-basic-loops.html

## 问题记录
### `=~`无法正常匹配
  1. 不要使用引号包裹
  2. 空格使用`\ `或`[[:space:]]`匹配

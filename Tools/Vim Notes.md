# Vim Notes
```
s                = xi
C                = c$ 修改到行尾
S                = 0c$ 修改一整行
D                = d$ 删除到行尾
Y                = yy
A                = $a
I                = 0i
cw               = 修改一个词
cc               = S

fx               = 查找下一个x
Fx               = 查找上一个x
vfx/zfx          = 选择/删除至下一个x
*                = 向下搜索光标所在单词
%                = 跳转到匹配的括号、注释、宏块

d/word           = 删至下一个word前
d?word           = 删至上一个word前

bve/evb          = 选择光标处单词
BvE/EvB          = 选择光标处字符串
ve/vb            = 选择当前光标开始的单词
vE/vB            = 选择当前光标开始的字符串

U                = 撤销当前行所有操作

di['"{([<wW]       = 删除配对标点内内容             w表示单词 W表示字符串
yi['"{([<wW]       = 复制配对标点内内容
vi['"{([<wW]       = 选择配对标点内内容
da['"{([<wW]       = 删除配对标点内内容(包括标点)
ya['"{([<wW]       = 复制配对标点内内容(包括标点)
va['"{([<wW]       = 选择配对标点内内容(包括标点)

c-d              = 向下滚半屏
c-u              = 向上滚半屏
c-f              = 上一页
c-b              = 下一页
c-o              = 后退
c-i              = 前进

gd               = 跳转到单词首次出现行
[c-d             = 跳转到宏定义行
[c-i             = 跳转到函数、变量定义行

/                = 向下查找
?                = 向上查找

~                = 转换大小写
.                = 重复刚才的操作

=                = 格式化所选内容
==               = 格式化当前行
gg=G             = 全文格式化

mx               = 标记x [a-zA-Z]
:marks           = 列举所有标记
:delmarks a b c  = 删除标记a b c
:delmarks!       = 删除所有标记

"+yy             = 复制到系统剪切板
"+p              = 从系统剪切板粘贴

替换:
:[range]s/pattern/string/[flags]
range:
.                = 当前行
$                = 最后一行
N                = 行号
'x               = 标记x所在行
range,range      = 范围
range-N          = range-N行
range+N          = range+N行
range-N, range+N = 范围
%                = 所有行
flags:
g                = 指定范围
c                = 需要确认(y/n)
i                = 不区分大小写

insert模式下:
c-p/c-n          = 补全, c-h删除 c-d取消
c-xl             = 整行补全
c-xf             = 文件名补全
c-xd             = 宏定义补全
c-xv             = vim命令补全

zf10j            = 向下折叠10行
zf10k            = 向上折叠10行
zf               = 折叠所选行
zd               = 删除折叠
zD               = 删除嵌套折叠
zE               = 删除所有折叠
zo               = 打开当前折叠
zc               = 关闭当前折叠
zm               = 关闭所有折叠
zM               = 关闭所有嵌套折叠
zr               = 打开所有折叠
zR               = 打开所有嵌套折叠
zn               = 禁用折叠
zN               = 启用折叠

c-wv             = vs [file]
c-ws             = sp [file]
vs [file]        = 纵向分割窗口
sp [file]        = 横向分割窗口
c-w[hjkl]        = 跳转窗口
c-ww             = 移动到下一个窗口
c-w10<           = 窗口宽度缩小10格
c-w10>           = 窗口宽度增加10格
c-w10-           = 窗口高度缩小10格
c-w10=           = 窗口高度增加10格
c-wT             = 移动到新tab

:tabs            = 查看所有tab
:tabnew file     = 新tab
:tabe file       = 当前tab打开file
:tabn            = 切换到下一个tab
:tabp            = 切换到上一个tab
gt               = 切换到上一个tab
gT               = 切换到下一个tab
1gt              = 切换到第一个tab
:tabm 0-n   = 移动tab
:tabdo 命令 = 所有tab执行命令

gf               = 编辑光标下的文件
c-^              = 切换轮换文件
:find            = 当前工作目录查找并找开文件
:cd path         = 切换工作目录
:pwd             = 显示当前工作目录
:file            = 显示文件名
:file newfile    = 置当前文件名为newfile
:files           = 显示文件名

:e path          = 当前tab打开path

$vimdiff f1 f2   = 比较f1 f2

:w file          = 另存为file
:r file          = 读取file中数据到光标后
:n1,n2 w file    = n1-n2行另存为file

:mksession file  = 创建会话
$vim -S file     = 打开会话

~/.vimrc
" 显示行号
set number
" 高亮
syntax on
" 使用鼠标
set mouse=a
" 编码
set encoding=utf-8
" 256色
set t_Co=256
" 检查文件类型
filetype indent on
" tab显示空格数
set tabstop=2
" 自动保持缩进
set autoindent
" >>缩进空格数
set shiftwidth=2
" tab转化为空格
set expandtab
" tab 转化为多个空格
set softtabstop=2
" 光标所在行高亮
set cursorline
" 显示光标当前行行号
set relativenumber
" 匹配括号
set showmatch
" 高亮搜索
set hlsearch
" 自动跳转到匹配结果
set incsearch
" 共享剪切板
set clipboard=unnamed
" 不自动换行
set nowrap
```

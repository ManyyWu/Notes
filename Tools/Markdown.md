# <span id="jump_start">目录</span>

[笔记](#笔记)
<br>
[Markdown格式建议](#Markdown格式建议)


# 笔记

## 标题

一极标题
==
二级标题
--

# 一级标题
## 二级标题
### 三级标题
#### 四级标题
##### 五级标题
###### 六级标题

## 文本样式

* 非加粗**加粗**非加粗
* __加粗__
* 非斜体*斜体*非斜体
* _斜体_
* 非加粗斜体***加粗斜体***非加粗斜体
* ~~删除线~~

## 段落

<p>这是第一段文字</p>
<p>文是第二段文字</p>

这是第三段文字

这是第四段文字

## 换行

这是第一行(两个空格换行)  
这是第二行(`<br>`换行)<br>这是第三行
这还是第三行

这里是另一个段落了

## 引用

> 第一级
> 
> 常用于：注意、贴士、警告、解释、网页、书籍、层级对话、其他人的言论
> <br><br>**和正文一样，引用内的文本也要使用两个空格或`<br>`换行**
> * 列表
>
>> 第二级
>>> 第三级
>>>> 第四级

## 列表

### 有序列表

1. 元素1
2. 元素2
3. 元素3
   1. 元素3.1(每级加三个/四个空格缩进)
   2. 元素3.2
   3. 元素3.3
       1. 元素3.3.1(表项后加两个空格换行)  
          这里是3.3.1的内容(文本用三个/四个空格缩进)
       2. 元素3.1.2
          <br>这里是3.3.2的内容(`<br>`换行)
       3. 元素3.3.3

<ol>
<li>元素1</li>
<li>元素2</li>
<li>元素3</li>
  <ol>
    <li>元素3.1</li>
    <li>元素3.3</li>
    <li>元素3.3</li>
  </ol>
</ol>

### 无序列表

* 元素1
* 元素2
* 元素3
    - 元素1(每级加两个/四个空格缩进)
    - 元素2
    - 元素3
      * 元素1
      * 元素2
      * 元素3  
         这里是3.3.1的内容(两个空格换行)
         > 3.3.1的引用

<ul>
  <li>元素1</li>
  <li>元素2</li>
  <li>元素3</li>
  <ul>
    <li>元素1</li>
    <li>元素2</li>
    <li>元素3</li>
</ul>
</ul>

## 代码

`` ` ``反引号转义

命令：`ls -sail`

命令：<code>ls -sail</code>

命令（四个空格缩进）：

    &lt;html>
      &lt;head>
      &lt;/head>
    &lt;/html>

命令：
```Shell
    &lt;html>
      &lt;head>
      &lt;/head>
    &lt;/html>
```

## 链接

这是一个超链接：[`ls`](https://man7.org/linux/man-pages/man1/ls.1.html)
<br>
这是一个超链接：***[Notes/Tools/Markdown.md](https://github.com/ManyyWu/Notes/new/master/Tools/Markdown.md)***
<br>
这是一个超链接：<a href="https://github.com/ManyyWu/Notes/new/master/Tools/Markdown.md" title="Hover时显示的内容">Notes/Tools/Markdown.md</a>
<br>
这是一个邮箱：<fake@example.com>

## 图片

* 内联式图片  
![加载失败时显示的内容](https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png)

-------------------------------------------------------------------------------------------------------------------------------------
* 文本显示在图片下方
<img src="https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png" width="100">
Linux

-------------------------------------------------------------------------------------------------------------------------------------
* 文本显示在图片下方，文本与图片对齐
<p align="left">
  <img src="https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png" width="100">
  <br>
  Linux
</p>
<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png" width="100">
  <br>
  Linux
</p>
<p align="right">
  <img src="https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png" width="100">
  <br>
  Linux
</p>

-------------------------------------------------------------------------------------------------------------------------------------
* 利用标签将文字与图片对齐，图片和文字各占一个单元格(只支持左右对齐)
<table>
  <tr>
    <td>Linux</td>
  </tr>
  <tr>
    <td>
      <img src="https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png" width="100" align="right">
      <img src="https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png" width="100" align="right">
      <img src="https://upload.wikimedia.org/wikipedia/commons/a/af/Tux.png" width="100" align="right">
    </td>
  </tr>
  <tr>
    <td>三个Linux</td>
  </tr>
</table>

> **注意**：
> * 外链图片所在的网站开启了“防盗链”（判断请求来源），GitHub 的抓取可能会被拦截，导致图片显示为破损图标。
> * 图片与文本之间是紧凑排列

## 锚点

[跳转到开头](#jump_start) [跳转到开头](#目录)
<br>
[锚点1](##锚点) [锚点2](##锚点-1) [锚点3](##锚点-2) [锚点4](##锚点-3)

GitHub 会自动为每个的锚点生成一个ID，规则如下：
* 所有大写字母转为小写
* 空格变为`-`
* 标点符号（如 .、?、!、,）会被剔除
* 中文字符会原样保留（虽然在URL编码中会显示成 %xx）
* 如果文档中有两个完全相同的标题，通过数字后缀来区分它们

## 分隔线

分隔线
---
分隔线
***
分隔线
___


# Markdown格式建议

## 标题

* `#`x标题后加1个空行，一级标题前加2个空行

## 符号

* 中英文混合尽量使用英文符号，除非是`《》` `【】`
* `,` `.`后加1个空格
* 句尾不加`。`
* 不使用Tab

## 反引号

* 代码/命令/表达式/函数定义等加反引号


# 测试

## 锚点

<br>
<br>
<br>
<br>
<br>

## 锚点

<br>
<br>
<br>
<br>
<br>

## 锚点

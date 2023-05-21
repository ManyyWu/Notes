# 正则表达式
  * 不匹配单词 \b((?!abc)\w)+\b
  * 中文 [\u4e00-\u9fa5]
  * 韩文 [\uac00-\ud7ff]
  * 日文 [\u0800-\u4e00]
  * 匹配包括下划线的任何单词字符 [\w\W]
  * 匹配任何不可见字符 [\s\S]
  * 匹配数字字符 [\d\D]

# grep
  * grep就近匹配`grep -Pzo '<struct>[\w\W]*?<\/struct>'`，-P只支持UTF8

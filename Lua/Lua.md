# Lua

## Lua基础
### 操作符
  * //：向下取整
  * ^：乘方
  * 表、用户数据和线程都是比较引用，需要定义元方法"eq"进行比较
  * #: 取表长度（v5.1中table.getn已移除）

### 函数
  * 闭合函数：函数加上该函数所需访问的所有”非局部的变量“
  * 非全局函数：存储在局部变量中的函数，如`local function test() end`
  * 尾调用：该函数是另一个函数的最后一个动作，如`return fun()`（`return fun() + 1`不是尾调用），递归时使用尾调用可以防止栈溢出
  * 变参函数：
    ```Lua
    function f(...)
      local t = {...}
      local len = select("#", ...)
      for i = 1, len do
        print(t[i])
      end
    end
    
    f(nil, 1, 2, 3, 4, 5, nil, nil)
    ```

### [正则表达式](https://cloudwu.github.io/lua53doc/manual.html#6.4.1)

### 表
  * lua的表索引从1开始，可以使用索引0，但不会计算长度，pairs会遍历索引0，ipairs不会遍历索引0
  * table.pack、table.unpack，v5.1版本之后从全局函数移到table下

### _ENV、_G
  * 全局变量是_ENV中的键值，_G是_ENV是一个键，引用_ENV本身
  * 在v5.3中_G没有实际意义，LuaJIT文件中使用`local _G = _G`，并在使用全局变量时显示指定`_G.var`可以提高速度，但在v5.3中会更慢，相当于`_ENV._G.var`

### load、loadfile、dofile、require区别
  * load（同v5.2已弃用的loadstring）从字符串加载代码块，作为一个函数返回
  * loadfile和load类似，但从文件加载，dofile实际是包装了loadfile，dofile相当于`loadfile("name")()`
  * load和loadfile使用更灵活，但每次调用都会重新解释，文件内容没有修改的情况下尽量不要重复调用
  * load和loadfile加载时有语法错误都不会抛出异常，正确使用方法：
    ```Lua
    f, err = load("print('hello world!')")
    if err then
    print(err)
    else
    f()
    end
    -- 或者
    f = assert(load("print('hello world!')"))
    f()
    ```
  * `require "module_name"`加载模块时会自动搜索package.cpath目录中匹配的模块或c动态库，已经加载的文件不会重复加载，如果需要重新加载需要执行 `package.loaded["module_name"] = nil`

### 错误处理
  * assert为error的包装函数，都会终止程序
  * pcall、xpcall以安全模式执行函数，可以捕获函数执行中的任何错误，如果没有发生错误，那么返回true及函数调用的返回值，否则返回false及错误信息。当然错误信息不一定是一个字符串，还可以是lua中的任何值
  * 示例：
    ```Lua
    function f (a)
      assert(type(a) ~= "number", "invalid param")
      if type(a) == "table" then
        error("invalid param", 1)
      end
      if type(a) == "boolean" then
        error({msg = "invalid param"}, 1)
      end
      return a
    end
      
    local ok, result = pcall(f, "hello world!")
    print(result)
      
    local ok, err = pcall(f, 1)
    if err then
      print(err)
    end
    
    local ok, err = pcall(f, {})
    if err then
      print(err)
    end
      
    local ok, err = pcall(f, false)
    if err then
      print(err.msg)
    end
      
    local ok, result = xpcall(f, function () print(debug.traceback()) end, {})
    ```
### 迭代器
  * 迭代器分为有状态迭代器（闭包实现）和无状态迭代器（如pairs、ipairs）
  * 优先使用无状态迭代器，因为创建闭包会消耗额外的性能
  * 使用方法：
    ```Lua
    function iter(t) -- 闭包实现的有状态的迭代器
      local i = 0
      return function ()
        i = i + 1
        local v = t[i]
        if v then
          return i, v
        end
      end
    end
    
    function iter_no_status (t, i)
      i = i + 1
      local v = t[i]
      if v then
        return i, v
      end
    end
    
    function iter1(t) -- 无状态的迭代器
      -- 迭代函数, 状态常量, 控制变量（仅用于初始化）
      return iter_no_status, t, 0
    end
    
    local t = {1, 2, 3, 4, 5}
    
    local it = iter(t)
    while true do
      i, v = it()
      if not i then
        break
      end
      print("2^" .. i .. "=" .. math.floor(2 ^ v))
    end
    
    print()
    
    for i, v in iter(t) do
      print("2^" .. i .. "=" .. math.floor(2 ^ v))
    end
    
    print()
    
    for i, v in iter_no_status, t, 0 do
      print("2^" .. i .. "=" .. math.floor(2 ^ v))
    end
    
    print()
    
    for i, v in iter1(t) do
      print("2^" .. i .. "=" .. math.floor(2 ^ v))
    end
    ```
### 工厂方法实现的两种方式
  * 元表实现
    ```Lua
    local Cube = {}
    
    Cube.getSideLength = function (self)
      return self.sideLength
    end
    
    Cube.getVolume = function (self)
      return math.floor(self.sideLength ^ 3)
    end
    
    Cube.setSideLength = function (self, sideLength)
      self.sideLength = sideLength
    end
    
    Cube.new = function (sideLength)
      local c = {}
      local meta = { __index = Cube }
    
      c.sideLength = sideLength
      setmetatable(c, meta)
    
      return c
    end
    
    local c = Cube.new(0)
    c:setSideLength(5)
    print(c:getSideLength())
    print(c:getVolume())
    ```
  * 闭包实现
    ```Lua
    local Square = {}
    
    Square.new = function (sideLength)
      local getSideLenght = function (self)
        return self.sideLength
      end
    
      local getArea = function (self)
        return math.floor(self.sideLength ^ 2)
      end
    
      local setSideLength = function (self, sideLength)
        self.sideLength = sideLength
      end
        
      return { sideLength = sideLength, getSideLength = getSideLenght, getArea = getArea, setSideLength = setSideLength }
    end
    
    local s = Square.new(0)
    s:setSideLength(5)
    print(s:getSideLength())
    print(s:getArea())
    ```
## Lua优化建议
  * 频繁执行的代码尽量不要直接使用路径很深的表成员和全局变量（每次使用都会在_ENV表搜索），使用局部变量代替`local xx = t.xxx.xx`
  * 频繁执行的代码尽量不要创建变量，在外部定义好
  * ..比string.format效率高，字符串较多的情况下使用table.concat最快，
  * unpack跟循环赋值相比效率非常低，如果数组长度确定，不要使用unpack
  * 判断空表的方法`next(t) == nil`
  * 删除table中的元素的方法：
    ```Lua
    -- 使用table.remove删除所有元素
    for i = #t, 1, -1 do -- 必须反向迭代，因为删除元素时，后面的元素会前移
      table.remove(t, i)
    end
    -- 使用table.remove删除指定元素
    function removeItem (t, item)
      local removed = 0
      for i = 1, #t do
        if t[i - removed] == item then
          table.remove(t, i - removed)
        end
      end
    end
    
    -- 使用nil删除所有元素（清空数组最快的方法）
    for i in pairs(t) do
     t[i] = nil
    end
    --使用nil删除指定元素
    t[item] = nil
    -- 注意：使用t[i] = nil，nil会影响#t的结果
    -- 如果不能保证数组里没有nil，就不要使用#t取表的长度
    ```
  * 表添加元素，使用该方法更快：
    ```Lua
    local t = {} -- LuaJIT使用table_new预先分配内存速度会更快
    local len = #t + 1
    for i = 1, 1e7 do
      t[len] = i
      len = len + 1
    end
    
    -- 对于元素较少的表，可以预先分配好空间，防止频繁扩容
    -- 条件允许，尽量将表提前定义在外部
    local t1= {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    function test()
      for i = 1, #t1 do
        t1[i] = 1
      end
    end
    ```
## 调试
### 打印变量
  * dump
    ```Lua
    function dump_inner(data, showMetatable, tabIndent, noTable, lastCount, result)
      if type(data) ~= "table" then
        if type(data) == "string" then
          table.insert(result, "\"" .. data .. "\"")
        elseif type(data) == "function" then
          local funcInfo = debug.getinfo(data) -- _G中的函数可以是多个变量的值，因此函数名为nil
          setmetatable(funcInfo, { __index = function () return "" end })
          table.insert(result, "function \'" .. funcInfo.name .. "\' <" .. funcInfo.short_src .. ":" .. funcInfo.linedefined .. ">")
        else
          table.insert(result, tostring(data))
        end
      else
        if not lastCount then lastCount = 0 end
        local indent = tabIndent and "\t" or "    "
        local count = lastCount + 1
        if not noTable then
          table.insert(result, "{\n")
        else
          count = count - 1
        end
    
        if showMetatable then
          for i = 1, count do table.insert(result, indent) end
          local mt = getmetatable(data)
          table.insert(result, "\"__metatable\" = ")
          dump_inner(mt, showMetatable, tabIndent, false, count, result)
          table.insert(result, ",\n")
        end
    
        for key, value in pairs(data) do
          for i = 1, count do table.insert(result, indent) end
          if type(key) == "string" then
            table.insert(result, "\"" .. key .. "\" = ")
          elseif type(key) == "number" then
            table.insert(result, "[" .. key .. "] = ")
          else
            table.insert(result, tostring(key))
          end
          dump_inner(value, showMetatable, tabIndent, false, count, result)
          table.insert(result, ",\n")
        end
    
        for i = 1, lastCount or 0 do table.insert(result, indent) end
        if not noTable then
          table.insert(result, "}")
        end
      end
    
      if not lastCount then
        table.insert(result, "\n")
      end
    end
    
    -- data：变量
    -- showMetatable：包含元表
    -- tabIndent：使用tab缩进
    -- noTable：不使用{}输出
    function dump(data, showMetatable, tabIndent, noTable)
      local result = {}
      dump_inner(data, showMetatable, tabIndent, noTable, 0, result)
      return table.concat(result)
    end
    
    function dump_print(data, showMetatable, tabIndent, noTable)
      print(dump(data, showMetatable, tabIndent, noTable))
    end
    ```
### 获取堆栈信息
#### 调用栈级别
  * 被调用的调试库函数为0，当前函数为1，依此类推。。。
  * 打印其他协程的堆栈时，需要指定级别0
#### debug.trackback([thread,] [message [, level]])
    ```Lua
    -- thread默认为当前协程，message被堆栈信息之前，level指明从哪一层开始回溯，默认为1，即当前函数，0表示debug.traceback本函数
    
    -- 打印当前函数堆栈
    print(debug.traceback())
    print(debug.traceback("test"))
    -- 打印co协程当前堆栈，level需要填0
    print(debug.traceback(co, "test", 0))
    ```
### 获取函数信息
#### debug.getinfo ([thread,] f [, what])
    ```Lua
    -- 该函数返回包含一个函数信息的表
    -- f可以是函数名，如果通过名字指定的函数不存在，则报错。f也可以是一个数值，如果是数值则代表该函数的栈级别。
    --如果what不指定，默认情况下返回除合法行号表外的所有域：
    --source: 创建这个函数的"chunk"的名字。 
    --    如果"source"以'@'打头，表示这个函数定义在一个文件中，而'@'之后的部分就是文件名。
    --    若"source"以'='打头，表示之后的部分由用户行为来决定如何表示源码。
    --    其它的情况下，这个函数定义在一个字符串中，而"source"正是那个字符串。
    --short_src: 一个“可打印版本”的"source"，用于出错信息。
    --linedefined: 函数定义开始处的行号。
    --lastlinedefined: 函数定义结束处的行号。
    --what: 如果函数是一个Lua函数，则为一个字符串"Lua"；
    --    如果是一个C函数，则为"C"；
    --    如果是一个"chunk"的主体部分，则为"main"。
    --currentline: 给定函数正在执行的那一行。当提供不了行号信息的时候，"currentline"被设为-1。
    --name: 给定函数的一个合理的名字。
    --    因为Lua中的函数是"first-class values"，所以它们没有固定的名字。
    --    一些函数可能是全局复合变量的值，另一些可能仅仅只是被保存在一个"table"的某个域中。
    --    Lua会检查函数是怎样被调用的，以此来找到一个适合的名字。
    --    如果它找不到名字，该域就被设置为"NULL"。
    --namewhat: 用于解释"name"域。
    --    其值可以是"global"，"local"，"method"，"field"，"upvalue"，或是""，
    --    这取决于函数怎样被调用。（Lua用空串表示其它选项都不符合）
    --istailcall: 如果函数以尾调用形式调用，这个值为"true"。在这种情况下，当前栈级别的调用者不在栈中。
    --nups: 函数的"upvalue"个数。
    --nparams: 函数固定形参个数（对于C函数永远是0）。
    --isvararg: 如果函数是一个可变参数函数则为"true"（对于C函数永远为"true"）。
    --func: 函数本身。
    --activelines: 合法行号表。
    --    表中的整数索引用于描述函数中哪些行是有效行。
    --    有效行指有实际代码的行，即你可以置入断点的行。无效行包括空行和只有注释的行。
    --"what"可以指定如下参数，以指定返回值"table"中包含上面所有域中的哪些域：
    --    'n': 包含"name"和"namewhat"域；
    --    'S': 包含"source"，"short_src"，"linedefined"，"lastlinedefined"以及"what"域；
    --    'l': 包含"currentline"域；
    --    't': 包含"istailcall"域；
    --    'u': 包含"nup"，"nparams"以及"isvararg"域；
    --    'f': 包含"func"域；
    --    'L': 包含"activelines"域；
    
    -- 获取当前函数信息
    t = debug.getinfo(func)
    t = debug.getinfo(1)
    t = debug.getinfo(1, "n")
    -- 获取协程当前函数信息
    t = debug.getinfo(co, 1)
    ```
### upvalue
  * 上值即闭包内访问过，由外部函数持有的local局部变量
  * 上值的顺序即在函数内访问顺序

## C API
### 栈
  * LUA_MINSTACK：默认栈大小
  * lua_checkstack：扩大可用栈大小
### 错误处理
  * longjmp

## [中文文档](https://cloudwu.github.io/lua53doc/)
## [云风lua调试库](https://github.com/cloudwu/luadebug)
## 安装
### [Windows安装luajit](https://openresty.org/en/download.html)
### linux安装luajit
### lua模块管理
  * [luarocks](https://luarocks.org/)
### luasocket
  * [luasocket](http://files.luaforge.net/releases/luasocket/luasocket)
  * 注意与luasocket win32与lua win32对应
  * /etc/profile添加：
    ```Shell
    export LUA_PATH="/usr/local/share/lua/5.1/?.lua;;"
    export LUA_CPATH="/usr/local/lib/lua/5.1/?.so;;"
    ```

## TODO
  * [Lua字符串使用优化](http://blog.codingnow.com/2006/01/_lua.html)
  * [REGISTRYINDEX](http://blog.codingnow.com/2006/11/lua_c.html)
  * [REGISTRYINDEX](https://hytc1106hwc.github.io/lua/how-to-write-c-functions/registry-usage/)


# Rust

## 基础
### 类型
#### 字符串长度
  * 字节长度: len()
  * UTF-8字符长度: chars().count()
#### 字面量
  * 可以使用任意数量下划线分割数字，提高可读性，比如: `123_456_789`
#### 枚举
  * 枚举也可以定义方法、实现trait
#### 类型别名和newtype
  * 类型别名: `type NewType = ExistType;`
  ```Rust
  // 用于缩短类型名称、方便书写
  // 它们只是别名，和原类型完全相同，可以混用
  type OrderMap = std::collections::HashMap<OrderId, Order>;
  type OrderResult<T> = Result<T, String>;
  ```
  * newtype: `struct NewType(ExistType);`
  ```Rust
  // 区分不同概念
  #[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
  struct UserId(u64);
  
  #[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
  struct OrderId(u64);
  
  #[derive(Debug)]
  struct Order {
      id: OrderId,
      buyer: UserId,
      discount: Percentage,
      tags: Tags,
  }
  
  
  // 维护数据约束，通过私有字段和构造函数控制创建过程
  // 外部只能通过暴露的接口访问内部数据
  #[derive(Debug)]
  pub struct Percentage(u8);
  
  impl Percentage {
      pub fn new(value: u8) -> Result<Self, String> {
          if value <= 100 {
              Ok(Self(value))
          } else {
              Err(format!("百分比不能超过 100，当前值是 {value}"))
          }
      }
  
      pub fn value(&self) -> u8 {
          self.0
      }
  }
  
  // 绕过孤儿规则：为已有类型实现外部 trait
  #[derive(Debug)]
  struct Tags(Vec<String>);
  
  impl std::fmt::Display for Tags {
      fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
          write!(f, "{}", self.0.join(", "))
      }
  }
  ```
#### 动态大小类型DST
  切片`str`、`[T]`和trait对象`dyn Trait`在编译期无法确定大小或布局  
  DST无法直接使用，但可以通过引用或Box间接使用
  ```Rust
  #[allow(unused)]
  fn main() {
      let a: &str = "";
      let b: &[i32; 1] = &[1];
      let c: Box<str> = "".into();
      let c: Box<[u8]> = Box::new([1]);
  }
  ```
#### 零大小类型ZST
  ZST在内存中不占空间，但可以实例化，包括`Struct T`、`struct T {}`、`()`、`[T, 0]`
  ZST对齐要求为1
  ```Rust
  use std::mem::{size_of, size_of_val};

  fn main() {
      {
          struct Test;
          assert_eq!(0, size_of::<Test>());
      }
      {
          struct Test();
          assert_eq!(0, size_of::<Test>());
      }
      {
          assert_eq!(0, size_of::<[u8; 0]>());
      }
      {
          // []是静态数据
          // &[]相当于&[_, 0]，是一个胖指针
          let v: &[u8; 0] = &[];
          assert_ne!(0, size_of_val(&v));
      }
      {
          // &()是一个普通的指针
          let v: &() = &();
          assert_ne!(0, size_of_val(&v));
      }
  }
  ```
#### 空类型
  空类型不允许实例化，主要作用是使类型不可达
  ```Rust
  enum Void {}
  
  fn main() {
      fn test() -> Result<(), Void> {
          Ok(())
      }
      match test() {
          Ok(_) => {}
          Err(_) => {} // 不可到达分支，因为Void不能实例化
      }
  }
  ```
### 结构体
#### 结构体更新语法
  `..`语法指定使用其他实例创建实例，剩余未显示初始化的字段都使用给定实例对应字段的值更新(move)
  ```Rust
  fn main() {
    struct Test {
      name: String,
      age: u32,
    }
    let t = Test {
      name: String::from("test"),
      age: 20,
    };
    let t1 = Test {
      name: String::from("test1"),
      ..t
    };
    println!("{}, {}", t1.name, t1.age);
  }
  ```
### 标签
  `'label loop { break 'label; }`
### 函数
  * 函数内可以定义函数
  * 常量函数是可以在常量上下文中调用的函数
  ```Rust
  const fn square(x: i32) -> i32 {
      x * x
  }
  const VALUE: i32 = square(12);
  ```
### 借用
  * 概念
    * 共享借用: 通过`&T`创建对某个数据的不可变引用。只要存在共享借用，数据本身就不能被修改或移动。
    * 可变借用(也称独占借用): 通过`&mut T`获取数据独占访问权限。在同一生命周期内，某个数据一旦存在可变借用，就不能有其他任何其他借用(无论是共享借用还是可变借用)
    * 重借用: 从一个已存在的引用中，再创建一个新的引用，在新的生命周期内原引用(如果原引用是可变引用)会被暂时冻结/挂起，直到新引用的生命周期结束。重借用包括: 
      * 从`&T`中创建`&T`(原引用和新引用都可正常访问)
      * 从`&mut T`中创建不可变引用`&T`(原引用被临时冻结，可读但不可写)
      * 从`&mut T`中创建可变引用`&mut T`(原引用被临时挂起，即独占权被临时转移给新的引用，原引用完全不能访问)，这种情况即可变重借用
    * 隐式重借用: 将一个可变引用`&mut T`传递给一个可变借用`&mut T`的函数或赋值给一另个变量时，Rust不会move这个引用本身，而是自动隐式地根据原引用创建一个生命周期比较短的新引用，相当于自动插入`&mut *old_ref`，触发场景: 
      * 函数调用传入`&mut T`时
      * 显式类型标注的赋值与重新绑定
      * 方法调用中的self接收者
  * 一个对象在同一时间只能有一个可变借用或者多个不可变借用，不能同时拥有可变借用和不可变借用
  * 示例
    ```Rust
    fn main() {
      {
        let mut str = String::default();
        let r1: &String = &str; // 从数据创建共享借用
        let r2: &String = &*r1; // 从引用创建共享借用
    
        let r3 : &mut String = &mut str;
        let r4 : &String = &*r3; // 从可变借用中创建共享借用
      }
      {
        let mut str = String::default();
        let r1: &mut String = &mut str;
        let r2: &mut String = r1; // 隐式重借用，相当于 let r2: &mut String = &mut *r1;
      }
      {
        fn test(v: &mut String) {}
        let mut str = String::default();
        let r1: &mut String = &mut str;
        test(r1); // 隐式重借用，相当于 test(&mut *r1)
      }
      {
          let mut str = String::default();
          let r1: &mut String = &mut str;
          r1.push_str("hello"); // 隐式重借用，相当于 (&mut *r1).push_str("hello");
      }
      {
        let mut str = String::default();
        let r1: &mut String = &mut str;
        let r2 = r1; // r1 moved，因为没有强制要求进行类型转换
      }
      {
        let mut str= String::new();
        let r1: &String = &str;
        str.push_str("hello"); // error: 存在共享借用，无法被修改
        let str1 = str; // error:  存在共享借用，无法移动
        println!("{}", r1);
      }
      {
        let mut str = String::default();
        let r1: &mut String = &mut str;
        let r2: &String = &str; // error: 存在可变借用，不能共享借用
        println!("{}, {}", r1, r2);
      }
      {
        let mut str = String::from("hello");
        let r1: &mut String = &mut str;
        let r2: &String = &*r1;
        let _ = r1.clone(); // ok, r1被临时冻结，但允许共享读取
        println!("{}, {}", r1, r2); // ok, 都是共享读取
      }
      {
        let mut str = String::default();
        let r1: &mut String = &mut str;
        let r2: &mut String = &mut *r1;
        println!("{}, {}", r1, r2); // error: r2可变可借用时，r1被临时挂起，不允许访问
      }
      {
        struct Point { x: i32, y: i32 };
        let mut point = Point { x: 0, y: 0 };
        let x: &mut i32 = &mut point.x;
        let y: &mut i32 = &mut point.y;
        println!("{}, {}", x, y); // ok, 编译器允许独立借用结构体的不同字段
      }
      {
        let mut str = String::default();
        let r1: &mut String = &mut str;
        let r2: &&mut String = &r1; // 二级引用
        println!("{}, {}", r1, r2); // ok
      }
      {
        let mut str = String::default();
        let mut r1: &mut String = &mut str;
        let r2: &mut &mut String = &mut r1; // 二级可变引用
        r2.push_str(""); // ok
        println!("{}, {}", r1, r2); // error: r2可变借用时，r1被临时挂起，不允许访问
      }
    }

    ```
### 自动解引用
  自动解引用的情况:
  * 方法调用
  * 成员访问
  * 比较操作符两边是同类型引用
### 隐式Deref转换
  ```Rust  
  fn test(_s: &str) {}
  
  fn main() {
      {
          let s: &str = &String::default(); // Deref自动解引用
          test(&s);
      }
      {
          let s: String = String::default();
          test(&s); // Deref自动解引用
      }
      {
          let s: Box<String> = Box::new(String::default());
          test(&s); // Deref自动解引用
      }
  }
  ```
### 全局变量
  ```Rust
  #[allow(unused)]
  fn main() {
      {
          // 静态常量
          // 静态常量可能会被内联到代码，因此各处不保证引用的地址相同
          const MAX_COUNT: i32 = i32::MAX;
  
          // 静态变量
          // 静态变量必须实现Sync特征
          // 静态变量不会被内联，地址唯一
          // static G_COUNT: Rc<i32> = Rc::new(0);
      }
      {
          // 静态变量可以在unsafe块中修改
          static mut G_COUNT: i32 = 0;
          unsafe { G_COUNT += 1; }
          std::thread::spawn(|| { unsafe { G_COUNT = G_COUNT + 1; } }).join(); // 非线程安全
          unsafe { assert_eq!(G_COUNT, 2); }
      }
      {
          // 原子类型
          use std::sync::atomic;
          static G_COUNT: atomic::AtomicI32 = atomic::AtomicI32::new(0);
          G_COUNT.compare_exchange(0, 1, atomic::Ordering::SeqCst, atomic::Ordering::Relaxed);
          assert_eq!(G_COUNT.load(atomic::Ordering::Relaxed), 1);
      }
      {
          // 使用全局变量管理动态分配的变量
          static mut G_COUNT: Option<&mut i32> = None;
          unsafe { G_COUNT = Some(Box::leak(Box::new(0))); }
          unsafe { assert_eq!(*G_COUNT.as_deref_mut().unwrap(), 0); }
      }
      {
          // OnceCell: 单线程的全局变量，只能初始化一次
          use std::cell::OnceCell;
          struct Logger;
          let count: OnceCell<Logger> = OnceCell::new();
          count.get_or_init(|| Logger);
      }
      {
          // OnceLock: 多线程的全局变量，只能初始化一次
          use std::sync::OnceLock;
          struct Logger;
          static G_COUNT: OnceLock<Logger> = OnceLock::new();
          G_COUNT.get_or_init(|| Logger);
      }
      {
          // lazy_static第三方库
          // 运行时初始化
      }
  }
  ```
### 内存对齐
  * 为了避免浪费空间，Rust中数据结构布局不保证顺序
### 堆栈
  * 在Rust中，main线程的栈大小是8MB，普通线程是2MB，在函数调用时会在其中创建一个临时栈空间
  * cargo test是普通线程，cargo bench是主线程

## 泛型
  * 泛型支持指定默认类型
  * 约束条件尽量在impl中指定，除非该类型没有impl实现，才在定义时指定(因为即使在定义时指定了，impl中也需要再次指定)
  ```Rust
  #[derive(Debug)]
  struct Pair<T, U> {
      //      ^^^^
      // 声明：Pair 有两个泛型参数 T、U
  
      first: T,  // 使用 T
      second: U, // 使用 U
  }
  
  // A、B 只是局部名字，不必与 struct 中的 T、U 同名
  impl<A, B> Pair<A, B> {
      // ^^^^       ^^^^
      // 声明 A、B   把 A、B 传给 Pair
      //
      // 对应关系按位置确定：
      // struct 的 T = impl 的 A
      // struct 的 U = impl 的 B
  
      // A、B 已经由 impl 声明，方法不用再写 <A, B>
      fn first(&self) -> &A {
          &self.first
      }
  
      fn second(&self) -> &B {
          &self.second
      }
  
      // V 是这个方法新增的类型，因此在方法名后声明 <V>
      fn replace_second<V>(self, new_second: V) -> Pair<A, V> {
          //                 ^ 新类型 V        ^ 使用 A 和 V
          Pair {
              first: self.first,      // A
              second: new_second,     // V
          }
      }
  }
  
  // 针对特定类型 Pair<f64, f64> 的实现
  // 类型已经确定，不需要 impl<T>
  impl Pair<f64, f64> {
      fn sum(&self) -> f64 {
          self.first + self.second
      }
  }
  
  // 针对特定类型的 Pair<Vec<E>, usize> 的实现
  impl<E> Pair<Vec<E>, usize> {
      // ^ 声明 E
      //          ^^^^^^ 使用 E：Pair 的第一个类型是 Vec<E>
      //                  Pair 的第二个类型固定为 usize
  
      fn first_item(&self) -> Option<&E> {
          self.first.first()
      }
  
      fn stored_len(&self) -> usize {
          self.second
      }
  }
  
  // 普通泛型函数：函数自己声明 T
  fn duplicate<T: Clone>(value: T) -> Pair<T, T> {
      //          ^ 使用 T              ^ 使用 T
      Pair {
          first: value.clone(),
          second: value,
      }
  }
  
  // struct Pair<T, U>
  // │
  // │  T、U 只在结构体定义中声明字段类型
  // │
  // ├── impl<A, B> Pair<A, B>
  // │   │
  // │   │  A、B 属于整个 impl 块
  // │   │
  // │   ├── fn first(&self) -> &A
  // │   │       直接使用已有的 A，不重新声明
  // │   │
  // │   └── fn replace_second<V>(...)
  // │           V 是该方法新引入的类型
  // │
  // ├── impl Pair<f64, f64>
  // │       类型全部确定，不声明泛型
  // │
  // └── impl<E> Pair<Vec<E>, usize>
  // E 是未知类型，需要声明
  // Vec<E> 使用 E
  // usize 已确定，不需要声明
  ```

## 模式匹配
  [参考](https://rustwiki.org/zh-CN/reference/patterns.html)
  ```Rust
  #[derive(Copy, Clone)]
  struct Tuple(i32, i32);
  
  #[derive(Copy, Clone)]
  struct Test {
      a: i32,
      b: Option<(i32, i32)>,
      c: Tuple,
  }
  
  enum MyEnum {
      A(i32, i32, i32),
      B,
  }
  
  enum MyEnum1 {
      A = 1, B, C,
  }
  
  #[allow(unused)]
  fn main() {
      let mut t = Test {
          a: 0,
          b: Some((1, 2)),
          c: Tuple(1, 2),
      };
      let e = MyEnum::A(1, 2, 3);
      let v = ['h', 'e', 'l', 'l', 'o', '!'];
  
      // 解构
      match t {
          Test { a, b, c } => {} // 因为Test实现了Copy特征，t的成员不会转移所有权
          Test { ref a, b: Some((ref mut b1, mut b2)), c } => {} // a为不可变借用，b1为可变借用，b2为可变变量(转移所有权)
      }
      match &t {
          Test { a, b: Some((b1, b2)), c } => {} // 对引用解构，被匹配的变量也将被赋值为对应元素的引用
          _ => {}
      }
      match e {
          MyEnum::A(a, b, _) => {} // 省略第3个成员
          MyEnum::A(a, b, _c) => {} //_c会绑定到变量，而_不会绑定
          MyEnum::A(a, ..) => {} // 省略后2个成员
          MyEnum::A(.., c) => {} // 省略前2个成员
          MyEnum::B => {}
          //MyEnum::A(ab @ .., c) => {} // error: `ab @ ` is not allowed in a tuple struct
          _ => {}
      }
  
      // 范围匹配模式
      match v {
          ['h', .., '!'] => {} // 匹配以'!'结尾的切片
          [start @ .., '!'] => {} // 开头匹配并绑定变量名, start = ['h', 'e', 'l', 'l', 'o']
          ['h', mid @ .., '!'] => {} // 部分匹配并绑定变量名, mid = ['e', 'l', 'l', 'o']
          ['h', .., '!'] if v[1] == 'e' => {} // 匹配守卫
          _ => {}
      }
  
      // or模式
      match (1, 2) {
          (1 | 2, 1 | 2) => {}
          (1, _) | (_, 2) => {}
          (x @ 1, _) | (_, x @ 2) => println!("{}", x),
          _ => {}
      }
  
      // 字面量匹配
      match 1 {
          1 | 2 => {}
          _ => {}
      }
  
      // 范围匹配
      // 支持类型: 整型(u8、i8、u16、i16、usize、isize...)，字符型(char)，浮点类型(f32和f64) [已弃用]
      match 1 {
          0..=10 => {} // 范围匹配，目前只支持全闭合区间
          0..=10 if 1 % 2 == 0 => {} // 匹配守卫，匹配分支后再检查后置条件
          _ => {}
      };
  
      // if let
      // match需要穷举所有分支, 而if let是match的语法糖，只关心指定分支，其他分支(`_分支`)由else负责
      if let MyEnum::A(a, b, c) = e {} else if let MyEnum::B = e {} else {}
      
      // let else
      // 在模式不匹配时发散，例如continue、break、return、panic!
      let Some(v) = Option::<()>::None else { panic!(""); };

      // let
      let (ref x, ref y, ref z) = (1, 2, 3);
      let Test {ref a, ref b, ref c} = t;
      let ref mut i = &0; // ref修饰变量名时相当于强行加上引用
  
      //for
      let mut s = Vec::from([1, 2, 3]);
      for (index, value) in s.iter().enumerate() {}
  
      // while let
      let mut s1 = s.clone();
      while let Some(top) = s1.pop() {}
  
      // 函数参数本身也是模式
      fn test(&(x, y): &(i32, i32)) {}
  
      // matches宏(注意参数顺序，左边是表达式，右边是模式)
      let foo = 'f';
      assert!(matches!(foo, 'A'..='Z' | 'a'..='z'));
      let bar = Some(4);
      assert!(matches!(bar, Some(x) if x > 2));
      let mut s1 = Vec::from([MyEnum1::A, MyEnum1::B, MyEnum1::C]);
      // for x in s1.iter().filter(|x| **x == MyEnum1::A) {} // must implement `PartialEq`
      for x in s1.iter().filter(|x| matches!(x, MyEnum1::A | MyEnum1::B | MyEnum1::C)) {}
  }
  ```

## Trait
### 孤儿规则
  为一个类型实现实现Trait时，至少要有一个类型是当前crate定义的。即不能使用外部类型给外部类型实现Trait，但是可以通过newtype绕过限制
### 有条件地实现方法(T满足条件，给类型<T>实现方法/关联函数)
  ```Rust
  impl<T: 条件> 类型<T> {
    fn 方法(&self) { }
  }
  ```
### 为满足约束的类型实现Trait(T满足条件，给T实现Trait)
  ```Rust
  // 为类型实现特征
  impl 特征 for 类型 {
  }
  // 为满足特定条件的类型实现特征
  impl<T: 条件> 特征 for T {
    // 实现
  }
  ```
### 特征对象的限制
  ```Rust
  fn main() {
    trait Service {
      // 以下方法不能通过动态派发(dyn Trait)
      // fn name() -> String;              // 必须有可用于动态分发的接收者，如&self、&mut self、Box<Self>
      // fn convert<T>(&self, value: T);   // 方法不能使用类型泛型参数(可使用生命周期泛型)，因为每种泛型都需要生成不同的代码，无法用固定的虚表索引
      // fn clone_self(&self) -> Self;     // 返回值不能是Self，因为Self类型未知、大小未知
      // fn ref_self(&self) -> &Self;      // 类型未知
  
      // ok, 返回类型是统一的 Box<dyn Service>
      fn clone_to_box(&self) -> Box<dyn Service>;
  
      // ok, 给上面的方法加上约束，使其只对特定类型可用，但仍无法动态派发
      fn name() -> String where Self: Sized;
      fn convert<T>(&self, value: T) where Self: Sized;
      fn clonse_self(&self) -> Self where Self: Sized;
    }
  
    struct Test {};
  
    impl Service for Test {
      fn clone_to_box(&self) -> Box<dyn Service> { Box::new(Test {}) }
  
      fn name() -> String where Self: Sized { String::from("test") }
  
      fn convert<T>(&self, value: T) where Self: Sized { }
  
      fn clonse_self(&self) -> Self where Self: Sized { Self {} }
    }
  
    let t = Test {};
    let v: &dyn Service = &t;
    v.clone_to_box();
    <Test as Service>::name();
    Service::convert(&t, &t);
    Service::clonse_self(&t);
  }
  ```
### 常用特征
#### Drop特征
  离开作用域时自动调用析构方法drop
#### From/Into
#### Move、Clone和Copy
##### Move
  * Move 表示所有权转移。Move之后，源位置通常被视为未初始化，因此不能继续读取，直到重新赋值
  * Move 在语义上不是浅拷贝或深拷贝。实现层面通常只转移值自身的内存表示，编译器也可能将实际的数据复制优化掉。
  * 如果值包含堆资源，如 String或Vec<T>，Move不会复制堆中的内容，只转移其所有权。实现层面通常处理的是指针、长度、容量等字段。
  * 如果值完全存储在栈上，如大型数组或大型结构体，Move在未被优化时可能需要复制该值的全部内存表示。为避免栈溢出和较大的复制成本，不宜在栈上放置过大的值。
  * 在需要按值使用变量时，若类型实现了Copy，会复制值，原变量仍可使用；若未实现Copy，则发生Move，原变量不能继续读取。
  * 将非Copy字段从结构体中移出会造成部分移动。被移动的字段不能继续使用，其他未移动字段仍可单独使用，但结构体暂时不能作为完整值使用。
  * 实现了Drop的类型，通常不能直接移出其非Copy字段。
  * 对于没有实现Copy的类型，如`let x = "".to_string(); x;`中的`x;`相当于`let _temp = x;`
##### Copy
  * Copy是浅拷贝，表示值可以通过简单的按位复制被隐式复制。赋值、传参后，原变量仍然可用。
  * 类型实现Copy的前提是所有直接字段都实现Copy，并且该类型没有实现Drop
  * 默认支持Copy的类型: 基本类型、基本类型组成的元组、&T、指针，&T实现Copy与T是否实现无关，&mut T不能实现Copy
##### Clone
  * Clone是一般是深拷贝（由具体实现决定）
  * 使用`#[derive(Clone)]`时，编译器会依次克隆所有字段，因此所有字段都必须实现Clone
  * 手动实现Clone时，可自定义克隆行为，因此不严格要求所有字段都必须实现Clone
  * 引用本身实现了Clone，克隆引用只会复制引用。但使用r.clone()方法语法时，自动解引用可能使调用解析到T::clone()。需要明确克隆引用时，可以写<&T>::clone(&r)或直接赋值。
### 外部特征
  * Rust中无法为外部类型实现外部特征，比如无法为Vec实现Display，但可以通过newtype实现`struct MyVec(Vec<i32>); impl Display for Myvec {}`
### 约束条件
  * 以下三种写法等效
    * `pub fn notify(item: &(impl Summary + Display)) {}`
    * `pub fn notify<T: Summary + Display>(item: &T) {}`
    * `pub fn notify<T>(item: &T) where T: Summary + Display {}`
### 有条件地实现方法和特征
  ```Rust
  use std::fmt::{Debug};

  struct Test<T>(T);

  impl<T: Default + Clone> Test<T> {
      fn new() -> Test<T> {
          Test(T::default())
      }

      fn from(t: T) -> Test<T> {
          Test(t.clone())
      }
  }

  impl<T: std::ops::Add<Output=T> + Copy> Test<T> {
      fn add(&mut self, t: &Self) {
          self.0 = self.0 + t.0
      }
  }

  impl<T: Debug> Test<T> {
      fn print(&self) {
          println!("{:?}", self.0);
      }
  }

  impl<T: PartialEq> PartialEq for Test<T> {
      fn eq(&self, other: &Self) -> bool {
          self.0 == other.0
      }
  }

  fn main() {
      let mut a = Test::<String>::new();
      //a.add(&Test::from("".to_string())); // String未实现std::ops::Add和Copy
      assert_eq!(true, a.eq(&Test::<String>::new()));
      a.print();

      let mut b = Test::<i32>::new();
      b.add(&Test::from(3));
      assert_eq!(false, b.ne(&Test::<i32>::from(3)));
      b.print();
  }
  ```
### 多态
  * `fn test<T: std::fmt::Display>(t: &T) {}`与`fn test(t: &impl std::fmt::Display) {}`相同，都是静态派发，后者是前者的语法糖
#### 静态多态与动态多态
  ```Rust
  use std::fmt::Debug;

  fn type_of<T>(_: &T) -> &str { std::any::type_name::<T>() }

  #[allow(unused)]
  fn main() {
      // impl Trait是静态多态，在编译时单态化展开
      {
          fn make_string() -> impl Debug { String::default() }
          fn make_vec() -> impl Debug { Vec::<&str>::default() }
          assert_eq!("alloc::vec::Vec<&str>", type_of(&make_vec()));
          assert_eq!("alloc::string::String", type_of(&make_string()));

          fn from(v: &impl Debug) { println!("{:?}", v) }
          from(&"");
      }
      // 泛型是静态多态，编译时展开
      {
          fn make_obj<T: Debug + Default>() -> T {
              T::default()
          }
          assert_eq!("alloc::vec::Vec<&str>", type_of(&make_obj::<Vec<&str>>()));
          assert_eq!("alloc::string::String", type_of(&make_obj::<String>()));
      }
      // dyn Trait是动态多态
      {
          fn make_obj<T: Debug + Default + 'static>() -> Box<dyn Debug>{
              Box::new(T::default())
          }
          fn make_obj_ref<T: Debug + Default>(obj: &dyn Debug) -> Box<&dyn Debug> {
              Box::new(obj)
          }
          let v = [make_obj::<String>(), make_obj::<Vec<&str>>()];
          let r = [make_obj_ref::<String>(&v[0]), make_obj_ref::<Vec<&str>>(&v[1])];
          assert_eq!("alloc::boxed::Box<dyn core::fmt::Debug>", type_of(&make_obj::<String>()));
      }
  }
  ```
#### 动态多态
  ```Rust
  trait Vehicle {
      fn name(&self) -> &str;
  }

  struct Car;
  impl Vehicle for Car {
      fn name(&self) -> &str {
          "car"
      }
  }

  struct Trunk;
  impl Vehicle for Trunk {
      fn name(&self) -> &str {
          "trunk"
      }
  }

  struct Person<'a> {
      vehicle: Option<&'a dyn Vehicle>,
  }

  impl<'a /*T不可在此定义，impl中定义必须在Person中使用*/> Person<'a> {
      fn new() -> Person<'a> {
          Person { vehicle: None }
      }

      fn set_car<T: Vehicle>(&mut self, v: &'a T) {
          self.vehicle = Some(v);
      }

      fn get_car_name(&self) -> &str {
          match self.vehicle {
              Some(v) => v.name(),
              None => "",
          }
      }
  }

  fn main() {
      let mut p = Person::new();
      p.set_car(&Trunk {});
      p.get_car_name();
  }
  ```
#### trait中使用关联类型代替泛型
  ```Rust
  use std::fmt::{Debug};
  
  #[allow(unused)]
  fn main() {
      trait MyTrait: Debug + Copy + Clone/*对派生类型的约束*/ {
          type Type: Debug + Copy + Clone; // 对关联类型的约束
  
          fn f(v: Self::Type);
      }
  
      #[derive(Debug, Copy, Clone)]
      struct MyStruct;
  
      impl MyTrait for MyStruct {
          type Type = ();
  
          fn f(v: Self::Type) {}
      }
  }
  ```
#### 在Trait中定义异步方法
  * [解决方案](https://stackoverflow.com/questions/65921581/how-can-i-define-an-async-method-in-a-trait)
  * [参考](https://doc.rust-lang.org/reference/items/traits.html#object-safety)
#### [具有泛型参数的Trait方法为什么不是对象安全的？](https://stackoverflow.com/questions/67767207/why-are-trait-methods-with-generic-type-parameters-object-unsafe)

## 属性
  [参考](https://rustwiki.org/zh-CN/reference/attributes.html?highlight=repr#%E5%86%85%E7%BD%AE%E5%B1%9E%E6%80%A7%E7%9A%84%E7%B4%A2%E5%BC%95%E8%A1%A8)
  * 指定枚举数值范围: `#[repr(u8) enum MyEnum {}`

## 字符串转换
  ```
  fn main() {
      // char, 参考: https://doc.rust-lang.org/beta/std/primitive.ehar.html
      println!("{}", char::from_u32(0x1d54f).unwrap());
  
      // &str为起点
      let s: &str = "Hello world!";
      let _: &[u8] = s.as_bytes();
      let s: String = s.to_string();
      let s: String = s.to_owned();
      let _: Vec<u8> = s.as_bytes().to_vec();
      let _: Vec<u8> = s.as_bytes().to_owned();
      let _: Vec<char> = s.chars().collect();
  
      // String为起点
      let s: String = String::from("Hello world!");
      let _: &str = &s;
      let _: &str = s.as_str();
      let _: &str = &s[0..];
      let _: &[u8] = s.as_bytes();
      let _: Vec<char> = s.chars().collect();
      let _: Vec<u8> = s.as_bytes().to_vec();
  
      // &[u8]为起点
      let s: &[u8] = br"Hello world!";
      let _: String = s.iter().map(|b| *b as char).collect();
      let _: Vec<u8> = s.to_vec();
      let _: Vec<u8> = s.to_owned();
  
      // Vec<u8>为起点
      let s: Vec<u8> = br"Hello world!".to_vec();
      let _: &[u8] = s.as_slice();
      let _: String = String::from_utf8(s.clone()).unwrap();
      let _: Vec<char> = s.iter().map(|b| *b as char).collect();
  
      // Vec<char>为起点
      let s: Vec<char> = vec!['H', 'e', 'l', 'l', 'o', ' ', 'w', 'o', 'r', 'l', 'd', '!'];
      let _: &[char] = s.as_slice();
      let _: String = s.iter().collect();
  }
  ```
  
## 生命周期
### 生命周期约束
  ```Rust
  struct Test<'a> {
    v: &'a str,
  }

  impl<'a> Test<'a> {
    fn test<'b>(&'a self, v: &'b str) -> &'b str
    where 'a: 'b { 
      self.v
    }
  }
  // 'a: 'b 通俗地解释是：函数承诺返回的引用至少可以活'b，但实际返回的self.v只能活'a，
  // 所以为了使'a能覆盖'b，需要告诉编译器'a的生命周期至少是'b
  ```
### 不太聪明的生命周期检查
  ```Rust
  #[derive(Debug)]
  struct Foo;
  
  impl Foo {
      fn mutate_and_share<'a>(&'a mut self) -> &'a Self {
          &*self // self本身是对self(即foo)的可变借用，返回值是从这个可变借我派生出的再借用
      }
      fn share(&self) {}
  }
  
  fn main() {
      let mut foo = Foo;
      let loan = foo.mutate_and_share();
      foo.share(); // ERROR: 返回的再借用与loan共存，违反借用规则
      println!("{:?}", loan);
  }
  ```
  ```Rust
  // 编译错误
  use std::collections::HashMap;
  use std::hash::Hash;
  
  #[allow(unused)]
  fn main() {
      // 编译错误
      {
          fn get_value<K, V>(map: &mut HashMap<K, V>, key: K) -> &mut V
              where
                  K: Clone + Eq + Hash,
                  V: Default {
              match map.get_mut(&key) {
                  Some(v) => v,
                  None => {
                      // 理论上两个分支的借用互不影响，但编译器借用检查器的控制流分析存在限制，下一代借用检查器方案Polonius会解决这个问题
                      map.insert(key.clone(), V::default()); // error[E0499]: cannot borrow `*map` as mutable more than once at a time
                      map.get_mut(&key).unwrap()
                  }
              }
          }
      }
      // 编译通过
      {
          fn get_value<K, V>(map: &mut HashMap<K, V>, key: K) -> &mut V
              where
                  K: Clone + Eq + Hash,
                  V: Default {
              if !map.contains_key(&key) {
                  map.insert(key.clone(), V::default());
              }
              return map.get_mut(&key).unwrap();
          }
      }
      // 编译通过(更简洁的写法)
      {
          fn get_value<K, V>(map: &mut HashMap<K, V>, key: K) -> &mut V
              where
                  K: Clone + Eq + Hash,
                  V: Default {
              map.entry(key).or_default()
          }
      }
  }
  ```
  ```Rust
  struct Test {
      a: u32,
      b: u32
  }
  
  impl Test {
      fn increase(&mut self) {
          // 允许对结构不同字段同时可变引用
          let mut a = &mut self.a;
          let mut b = &mut self.b;
          *b += 1;
          *a += 1;
      }
  
      //fn increase_a(&mut self) {
      //    self.a += 1;
      //}
  
      //fn increase(&mut self) {
      //    let b = &mut self.b;
      //    self.increase_a(); // error: 对结构的重复可变借用
      //    *b += 1;
      //}
  }
  ```
  ```Rust
  use std::cell::RefCell;
  use std::io::Write;
  
  struct Data {
      string: String,
  }
  
  struct Writer {
      data: Data,
      writer: Vec<u8>,
  }
  
  #[allow(unused)]
  fn write(s: RefCell<Writer>) {
      // 重复借用问题
      {
          // let mut mut_s = s.borrow_mut();
          // let str = &mut_s.data.string; // mut_s deref时会借用
          // mut_s.writer.write(str.as_bytes()); // mut_s deref时会可变借用
      }
      // 解决办法: 先对mut_s解引用，再对结构的不同字段借用
      {
          let mut mut_s = s.borrow_mut();
          let tmp = &mut *mut_s;
          let str = &tmp.data.string;
          tmp.writer.write(str.as_bytes());
      }
      // 类似的还有:
      // Box
      // MutexGuard(来源于 Mutex)
      // PeekMut(来源于 BinaryHeap)
      // RwLockWriteGuard(来源于 RwLock)
      // String
      // Vec
      // Pin
  }
  ```
  ```Rust
  fn main() {
      // 闭包中返回引用时，编译器无法推测生命周期，且很难被解决，最好用普通函数代替
      // let _ = |x: &i32| -> &i32 { x }; // Error: lifetime may not live long enough
  
      fn f(x: &i32) -> &i32 { x }
  }
  ```
  
## `T:'static` vs `&'static T`
  [常见的 Rust 生命周期误解](https://github.com/pretzelhammer/rust-blog/blob/master/posts/common-rust-lifetime-misconceptions.md)
  ```Rust
  static N: i32 = 1;
  
  struct Test<'a>(&'a i32);
  static T: Test = Test(&N);
  
  // T:'static: T可以被安全地无期限地持有，甚至可以直到程序结束。属于特征约束，即T类型不持有非'static生命周期的引用
  fn ref_1<T: 'static>(_: &'static T) {}
  
  // &'static T: 引用必须要活得跟剩下的程序一样久，生命周期针对的是引用本身
  fn ref_2<T>(_: &'static T) {}
  
  fn main() {
      ref_1(&T);
  
      // let t = Test(&N);
      // ref_1(&t); // error[E0597]: `t` does not live long enough
  
      let n = 1;
      ref_2(&N);
      ref_2(&1);
      // ref_2(&n); // error[E0597]: `n` does not live long enough
  }
  ```
  
## 闭包
### 闭包的Fn特征推导规则
  * 一个闭包实现了哪种Fn特征取决于该闭包如何使用被捕获的变量，而不是取决于闭包如何捕获它们
  * 所有的闭包都自动实现了FnOnce特征，因此任何一个闭包都至少可以被调用一次
  * 移出捕获值，仅实现FnOnce
  * 不移出但修改捕获值，实现FnMut + FnOnce
  * 既不移出也不修改捕获值，实现Fn + FnMut + FnOnce
### Fn、FnMut、FnOnce的关系
  * Fn        能满足 FnMut 和 FnOnce 的要求
  * FnMut     能满足 FnOnce 的要求
  * FnOnce    要求最宽，只保证能调用一次
### 闭包中必须要显式添加move的场景
  * 闭包被发送到新线程
  * 从函数返回捕获局部变量的闭包
  * 闭包需要存活得比被捕获变量所在作用域更久
  * async块需要拥有外部数据
 
  ```Rust
  fn test<'a, F> (f: F) -> &'a mut String
      where
          F: FnOnce () -> &'a mut String {
      f()
  }
  
  fn test1<F>(mut f: F) -> String
      where
          F: FnMut () -> String {
      f()
  }
  
  fn test2<F>(f: F) -> String
      where
          F: FnOnce () -> String {
      f()
  }
  
  fn test3<F>(f: F) -> String
      where
          F: Fn () -> String {
      f()
  }
  
  fn main () {
 
      let mut a = String::from("Hello world");
      println!("{:?}", test(|| &mut a));                    // FnOnce
      println!("{:?}", test1(|| { a += "!"; a.clone() }));  // FnMut
      println!("{:?}", test3(|| { let b = a.clone(); b })); // Fn
      println!("{:?}", test2(|| { let b = a.clone(); b })); // Fn
      println!("{:?}", test2(move || { let b = a; b }));    // FnOnce
  }
  ```

## 智能指针
### 区别
  * Box: 简单的智能指针
    * 使用Box::leak可以泄漏Box管理的对象，并且该对象具体与程序相同的生命周期
      ```Rust
      struct Test;

      impl Test {
          fn new() -> Test {
              println!("new Test");
              Test
          }
      }
      
      impl Drop for Test {
          fn drop(&mut self) {
              println!("drop Test");
          }
      }
      
      fn convert_to_static<T>(v: Box<T>) -> &'static mut T { Box::leak(v) }
      
      fn main() {
          {
              let _ = Test::new(); // 离开作用域会销毁
          }
          {
              let _ = Box::leak(Box::new(Test::new())); // 离开作用域不会销毁
          }
          {
              let _ = convert_to_static(Box::new(Test::new())); // 离开作用域不会销毁
          }
          {
              let _ = Box::from(Box::leak(Box::new(Test::new()))); // 回收泄漏的对象
          }
      }
      ```
  * Rc/Arc: 带引用计数的智能指针，内部不可变；Rc不能跨线程使用；Arc可跨线程使用
  * Cell: Cell可以对不可变值的内部进行修改，适用于可Copy类型的智能指针
    ```Rust
    let a = Cell::new(1);
    let b = &a;
    let c = &a;
    b.set(2);
    c.set(3);
    ```
  * RefCell: RefCell可以对不可变值进行可变借用，RefCell只是将借用规则从编译期推迟到程序运行期，违背借用规则会导致运行期的panic
    ```Rust
    let a = RefCell::new(String::from("hello, world"));
    let b = a.borrow();
    let c = a.borrow_mut(); // panic
    ```
  * Pin:
    * 与Sync/Send类似的标记特征，绝大多数类型都自动实现了Unpin  
    `impl<P> Unpin for Pin<P> where P: Unpin {}`
    * Pin解决的问题是在Safe Rust下保证Pin<T>中的T内存地址不会改变。如果Pin<T>不能被移动，T必须实现!Unpin特征
    * Pin<T>保证T不被move，Pin<P<T>>是保证P<T>不被move而不是T
    * Unpin只保证在Safe Rust下拿到&mut T，如果实现了Unpin特征还是可以Pin的但是不再有任何效果(还是可以拿到&mut T)。被Pin住的内存只能通过Unsafe方式拿到&mut T，比如get_unchecked_mut  
    `pub const unsafe fn get_unchecked_mut(self) -> &'a mut T { self.__pointer }`  
    `pub const fn get_mut(self) -> &'a mut T where T: Unpin, { self.__pointer }`  
    ```Rust
    use std::marker::PhantomPinned;
    use std::ops::DerefMut;
    use std::pin::pin;
    
    fn check_unpin(_: impl Unpin) {}
    
    #[allow(unused)]
    fn main() {
    {
        #[derive(Clone,Copy)]
        struct Test; // Test是Unpin

        let mut p = pin!(Box::new(Test));
        check_unpin(**p);

        p.deref_mut(); // 允许可变借用
        p.get_mut(); // 允许move
    }
    {
        #[derive(Clone, Copy)]
        struct Test { _marker: PhantomPinned } // Test是!Unpin

        let mut p = pin!(&Test { _marker: PhantomPinned }); // 固定到栈上
        check_unpin(*p); // &T自动实现了Unpin
        // check_unpin(**p); // `PhantomPinned` cannot be unpinned

        // p.deref_mut(); // 禁止可变借用
        // p.get_mut(); // 禁止move

        pin!(Box::new(Test { _marker: PhantomPinned })); // 固定到堆上
    }
    {
        let f = async {}; // Future是!Unpin
        // check_unpin(f); // `async fn` cannot be unpinned

        tokio::pin!(f); // f: Pin<& Future>
        check_unpin(f); // pin<Future>是Unpin
    }

    ```
### 组合使用
  * Rc<RefCell<T>>: 多个所有者+单线程内部可变性
  * Arc<Mutex<T>>: 多线程内部可变性
  
## 使用Cell解决借用冲突
  ```Rust
  use std::cell::Cell;
  
  fn main() {
      let mut v = Vec::<i32>::new();
      for i in 0..9 {
          v.push(i);
      }
      // for i in v.iter().filter(|&num| num %2 == 0 ) {
      //     v[*i as usize] *= 2; // cannot borrow `v` as mutable because it is also borrowed as immutable
      // }
      let vc = Cell::from_mut(&mut v[..]).as_slice_of_cells();
      for i in vc.iter().filter(|&num| num.get() % 2 == 0) {
          vc[i.get() as usize].set(i.get() * 2);
      }
      println!("{:?}", v);
  }
  ```

## 异步
### async闭包
  `async move {}`相当于普通闭包的`move || {}`
### async/await
  ```Rust
  use std::cell::RefCell;
  use std::pin::Pin;
  use std::process::exit;
  use std::sync::{Arc, mpsc::{channel, Receiver, Sender}, Mutex};
  use std::time::{Duration, Instant};
  use std::task::{Context, Poll, Waker};
  use std::thread;
  use std::thread::sleep;
  use futures::{Future};
  use futures::future::BoxFuture;
  use futures::task::{ArcWake, waker_ref};
  
  struct Task {
    // Task实际不跨线程，理论上不需要Mutex，但ArcWake要求Task是Sync
    future: Mutex<BoxFuture<'static, ()>>,
  
    // task就绪时，task使用sender向队列发送自身获得poll的机会
    sender: Sender<Arc<Task>>,
  }
  
  impl ArcWake for Task {
    fn wake_by_ref(arc_self: &Arc<Self>) {
      arc_self.sender.send(arc_self.clone()).unwrap();
    }
  }
  
  struct MiniTokio {
    // 等待poll的任务
    scheduled: Receiver<Arc<Task>>,
  
    sender: Sender<Arc<Task>>,
  }
  
  impl MiniTokio {
    fn new() -> MiniTokio {
      let (tx, rx) = channel();
  
      MiniTokio {
        scheduled: rx,
        sender: tx,
      }
    }
  
    async fn sleep(duration: Duration) {
      struct Timer {
        end: Instant,
  
        waker: Option<Arc<Mutex<Waker>>>,
      }
  
      impl Future for Timer {
        type Output = ();
  
        // poll调用时机:
        // 1. 外层Future被poll并执行到await时，被等待的Future会被poll
        // 2. wake只是把任务重新加入执行器的就绪队列
        // 3. 执行器之后再次poll外层任务，外层任务再继续poll被等待的Future
        //
        // Future需要pin的原因:
        // 因为Future需要在loop中不断poll，需要保证其在内存中的位置不会被移动
        // 解决方法一: 要求Future是Unpin，然后使用&mut Future来poll
        // 因为future库的实现会自动给&mut Future实现Future，&mut Future作为Future来poll，Future则不会被move
        // impl<F: ?Sized + Future + Unpin> Future for &mut F {
        //     type Output = F::Output;
        //     fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        //         F::poll(Pin::new(&mut **self), cx)
        //     }
        // }
        // 解决方法二: 使用tokio::pin把Future固定(Future变成Pin<&mut Future>)，然后再可变借用它，即&mut Pin<&mut Future>，它是Unpin的
        fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
          if let Some(waker) = &self.waker {
            // 判断两个wake是否会唤醒同一个任务，如果不是则需要更新waker，否则Future完成条件发生变化时可能无法被唤醒
            // 返回true：保证唤醒同一任务
            // 返回false：无法确认，可能相同，也可能不同
            let mut waker = waker.lock().unwrap();
            if !waker.will_wake(cx.waker()) {
              *waker = cx.waker().clone();
            }
            println!("[TIMER]poll");
          } else {
            let waker = Arc::new(Mutex::new(cx.waker().clone()));
            self.waker = Some(waker.clone());
  
            // 第一次poll时创建一个线程（简单的实现方式）
            let end = self.end;
            thread::spawn(move || {
              sleep(end.saturating_duration_since(Instant::now()));
  
              // 唤醒Timer
              waker.lock().unwrap().wake_by_ref();
            });
            println!("[TIMER]create");
          }
  
          if Instant::now() >= self.end {
            println!("[TIMER]ready");
            Poll::Ready(())
          } else {
            println!("[TIMER]pending");
            Poll::Pending
          }
        }
      }
  
      Timer {
        end: Instant::now() + duration,
        waker: None
      }.await;
    }
  
    fn spawn(future: impl Future<Output=()> + Send + 'static) -> Arc<Task> {
      println!("[RUNTIME]spawn");
      let mut task = Option::<Arc<Task>>::None;
      RUNTIME.with(|runtime| {
        task = Some(Arc::new(Task {
          future: Mutex::new(Box::pin(future)),
          sender: runtime.borrow().sender.clone(),
        }));
      });
      let task = task.unwrap();
      task.sender.send(task.clone()).unwrap();
      task
    }
  
    fn run() {
      // Future执行过程
      // 执行器准备 Task 对应的 Waker
      // ↓
      // 使用 Waker 创建 Context
      // ↓
      // 执行器调用 Future::poll(..., &mut Context)
      // ↓
      // Future 未完成，克隆并保存 Context 中的 Waker
      // ↓
      // Future 返回 Pending，Context 的本次借用结束
      // ↓
      // I/O、定时器等事件完成
      // ↓
      // 调用保存的 Waker
      // ↓
      // 对应 Task 再次进入执行器的就绪队列
      // ↓
      // 执行器创建新的 Context，再次 poll Future
      RUNTIME.with(|runtime: &RefCell<MiniTokio>| {
        // while let在future.poll期间会继续持有runtime的借用，在future中再次调用spawn会借用失败
        // 解决方法 while let it = { let it = $expr; it }
        while let Ok(task) = { let task = runtime.borrow_mut().scheduled.recv(); task } {
          println!("[RUNTIME]poll");
          let mut future = task.future.lock().unwrap();
          let waker = waker_ref(&task);
          let ctx = &mut Context::from_waker(&waker);
          let _ = future.as_mut().poll(ctx);
        }
      });
    }
  }
  
  thread_local! {
        static RUNTIME: RefCell<MiniTokio> = RefCell::new(MiniTokio::new());
    }
  
  fn main() {
    MiniTokio::spawn(async {
      println!("sleep1 begin");
      MiniTokio::sleep(Duration::from_secs(3)).await;
      println!("sleep1 end");
  
      println!("sleep2 begin");
      MiniTokio::sleep(Duration::from_secs(1)).await;
      println!("sleep2 end");
  
      MiniTokio::spawn(async {
        let future = async {
          println!("sleep4 begin");
          MiniTokio::sleep(Duration::from_secs(1)).await;
          println!("sleep4 end");
  
          // MiniTokio未实现自动退出
          exit(0);
        };
  
        println!("sleep3 begin");
        MiniTokio::sleep(Duration::from_secs(1)).await;
        println!("sleep3 end");
  
        future.await;
      });
    });
    MiniTokio::run();
  }
  ```

## 线程同步
### 消息队列
  * 消息队列遵循借用规则，如果发送对象实现了Copy特征，会拷贝一份发送，否会将所有权转移到另一个线程
#### Send和Sync
  * Send和Sync特征本质上是标记，几乎所有类型默认都实现了Send和Sync，除非使用!移除特征实现
  * 实现Send的类型所有权可以移动到其他线程
  * Sync相当于&T实现了Send，表示T可被多个线程不可变引用
  * !Sync+Send的有Cell、Refcell、UnsafeCell等，因为其具有内部可变性，多线程访问会引发数据竞争
  * !Send+Sync的有MutexGuard，因为它不能在其它线程析构，这种例子比较少
  * 裸指针、Rc两者都没有实现
#### Send模拟
  ```Rust
  use std::time::Duration;
  
  #[tokio::main]
  async fn main() {
      {
          fn require_send(_: impl Send) {}
  
          async fn test() {
              // test持有未实现Send的Rc变量，因此test是非Send
              // 解决方法: 在.await前销毁非Send变量
              let rc = std::rc::Rc::new(0);
              drop(rc);

              // 或用代码块包含
              {
                let rc = std::rc::Rc::new(0);
              }
  
              // .await意味着test可能跨线程执行
              tokio::task::yield_now().await;
          }
  
          require_send(test());
      }
      {
          let mutex = std::sync::Arc::new(std::sync::Mutex::new(0));
          let m1 = mutex.clone();
          tokio::spawn(async move {
              let mut v = m1.lock().unwrap();
              drop(v);
  
              // test持有未实现Send的MutexGuard，因此async块是非Send
              // 解决方法: 在v被引用的情况下，drop(v)不被编译器识别，可使用块封装非Send变量的作用域
              {
                  let mut v = m1.lock().unwrap();
                  *v += 1;
              }
  
              // Future是否Send取决于是否有非Send类型被跨越.await持有，
              tokio::time::sleep(Duration::from_secs(1)).await;
          });
          tokio::time::sleep(Duration::from_secs(2)).await;
      }
  }
  ```

## 数据结构
### 链表
#### Box<T>实现单链表(栈)
  ```Rust
  use std::ptr::{null_mut};
  
  type Link<T> = Option<Box<Node<T>>>;
  
  #[derive(Debug)]
  struct Node<T> {
      data: T,
      next: Link<T>,
  }
  
  #[derive(Debug)]
  struct List<T> {
      head: Link<T>,
      tail: *mut Node<T>
  }
  
  impl<T> List<T> {
      fn new () -> Self {
          List { head: None, tail: null_mut() }
      }
  
      fn push_front (&mut self, data: T) {
          self.head = Some(Box::new(Node {
              data: data,
              next: self.head.take()
          }));
          if self.tail.is_null() {
              self.tail = self.head.as_mut().unwrap().as_mut();
          }
      }
      
      fn push_back (&mut self, data: T) {
          let new = Box::new(Node {
              data: data,
              next: None
          });
          let old_tail = self.tail;
          self.tail = if old_tail.is_null() {
              self.head = Some(new);
              self.head.as_mut().unwrap().as_mut()
          } else {
              unsafe {
                  (*old_tail).next = Some(new);
                  (*old_tail).next.as_mut().unwrap().as_mut()
              }
          }
      }
  
      fn pop_front (&mut self) -> Option<T> {
          match &self.head {
              None => None,
              Some(_) => {
                  let Node { data, next } = *self.head.take().unwrap();
                  if next.is_none() {
                      self.tail = null_mut();
                  }
                  self.head = next;
                  Some(data)
              },
          }
      }
  
      fn peek_front (&self) -> Option<&T> {
          self.head.as_ref().map(|node| {
              &node.data
          })
      }
  
      fn peek_front_mut (&mut self) -> Option<&mut T> {
          self.head.as_mut().map(|node| {
              &mut node.data
          })
      }
  
      fn peek_back (&self) -> Option<&T> {
          if self.tail.is_null() {
              None
          } else {
              unsafe {
                  Some(&(*self.tail).data)
              }
          }
      }
  
      fn peek_back_mut (&mut self) -> Option<&mut T> {
          if self.tail.is_null() {
              None
          } else {
              unsafe {
                  Some(&mut (*self.tail).data)
              }
          }
      }
  
      fn iter<'a> (&'a self) -> ListIter<'a, T> {
          //ListIter(self.head.as_ref().map(|node| { node.deref() }))
          ListIter(self.head.as_deref()) // v1.40.0
      }
  
      fn iter_mut<'a> (&'a mut self) -> ListIterMut<'a, T> {
          ListIterMut(self.head.as_deref_mut())
      }
  }
  
  struct ListIntoIter<T>(List<T>);
  
  impl<T> Iterator for ListIntoIter<T> {
      type Item = T;
  
      fn next(&mut self) -> Option<Self::Item> {
          self.0.pop_front()
      }
  }
  
  impl<T> IntoIterator for List<T> {
      type Item     = T;
      type IntoIter = ListIntoIter<T>;
  
      fn into_iter(self) -> Self::IntoIter {
          ListIntoIter(self)
      }
  }
  
  struct ListIter<'a, T>(Option<&'a Node<T>>);
  
  impl<'a, T> Iterator for ListIter<'a, T> {
      type Item = &'a T;
  
      fn next(&mut self) -> Option<Self::Item> {
          self.0.map(|next | {
              self.0 = next.next.as_deref();
              &next.data
          })
      }
  }
  
  struct ListIterMut<'a, T>(Option<&'a mut Node<T>>);
  
  impl<'a, T> Iterator for ListIterMut<'a, T> {
      type Item = &'a mut T;
  
      fn next(&mut self) -> Option<Self::Item> {
          self.0.take().map(|next | {
              self.0 = next.next.as_deref_mut();
              &mut next.data
          })
      }
  }
  
  // 自动实现的drop是递归析构，改成循环析构防止栈溢出 
  impl<T> Drop for List<T> {
      fn drop(&mut self) {
          while self.pop_front().is_some() { }
      }
  }
  
  #[cfg(test)]
  mod test {
      use super::List;
      use super::ListIntoIter;
  
      #[derive(Debug,PartialEq)]
      struct Test {
          value: i32,
      }
  
      #[test]
      fn push () {
          type MyList<'a> = List<Test>;
          let mut list = MyList::new();
  
          list.push_front(Test { value: 2 });
          list.push_front(Test { value: 1 });
          list.push_back(Test { value: 3 });
  
          assert_eq!(list.pop_front().unwrap().value, 1);
          assert_eq!(list.pop_front().unwrap().value, 2);
          assert_eq!(list.pop_front().unwrap().value, 3);
      }
  
      #[test]
      fn peek () {
          type MyList<'a> = List<Test>;
          let mut list = MyList::new();
  
          assert!(list.peek_front_mut().is_none());
          assert!(list.peek_back_mut().is_none());
  
          list.push_front(Test{ value: 1 });
          list.push_front(Test{ value: 2 });
  
          assert_eq!(list.peek_front().unwrap().value, 2);
          assert_eq!(list.peek_back().unwrap().value, 1);
      }
  
      #[test]
      fn iter () {
          type MyList<'a> = List<Test>;
          let mut list = MyList::new();
          let mut list1 = MyList::new();
  
          for i in 1..=10 {
              list.push_front(Test{ value: i });
          }
  
          let mut it = list.into_iter();
          while let Some(data) = it.next() {
              list1.push_back(data);
          }
  
          let mut it = list1.iter_mut();
          while let Some(data) = it.next() {
              data.value = data.value + 1;
          }
  
          let mut it = list1.iter();
          while let Some(data) = it.next() {
              if it.0.is_some() {
                  assert_eq!(it.0.unwrap().data.value , data.value - 1);
              }
          }
          
          let mut it = ListIntoIter(list1);
          while it.next().is_some() { }
      }
  }
  ```
### Rc<RefCell<T>>实现的双链表(无迭代功能)
  ```Rust
  use std::cell::{Ref, RefMut, RefCell};
  use std::rc::Rc;
  
  #[derive(Debug,PartialEq)]
  struct Test {
      value: i32,
  }
  
  type Link<T> = Option<Rc<RefCell<Node<T>>>>;
  
  #[derive(Debug)]
  struct Node<T>
      where
          T: std::fmt::Debug {
      data: T,
      next: Link<T>,
      prev: Link<T>,
  }
  
  impl<T> Node<T>
      where
          T: std::fmt::Debug {
      fn new (data: T) -> Rc<RefCell<Node<T>>> {
          Rc::new(RefCell::new(Node { data: data, next: None, prev: None }))
      }
  }
  
  #[derive(Debug)]
  struct List<T>
      where
          T : std::fmt::Debug {
      head: Link<T>,
      tail: Link<T>,
  }
  
  impl<T> List<T>
      where
          T: std::fmt::Debug {
      fn new () -> Self {
          List { head: None, tail: None }
      }
  
      fn push_front (&mut self, data: T) {
          let new = Node::new(data);
          match self.head.take() {
              Some(head) => {
                  head.borrow_mut().prev = Some(new.clone());
                  new.borrow_mut().next = Some(head.clone());
                  self.head = Some(new);
              }
              None => {
                  self.head = Some(new.clone());
                  self.tail = Some(new);
              }
          }
      }
  
      fn push_back (&mut self, data: T) {
          let new = Node::new(data);
          match self.tail.take() {
              Some(tail) => {
                  tail.borrow_mut().next = Some(new.clone());
                  new.borrow_mut().prev = Some(tail.clone());
                  self.tail = Some(new);
              },
              None => {
                  self.head = Some(new.clone());
                  self.tail = Some(new);
              }
          }
      }
  
      fn pop_front (&mut self) -> Option<T> {
          self.head.take().map(|node| {
              match node.borrow_mut().next.take() {
                  Some(next) => {
                      next.borrow_mut().prev = None;
                      self.head = Some(next.clone());
                  },
                  None => {
                      self.tail = None;
                  }
              };
              Rc::try_unwrap(node).unwrap().into_inner().data
              //Rc::try_unwrap(node).ok().unwrap().into_inner().data // T不需要实现std::fmt::Debug
          })
      }
  
      fn pop_back (&mut self) -> Option<T> {
         self.tail.take().map(|node| {
              match node.borrow_mut().prev.take() {
                  Some(prev) => {
                      prev.borrow_mut().next = None;
                      self.tail = Some(prev.clone());
                  },
                  None => {
                      self.head = None;
                  }
              }
             Rc::try_unwrap(node).unwrap().into_inner().data
         }) 
      }
  
      fn peek_front (&self) -> Option<Ref<T>> {
          self.head.as_ref().map(|node| {
              Ref::map(node.borrow(), |node| {
                  &node.data
              })
          })
      }
  
      fn peek_front_mut (&mut self) -> Option<RefMut<T>> {
          self.head.as_mut().map(|node| {
              RefMut::map(node.borrow_mut(), |node| {
                  &mut node.data
              })
          })
      }
  
      fn peek_back (&self) -> Option<Ref<T>> {
          self.tail.as_ref().map(|node| {
              Ref::map(node.borrow(), |node| {
                  &node.data
              })
          })
      }
  
      fn peek_back_mut (&mut self) -> Option<RefMut<T>> {
          self.tail.as_mut().map(|node| {
              RefMut::map(node.borrow_mut(), |node| {
                  &mut node.data
              })
          })
      }
      
      // iter和iter_mut暂无法优雅且安全地实现
  }
  struct ListIntoIter<T>(List<T>) where T: std::fmt::Debug;
  
  impl<T> Iterator for ListIntoIter<T>
      where
          T: std::fmt::Debug {
      type Item = T;
  
      fn next(&mut self) -> Option<Self::Item> {
          self.0.pop_front()
      }
  }
  
  impl<T> IntoIterator for List<T>
      where
          T: std::fmt::Debug {
      type Item     = T;
      type IntoIter = ListIntoIter<T>;
  
      fn into_iter(self) -> Self::IntoIter {
          ListIntoIter(self)
      }
  }
  
  impl<T> Drop for List<T>
      where
          T : std::fmt::Debug{
      fn drop(&mut self) {
          while self.pop_front().is_some() { }
      }
  }
  
  #[test]
  fn test () {
      type MyList = List<Test>;
      let mut list = MyList::new();
      assert!(list.peek_front_mut().is_none());
      assert!(list.peek_back_mut().is_none());
  
      for i in 1..=10 {
          list.push_front(Test { value: i })
      }
      let mut next = list.head.clone(); // 这种方法实现迭代器不安全，用户可以在持有节点时对链表进行pop操作
      while let Some(node) = next.take() {
          if node.borrow().next.is_some() {
              assert_eq!(list.peek_front().unwrap().value, node.borrow().next.as_ref().unwrap().borrow().data.value + 1);
          }
          next = node.borrow().next.clone();
          drop(node);
          list.pop_front();
      }
  
      for i in 1..=10 {
          list.push_back(Test { value: i })
      }
      let mut prev = list.tail.clone();
      while let Some(node) = prev.take() {
          if node.borrow().prev.is_some() {
              assert_eq!(list.peek_back().unwrap().value, node.borrow().prev.as_ref().unwrap().borrow().data.value + 1);
          }
          prev = node.borrow().prev.clone();
          drop(node);
          list.pop_back();
      }
  
      for i in 1..=10 {
          list.push_back(Test { value: i })
      }
      let mut it = ListIntoIter(list);
      while it.next().is_some() { }
  
      //let mut next = list.head.as_ref().map(|node| {
      //    node.borrow()
      //});
      //while let Some(node) = next.take() {
      //    node.next.as_ref().map(|node| {
      //        node.borrow()
      //    });
      //    // node.next.unwrap().borrow()和node有相同的生命周期
      //    // node释放，next无法继续持有next.unwrap().borrow()
      //}
  }
  ```
### Unsafe实现的双链表
  ```Rust
  use std::ptr::{null_mut};
  
  type Link<T> = Option<Box<Node<T>>>;
  
  #[derive(Debug)]
  struct Node<T> {
      data: T,
      next: Link<T>,
  }
  
  #[derive(Debug)]
  struct List<T> {
      head: Link<T>,
      tail: *mut Node<T>
  }
  
  impl<T> List<T> {
      fn new () -> Self {
          List { head: None, tail: null_mut() }
      }
  
      fn push_front (&mut self, data: T) {
          self.head = Some(Box::new(Node {
              data: data,
              next: self.head.take()
          }));
          if self.tail.is_null() {
              self.tail = self.head.as_mut().unwrap().as_mut();
          }
      }
      
      fn push_back (&mut self, data: T) {
          let new = Box::new(Node {
              data: data,
              next: None
          });
          let old_tail = self.tail;
          self.tail = if old_tail.is_null() {
              self.head = Some(new);
              self.head.as_mut().unwrap().as_mut()
          } else {
              unsafe {
                  (*old_tail).next = Some(new);
                  (*old_tail).next.as_mut().unwrap().as_mut()
              }
          }
      }
  
      fn pop_front (&mut self) -> Option<T> {
          match &self.head {
              None => None,
              Some(_) => {
                  let Node { data, next } = *self.head.take().unwrap();
                  if next.is_none() {
                      self.tail = null_mut();
                  }
                  self.head = next;
                  Some(data)
              },
          }
      }
  
      fn peek_front (&self) -> Option<&T> {
          self.head.as_ref().map(|node| {
              &node.data
          })
      }
  
      fn peek_front_mut (&mut self) -> Option<&mut T> {
          self.head.as_mut().map(|node| {
              &mut node.data
          })
      }
  
      fn peek_back (&self) -> Option<&T> {
          if self.tail.is_null() {
              None
          } else {
              unsafe {
                  Some(&(*self.tail).data)
              }
          }
      }
  
      fn peek_back_mut (&mut self) -> Option<&mut T> {
          if self.tail.is_null() {
              None
          } else {
              unsafe {
                  Some(&mut (*self.tail).data)
              }
          }
      }
  
      fn iter<'a> (&'a self) -> ListIter<'a, T> {
          //ListIter(self.head.as_ref().map(|node| { node.deref() }))
          ListIter(self.head.as_deref()) // v1.40.0
      }
  
      fn iter_mut<'a> (&'a mut self) -> ListIterMut<'a, T> {
          ListIterMut(self.head.as_deref_mut())
      }
  }
  
  struct ListIntoIter<T>(List<T>);
  
  impl<T> Iterator for ListIntoIter<T> {
      type Item = T;
  
      fn next(&mut self) -> Option<Self::Item> {
          self.0.pop_front()
      }
  }
  
  impl<T> IntoIterator for List<T> {
      type Item     = T;
      type IntoIter = ListIntoIter<T>;
  
      fn into_iter(self) -> Self::IntoIter {
          ListIntoIter(self)
      }
  }
  
  struct ListIter<'a, T>(Option<&'a Node<T>>);
  
  impl<'a, T> Iterator for ListIter<'a, T> {
      type Item = &'a T;
  
      fn next(&mut self) -> Option<Self::Item> {
          self.0.map(|next | {
              self.0 = next.next.as_deref();
              &next.data
          })
      }
  }
  
  struct ListIterMut<'a, T>(Option<&'a mut Node<T>>);
  
  impl<'a, T> Iterator for ListIterMut<'a, T> {
      type Item = &'a mut T;
  
      fn next(&mut self) -> Option<Self::Item> {
          self.0.take().map(|next | {
              self.0 = next.next.as_deref_mut();
              &mut next.data
          })
      }
  }
  
  // 自动实现的drop是递归析构，改成循环析构防止栈溢出 
  impl<T> Drop for List<T> {
      fn drop(&mut self) {
          while self.pop_front().is_some() { }
      }
  }
  
  #[cfg(test)]
  mod test {
      use super::List;
      use super::ListIntoIter;
  
      #[derive(Debug,PartialEq)]
      struct Test {
          value: i32,
      }
  
      #[test]
      fn push () {
          type MyList<'a> = List<Test>;
          let mut list = MyList::new();
  
          list.push_front(Test { value: 2 });
          list.push_front(Test { value: 1 });
          list.push_back(Test { value: 3 });
  
          assert_eq!(list.pop_front().unwrap().value, 1);
          assert_eq!(list.pop_front().unwrap().value, 2);
          assert_eq!(list.pop_front().unwrap().value, 3);
      }
  
      #[test]
      fn peek () {
          type MyList<'a> = List<Test>;
          let mut list = MyList::new();
  
          assert!(list.peek_front_mut().is_none());
          assert!(list.peek_back_mut().is_none());
  
          list.push_front(Test{ value: 1 });
          list.push_front(Test{ value: 2 });
  
          assert_eq!(list.peek_front().unwrap().value, 2);
          assert_eq!(list.peek_back().unwrap().value, 1);
      }
  
      #[test]
      fn iter () {
          type MyList<'a> = List<Test>;
          let mut list = MyList::new();
          let mut list1 = MyList::new();
  
          for i in 1..=10 {
              list.push_front(Test{ value: i });
          }
  
          let mut it = list.into_iter();
          while let Some(data) = it.next() {
              list1.push_back(data);
          }
  
          let mut it = list1.iter_mut();
          while let Some(data) = it.next() {
              data.value = data.value + 1;
          }
  
          let mut it = list1.iter();
          while let Some(data) = it.next() {
              if it.0.is_some() {
                  assert_eq!(it.0.unwrap().data.value , data.value - 1);
              }
          }
          
          let mut it = ListIntoIter(list1);
          while it.next().is_some() { }
      }
  }
  ```

## 宏
### 常用宏
#### 输出与格式化
  * `print!/eprint!/println!/eprintln!`: 输出到标准输出/标准错误
  * `format!`: 格式化并创建String
  * `format_args!`: 创建fmt::Arguments
  * `write!/writeln!`: 写入
#### 集合与字符串
  * `vec!`: 创建Vec
  * `concat!`: 编译期连接字面量
  * `stringify!`: 把源代码文本转换成字符串
  * `matches!`: 判断值是否匹配某个模式
#### 断言宏
  * `assert!/assert_eq!/assert_ne!`: 断言
  * `debug_assert!/debug_assert_eq!/debug_assert_ne!`: 断言(仅Debug) 
#### 调试、错误与占位宏
  * `dbg!`: 打印表达式及其结果(取得表达式所有权并返回它)
  * `todo!`: 标记尚未实现(执行到此处会panic)
  * `unimplemented!`: 类似`todo!`，语义偏“未实现”
  * `unreachable!`: 标记不可达(执行到此处会panic)
  * `unreachable_unchecked!`: 绝不可达，编译器可基于这个事实承诺
#### 编译期信息宏
  * `file!`: 获取当前源文件名
  * `line!`: 获取当前源代码行号
  * `column!`: 获取当前源代码列号
  * `module_path!`: 获取当前模块路径
  * `env!`: 读取编译期环境变量
  * `option_env!`: 可选读取编译期环境变量
  * `compile_error!`: 主动产生编译错误
#### 条件编译宏与属性
  * `cfg!`: 判断编译配置并返回bool
  * `#[cfg(...)]`: 根据条件编译代码
  * `#[cfg_attr(...)]`: 根据条件添加属性
  * `compile_error!`: 在指定配置下终止编译
#### 文件嵌入宏
  * `include_str!`: 将文件嵌入为字符串
  * `include_bytes!`: 将文件嵌入为字节数组
  * `include!`: 将文件解析为Rust代码并插入
#### 指针与底层编程宏
  * `addr_of!`: 创建字段的原始常量指针
  * `addr_of_mut!`: 创建字段的原始可变指针
  * `asm!`: 编写内联汇编
  * `global_asm!`: 定义模块级汇编代码
  * `naked_asm!`: 为naked函数提供汇编体
#### 异步与固定值宏
  * `std::pin::pin!`: 将值固定在当前作用域
  * `std::task::ready!`: 未就绪时提前返回Poll::Pending
  * `thread_local!`: 定义线程局部静态变量
#### 声明宏开发
  * `macro_rules!`: 定义声明宏
#### 测试属性
  * `#[test]`: 定义单元测试
  * `#[cfg(test)]`: 仅在测试构建中编译
  * `#[ignore]`: 默认忽略测试
  * `#[should_panic]`: 测试代码是否panic
#### 标准派生宏
  * `#[derive(Debug)]`: 生成调试格式化实现({:?}和{:#?})
  * `#[derive(Clone)]`: 生成显式复制实现
  * `#[derive(Copy, Clone)]`: 生成隐式按位复制语义
  * `#[derive(Default)]`: 生成默认值
  * `#[derive(PartialEq)]`: 支持==和!=
  * `#[derive(Eq)]`: 表示完整相等关系
  * `#[derive(PartialOrd)]`: 支持部分排序 
  * `#[derive(Ord)]`: 支持全序
  * `#[derive(Hash)]`: 生成哈希实现
#### 代码检查与文档属性
  * `#[allow(...)]`: 关闭指定lint
  * `#[expect(...)]`: 声明预期出现指定lint
  * `#[expect(...)]`:	有意保留触发 lint 的代码
  * `#![warn()]`: 将lint设置为警告	不会阻止编译
  * `#![deny()]`: 将lint设置为错误
  * `#![forbid()]`: 禁止某类代码
  * `#[must_use]`: 提醒调用者必须使用返回值
  * `#[deprecated(note = "...")]`: 标记API已弃用
  * `#![doc = include_str!("...")]`: 动态嵌入文档
  * `#[rustfmt::skip]`: 跳过自动格式化，不可作为常规格式化解决方案
#### 优化与类型布局属性
  * `#[inline]`: 提示编译器内联函数
  * `#[inline(always)]`: 强烈建议编译器内联函数
  * `#[inline(never)]`: 建议编译器不要内联函数
  * `#[cold]`: 标记函数为低频执行路径
  * `#[track_caller]`: 在函数中保留调用者的源码位置
  * `#[repr(C)]`: 使用兼容 C 语言的内存布局
  * `#[repr(transparent)]`: 让包装类型采用内部字段的内存布局
  * `#[repr(u8)]`: 指定枚举判别值使用 `u8` 表示
  * `#[non_exhaustive]`: 允许将来为结构体或枚举增加字段或变体
#### Serde 与 JSON 宏
  * `#[derive(Serialize)]`: 生成序列化实现
  * `#[derive(Deserialize)]`: 生成反序列化实现
  * `serde_json::json!`: 构造 JSON 值
  * `#[serde(rename = "...")]`: 修改序列化和反序列化时的字段名
  * `#[serde(rename_all = "...")]`: 按指定规则批量修改字段名
  * `#[serde(default)]`: 字段缺失时使用默认值
  * `#[serde(skip)]`: 跳过字段的序列化和反序列化
  * `#[serde(skip_serializing)]`: 序列化时跳过字段
  * `#[serde(skip_deserializing)]`: 反序列化时跳过字段
  * `#[serde(skip_serializing_if = "...")]`: 满足条件时跳过字段序列化
  * `#[serde(flatten)]`: 将嵌套结构体的字段展开到当前对象
  * `#[serde(tag = "...")]`: 使用指定字段标记枚举变体
  * `#[serde(untagged)]`: 不生成枚举变体标签
  * `#[serde(with = "...")]`: 使用指定模块自定义序列化和反序列化
  * `#[serde(serialize_with = "...")]`: 使用指定函数自定义序列化
  * `#[serde(deserialize_with = "...")]`: 使用指定函数自定义反序列化
#### Tokio 异步宏
  * `#[tokio::main]`: 创建 Tokio 运行时并执行异步 `main` 函数
  * `#[tokio::test]`: 创建 Tokio 运行时并执行异步测试
  * `tokio::join!`: 并发等待多个 Future 全部完成
  * `tokio::try_join!`: 并发等待多个返回 `Result` 的 Future
  * `tokio::select!`: 等待多个异步分支中的一个完成
  * `tokio::pin!`: 将 Future 固定在当前栈上
#### 日志与追踪宏
  * `trace!`: 记录最细粒度的追踪日志
  * `debug!`: 记录调试信息
  * `info!`: 记录普通运行信息
  * `warn!`: 记录警告或可恢复问题
  * `error!`: 记录错误事件
  * `tracing::span!`: 创建结构化追踪跨度
  * `tracing::event!`: 创建指定等级的结构化事件
  * `#[tracing::instrument]`: 自动为函数创建追踪跨度
  * `#[instrument(skip(...))]`: 创建函数跨度时跳过指定参数
  * `#[instrument(skip_all)]`: 创建函数跨度时跳过所有参数
  * `#[instrument(fields(...))]`: 为函数跨度添加自定义字段
#### 错误处理宏
  * `anyhow!`: 创建动态错误
  * `bail!`: 创建错误并立即返回
  * `ensure!`: 条件不满足时立即返回错误
  * `#[derive(thiserror::Error)]`: 自动实现 `std::error::Error`
  * `#[error("...")]`: 定义错误的显示文本
  * `#[from]`: 自动实现来源错误到当前错误的转换
  * `#[source]`: 指定错误链中的底层错误
  * `#[error(transparent)]`: 透明转发底层错误的显示和来源信息
#### Clap 命令行宏
  * `#[derive(clap::Parser)]`: 定义命令行参数解析器
  * `#[derive(clap::Subcommand)]`: 定义命令行子命令
  * `#[derive(clap::Args)]`: 定义可复用的参数组
  * `#[derive(clap::ValueEnum)]`: 定义枚举形式的参数值
  * `#[command(name = "...")]`: 设置命令名称
  * `#[command(version)]`: 显示程序版本信息
  * `#[command(about = "...")]`: 设置命令说明
  * `#[command(subcommand)]`: 将字段声明为子命令
  * `#[command(flatten)]`: 展开并复用参数组
  * `#[arg(short)]`: 为参数设置短选项
  * `#[arg(long)]`: 为参数设置长选项
  * `#[arg(default_value = "...")]`: 设置参数默认值
  * `#[arg(required = true)]`: 将参数设置为必填
  * `#[arg(value_enum)]`: 将参数限制为枚举值
  * `#[arg(env = "...")]`: 从环境变量读取参数
  * `#[arg(flatten)]`: 将参数组展开到当前命令
#### SQLx 数据库宏
  * `sqlx::query!`: 编译期检查 SQL 并生成查询结果类型
  * `sqlx::query_as!`: 编译期检查 SQL 并将结果映射到结构体
  * `sqlx::query_scalar!`: 编译期检查并查询单列值
  * `sqlx::query_file!`: 从文件读取并检查 SQL 查询
  * `sqlx::query_file_as!`: 从文件读取 SQL 并将结果映射到结构体
  * `sqlx::query_file_scalar!`: 从文件读取 SQL 并查询单列值
  * `sqlx::migrate!`: 编译期嵌入数据库迁移文件
  * `#[derive(sqlx::FromRow)]`: 生成数据库行到结构体的转换实现
  * `#[derive(sqlx::Type)]`: 生成 Rust 类型与数据库类型的映射实现
  * `#[sqlx(rename = "...")]`: 修改字段或变体对应的数据库名称
  * `#[sqlx(rename_all = "...")]`: 按指定规则批量修改数据库字段名
  * `#[sqlx(default)]`: 数据库字段缺失时使用默认值
  * `#[sqlx(flatten)]`: 将嵌套结构体字段展开映射
  * `#[sqlx(skip)]`: 跳过指定字段的数据库映射
#### 不建议优先使用的宏
  * `lazy_static!`: 延迟初始化全局静态值，现代代码可使用 `LazyLock` 或 `OnceLock`
  * `concat_idents!`: 拼接标识符，功能和稳定性受限
  * `format_args_nl!`: 创建带换行的格式化参数，主要用于内部实现
  * `const_format_args!`: 在常量环境中创建格式化参数，稳定性受限
  * `assert_matches!`: 断言值匹配指定模式，部分工具链可能不可用

### 宏手册
  https://zjp-cn.github.io/tlborm/

## 模块与包
### 可见性
  * pub: 无限制
  * pub(crate): 当前包可见
  * pub(self): 当前模块可见
  * pub(super): 在父模块可见
  * pub(in <path>): 在某个模块可见，path必须是父模块或祖先模块。举例:pub(in crate::mod_name)
### 作用域与私有性
  ```Rust
  mod outer {
    fn f() {}
  
    mod inner {
      pub mod mod_0 {
        pub mod mod_1 {
          fn f() {}
        }
        pub mod mod_2 {
          pub fn f() {}
        }
  
        mod mod_3 {}
      }
  
      pub trait Network { // impl中的关联类型、关联常量、关联函数、方法的可见性由trait自身可见性决定
        type Error;
        const NAME: &'static str;
  
        fn run() -> Result<(), Self::Error>;
      }
  
      pub struct SyncNetwork { }

      impl SyncNetwork {
        fn f() {}                                      // private
      }
  
      impl Network for SyncNetwork {
        type Error = ();
        const NAME: &'static str = "Sync";             // public
  
        fn run() -> Result<(), Self::Error> { Ok(()) } // public
      }
  
      pub enum NETWORK_TYPE {
        SYNC, // public，公开枚举的变体无需声明pub
      }
  
  
      #[cfg(test)]
      fn test() {
        use mod_0::mod_1::f;                                        // error: private
        use mod_0::mod_3;                                           // error: private
        use mod_0::mod_2::f;                                        // 从当前作用域开始的相对路径，适用于已通过use引入的模块、crate根模块、外部crate
        use self::mod_0::mod_2::f;                                  // 从当前模块开始的相对路径，明确访问当前模块中的名称，适用于访问当前模块内部的符号、导入和导出内部符号
        use crate::outer::inner::mod_0::mod_2::f;                   // 绝对路径，适用于跨模块访问、明确路径、代码移动后路径仍从crate开始等场景
        use super::f;                                               // 子模块访问父模块，适用于兄弟模块经由八模块访问
        use std::collections::HashMap;                              // 引入需要频繁访问的符号
        let _ = std::collections::HashMap::<String, String>::new(); // 偶尔使用、符号存在重复的情况，明确来源访问
      }
    }
  }
  ```
### 模块定义
#### 方式一: 
  文件层次
  ```txt
  src/
    |-- services/
    |   |-- mod.rs
    |   `-- cache.rs
    |   `-- network.rs
    `-- main.rs
  ```

  src/mod.rs
  ```Rust
  // 这里为了压缩层级，向外部隐藏cache和network子模块，不使用pub
  mod cache;   // 声明crate::service::cache, 查找cache.rs
  mod network; // 声明crate::service::network, 查找network.rs

  // 重导出，把两个子模块直接暴露到service模块
  pub use self::cache::Cache;
  pub use self::network::{SyncNetwork, AsyncNetwork, Network};

  /* 适合在mod.rs中定义内联子模块的场景 */
  
  // 1. 代码量很小的模块可以在mod.rs中可定义模块，
  pub mod tiny_module {
  
  }
  
  // 2. 私有模块也可以在mod.rs中定义，只公开必要接口
  mod private_module {
    pub fn internal_f() {}
  }
  
  pub fn f() {
    self::private_module::internal_f();
  }
  
  // 3. 根据不同平台对模块进行不同实现
  #[cfg(target_os = "linux")]
  mod platform {
  
  }
  
  #[cfg(target_os = "windows")]
  mod platform {
  
  }
  
  #[cfg(target_os = "macos")]
  mod platform {
  
  }
  
  #[cfg(not(any(
    target_os = "linux",
    target_os = "windows",
    target_os = "macos",
  )))]
  compile_error!("当前操作系统不受支持");
  
  // 4. 模块级的测试用例
  #[cfg(test)]
  mod tests {
    use super::*;
  
    #[test]
    fn test() {
  
    }
  }
  
  // 5. API分类
  pub mod sync_network {
    use crate::service::network::{SyncNetwork, Network};
  
    pub fn run() {
      SyncNetwork::run();
    }
  }
  
  pub mod async_network {
    use crate::service::network::{AsyncNetwork, Network};
  
    pub fn run() {
      AsyncNetwork::run();
    }
  }

  ```

  src/service/cache.rs
  ```Rust
  pub struct Cache {}
  
  impl Cache {
    pub fn run() {}
  }
  ```

  src/service/network.rs
  ```Rust
  pub trait Network { // pub已指定函数的可见性，impl中不再需要指定pub
    fn run();
  }
  
  pub struct SyncNetwork { }
  
  impl Network for SyncNetwork {
    fn run() {}
  }
  
  pub struct AsyncNetwork { }
  
  impl Network for AsyncNetwork {
    fn run() {}
  }
  ```

  src/main.rs
  ```Rust
  mod service; // 声明模块crate::service, 查找service.rs
  
  use crate::service::{Network, SyncNetwork, AsyncNetwork};
  use crate::service::Cache;
  use crate::service::f;
  
  fn main() {
    SyncNetwork::run();
    AsyncNetwork::run();
    Cache::run();
    f();
  }
  ```
#### 方式二
  文件层次
  ```txt
  src/
    |-- service /
    |   |
    |   `-- cache.rs
    |   `-- network.rs
    |-- service.rs
    `-- main.rs
  ```

  src/service/cache.rs
  ```Rust
  pub struct Cache {}
  
  impl Cache {
    pub fn run() {}
  }
  ```

  src/service/network.rs
  ```Rust
  pub trait Network {
    fn run();
  }
  
  pub struct SyncNetwork { }
  
  impl Network for SyncNetwork {
    fn run() {}
  }
  
  pub struct AsyncNetwork { }
  
  impl Network for AsyncNetwork {
    fn run() {}
  }
  ```

  src/service.rs
  ```Rust
  pub mod cache;   // 声明crate::service::cache, 查找service/cache.rs
  pub mod network; // 声明crate::service::network, 查找service/network.rs
  ```

  src/main.rs
  ```Rust
  mod service; // 声明模块crate::service, 查找service.rs
  
  use crate::service::network::{Network, SyncNetwork, AsyncNetwork};
  use crate::service::cache::Cache;
  
  fn main() {
    SyncNetwork::run();
    AsyncNetwork::run();
    Cache::run();
  }
  ```
#### 方式三(库)

## 错误处理
### 枚举实现错误码
  ```Rust
  use std::fs::File;
  use std::io::{Error, ErrorKind};

  // 缺点是为了使用?运算符需要为每种错误类型实现From、Display等特征
  enum MyError {
      Succeed,
      SystemError,
      FileNotFound(String),
      IOError(std::io::Error),
  }
  
  fn main() {
      {
          fn test(e: MyError) -> Result<(), MyError> { Err(e) }
  
          assert!(matches!(test(MyError::Succeed), Err(MyError::Succeed)));
          assert!(matches!(test(MyError::SystemError), Err(MyError::SystemError)));
          assert!(matches!(test(MyError::FileNotFound("".to_string())), Err(MyError::FileNotFound(_))));
          assert!(matches!(test(MyError::IOError(ErrorKind::AddrInUse.try_into().unwrap())), Err(MyError::IOError(_))));
      }
  
      {
          impl From<std::io::Error> for MyError {
              fn from(value: Error) -> Self {
                  MyError::IOError(value)
              }
          }
  
          fn test() -> Result<(), MyError> {
              File::open("")?; // 未实现From<std::io::Error>特征时报错 error[E0277]: `?` couldn't convert the error to `MyError`
              Ok(())
          }
          assert!(matches!(test(), Err(MyError::IOError(_))));
      }
  }
  ```
  * https://juejin.cn/post/7130619933251076126
### 自定义错误类型
  ```Rust
  use std::error::Error;
  use std::fmt::{Debug, Display, Formatter};
  
  struct MyError;
  
  impl Debug for MyError {
      fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
          write!(f, "{}", "MyError")
      }
  }
  
  impl Display for MyError {
      fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
          write!(f, "{}", "MyError")
      }
  }
  
  impl Error for MyError {}
  
  fn main() {
      {
          fn test() -> impl Error {
              MyError
          }
      }
      {
          fn test() -> Result<(), Box<dyn Error>> {
              Err(Box::new(MyError))
          }
      }
  }
  ```
### 错误处理库
  * thiserror
  * anyhow
  * 关于如何选用thiserror和anyhow只需要遵循一个原则即可: 是否关注自定义错误消息，关注则使用thiserror(常见业务代码)，否则使用anyhow(编写第三方库代码)
  ```Rust
  fn main() {
      {
          // anyhow
          use anyhow::Result;
  
          fn test_anyhow() -> Result<()> {
              std::fs::read("")?;
              Ok(())
          }
          println!("0.\n{:?}\n", test_anyhow());
  
          // thiserror
          use std::error::Error;
          use thiserror::Error;
          // #[error(fmt)]用于实现Display特征
          // 支持但不仅限于:
          // #[error("{var}")]   -> write!("{}", self.var)
          // #[error("{0}")]     -> write!("{}", self.0)
          // #[error("{var:?}")] -> write!("{:?}", self.var)
          // #[error("{0:?}")]   -> write!("{:?}", self.0)
          //
          // #[from]属性用于实现From特征
          // #[source]属性或将字段命名为source用于实现返回底层的错误类型的source方法，#[from]属性始终包含#[source]属性
          // #[backtrace]属性用于实现返回std::backtrace::Backtrace类型的provide方法(需要添加backtrace字段)
          // #[error(transparent)]属性将Display方法直接转发到底层错误，用于无需添加其他信息的场景
          #[derive(Error, Debug)]
          enum MyError {
              #[error("Succeed")]
              Succeed,
              #[error("System error")]
              SystemError,
              #[error("file {} not found", .0)]
              FileNotFound(String),
              #[error("IO error: {}", .err)]
              IOError {
                  #[from] // #[from]也会自动实现source()函数
                  err: std::io::Error,
              },
              #[error("Invalid Param: {}, expected: {}", .expected, .found)]
              InvalidParam {
                  expected: String,
                  found: String,
              },
              #[error(transparent)]
              Other(
                  #[from]
                  anyhow::Error
              ),
              #[error("Unknown error")]
              Unknown,
          }
          fn test_io_error() -> Result<(), MyError> {
              std::fs::read("")?;
              Ok(())
          }
          println!("1.\n{}\n", MyError::Succeed);
          println!("2.\n{}\n", MyError::SystemError);
          println!("3.\n{}\n", MyError::FileNotFound("/etc/bashrc".to_string()));
          println!("4.\n{}\n{:?}\n", test_io_error().unwrap_err(), test_io_error().unwrap_err().source());
          println!("5.\n{}\n", MyError::InvalidParam { expected: "-1".to_string(), found: "[0, i32::Max]".to_string() });
          println!("6.\n{}\n", test_anyhow().unwrap_err())
      }
      {
          use thiserror::Error;
  
          #[derive(Error, Debug)]
          #[error("MyError happened, source: {}, param: {}", .err, .param)]
          struct MyError {
              #[source]
              err: std::io::Error,
  
              param: String,
          }
          let e = MyError { err: std::fs::read("").unwrap_err(), param: "".to_string() };
          println!("9.\n{}\n", e);
      }
  }
  ```
### panic!
  * panic!打印堆栈并退出程序
  * panic后默认处理策略会开始展开unwinding(退栈)，即Rust会沿调用栈退出每一个函数，同时清理各层的局部变量。另一种策略是直接abort，即不清理数据就退出程序，可在Cargo.toml中配置:
    ```Rust
    [profile.release]
    panic = "abort"
    ```
  * RUST_BACKTRACE=1 cargo run可以输出更详细的堆栈信息
  * 示例
  ```Rust
  #[cfg(test)]
  mod test {
      #[test]
      fn hock() {
          // 设置勾子函数
          std::panic::set_hook(Box::new(|ctx| {
              println!("Callback\n{:?}", ctx);
          }));
          // std::panic::take_hook(); // 取消hock
          std::panic::panic_any("Error");
      }
  
      #[test]
      fn catch_unwind() {
          // 捕获闭包中的panic
          let result = std::panic::catch_unwind(|| {
              panic!("OH NO!!!");
          });
          // 恢复panic
          if let Err(ctx) = result {
              println!("{:?}", ctx.downcast_ref::<&'static str>());
              std::panic::resume_unwind(Box::new(ctx))
          }
      }
  
      #[test]
      fn panic() {
          panic!("Error Info");
      }
  }
  ```

## 类型测试
  ```Rust
  fn type_of<T>(_: &T) -> &str { std::any::type_name::<T>() }
  
  fn main() {
      assert_eq!(type_of(&""), "&str");
      assert_eq!(std::any::TypeId::of::<i32>(), std::any::Any::type_id(&0));
      assert_eq!(std::any::TypeId::of::<&str>(), std::any::Any::type_id(&""));
      assert_eq!(std::any::TypeId::of::<String>(), std::any::Any::type_id(&"".to_string()));
  }
  ```

## 所有权
### take/replace
  ```Rust
  #[derive(Default, Debug)]
  struct Test {
      v: i32,
  }
  
  fn main() {
      let mut a = Test { v: 1 };
      let b = std::mem::take(&mut a);
      assert_eq!(0, a.v);
      assert_eq!(1, b.v);
      let c = std::mem::replace(&mut a, b);
      assert_eq!(1, a.v);
      assert_eq!(0, c.v);
  }
  ```

## 疑难杂症
### * Rc<RefCell<T>>.as_ref().map返回Ref<T>时无法自动推导，报错: "type annotations needed for Option<&Borrowed>"
    Rc<T>通过实现std::borrow::Borrow特征实现了borrow()，Ref通过方法实现borrow()  
    vscode自动导入"use std::borrow::Borrow;"，导致Rc<T>不会自动解引用调用Ref<T>的borrow()
### While let持有临时变量生命周期过长
  ```Rust
  use std::cell::RefCell;
  
  macro_rules! drop_guards { ( $expr: expr ) => { { let it = $expr; it } } }
  
  fn main() {
  let cell = RefCell::new(Some(0));
  
      // 临时变量cell.borrow_mut()的生命周期比预期的长，临时变量仅在遇到分号时才会清理，它会持续到while let/if let语句结束
      while let _ = cell.borrow_mut().unwrap() {
          assert!(cell.try_borrow().is_err());
          break;
      }
      if let _ = cell.borrow_mut().unwrap() {
          assert!(cell.try_borrow().is_err());
      };
  
      // 这种方式不能解决问题
      while let _ = { cell.borrow_mut().unwrap() } {
          assert!(cell.try_borrow().is_err());
          break;
      }
  
      // 解决办法: 
      while let _ = { let v = cell.borrow_mut().unwrap(); v } {
          assert!(cell.try_borrow().is_ok());
          break;
      }
      while let _ = drop_guards!(cell.borrow_mut().unwrap()) {
          assert!(cell.try_borrow().is_ok());
          break;
      }
      if let _ = drop_guards!(cell.borrow_mut().unwrap()) {
          assert!(cell.try_borrow().is_ok());
      }
  
  }
  ```

## Unsafe
### Unsafe的作用
  * 解引用裸指针
  * 调用一个Unsafe或外部的函数
  * 访问或修改一个可变的静态变量
  * 实现一个Unsafe特征
  * 访问union中的字段
### Unsafe实现类型强制转换
#### transmuter
  * 延长和缩短生命周期
  * 强制类型转换(注意: 使用transmute时要保证源类型和目标类型的内存布局和大小相同)
    ```Rust
    #[repr(i32)]
    enum Test {
        A = 1,
    }
    
    impl Test {
        fn from(v: i32) -> Test {
            unsafe { std::mem::transmute(v) }
        }
    }
    
    fn main() {
        // 枚举转i32，有大小检查
        let _a: i32 = unsafe { std::mem::transmute(Test::A) };
        // 枚举转i32，无大小检查
        let a: i32 = unsafe { std::mem::transmute_copy(&Test::A) };
        // i32转枚举
        let _b: Test = Test::from(a);
    }
    ```

## 调试
### dbg!
  `dbg!`宏接受一个表达式的所有权，并将表达式以Debug格式打印到stderr(包含文件名、行号、表达式、值)，然后返回该值的所有权

## 性能优化
  * 循环尽量使用迭代器代替索引访问，使用map转换、filter过滤、fold聚合、chain链接等方法代替if判断，不仅有更多多编译器优化空间，还可提高运行效率
  * 编译器优化时会消除多层函数调用，所以不需要过多操心函数嵌套的问题
  * [警惕UTF-8引发的性能隐患](https://course.rs/compiler/pitfalls/utf8-performance.html)

## 实用工具
### Unsafe Rust工具
  * rust-bindgen: 生成用于Rust的C API接口
  * cbindgen: 生成用于C的Rust API接口
  * cxx: 无需使用Unsafe双向调用C++和Rust
  * Miri: 检查执行路径中的未定义行为(UB)
  * Clippy: 代码检查工具
  * Prusti: 验证给定特定条件的代码的安全性
  * Fuzzers: 模糊测试器
 
## 库
### CLI
  * pico_args: 轻量参数解析器
  * clap: 功能齐全的参数解析器
### 日志
  * [tracing](https://rust-book.junmajinlong.com/ch102/tracing.html)
### 异步库
  * Tokio: 异步库
  * rayon: 并行库

### Tokio
#### Runtime
##### 创建Runtime的两种方式
  以下两种方式等价
  ```Rust
  #[tokio::main]
  async fn main() {
      println!("Hello world");
  }
  ```
  ```Rust
  fn main() {
      tokio::runtime::Builder::new_multi_thread()
          .enable_all()
          .build()
          .unwrap()
          .block_on(async {
              println!("Hello world");
          })
  }
  ```
  `#[tokio::main]`支持的属性:
  * 单线程运行时: `#[tokio::main(flavor = "current_thread")]`
  * 多个线程运行时: `#[tokio::main(flavor = "multi_thread", worker_threads = 10)]`或`#[tokio::main(worker_threads = 2)]`
  * 启动时暂停时钟: `#[tokio::main(flavor = "current_thread", start_paused = true)]`
##### runtime示例
  ```Rust
  use std::sync::Arc;
  use std::sync::atomic::{AtomicU8, Ordering};
  use std::time::Duration;
  use chrono::Local;
  use tokio::{task, time};
  
  fn now() -> String {
      Local::now().format("%F %T").to_string()
  }
  
  fn main() {
      println!("[{}]start", now());
  
      let runtime = tokio::runtime::Builder::new_current_thread()
          .enable_all()
          .max_blocking_threads(512) // blocking thread最大数量
          .thread_keep_alive(Duration::from_secs(0)) // blocing thread池淘汰超时时间
          .on_thread_start(|| println!("[{}]blocking thread start", now())) // 线程启动回调
          .on_thread_stop(|| println!("[{}]blocking thread stop", now())) // 线程关闭回调
          // .on_thread_park(|| println!("[{}]park", now())) // 线程挂起回调
          // .on_thread_unpark(|| println!("[{}]unpark", now())) // 线程恢复回调
          .build()
          .unwrap();
  
      // panic: 必须在runtime上下文调用
      // spawn(async {});
  
      {
          // 在当前线程中执行同步任务，并且把其他异步任务转换到其他worker thread
          // block_in_place对比spawn_blocking有一个优点是不要求参数具有'static生命周期，因此在block_in_place中也可以进入runtime上下文，而spawn_blocking则不行
          // task::spawn_blocking(|| { //error: function requires argument type to outlive `'static`
          //     let _ctx = runtime.enter();
          // });
          task::block_in_place(|| {
              let _ctx = runtime.enter();
  
              // 因为当前运行时是单线程，会阻塞直至任务完成
              runtime.block_on(async {
                  time::sleep(Duration::from_secs(3)).await;
                  println!("[{}]out block_in_place", now());
              });
          });
  
          // 向runtime添加一个只在当前线程执行的本地任务（添加到独立的列队）
          let local_set = task::LocalSet::new();
          local_set.spawn_local(async {
              println!("[{}]spawn_local", now());
          });
          // 与JoinSet不同，LocalSet会把异步任务另入独立的队列，因此只有对LocalSet poll时才会开始执行该列表的任务
          runtime.block_on(async {
              time::sleep(Duration::from_secs(3)).await;
          });
          runtime.block_on(async {
              local_set.await;
          });
  
          // 在LocalSet上下文内部使用task::spawn_local也可以创建本地任务
          task::LocalSet::new().block_on(&runtime, async {
              task::spawn_local(async {}).await.unwrap();
          })
      }
      {
          // 以非阻塞方式进入runtime上下文
          // _ctx离开作用域时不会移除队列中未完成的异步任务，在下次进入runtime时会继续执行
          let _ctx = runtime.enter();
  
          let mut set = task::JoinSet::new();
          // 使用JoinSet创建并收集异步任务
          set.spawn(async {
              // 创建一个不受调度器控制（不会挂起）的异步任务，该任务执行完前会阻塞线程
              // unconstrained会导致当前线程内其他异步任务饥饿，尽量使用block_in_place和spawn_blocking代替
              task::unconstrained(async {
                  time::sleep(Duration::from_secs(1)).await;
                  println!("[{}]out unconstrained", now())
              }).await;
  
              time::sleep(Duration::from_secs(1)).await;
              println!("[{}]async timer has expired", now());
          });
          runtime.block_on(async {
              // 使用JoinSet等待任务完成
              set.join_next().await;
          });
      }
      {
          let _ctx = runtime.enter();
  
          let f = Arc::new(AtomicU8::new(0));
          let ff = f.clone();
          let fff = f.clone();
          // 向runtime添加异步任务(不是创建新线程)
          runtime.spawn(async move {
              time::sleep(Duration::from_secs(3)).await;
              fff.compare_exchange(0, 1, Ordering::Acquire, Ordering::Relaxed).unwrap();
              println!("[{}]0->1", now());
          });
  
          // 创建新线程执行同步任务
          runtime.spawn_blocking(move || {
              while 1 != ff.load(Ordering::Relaxed) {
                  std::thread::sleep(Duration::from_secs(3))
              }
              ff.compare_exchange(1, 2, Ordering::Acquire, Ordering::Relaxed).unwrap();
              println!("[{}]1->2", now());
              // 因为设置了淘汰时间为0，该线程执行完马上销毁
          });
  
          // 以阻塞方式进入runtime上下文
          runtime.block_on(async move {
              while 2 != f.load(Ordering::Relaxed) {
                  time::sleep(Duration::from_secs(1)).await;
  
                  // 让出CPU，等待下次调度
                  task::yield_now().await;
                  println!("[{}]yield", now());
              }
              println!("[{}]2->end", now());
          })
      }
  
      runtime.spawn_blocking(|| {
          std::thread::sleep(Duration::from_secs(3));
          println!("[{}]sync timer has expired", now());
      });
  
      // runtime离开作用域、drop时自动释放，关闭过程:
      // 1. 移除任务队列，不再调度新任务
      // 2. 移除正在执行但尚未完成的异步任务，终止所有worker thread
      // 3. 移除Reactor，禁止接收事件
      // blocking thread以及阻塞的线程因不受调度器控制仍会继续执行，这里的drop会阻塞直至所有blocking thread执行完成
      drop(runtime);
  
      println!("[{}]end", now());
  }
  ```
##### select!/join!/try_join!
  ```Rust
  use tokio::{time, join, try_join, select, pin};
  use std::future::Future;
  use std::pin::Pin;
  use std::sync::Arc;
  use std::task::{Context, Poll};
  use std::time::Duration;
  
  #[tokio::main]
  async fn main() {
      {
          async fn task1() -> Result<(), ()> {
              time::sleep(Duration::from_secs(1)).await;
              Err(())
          }
          async fn task2() -> Result<(), ()> {
              time::sleep(Duration::from_secs(2)).await;
              Err(())
          }
          async fn task3() -> Result<(), ()> {
              time::sleep(Duration::from_secs(3)).await;
              Err(())
          }
          // 等待所有任务完成
          join!(task1(), task2(), task3());
  
          // 等待所有任务完成或第一个返回Err的任务
          try_join!(task1(), task2(), task3());
  
          // 等待任意一个任务完成
          // tokio::select! {
          //     biased;
          //
          //     <pattern> = <async expression> (, if <precondition>)? => <handler>,
          //     <pattern> = <async expression> (, if <precondition>)? => <handler>,
          //     ...
          //     else => <handler>
          // };
          //
          // 工作流程:
          // 1. 评估分支中的if前置条件，禁用返回false的分支
          // 2. 收集所有分支中的异步表达式（包括禁用的分支），在同一线程中轮询所有未被禁用的异步任务
          // 3. 当某个分支的异步任务完成时，返回值匹配成功时执行对应分支的handler，如果匹配失败，则禁用当前分支
          // 4. 如果所有分支都被禁用，则执行else分支（如果没有else分支，则panic）
          //
          // 返回值:
          // 1. <async expression>的返回值会传递给<pattern>
          // 2. <handleer>有相同类型的返回值时会通过select!返回
          //
          // biased:
          // 1. 默认情况下，select随机选择分支进行检查，biased模式使select!按照从上到下的顺序轮询future
          // 2. 对于biased模式，优先把"具有大量消息且很快就绪"的分支放前面，防止future不断就绪而被忽略
          //
          // 什么情况下使用biased?
          // 1. 随机数生成会有一定的开销，而随机是不必要时
          // 2. 依赖已知的轮询顺序时
          //
          // 详情参考: https://docs.rs/tokio/latest/tokio/macro.select.html
          select!{
                biased; // select!默认为伪随机公平地轮询，biased选项可使select!按顺序轮询
  
                Ok(_) = task1(), if false => {},
                Ok(_) = task2(), if false => {},
                Ok(_) = task3(), if false => {},
                else => {} // else的handler必须用花括号包裹
          }
  
          let task1 = tokio::spawn(async {});
          while !task1.is_finished() {} // 考虑使用JoinSet和join!/try_join!等代替
      }
      // async fn和async block创建的future完成后不能再调用.await
      {
          pin! { let f = async {}; }
          select! { _ = &mut f => {} }
          // select! { _ = &mut f => {} } // panic: resumed after completion
  
          async fn test() {}
          pin! { let f = test(); }
          select! { _ = &mut f => {} }
          // select! { _ = &mut f => {} } // panic: resumed after completion
  
          let mutex = std::sync::Arc::new(tokio::sync::Mutex::new(0));
          let m1 = mutex.clone();
          let m2 = mutex.clone();
  
          pin! {
              let f1 = async move {
                  m1.lock().await;
              };
              let sleep = tokio::time::sleep(Duration::from_secs(3));
          }
  
          async fn f2(m: std::sync::Arc<tokio::sync::Mutex<i32>>) {
              m.lock().await;
          }
  
          loop {
              let m3 = mutex.clone();
              let m4 = mutex.clone();
  
              pin! {
                  let f3 = async move {
                      m4.lock().await;
                  };
              }
  
              select! {
                  // biased;
  
                  // async block panic的原因: 
                  // 1. 按顺序每次都会先轮询该分支
                  // 2. 因为f1每次都是轮询同一个future，第二次选择该分支时由于future已经完成而panic
                  // _ = &mut f1 => {}, // panic: resumed after completion
  
                  // 改成async fn函数，每次调用都会产生一个新的future
                  _ = f2(mutex.clone()) => {},
  
                  // 或者将async block移至<async expression>
                  _ = async move { m3.lock().await; } => {},
  
                  // 或者在loop中创建async block
                  _ = &mut f3 => {},
  
                  _ = &mut sleep => {  break; },
              }
          }
      }
      // select!不同分支的<handler>中可以同时可变借用同一个变量
      {
          let mut v = 0;
          tokio::select! {
              _ = async {} => { &mut v; }
              _ = async {} => { &mut v; }
          }
      }
      // 当在循环中select!时，分支中的future可以被修改
      // 在使用select!时需要注意async block完成后不能再select
      {
          struct BlockedFuture;
  
          impl Future for BlockedFuture {
              type Output = ();
  
              fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
                  Poll::Pending
              }
          }
  
          let mutex = Arc::new(tokio::sync::Mutex::new(0));
  
          // pin! {
          //     let sleep = async {
          //         tokio::time::sleep(Duration::from_secs(1)).await;
          //     };
          // }
  
          async fn action(m: Arc<tokio::sync::Mutex<i32>>, b: bool) -> bool {
              if !b {
                  m.lock().await;
              } else {
                  tokio::time::sleep(Duration::from_secs(5)).await;
              }
              b
          }
  
          async fn gen_sleep(block: bool) {
              if block {
                  BlockedFuture {}.await;
              } else {
                  tokio::time::sleep(Duration::from_secs(1)).await;
              }
          }
  
          pin! {
              let sleep = gen_sleep(false);
              let f = action(mutex.clone(), false);
          }
  
          let mut i = 0;
          loop {
              i += 1;
  
              select! {
                  ret = &mut f => {
                      if ret {
                          break;
                      }
  
                      // 更新f
                      f.set(action(mutex.clone(), false));
                  },
                  _ = &mut sleep => {
                      f.set(action(mutex.clone(), true));
  
                      // 用注释中的async block设置sleep会编译失败，因为它们是不同的类型
                      // sleep.set(async {
                      //     BlockedFuture {}.await;
                      // });
  
                      // sleep完成后再轮询仍然是完成状态，把它设置为永远不可能唤醒的Future，防止死循环
                      sleep.set(gen_sleep(true));
                      // continue;
                  },
              }
          }
      }
  }
  ```
##### pin!
  调用async fn返回的匿名Future是! Unpin的，需要先固定这些Future，才能对其轮询  
  调用.await可以解决这个问题，但会消耗Future。另一种方式是使用`(& mut Future).await`，这种方式需要调用者负责固定Future  
  比如select!中需要Future满足Unpin，可使用pin!固定Future，然后在select!中使用& mut Future
  ```Rust
  async fn test() {}

  #[tokio::main]
  async fn main() {
      let future = test();
      tokio::pin!(future);
      (&mut future).await;
  }
  ```

##### 等待任务完成
##### 在不同线程创建runtime
  ```Rust
  fn main() {
      let t1 = std::thread::spawn(|| {
          let rt = tokio::runtime::Runtime::new().unwrap();
          rt.block_on(async {});
      });
  
      let t2 = std::thread::spawn(|| {
          let rt = tokio::runtime::Runtime::new().unwrap();
          rt.block_on(async {});
      });
  
      t1.join().unwrap();
      t2.join().unwrap();
  }
  ```
#### time
  ```Rust
  use std::sync::OnceLock;
  use std::time::Duration;
  use tokio::time;
  
  static START: OnceLock<time::Instant> = OnceLock::new();
  
  fn now() -> String {
      START.get_or_init(|| time::Instant::now());
      format!("+{}ms", (time::Instant::now() - *START.get().unwrap()).as_secs_f64()).to_string()
  }
  
  #[tokio::main]
  async fn main() {
      {
          println!("[{}]sleep", now());
  
          let s = time::sleep(Duration::from_secs(1));
          tokio::pin!(s);
  
          // 修改终点
          s.as_mut().reset(time::Instant::now() + Duration::from_secs(2));
  
          // 开始执行
          s.await;
          println!("[{}]resume", now());
          println!();
      }
      {
          // 带超时的异步任务
          let t = time::timeout(Duration::from_secs(1), async {
              time::sleep(Duration::from_secs(3)).await;
          });
          assert!(matches!(t.await, Err(_)));
      }
      {
          // 间隔任务
          // 第一个参数为最早开始时间，第一个tick不早于这个时间返回
          let mut itv = time::interval_at(time::Instant::now() + Duration::from_secs(3), Duration::from_secs(1));
          println!("[{}]start", now()); // +0s
          itv.tick().await;
          println!("[{}]tick 1", now()); // +3s
          itv.tick().await;
          println!("[{}]tick 2", now()); // +4s
          itv.tick().await;
          println!("[{}]tick 3", now()); // +5s
          println!();
      }
      {
          // Interval默认是冲刺型策略(Burst策略)，当出现延迟后，接下来的tick会尽快赶上正常计时
          let mut itv = time::interval_at(time::Instant::now() + Duration::from_secs(1)/*最早开始时间*/, Duration::from_secs(1));
          itv.set_missed_tick_behavior(time::MissedTickBehavior::Burst);
          time::sleep(Duration::from_secs(3)).await;
          println!("[{}]start", now()); // +3s
          itv.tick().await;
          println!("[{}]tick 1", now()); // +3s
          itv.tick().await;
          println!("[{}]tick 2", now()); // +3s
          itv.tick().await;
          println!("[{}]tick 3", now()); // +3s
          println!();
      }
      {
          // 延迟性计时策略(Delay策略)，当出现延迟后仍接指定间隔计时
          let mut itv = time::interval_at(time::Instant::now() + Duration::from_secs(1)/*最早开始时间*/, Duration::from_secs(1));
          itv.set_missed_tick_behavior(time::MissedTickBehavior::Delay);
          println!("[{}]start", now()); // +0s
          itv.tick().await;
          println!("[{}]tick 1", now()); // +1s
          itv.tick().await;
          println!("[{}]tick 2", now()); // +2s
          itv.tick().await;
          println!("[{}]tick 3", now()); // +3s
          println!();
      }
      {
          // 忽略型计时策略(Skip策略)，当出现延迟后tick会尽可能在下一个interval倍数周期时间返回，使其符合start+N*interval
          let mut itv = time::interval_at(time::Instant::now() + Duration::from_secs(1)/*最早开始时间*/, Duration::from_secs(1));
          itv.set_missed_tick_behavior(time::MissedTickBehavior::Skip);
          println!("[{}]start", now()); // +0s
          itv.tick().await;
          println!("[{}]tick 1", now()); // +1s
          time::sleep(Duration::from_millis(2900)).await;
          itv.tick().await;
          println!("[{}]tick 2", now()); // +3.9xxs
          time::sleep(Duration::from_millis(100)).await;
          itv.tick().await;
          println!("[{}]tick 3", now()); // +4s
          time::sleep(Duration::from_millis(100)).await;
          itv.tick().await;
          println!("[{}]tick 4", now()); // +5s
          time::sleep(Duration::from_millis(100)).await;
          itv.tick().await;
          println!("[{}]tick 5", now()); // +6s
      }
  }
  ```
#### task通信
  ```Rust
  use std::time::Duration;
  use chrono::Local;
  use tokio::sync::{broadcast, mpsc, oneshot, watch};
  use tokio::{task, time};
  use tokio::time::{sleep, interval};
  
  fn now() -> String {
      Local::now().format("%F %T").to_string()
  }
  
  #[tokio::main]
  async fn main() {
      // 一对一、一次性的通道
      {
          let (tx, mut rx) = oneshot::channel::<u8>();
          assert_eq!(oneshot::error::TryRecvError::Empty, rx.try_recv().unwrap_err());
          task::spawn(async move {
              sleep(Duration::from_secs(1)).await;
              tx.send(1).unwrap(); // send是非阻塞同步函数
              // tx moved
          });
          assert_eq!(1, rx.await.unwrap());
          // rx moved
      }
      {
          let (tx, mut rx) = oneshot::channel::<u8>();
          assert_eq!(oneshot::error::TryRecvError::Empty, rx.try_recv().unwrap_err());
          tx.send(1).unwrap();
          assert_eq!(1, rx.try_recv().unwrap());
          assert_eq!(oneshot::error::TryRecvError::Closed, rx.try_recv().unwrap_err());
          // recv之后接收端不可再用，但还可以调用try_recv
          // rx.await.unwrap(); // panic
      }
      {
          let (tx, rx) = oneshot::channel::<u8>();
          drop(rx);
          assert_eq!(1, tx.send(1).unwrap_err()); // 接收端关闭时发送失败
      }
      {
          let mut itv = interval(Duration::from_millis(100));
          let (tx, mut rx) = oneshot::channel::<u8>();
          tokio::spawn(async move {
              time::sleep(Duration::from_secs(1)).await;
              tx.send(1).unwrap();
          });
          'label: loop {
              tokio::select! {
                  _ = itv.tick() => println!("tick"),
                  _ = &mut rx => { break 'label; }
              }
          }
          println!();
      }
      // 多对一通道
      {
          let (tx, mut rx) = mpsc::channel::<u8>(3);
          assert_eq!(mpsc::error::TryRecvError::Empty, rx.try_recv().unwrap_err());
          for i in 0..5 {
              let tx = tx.clone();
              task::spawn(async move {
                  tx.send(i).await.unwrap();
                  println!("[{}]send {i}", now());
              });
          }
          drop(tx);
  
          while let Some(v) = rx.recv().await {
              time::sleep(Duration::from_secs(1)).await;
              println!("[{}]recv {v}", now());
          }
          assert_eq!(mpsc::error::TryRecvError::Disconnected, rx.try_recv().unwrap_err());
          assert_eq!(None, rx.recv().await);
          println!();
      }
      {
          let (tx, mut rx) = mpsc::channel::<u8>(3);
          tx.send(0).await.unwrap();
          tx.send(1).await.unwrap();
          tx.send(2).await.unwrap();
          drop(tx);
          rx.close();
  
          // 发送端关闭后，接收端仍可以接收通道中已存在的消息
          while let Some(v) = rx.recv().await {
              println!("[{}]recv {v}", now());
          }
          assert_eq!(None, rx.recv().await);
          println!();
      }
      {
          let (tx, rx) = mpsc::channel::<u8>(1);
          drop(rx);
          assert_eq!(mpsc::error::SendError(1), tx.send(1).await.unwrap_err());
      }
      {
          // 无界通道，可无限缓冲直至内存耗尽
          let (tx, mut rx) = mpsc::unbounded_channel();
          task::spawn_blocking(move || {
              for i in 0..=100 {
                  // 同步函数
                  tx.send(i).unwrap();
              }
          });
          while let Some(_) = rx.recv().await {}
      }
      // 多对多广播通道
      {
          let (tx, mut rx) = broadcast::channel::<u8>(1);
          assert_eq!(broadcast::error::TryRecvError::Empty, rx.try_recv().unwrap_err());
          tx.send(0).unwrap();
          tx.send(1).unwrap();
          tx.send(2).unwrap();
          // 接收端落后两个消息，再次接收时返回第3个消息
          assert_eq!(broadcast::error::TryRecvError::Lagged(2), rx.try_recv().unwrap_err());
          assert_eq!(2, rx.try_recv().unwrap());
          drop(tx);
          assert_eq!(broadcast::error::TryRecvError::Closed, rx.try_recv().unwrap_err());
          assert_eq!(broadcast::error::RecvError::Closed, rx.recv().await.unwrap_err());
      }
      {
          let (tx, rx) = broadcast::channel::<u8>(1);
          drop(rx);
          assert!(matches!(tx.send(0), Err(broadcast::error::SendError(0u8))));
      }
      // 单对多watch通道
      {
          let (tx, mut rx) = watch::channel::<u8>(0);
          task::spawn(async move {
              let _ = rx.changed().await.unwrap(); // 感知到变化并标记已读取
              assert_eq!(1, *rx.borrow());
              let _ = rx.changed().await.unwrap();
              assert_eq!(2, *rx.borrow());
              assert!(rx.changed().await.is_err());
          });
          assert_eq!(0, tx.send_replace(1));
          sleep(Duration::from_secs(1)).await; // 等rx感知到变化
          assert_eq!(1, tx.send_replace(2));
          drop(tx);
          sleep(Duration::from_secs(1)).await;
      }
  }
  ```
#### IO
  ```Rust
  ```
#### task同步
##### 同步机制
  * tokio::sync::Mutex
  * tokio::sync::RwLock
  * tokio::sync::Notify
  * tokio::sync::Barrier
  * tokio::sync::Semphore
##### std::sync::Mutex和tokio::sync::Mutex
  * 锁竞争不多时可使用std::sync::Mutex，注意MutexGuard和.await在同一个作用域可能导致死锁
  * tokio::sync::Mutex只有在跨多个异步过程时使用，但开销会更高。如非必要，尽量优先使用std::sync::Mutex同步或者可考虑使用性能更高的锁parking_lot::Mutex

## rustup
  * 卸载: rustup self uninstall
 
## Cargo
  * rustup镜像
    ```
    echo 'export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup' >> ~/.bash_profile
    echo 'export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup' >> ~/.bash_profile
    ```
  * cargo镜像: ~/.cargo/config添加
    ```
    [source.crates-io]
    registry = "https://github.com/rust-lang/crates.io-index"
    replace-with = 'ustc'
    [source.ustc]
    registry = "git://mirrors.ustc.edu.cn/crates.io-index"
    ```
  * error[E0635]: unknown feature `proc_macro_span_shrink`: 删除`Cargo.lock`和`target/`

## [项目大全](https://github.com/rust-unofficial/awesome-rust)

## 书
  * [Rust文档翻译指引](https://github.com/rust-lang-cn/rust-translation-guide?tab=readme-ov-file)
  * [Rust工程师枕边资料](https://github.com/0voice/Understanding_in_Rust)
  * [Rust程序设计语言](https://doc.rust-lang.org/stable/book/)（[中文版](https://rustwiki.org/zh-CN/book/title-page.html)）
  * [Rust版本指南](https://doc.rust-lang.org/nightly/edition-guide/introduction.html)（[中文版](https://rustwiki.org/zh-CN/edition-guide/introduction.html)）
  * [通过例子学Rust](https://doc.rust-lang.org/rust-by-example/index.html)（[中文版](https://rustwiki.org/zh-CN/rust-by-example/index.html)）
  * [Rust参考手册](https://doc.rust-lang.org/stable/reference/)（[中文版](https://rustwiki.org/zh-CN/reference/introduction.html)）
  * [Rust Cookbook](https://rust-lang-nursery.github.io/rust-cookbook/)（[中文版](https://rustwiki.org/zh-CN/rust-cookbook/)）
  * [Rust入门秘籍 中文版](https://rust-book.junmajinlong.com/about.html)
  * [Rust高级编程](https://krircc.github.io/rust/nomicon/index.html)（[中文版](https://krircc.github.io/rust/nomicon/index.html)）
  * [Rust语言备忘清单](https://cheats.rs)（[中文版](https://nootn.com/rust-language-cheat-sheet/)）
  * [Rust宏小册子](https://zjp-cn.github.io/tlborm/)（[中文版](https://veykril.github.io/tlborm/)）
  * [Rustlings](https://doc.rust-lang.org/book/title-page.html)（[中文版](https://github.com/rust-lang-cn/rustlings-cn)，[解答](https://www.cnblogs.com/Roboduster/p/17781712.html)）
  * [Cargo手删](https://doc.rust-lang.org/nightly/cargo/index.html)（[中文版](https://rustwiki.org/zh-CN/cargo/)）
  * [Rust语言圣经 中文版](https://course.rs/about-book.html)
  * [Rust中的异步编程 中文版](https://huangjj27.github.io/async-book/index.html)
  * [Programming Rust - Fast, Safe Systems Development 中文版](https://github.com/MeouSker77/ProgrammingRust/tree/main)
  * [Rust精选2021 中文版](https://rustmagazine.github.io/rust_magazine_2021/index.html)
  * [Rust精选2022 中文版](https://rustmagazine.github.io/rust_magazine_2022/index.html)

## 博客
  * [MichaelFu](https://blog.fudenglong.site/categories/rust/)


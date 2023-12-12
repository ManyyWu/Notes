# Rust

## 基础
### 类型
#### 字面量
  * 可以使用任意数量下划线分割数字，提高可读性，比如: `123_456_789`
#### 枚举
  * 枚举也可以定义方法、实现trait
#### 类型别名和newtype
  * 类型别名: `type NewType = ExistType;`
  * newtype: `struct NewType(ExistType);`
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
  ZST在内存中不占空间，但可以实例化
  ```Rust
  use std::mem::size_of;

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
### 标签
  `'label loop { break 'label; }`
### 函数
  * 函数内可以定义函数
### 借用
  * 一个对象在同一时间只能有一个可变借用或者多个不可变借用，不能同时拥有可变借用和不可变借用
  * 再借用
    ```Rust
    fn main() {
        {
            let mut a = String::from("");
            let r = &mut a;
            let rr = r; // move
            println!("{}", rr);
        }
        {
            let mut a = String::from("");
            let r = &mut a;
            let rr = &*r;
            println!("{}", r); // reborrow后允许不可变借用
            // r.push('!'); // reborrow后不允许可变借用
            println!("{}", rr);
        }
        {
            fn test(str: &mut String) { }
            let mut a = String::from("");
            let mut r = &mut a;
            test(r); // reborrow
        }
    }
    ```
### 自动解引用
  自动解引用的情况:
  * 方法调用
  * 成员访问
  * 比较操作符两边是同类型引用
### 内存对齐
  * 为了避免浪费空间，Rust中数据结构布局不保证顺序
### 堆栈
  * 在Rust中，main线程的栈大小是8MB，普通线程是2MB，在函数调用时会在其中创建一个临时栈空间
  * cargo test是普通线程，cargo bench是主线程

## 泛型
  * 泛型支持指定默认类型
  * 约束条件尽量在impl中指定，除非该类型没有impl实现才在定义时指定(因为即使在定义时指定了，impl中也需要再次指定)

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
  
      // matches宏
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
### 常用特征
#### Drop特征
  离开作用域时自动调用析构方法drop
#### From/Into
  
#### Move、Clone和Copy
##### Move
  * Move相当于浅拷贝, 但会使源对象不可用
  * 赋值时, 若类型未实现Copy特征, 会优先使用Move语义。Copy特征实现后优先使用Copy
  * Move对象的成员时, 会使对象及被Move的成员不可用, 但其他成员可用, 重新赋值可以使其可用
  * `let x = "".to_string(); x;`中的`x;`相当于`let _temp = x;`
##### Copy
  * Copy是浅拷贝，直接复制值
  * 所有字段实现Copy特征时才能派生Copy(一个类型如果要实现Copy特征它必须先实现Clone特征)
  * 默认支持Copy的类型: 基本类型、基本类型组成的元组、&T(这些类型不会赋值时Move是因为实现了Copy)
##### Clone
  * Clone是深拷贝，为类型实现Clone特征
  * 所有字段实现Clone特征时才能派生Clone
  * 未实现Clone时，引用类型的clone()等价于Copy。实现了Clone时，引用类型的clone()将克隆并自动解引用为引用所指类型
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
#### 静态多态与动态多态
  ```Rust
  use std::fmt::Debug;
  
  fn main() {
      // impl Trait是静态多态，在编译时单态化展开
      {
          fn make_string() -> impl Debug {
              String::default()
          }
          fn make_vec() -> impl Debug {
              Vec::<&str>::default()
          }
  
          let obj1 = make_string();
          let obj2 = make_vec();
          //let v = [obj1, obj2]; // obj1, obj2是不同类型
          println!("{:?} {:?}", obj1, obj2);
      }
      // 泛型是静态多态，编译时展开
      {
          fn make_obj<T: Debug + Default>() -> T {
              T::default()
          }
          let obj1: String = make_obj::<String>();
          let obj2: Vec<&str> = make_obj::<Vec<&str>>();
          println!("{:?} {:?}", obj1, obj2);
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
          let vr = [make_obj_ref::<String>(&v[0]), make_obj_ref::<Vec<&str>>(&v[1])];
          println!("{:?} {:?} {:?} {:?}", v[0], v[1], vr[0], vr[1]);
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

## 属性
  [参考](https://rustwiki.org/zh-CN/reference/attributes.html?highlight=repr#%E5%86%85%E7%BD%AE%E5%B1%9E%E6%80%A7%E7%9A%84%E7%B4%A2%E5%BC%95%E8%A1%A8)
  * 指定枚举数值范围: `#[repr(u8) enum MyEnum {}`

## 字符串转换
  ```
  &str    -> String--| String::from(s) or s.to_string() or s.to_owned()
  &str    -> &[u8]---| s.as_bytes()
  &str    -> Vec<u8>-| s.as_bytes().to_vec() or s.as_bytes().to_owned()
  String  -> &str----| &s if possible* else s.as_str()
  String  -> &[u8]---| s.as_bytes()
  String  -> Vec<u8>-| s.into_bytes()
  &[u8]   -> &str----| s.to_vec() or s.to_owned()
  &[u8]   -> String--| std::str::from_utf8(s).unwrap(), but don't**
  &[u8]   -> Vec<u8>-| String::from_utf8(s).unwrap(), but don't**
  Vec<u8> -> &str----| &s if possible* else s.as_slice()
  Vec<u8> -> String--| std::str::from_utf8(&s).unwrap(), but don't**
  Vec<u8> -> &[u8]---| String::from_utf8(s).unwrap(), but don't**
  ```
  
## 不太聪明的生命周期检查
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
                  //Some(v) => v, // 当v作为返回值时，v与map具有相同的生命周期，v在生命周期内会保持对map的可变借用
                  Some(v) => {
                      // v在这里可以使用，但不能返回
                      map.get_mut(&key).unwrap()
                  },
                  None => {
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
      ref_2(&n); // error[E0597]: `n` does not live long enough
  }
  ```
  
## 闭包
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
  
      // 一个闭包实现了哪种Fn特征取决于该闭包如何使用被捕获的变量，而不是取决于闭包如何捕获它们
      // 所有的闭包都自动实现了FnOnce特征，因此任何一个闭包都至少可以被调用一次
      // 没有移出所捕获变量的所有权的闭包自动实现了FnMut特征
      // 不需要对捕获变量进行改变的闭包自动实现了Fn特征
  
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
    * 如果Pin<T>不能被移动，T必须实现!Unpin特征
    * !Unpin只是保证在Safe Rust下拿到&mut T
    * 如果实现了Unpin特征还是可以Pin的，但是不再有任何效果
### 组合使用
  * Rc<RefCell<T>>: 多个所有者+单线程内部可变性
  * Arc<Mutex<T>>: 多线程内部可变性
  
## 使用Cell解决借用冲突
  ```Rust
  let mut v = Vec::<i32>::new();
  for i in 0 .. 9 {
      v.push(i);
  }
  //for i in v.iter().filter(|&num| num %2 == 0 ) {
  //    v[*i as usize] *= 2; // cannot borrow `v` as mutable because it is also borrowed as immutable
  //}
  let vc = Cell::from_mut(&mut v[..]).as_slice_of_cells();
  for i in vc.iter().filter(|&num| num.get() % 2 == 0 ) {
      vc[i.get() as usize].set(i.get() * 2);
  }
  println!("{:?}", v);
  ```

## 异步
### async/await
  ```Rust
  use std::{
      future::Future,
      sync::{Mutex, Arc, mpsc::{sync_channel, SyncSender, Receiver}},
      task::{Context, Poll},
      pin::Pin,
      thread,
      time::Duration,
  };
  use futures::{
      task::{ArcWake, waker_ref}, future::BoxFuture, FutureExt,
  };
  
  struct Task {
      future: Mutex<Option<BoxFuture<'static, ()>>>,
      sender: SyncSender<Arc<Task>>,
  }
  
  impl ArcWake for Task {
      fn wake_by_ref(arc_self: &Arc<Self>) {
          arc_self.sender.send(arc_self.clone()).expect("队列已满");
      }
  }
  
  struct Executor {
      sender: Option<SyncSender<Arc<Task>>>,
      recver: Option<Receiver<Arc<Task>>>,
  }
  
  impl Executor {
      fn new() -> Self {
          let (s, r) = sync_channel::<Arc<Task>>(10);
          Executor { sender: Some(s), recver: Some(r)}
      }
  
      fn spawn(&self, future: impl Future<Output = ()> + 'static + Send) -> Arc<Task> {
          let task = Arc::new(Task {
              future: Mutex::new(Some(future.boxed())),
              sender: self.sender.as_ref().unwrap().clone(),
          });
          self.sender.as_ref().unwrap().send(task.clone()).expect("队列已满！");
          task
      }
  
      fn run(&mut self) {
          self.sender.take();
          while let Ok(task) = self.recver.as_ref().unwrap().recv() {
              let mut future = task.future.lock().unwrap();
              if future.is_none() {
                  continue;
              }
              let waker = waker_ref(&task);
              let ctx = &mut Context::from_waker(&*waker);
              if future.as_mut().unwrap().as_mut().poll(ctx).is_ready() {
                  *future = None;
              }
          }
      }
  }
  
  struct MyFuture {
      complete: Arc<Mutex<bool>>,
  }
  
  impl Future for MyFuture {
      type Output = ();
  
      fn poll(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<Self::Output> {
          if *self.complete.lock().unwrap() {
              println!("ready");
              Poll::Ready(())
          } else {
              println!("pending");
              Poll::Pending
          }
      }
  }
  
  #[test]
  fn test1() {
      let mut e = Executor::new();
  
      let a = Arc::new(Mutex::new(false));
      let aa = a.clone();
      let b = Arc::new(Mutex::new(false));
      let bb = b.clone();
  
      // 不会按预期挂起。可能是因为async语法糖创建的Future，返回给poll的结果恒为Complete
      async fn f(complete: Arc<Mutex<bool>>) -> Poll<()> {
          if *complete.lock().unwrap() {
              println!("ready");
              Poll::Ready(())
          } else {
              println!("pending");
              Poll::Pending
          }
      }
  
      async fn ff(a: Arc<Mutex<bool>>, b: Arc<Mutex<bool>>) {
          println!("1");
          f(a).await;
          println!("2");
          f(b).await;
          println!("3");
      }
      let t = e.spawn(ff(a, b));
      let tt = t.clone();
  
      e.spawn(async move {
          thread::spawn(move || {
              println!("11");
              thread::sleep(Duration::from_secs(1));
              *aa.lock().unwrap() = true;
              t.wake();
              println!("22");
          });
      });
  
      e.spawn(async move {
          thread::spawn(move || {
              println!("33");
              thread::sleep(Duration::from_secs(3));
              *bb.lock().unwrap() = true;
              tt.wake();
              println!("44");
          });
      });
  
      e.run();
  }
  
  #[test]
  fn test2() {
      let mut e = Executor::new();
  
      let a = Arc::new(Mutex::new(false));
      let aa = a.clone();
      let b = Arc::new(Mutex::new(false));
      let bb = b.clone();
  
      async fn ff(a: Arc<Mutex<bool>>, b: Arc<Mutex<bool>>) {
          println!("1");
          MyFuture { complete: a }.await;
          println!("2");
          MyFuture { complete: b }.await;
          println!("3");
      }
      let t = e.spawn(ff(a, b));
      let tt = t.clone();
  
      e.spawn(async move {
          thread::spawn(move || {
              println!("11");
              thread::sleep(Duration::from_secs(1));
              *aa.lock().unwrap() = true;
              t.wake();
              println!("22");
          });
      });
  
      e.spawn(async move {
          thread::spawn(move || {
              println!("33");
              thread::sleep(Duration::from_secs(3));
              *bb.lock().unwrap() = true;
              tt.wake();
              println!("44");
          });
      });
  
      e.run();
  }
  
  #[test]
  fn test3() {
      let mut e = Executor::new();
  
      let a = Arc::new(Mutex::new(false));
      let aa = a.clone();
      let b = Arc::new(Mutex::new(false));
      let bb = b.clone();
  
      let t = e.spawn(async {
          println!("1");
          MyFuture { complete: a }.await;
          println!("2");
          MyFuture { complete: b }.await;
          println!("3");
      });
      let tt = t.clone();
  
      e.spawn(async move {
          thread::spawn(move || {
              println!("11");
              thread::sleep(Duration::from_secs(1));
              *aa.lock().unwrap() = true;
              t.wake();
              println!("22");
          });
      });
  
      e.spawn(async move {
          thread::spawn(move || {
              println!("33");
              thread::sleep(Duration::from_secs(3));
              *bb.lock().unwrap() = true;
              tt.wake();
              println!("44");
          });
      });
  
      e.run();
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
  https://zjp-cn.github.io/tlborm/

## 模块与包
### 文件分层
  ```文件层次
  src/
    |-- mod_0/
    |   |-- mod.rs
    |   `-- mod_1.rs
    `-- main.rs
  ```
  src/mod_0/mod.rs
  ```Rust
  // 当前作用域是mod_0
  
  pub mod mod_1;
  
  mod mod_2 {}
  ```
  src/mod_0/mod_1.rs
  ```Rust
  // 当前作用域是mod_1
  
  #[allow(unused)]
  fn f() {}
  
  #[allow(unused)]
  pub mod mod_2 {
      pub fn f() {}
  }
  
  ```
  src/main.rs
  ```Rust
  // 在当前作用域声明mod_0，会自动查找mod_0.rs或mod_0/mod.rs
  // 只能在函数或模块外声明
  mod mod_0;
  
  #[allow(unused)]
  mod mod_1 {
      pub struct MyStruct {
          v: i32,
      }
  
      // impl不需要使用pub
      impl MyStruct {
          pub fn new(v: i32) -> MyStruct { MyStruct { v } }
      }
  
      pub enum MyEnum {
          A(i32),
      }
  
      fn f() {}
  
      mod mod_2 {
          pub fn f() {}
      }
  
      pub mod mod_3 {
          pub fn f() {}
      }
  }
  
  #[allow(unused)]
  mod mod_2 {
      mod mod_3 {
          mod mod_4 {
              fn f() {
                  { use self::f; } // self代表自身模块create::mod_2::mod_3::mod_mod_4
                  { use super::mod_4::f; } // super代表父模块create::mod_2::mod_3
                  { use crate::mod_2::mod_3::mod_4; } // crate代表包根
              }
          }
      }
  }

  #[allow(unused)]
  fn main() {
      // { use mod_1::f; } // 不可见
      // { use mod_1::mod_2; } // 不可见
      { use mod_1; } // 同层级可见
      { use mod_1::mod_3::f; } // 相对路径
      { use crate::mod_1::mod_3::f; } // 绝对路径，优点是模块移动位置时不需要修改路径
      { use mod_1::MyEnum::A; } // 将枚举设置为pub，其字段也对外可见
      {
          let v = mod_1::MyStruct::new(0);
          // v.v // 将结构体设置为pub，其字段对外不可见
      }
      // { use mod_0::mod_2; } // 不可见
      // { use mod_0::mod_1::f; } // 不可见
      { use mod_0::mod_1::mod_2::f; }
  }
  ```

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
  * 关于如何选用thiserror和anyhow只需要遵循一个原则即可：是否关注自定义错误消息，关注则使用thiserror(常见业务代码)，否则使用anyhow(编写第三方库代码)
  ```Rust
  fn main() {
      {
          // anyhow
          use anyhow::Result;
  
          fn test_anyhow() -> Result<()> {
              std::fs::read("")?;
              Ok(())
          }
          println!("0.\n{:?}\n", test());
  
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
              IOError{
                  #[from] // #[from]也会自动实现source()函数
                  err: std::io::Error,
              },
              #[error("Invalid Param: {}, expected: {}", .expected, .found)]
              InvalidParam {
                  expected: String,
                  found: String,
              },
              #[error(transparent)]
              UnknowError(
                  #[from]
                  anyhow::Error
              ),
          }
          fn test() -> Result<(), MyError> {
              std::fs::read("")?;
              Ok(())
          }
          println!("1.\n{}\n", MyError::Succeed);
          println!("2.\n{}\n", MyError::SystemError);
          println!("3.\n{}\n", MyError::FileNotFound("/etc/bashrc".to_string()));
          println!("4.\n{}\n{:?}\n", test().unwrap_err(), test().unwrap_err().source());
          println!("5.\n{}\n", MyError::InvalidParam { expected: "-1".to_string(), found: "[0, i32::Max]".to_string() });
          println!("6.\n{}\n", test_anyhow().unwrap_err())
      }
      {
          // thiserror
          use std::error::Error;
          use thiserror::Error;
  
          #[derive(Error, Debug)]
          #[error("MyError happened, source: {}, param: {}", .err, .param)]
          struct MyError {
              #[source]
              err: std::io::Error,
  
              param: String,
          }
          let e = MyError { err: std::fs::read("").unwrap_err(), param: "".to_string() };
          println!("9.\n{:#?}\n{:#?}", e, e.source());
      }
  }
  ```
### panic!
  * panic!打印堆栈并退出程序
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
              panic!("Error");
          });
          // 恢复panic
          if let Err(ctx) = result {
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
  * 强制类型转换(注意：使用transmute时要保证源类型和目标类型的内存布局和大小相同)
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
## CLI
  * pico_args: 轻量参数解析器
  * clap: 功能齐全的参数解析器
## 日志
## 异步
  * Tokio: 异步库
  * rayon: 并行库

### Tokio
#### std::sync::Mutex和tokio::sync::Mutex
  * 锁竞争不多时可使用std::sync::Mutex，注意MutexGuard和.await在同一个作用域可能导致死锁
  * tokio::sync::Mutex只有在跨多个异步过程时使用，但开销会更高
  * 锁竞争多时可考虑使用性能更高的锁: parking_lot::Mutex

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

## 书
  * [Rust学习笔记](https://skyao.io/learning-rust/)
  * [简介 - Rust 程序设计语言 简体中文版](https://kaisery.github.io/trpl-zh-cn/ch00-00-introduction.html)
  * [简介 - Rust 版本指南 中文版](https://rustwiki.org/zh-CN/edition-guide/introduction.html)
  * [简介 - 通过例子学 Rust 中文版](https://rustwiki.org/zh-CN/rust-by-example/index.html)
  * [简介 - Rust 参考手册 中文版](https://rustwiki.org/zh-CN/reference/introduction.html)
  * [Rust 语言圣经 - Rust语言圣经(Rust Course)](https://course.rs/about-book.html)
  * [起步 - Rust 中的异步编程](https://huangjj27.github.io/async-book/index.html)
  * [理解tokio的核心(1): runtime - Rust入门秘籍](https://rust-book.junmajinlong.com/ch100/01_understand_tokio_runtime.html)
  * [Rust入门秘籍](https://rust-book.junmajinlong.com/about.html)
##

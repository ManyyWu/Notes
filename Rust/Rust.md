# Rust

## 基础
### 借用
  * 一个对象在同一时间只能有一个可变借用或者多个不可变借用，不能同时拥有可变借用和不可变借用
### 切片
  * 切片在Rust中是动态大小类型DST，只能使用其引用，无法直接使用
### 标签
  * `'label loop { break 'label; }`
### 函数
  * 函数内可以定义函数
### 自动解引用
  Rust自动解引用的情况:
  * 函数调用
  * 成员访问
  * 比较操作符两边是同类型引用

## 模式匹配
  [参考](https://rustwiki.org/zh-CN/reference/patterns.html)
  ```Rust
  #[derive(Copy, Clone)]
  struct Tuple(i32, i32);
  
  #[derive(Copy, Clone)]
  struct Test {
      a: i32,
      b: Option<(i32, i32)>,
      d: Tuple,
  }
  
  enum MyEnum {
      A(i32, i32, i32),
      B,
  }
  
  #[allow(unused)]
  fn main() {
      let mut t = Test {
          a: 0,
          b: Some((1, 2)),
          d: Tuple(1, 2),
      };
      let e = MyEnum::A(1, 2, 3);
      let v = ['h', 'e', 'l', 'l', 'o', '!'];
  
      // 解构
      match t {
          Test { a, b, d } => {} // 因为Test实现了Copy特征，t的成员不会转移所有权
          Test { ref a, b: Some((ref mut b1, mut b2)), d } => {} // a为不可变借用，b1为可变借用，b2为可变变量(转移所有权)
      }
      match &t {
          Test { a, b: Some((b1, b2)), d } => {} // 对引用解构，被匹配的变量也将被赋值为对应元素的引用
          _ => {}
      }
      match e {
          MyEnum::A(a, b, _) => {} // 省略第3个成员
          MyEnum::A(a, ..) => {} // 省略后2个成员
          MyEnum::A(.., c) => {} // 省略前2个成员
          MyEnum::B => {}
          //MyEnum::A(ab @ .., c) => {} // error: `ab @ ` is not allowed in a tuple struct
          _ => {}
      }
      let ref mut i = &0; // ref修饰变量名时相当于强行加上引用
  
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
          0..=10 => {}, // 范围匹配，目前只支持全闭合区间
          0..=10 if 1 % 2 == 0 => {} // 匹配守卫，匹配分支后再检查后置条件
          _ => {}
      };

      // match需要穷举所有分支, 而if let是match的语法糖，只关心指定分支，其他分支(`_分支`)由else负责
      if let MyEnum::A(a, b, c) = e {}
      else if let MyEnum::B = e {}
      else {}
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
  fn get_value<K, V>(map: &mut HashMap<K, V>, key: K) -> &mut V
      where
          K: Clone + Eq + Hash,
          V: Default
      {
      match map.get_mut(&key) {
          Some(v) => v, // v对map的可变借用会保持到match结束
          None => {
              map.insert(key.clone(), V::default()); // error[E0499]: cannot borrow `*map` as mutable more than once at a time
              map.get_mut(&key).unwrap()
          }
      }
  }
  // 编译通过
  fn get_value<K, V>(map: &mut HashMap<K, V>, key: K) -> &mut V
      where
          K: Clone + Eq + Hash,
          V: Default
      {
      match map.get_mut(&key) {
          Some(_) => map.get_mut(&key).unwrap(),
          None => {
              map.insert(key.clone(), V::default());
              map.get_mut(&key).unwrap()
          }
      }
  }
  // 编译通过(建议用该写法)
  fn get_value<K, V>(map: &mut HashMap<K, V>, key: K) -> &mut V
      where
          K: Clone + Eq + Hash,
          V: Default
      {
      if !map.contains_key(&key) {
          map.insert(key.clone(), V::default());
      }
      return map.get_mut(&key).unwrap();
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

## Trait
### Move、Clone和Copy
#### Move
  * Move相当于浅拷贝, 但会使源对象不可用
  * 赋值时, 若类型未实现Copy特征, 会优先使用Move语义。Copy特征实现后优先使用Copy
  * Move对象的成员时, 会使对象及被Move的成员不可用, 但其他成员可用, 重新赋值可以使其可用
  * `let x = "".to_string(); x;`中的`x;`相当于`let _temp = x;`
#### Copy
  * Copy是浅拷贝，直接复制值
  * 所有字段实现Copy特征时才能派生Copy(一个类型如果要实现Copy特征它必须先实现Clone特征)
  * 默认支持Copy的类型: 基本类型、基本类型组成的元组、&T(这些类型不会赋值时Move是因为实现了Copy)
#### Clone
  * Clone是深拷贝，为类型实现Clone特征
  * 所有字段实现Clone特征时才能派生Clone
  * 未实现Clone时，引用类型的clone()等价于Copy。实现了Clone时，引用类型的clone()将克隆并自动解引用为引用所指类型

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
  struct Node<T> where T: std::fmt::Debug {
      data: T,
      next: Link<T>,
      prev: Link<T>,
  }
  
  impl<T> Node<T> where T: std::fmt::Debug {
      fn new (data: T) -> Rc<RefCell<Node<T>>> {
          Rc::new(RefCell::new(Node { data: data, next: None, prev: None }))
      }
  }
  
  #[derive(Debug)]
  struct List<T> where T : std::fmt::Debug {
      head: Link<T>,
      tail: Link<T>,
  }
  
  impl<T> List<T> where T: std::fmt::Debug {
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
  
  impl<T> Iterator for ListIntoIter<T> where T: std::fmt::Debug {
      type Item = T;
  
      fn next(&mut self) -> Option<Self::Item> {
          self.0.pop_front()
      }
  }
  
  impl<T> IntoIterator for List<T> where T: std::fmt::Debug {
      type Item     = T;
      type IntoIter = ListIntoIter<T>;
  
      fn into_iter(self) -> Self::IntoIter {
          ListIntoIter(self)
      }
  }
  
  impl<T> Drop for List<T> where T : std::fmt::Debug{
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

## 疑难杂症
### * Rc<RefCell<T>>.as_ref().map返回Ref<T>时无法自动推导，报错: "type annotations needed for Option<&Borrowed>"
    Rc<T>通过实现std::borrow::Borrow特征实现了borrow()，Ref通过方法实现borrow()  
    vscode自动导入"use std::borrow::Borrow;"，导致Rc<T>不会自动解引用调用Ref<T>的borrow()

## Unsafe
  * 解引用裸指针，就如上例所示
  * 调用一个Unsafe或外部的函数
  * 访问或修改一个可变的静态变量
  * 实现一个Unsafe特征
  * 访问union中的字段

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
  * 镜像: ~/.cargo/config添加
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
##

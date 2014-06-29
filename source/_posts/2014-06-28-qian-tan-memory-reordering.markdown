---
layout: post
title: "浅谈Memory Reordering"
date: 2014-06-28 22:55:22 +0800
comments: true
categories: [Multithreading]
tags: [Multithreading, C++]
keywords: "Multithreading, C++, Memory Reordering, Memory Model"
description: "浅谈Memory Reordering in C++"
---

## Memory ordering
在我们编写的C/C++代码和它被在CPU上运行,按照一些规则,代码的内存交互会被
乱序.内存乱序同时由编译器(编译时候)和处理器(运行时)造成,都为了使代码运
行的更快.

{% img /images/blog/2014/multithreading/memory_model.png 'memory_ordering' %}

被编译开发者和处理器制造商遵循的中心内存排序准则是:
{% blockquote %}
不能改变单线程程序的行为.
{% endblockquote %}

因为这条规则,在写单线程代码时内存乱序被普遍忽略.即使在多线程程序中,它
也被时常忽略,因为有mutexes,semaphores等来防止它们调用中的内存乱序.仅当
lock-free技术被使用时,内存在不受任何互斥保护下被多个线程共享,内存乱序
的影响能被看到.

下面先比较Weak和Strong的内存模型,然后分两部分,实际内存乱序如何在编译和运行时发生,并如何防止它们.

<!-- more -->

## Weak VS strong Memory Models
[Jeff Preshing](http://preshing.com/about)在
[Weak vs. Strong Memory Models](http://preshing.com/20120930/weak-vs-strong-memory-models/)
中很好的总结了从Weak到Strong的类型:

| 非常弱                    | 数据依赖性的弱     | 强制      | 顺序一致                      |
|---------------------------+----------------------------+-------------------------------|
| DEC Alpha                 | ARM            | X86/64    | dual 386                      |
| C/C++11 low-level atomics | PowerPC        | SPARC TSO | Java volatile/C/C++11 atomics |


### 弱内存模型

在最弱的内存模型中,可能经历所有四种内存乱序
([LoadLoad, StoreStore, LoadStore and StoreLoad](http://g.oswego.edu/dl/jmm/cookbook.html)).任
何load或store的操作能与任何的其他的load或store操作乱序,只要它不改变一
个独立进程的行为.实际中,这样的乱序由于编译器引起的指令乱序或处理器本身
处理指令的乱序.

当处理器是弱硬件内存模式,通常称它为weakly-ordered或weak ordering.或说
它有relaxed memory model. **DEC Alpha** 是
[最具代表](http://www.mjmwired.net/kernel/Documentation/memory-barriers.txt#2277)
的弱排序的处理器.

C/C++的底层原子操作也呈现弱内存模型,无论代码的平台是如x86/64的强序处理
器.下面章节
[Memory ordering at compile time](http://dreamrunner.org/blog/2014/06/28/qian-tan-memory-reordering/#memory-ordering-at-compile-time)
会演示其弱内存模型,并说明如何强制内存顺
序来保护编译器乱序.

### 数据依赖性的弱

ARM和PowerPC系列的处理器内存模型和Alpha同样弱,除了它们保持
[data dependency ordering](http://www.mjmwired.net/kernel/Documentation/memory-barriers.txt#305).它
意味两个相依赖的`load`(load A, load B<-A)被保证顺序`load B<-A`总能在
`load A`之后.(A data dependency barrier is a partial ordering on interdependent loads only; it is not required to have any effect on stores, independent loads or overlapping loads.)


### 强内存模型

弱和强内存模型区别[存
在分歧](http://herbsutter.com/2012/08/02/strong-and-weak-hardware-memory-models/#comment-5903).[Preshing](http://preshing.com/20120930/weak-vs-strong-memory-models/)
总结的定义是:

{% blockquote %}
一个强硬件内存模型是在这样的硬件上每条机器指令隐性的保证acquire and release
semantics的执行.因此,当一个CPU核进行了一串写操作,每个其他的CPU核看到这
些值的改变顺序与其顺序一致.
{% endblockquote %}

所以也就是保证了四种内存乱序
([LoadLoad, StoreStore, LoadStore and StoreLoad](http://g.oswego.edu/dl/jmm/cookbook.html))
中的3种,除了不保证StoreLoad的顺序.基于以上的定义,x86/64系列处理器基本
就是强顺序的.之后
[Memory ordering at processor time](http://dreamrunner.org/blog/2014/06/28/qian-tan-memory-reordering/#memory-ordering-at-processor-time)
可以看到StoreLoad在X86/64的乱序实验.

### 顺序一致

在顺序一致
([Sequential consistency](http://en.wikipedia.org/wiki/Sequential_consistency))
的内存模型中,没有内存乱序存在.

如今,很难找到一个现代多核设备保证在硬件层Sequential consistency.也就早
期的386没有强大到能在运行时进行任何内存的乱序.

当用上层语言编程时,Sequential consistency成为一个重要的软件内存模
型.Java5和之后版本,用`volatile`声明共享变量.在C+11中,可以使用默认的顺
序约束`memory_order_seq_cst`在做原子操作时.当使用这些术语后,编译器会限
制编译乱序和插入特定CPU的指令来指定合适的memory barrier类型.

## Memory ordering at compile time
看如下代码:

``` c test.c
int A, B;
void test() {
  A = B + 1;
  B = 0;
}
```

不打开编译器的优化,把它编译成汇编,我们可以看到,`B`的赋值在`A`的后面,和
原程序的顺序一样.

``` sh
$ gcc -S -masm=intel test.c

	mov	eax, DWORD PTR B
	add	eax, 1
	mov	DWORD PTR A, eax
	mov	DWORD PTR B, 0
```

用`O2`打开优化:

``` sh
$ gcc -S -O2  -masm=intel test.c

	mov	eax, DWORD PTR B
	mov	DWORD PTR B, 0
	add	eax, 1
	mov	DWORD PTR A, eax
```

这次编译器把`B`的赋值提到`A`的前面.为什么它可以这么做呢?内存顺序的中心
没有破坏.这样的改变并不影响单线程程序,单线程程序不能知道这样的区别.

但是当编写lock-free代码时,这样的编译器乱序就会引起问题.看如下例子,一个
共享的标识来表明其他共享数据是否更新:

``` c
int value;
int updated = 0;
void UpdateValue(int x) {
    value = x;
    update = 1;
}
```

如果编译器把`update`的赋值提到`value`赋值的前面.即使在单核处理器系统中,会
有问题:在两个参数赋值的中间这个线程被中断,使得另外的程序通过`update`判
断以为`value`的值已经得到更新,实际上却没有.

### 显性的Compiler Barriers
一种方法是用一个特殊的被称为Compiler Barrier的指令来防止编译器优化的乱
序.以下
[`asm volative`](http://en.wikipedia.org/wiki/Memory_ordering#Compiler_memory_barrier)
是GCC中的方法.

``` c test_barrier.c
int A, B;
void test() {
  A = B + 1;
  asm volatile("" ::: "memory");
  B = 0;
}
```

经过这样的修改,打开优化,`B`的存储将保持在要求的顺序上.

``` sh
$ gcc -S -O2  -masm=intel test.c

	mov	eax, DWORD PTR B
	add	eax, 1
	mov	DWORD PTR A, eax
	mov	DWORD PTR B, 0
```

### 隐性的Compiler Barriers
在C++11中原子库中,每个不是relaxed的原子操作同时是一个compiler barrier.

``` c++
int value;
std::atomic<int> updated(0);
void UpdateValue(int x) {
    value = x;
    // reordering is prevented here
    update.store(1, std::memory_order_release);
}
```

每一个拥有compiler barrier的函数本身也是一个compiler barrier,即使它是
inline的.

``` c++
int a;
int b;
void DoSomething() {
    a = 1;
    UpdateValue(1);
    b = a + 1;
}
```

进一步推知,大多数被调用的函数是一个compiler barrier.无论它们是否包含
memory barrier.排除inline函数,被声明为[`pure attribution`](http://lwn.net/Articles/285332/)
或当
[link-time code generation](http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0474c/CHDHIEGF.html)
使用时.因为编译器在编译时,并不知道`UpdateValue`的运行是否依赖于`a`或会
改变`a`的值从而影响`b`,所以编译器不会乱序它们之间的顺序.

可以看到,有许多隐藏的规则禁止编译指令的乱序,也防止了编译器多进一步的代
码优化,所以在某些场景
[Why the "volatile" type class should not be used](https://www.kernel.org/doc/Documentation/volatile-considered-harmful.txt),
来让编译器进一步优化.


### 无缘由的存储

有隐形的Compiler Barriers,同样GCC编译器也有无缘由的存储.来自[这里的实例](https://gcc.gnu.org/ml/gcc/2007-10/msg00266.html):

``` c
extern int v;
  
    void
    f(int set_v)
    {
      if (set_v)
        v = 1;
    }

```

在i686,GCC 3.3.4--4.3.0用`O1`编译得到:

``` sh
            pushl   %ebp
            movl    %esp, %ebp
            cmpl    $0, 8(%ebp)
            movl    $1, %eax
            cmove   v, %eax        ; load (maybe)
            movl    %eax, v        ; store (always)
            popl    %ebp
            ret
```

在单线程中,没有问题,但多线程中调用`f(0)`仅仅只是读取v的值,但中断后回去
覆盖其他线程修改的值.引起
[data rate](http://www.devx.com/cplus/Article/42725).在新的C++11标准中
明确禁止了这样的行为,看[最近C+11标准进行的draft](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2012/n3337.pdf)§1.10.22节:

{% blockquote %}
Compiler transformations that introduce assignments to a potentially shared memory location that would not be modified by the abstract machine are generally precluded by this standard.
{% endblockquote %}

## Memory ordering at processor time

看一个简单的CPU乱序的简单例子,即使在强内存模型的X86/64也能看到.有两个
整数`X`和`Y`初始是0,另外两个变量r1和r2读取它们的值,两个线程并行运行,执
行如下的机器代码:

{% img center /images/blog/2014/multithreading/ordering-example.png 370 100  'ordering-example' %}

每个线程存储1到一个共享变量,然后把对方变量读取到一个变量或一个寄存器中.无
论哪个线程先写1到内存,另外个线程读回那个值,意味着最后r1=1或r2=1或两者
都是.但是X86/64是强内存模型,它还是允许**乱序**机器指令.特别,每个线程允许
延迟存储到读回之后.以致最后r1和r2能同时等于0--违反直觉的一个结果.因为
指令可能如下顺序执行:

{% img center /images/blog/2014/multithreading/reordering-example.png 190 100  'reordering-example' %}

写一个实例程序,实际看一下CPU的确乱序了指令.源码可以
[Github下载](https://github.com/shishougang/blog_multithreading/tree/master/memory_reordering).两
个读写的线程代码如下:

``` c++
sem_t begin_sem1;
sem_t begin_sem2;
sem_t end_sem;

int X, Y;
int r1, r2;

void *ThreadFunc1(void *param) {
  MersenneTwister random(1);
  for (;;) {
    sem_wait(&begin_sem1);
    // random delay
    while (random.Integer() % 8 != 0) {
    }
    X = 1;
    asm volatile("" ::: "memory");  // prevent compiler ordering
    r1 = Y;
    sem_post(&end_sem);
  }
  return NULL;
}

void *ThreadFunc2(void *param) {
  MersenneTwister random(2);
  for (;;) {
    sem_wait(&begin_sem2);
    // random delay
    while (random.Integer() % 8 != 0) {
    }
    Y = 1;
    asm volatile("" ::: "memory");  // prevent compiler ordering
    r2 = X;
    sem_post(&end_sem);
  }
  return NULL;
}
```

随机的延迟被插入在存储的开始处,为了交错线程的开始时间,以来达到重叠两个线程
的指令的目的.随机延迟使用线程安全的`MersenneTwister`类.汇编代码`asm
volatile("" ::: "memory");`如上节所述只是用来
[防止编译器的乱序](http://dreamrunner.org/blog/2014/06/28/qian-tan-memory-reordering/#memory-ordering-at-compile-time),
因为这里是要看CPU的乱序,排除编译器的乱序影响.

主线程如下,利用
[POSIX的semaphore](http://pubs.opengroup.org/onlinepubs/7908799/xsh/sem_init.html)
同步它与两个子线程的同步.先让两个子线程等待,直到主线程初始化`X=0`和
`Y=0`.然后主线程等待,直到两个子线程完成操作,然后主线程检查`r1`和`r2`的
值.所以semaphore防止线程见的不同步引起的内存乱序,主线程代码如下:

``` c++
int main(int argc, char *argv[]) {
  sem_init(&begin_sem1, 0, 0);
  sem_init(&begin_sem2, 0, 0);
  sem_init(&end_sem, 0, 0);

  pthread_t thread[2];
  pthread_create(&thread[0], NULL, ThreadFunc1, NULL);
  pthread_create(&thread[1], NULL, ThreadFunc2, NULL);

  int detected = 0;
  for (int i = 1; ; ++i) {
    X = 0;
    Y = 0;
    sem_post(&begin_sem1);
    sem_post(&begin_sem2);
    sem_wait(&end_sem);
    sem_wait(&end_sem);
    if (r1 == 0 && r2 == 0) {
      detected++;
      printf("%d reorders detected after %d iterations\n", detected, i);
    }
  }
  return 0;
}
```

在Intel i5-2435M X64的ubuntu下运行一下程序:

``` sh
1 reorders detected after 2181 iterations
2 reorders detected after 4575 iterations
3 reorders detected after 7689 iterations
4 reorders detected after 22215 iterations
5 reorders detected after 60023 iterations
6 reorders detected after 60499 iterations
7 reorders detected after 61639 iterations
8 reorders detected after 62243 iterations
9 reorders detected after 67998 iterations
10 reorders detected after 68098 iterations
11 reorders detected after 71179 iterations
12 reorders detected after 71668 iterations
13 reorders detected after 72417 iterations
14 reorders detected after 73970 iterations
15 reorders detected after 78227 iterations
16 reorders detected after 81897 iterations
17 reorders detected after 82722 iterations
18 reorders detected after 85377 iterations
...
```

差不多每**4000**次的迭代才发现一次CPU内存乱序.所以多线程的bug是多么难
发现.那么如何消除这些乱序.至少有如下两种方法:

1. 让两个子线程在同一个CPU核下运行.(没有可移植性方法,如下是linux平台的).
2. 使用CPU的memory barrier防止它的乱序.

### Lock to one processor
让两个子线程在同一个CPU核下运行,代码如下:

``` c++
  cpu_set_t cpus;
  CPU_ZERO(&cpus);
  CPU_SET(0, &cpus);
  pthread_setaffinity_np(thread[0], sizeof(cpu_set_t), &cpus);
  pthread_setaffinity_np(thread[1], sizeof(cpu_set_t), &cpus);
```

### Place a memory barrier

防止一个Store在Load之后的乱序,需要一个StoreLoad的barrier.这里使用
`mfence`的一个全部memory barrier,防止任何类型的内存乱序.代码如下:

``` c++
void *ThreadFunc1(void *param) {
  MersenneTwister random(1);
  for (;;) {
    sem_wait(&begin_sem1);
    // random delay
    while (random.Integer() % 8 != 0) {
    }
    X = 1;
    asm volatile("mfence" ::: "memory");  // prevent CPU ordering
    r1 = Y;
    sem_post(&end_sem);
  }
  return NULL;
  }
```

## More

1. [University of Cambridge整理的文档和论文](http://www.cl.cam.ac.uk/~pes20/weakmemory/)
2. [Paul McKenney概括他们做的一些工作和工具](http://lwn.net/Articles/470681/)
3. [The Art of Multiprocessor Programming](http://www.amazon.com/gp/product/0123973376/ref=as_li_ss_tl?ie=UTF8&tag=preshonprogr-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0123973376)
4. [C++ Concurrency in Action: Practical Multithreading](http://www.amazon.com/C-Concurrency-Action-Practical-Multithreading/dp/1933988770/ref=pd_sim_b_2?ie=UTF8&refRID=1QTX99XZAM6HKVG7X0G2)
5. [Is Parallel Programming Hard, And, If So, What Can You Do About It?](https://www.kernel.org/pub/linux/kernel/people/paulmck/perfbook/perfbook.2011.01.02a.pdf)


## Summarization
1. 有两种内存乱序存在:编译器乱序和CPU乱序.
2. 如何防止编译器乱序.
3. 如何防止CPU乱序.



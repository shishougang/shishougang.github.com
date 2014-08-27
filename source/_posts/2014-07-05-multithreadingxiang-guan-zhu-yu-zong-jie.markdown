---
layout: post
title: "Multithreading相关术语总结"
date: 2014-07-05 23:23:52 +0800
comments: true
categories: [Multithreading]
tags: [Multithreading, C++]
keywords: "Multithreading, C++, Memory Reordering, Memory Model, Memory barrier"
description: "Multithreading相关术语总结: Memory Barrier, Acquire
semantics, Release semantics, happens-before relation"
---

在谈到内存模型,Multithreading,尤其lock-free programmming等时,总会遇到
一些相关术语来描述,如Memory Barrier,Acquire semantics,Release
semantics,happens-before relation等.在这里稍微整理一下.

<!-- more -->

## Memory Barriers

在之前
[浅谈Memory Reordering](http://dreamrunner.org/blog/2014/06/28/qian-tan-memory-reordering/)
中谈到编译器reordering和在多核下的处理器的reordering,在lock-free
programming中,如果不控制好这两者的reordering就会引起上文中所不想的结果.

你可以通过指令强制CPU和编译器在内存处理上的顺序,这些指令就被成为
[Memory Barrier](http://en.wikipedia.org/wiki/Memory_barrier).

有很多指令作为memory barriers,所以需要知道很多不同类型的memory
barriers. [Doug Lea指出](http://g.oswego.edu/dl/jmm/cookbook.html)如下
的四大类可以很好的归纳在CPU上的特殊指令.尽管不是完全,大多数时候,一个正
真的CPU指令执行包含上面barrier类型的各种组合,或附带其他效果.无论如何,
一旦你理解了这四种类型的memory barriers,你就很好的理解了大部分真正CPU
的关于内存约束的指令.
[Memory Barriers Are Like Source Control Operations](http://preshing.com/20120710/memory-barriers-are-like-source-control-operations/)
这篇把Memory Barriers与Source Control作类比,熟悉Source Control机制的可
以很形象的理解各类Memory Barriers机制.

{% img center /images/blog/2014/multithreading/memory_barriers_types.png  'memory_barriers_types' %}

### LoadLoad

顺序: Load1; **LoadLoad**; Load2

保证Load1的数据加载在被load2和之后的load指令读取加载之前.是一个比较好
的方法防止看到旧的数据.以这个经典的例子,CPU1检查一个共享的标识变量flag来确
认一些数据是否被CPU1更新.如果标识变量flag是true的话,把`LoadLoad`barrier
放在读取更新数据之前:

``` c++
if (is_updated) {
    LOADLOAD_FENCE();  // Prevent reordering of loads
    return value;  // Load updated value
}
```

只要`is_updated`被CPU1看到为true, `LoadLoad`fence防止CPU1读到比标识变
量flag本身旧的`value`.

### StoreStore

顺序: Store1; **StoreStore**; Store2

保证Store1的数据被其他CPU看到在与这数据相关的Store2和之后的store指令之
前.同样,它足够的防止其他CPU看到自己的旧数据.同上一样的例子,CPU1需要更
新一些数据到共享的内存中,把`StoreStore` barrier放在标识变量flag是true
之前:

``` c++
value = x;
STORESTORE_FENCE();
is_updated = 1;  // Set shared flag to show the update of data
```

一旦其他CPU看到`is_updated`为true,它能自信它看到正确的`value`值.而且
`value`不需要原子类型,它可以是一个包含很多元素的大数据结构.

### LoadStore

顺序: Load1; **LoadStore**; Store2

保证Load1的数据被加载在与这数据相关的Store2和之后的store指令之
前.

### StoreLoad

顺序: Store1; **StoreLoad**; Load2

保证Store1的数据被其他CPU看到在数据被Load2和之后的load指令加载之前.也
就是说,它有效的防止所有barrier之前的stores与所有barrier之后的load乱序.

`StoreLoad`是唯一的.它是唯一的memory barrier类型来防止`r1=r2=0`在之前
[Memory ordering at processor time](http://dreamrunner.org/blog/2014/06/28/qian-tan-memory-reordering/#memory-ordering-at-processor-time)
中给出的例子.

`StoreLoad`有什么区别与`StoreStore`之后跟`LoadLoad`?虽
然,`StoreStore`按序把存储改变推送到主内存中,`LoadLoad`按序把改变加载过
来,但是这两种类型的barrier是不够的.Store可以延迟任意的指令,以致在Load
之后,Load也可以不是加载最新Store之后的内容.这就是为啥PowerPC的指令
`lwsync`,包含这三种memory barriers,`LoadLoad`,`LoadStore`和
`StoreStore`,但不包含`StoreLoad`,是不足以防止`r1=r2=0`在那个实例中.

### Data dependency barriers

除了上面4大类,还有`Loadload`的弱化模式的`Data dependency barrier`.如
`LoadLoad`类似,在两个load顺序执行,load2依赖于load1的结果,`Data
dependency barrier`需要插入保证两者的顺序.

但与`LoadLoad`不同,`Data dependency barrier`只是部分顺序约束在内在以来
的load,就是load1必须与load2是 **data** dependency 而不是仅仅是
**control** dependency.

* data dependency

r1与r2之间是data dependency.

``` c
r1 = 1;
r2 = r1;
```

* control dependency

r1与r2之间是control dependency.

``` c
r1 = value;
if (r1) {
    r2 = r1;
} else {
    r2 = 1;
}
```

### More

* [LINUX KERNEL MEMORY BARRIERS](https://www.kernel.org/doc/Documentation/memory-barriers.txt) 
* [Memory Barriers: a Hardware View for Software Hackers](www.rdrop.com/users/paulmck/scalability/paper/whymb.2010.07.23a.pdf)


## Acquire and Release semantics

在lock-free programming中,共享内存被多个线程通过合作传递信息来处理,在
这种处理下,acquire和release semantics是关键技术保证可靠的传递信息在线
程之间.

acqure和release semantics并没有好的被定义,这里借用Jeff Preshing在
[这里](http://preshing.com/20120913/acquire-and-release-semantics/)给
予的定义:

{% img right /images/blog/2014/multithreading/read_acquire.png  170 110 'read_acquire' %}


<strong>Acquire semantics</strong> 是一种只能应用于如下操作的性质: 从
共享内存读取,无论是
[read-modify-write](http://en.wikipedia.org/wiki/Read-modify-write)操
作还是普通的加载.这一操作被认为是一个 **read acquire**. Acquire
semantics防止read acquire程序上**之后**的任何读或写操作与它的内存乱
序.

<br>

{% img right /images/blog/2014/multithreading/write_release.png   170 110 'write_release' %}

**Release semantics** 是一种只能应用于如下操作的性质: 写入到共享内存,
无论是read-modify-write操作还是普通的存储.这一操作被认为是一个 **write release**.
Release semantics防止write release程序上**之前**的任何读或写
操作与它的乱序.

Acqure和release semantics能通过之前四种memory barrier的简单组合来达到.

{% img center /images/blog/2014/multithreading/acquire_release_semantics.png  'acquire_release_semantics' %}

Acqure和release semantics可以基本划分为如下结构:

{% img center /images/blog/2014/multithreading/acquire_release_semantics_category.png  'acquire_release_semantics_category' %}

### 使用明确的平台相关Fence指令

在X86/64使用`mefence`指令,mfence是一个满足全部memory barrier,防止任何类型的内存乱序.

{% img center /images/blog/2014/multithreading/platform-specific_fence.png  'platform-specific_fence' %}

### 可移植的C++11的Fences

C++11的atomic库定义了一个可移植的函数`atomic_thread_fence()`,输入一个
变量来指定什么类型的fence.

{% img center /images/blog/2014/multithreading/fence_in_c++11.png  'fence_in_c++11' %}

### 可移植的C++11的atomic,非明确的fence

在C++11中,可以直接对atomic变量直接约束fence,而不是显示的明确fence.与上
面明确fence相比,这实际是更优的方法来表达acquire and release semantics
在C++11中.

{% img center /images/blog/2014/multithreading/without_fence_c++11.png  'without_fence_c++11' %}

## Happens-before relation

*Happens-before* 是一个术语来描述C++11,Java,LLVM之类背后的[软件内存模型](http://dreamrunner.org/blog/2014/06/28/qian-tan-memory-reordering/#weak-vs-strong-memory-models).

在之上每个语言里都能找到*happends-before*的定义,尽管每个都有不同的说法,但
内在意思基本一致.粗略地讲,基本定义如下:

{% blockquote %}
A和B表示一个多线程进行的操作.若A <strong>happens-before</strong> B,那
么,在B进行前,A对B的内存影响有效的被B看到.
{% endblockquote %}

无论使用任何编程语言,它们都有一个共同处:如果操作A和B被同一个进程进行,A
的语句在B的语句之前在程序顺序上,那么A*优先发生(happens-before)*B.这也
是在之前
[Memory ordering](http://dreamrunner.org/blog/2014/06/28/qian-tan-memory-reordering/#weak-vs-strong-memory-models)
中谈到中心原则.

这里再次提一下指令重排序问题,有人有如下疑问: 指令重排序会破坏
happens-before原则吗？happens-before的程序次序原则说：在一个线程内，按
照程序代码顺序，书写在前面的操作会先行发生于书写在后面的操作。如果线程
内出现指令重排序，那不是破坏了程序次序原则了吗？

是会破坏程序次序的执行,但是并不破坏happens-before原则,并不造成内存对单
线程有效性的破坏.这里主要的困惑是时间上顺序的发生之前(happening
before)与先行发生(happens-before)两者关系.

时间上顺序的发生在前于(happening before)与先行发生(happens-before)两者是
不一样的,基本没太大关系.特别:

1. A先行发生(happens-before)B并不意味着A发生在前于(happening before)B.
2. A发生在前于(happening before)B并不意味A先行发生(happens-before)B.

谨记happens-before是由一系列编程语言特定定义的操作间的关系,它的存在独
立于时间的概念.

### happens-before并不意味happening before

如下例子有happens-before关系但并不是顺序执行,没有happening before.如下
代码:(1) 存储到A,之后(2)存储到B.根据程序顺序原则,(1) happens-before (2).


``` c++
int A, B;
void test() {
  A = B + 1;  // (1)
  B = 0;  // (2)
}
```

用O2打开优化编译的如下:

``` sh
$ gcc -S -O2  -masm=intel test.c

	mov	eax, DWORD PTR B
	mov	DWORD PTR B, 0
	add	eax, 1
	mov	DWORD PTR A, eax
```

从汇编指令看出,第二句`mov DWORD PTR B, 0`就已经完成对`B`的存储,但是
对`A`的存储还没进行.(1)顺序上并没有在(2)之前执行!

但是happens-before原则有被违背吗?根据定义,(1)的内存效用必须有效被看到
在进行(2)之前.也就是存储A必须影响存储B.

在这里,存储A实际并没有影响存储B.(2)被提前执行与之后执行仍然一样,相当与
(1)的内存有效性是一样的.因此,这并不算违背happens-before原则.

### happening before并不意味happens-before

这是个时间上发生于前但并含有happens-before关系的例子.如下的代码,想象一
个线程调用`UpdateValue`,而另一个线程调用`ConsumeValue`.因为处理共享的
数据并行的,为了简单,认为普通的读取和存储`int`是atomic的.因为程序顺序原
则,在(1)和(2)之间happens-before关系,(3)和(4)之间happens-before关系.

``` c++
int value = 0;
int updated = 0;

void UpdateValue() {
    value = 123;  // (1)
    update = 1;  // (2)
}

void ConsumeValue() {
if (update) {  // (3)
    printf("%d\n", value);  // (4)
}
```

进一步假设在运行开始的时候,(3)读取`update`到为1,这个值是有(2)在另外个线程
中存储的.这里,我们可以得出时间顺序上(2)必须发生前于(3).但是这里并没有规
则意味着在(2)和(3)之间有happens-before关系.(2)和(3)之间没有
happens-before关系,(1)和(4)之间也没有happens-before关系.因此,(1)和(4)
的内存可以重排序,因为编译器重排序或在CPU上内存重排序,以致(4)可以打印
"0",即使(3)读到1.

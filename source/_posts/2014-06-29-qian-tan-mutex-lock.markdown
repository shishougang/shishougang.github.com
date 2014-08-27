---
layout: post
title: "浅谈Mutex (Lock)"
date: 2014-06-29 20:52:09 +0800
comments: true
categories: [Multithreading]
tags: [Multithreading, C++, Mutex, Lock]
keywords: "Multithreading, C++, Mutex, Lock, Benchmark, Lightweight"
description: "浅谈Mutex(Lock)"
---

[Mutex](http://en.wikipedia.org/wiki/Mutual_exclusion)(又叫Lock),在多线程中,作为同步的基本类型,用来保证没有两个线程或进程同时在他们的关键区域.因为Mutex这种排它性,很多人认为Mutex开销很大,尽量避免使用它.就如这篇
分析完共享数据问题后,进一步分析说明
[Avoiding locks](http://courses.cs.washington.edu/courses/cse451/03wi/section/prodcons.htm)
来解决这个问题.但Mutex真的开销如此大,还是被大家误解了?Matthew
Dillon[写道](http://groups.google.com/group/net.micro.mac/msg/752d18de371bd65c?dmode=source),"Most
people have the misconception that locks are slow.”, Jeff Preshing也
[写了这篇"Locks Aren't Slow; Lock Contention Is"](http://preshing.com/20111118/locks-arent-slow-lock-contention-is/).

那么接下来做3个关于Mutex的Benchmark,具体分析一下Mutex的开销如何,最后并
利用原子操作和semaphore实现一个lightweight Mutex.

<!-- more -->

一个Mutex仅仅从Lock到Unlock具体开销是多少,是不是占用很多时间,从
[Always Use a Lightweight Mutex](http://preshing.com/20111124/always-use-a-lightweight-mutex/)
从可以看到在windows中有两种
Mutex:[Muetx](http://msdn.microsoft.com/en-us/library/windows/desktop/ms684266%28v=vs.85%29.aspx)
和
[Critical Section](http://msdn.microsoft.com/en-us/library/windows/desktop/ms682530%28v=vs.85%29.aspx),
重量级和轻量级的区别,两者的时间开销相差25倍多,所以一直使用轻量级的Mutex.

[这篇文章](http://ridiculousfish.com/blog/posts/barrier.html)在高强度
下lock的性能:每个线程做任何事情都占用lock(高冲突),lock占用极短的时间
(高频率).值得一读,但是在实际应用中,基本避免如此使用locks.这里对
Mutex Contention和Mutex Frequency都做最好和最坏场景的使用测试.

Mutex被灌以避免使用也因为其他原因.现在有很多大家熟知的
[lock-free programming](en.wikipedia.org/wiki/Non-blocking_algorithma)
技术.Lock-free编程非常具有挑战性,但在实际场景中获得巨大的性能.既然有
lock-free的技术吸引我们使用它们,那么locks就显得索然无味了.

但也不能因此忽略lock.因为在实际很多场景,它仍然是利器.

## Lightweight Mutex Benchmark

Linux下的POSIX thread是轻量级的Mutex.基于Linux特有的
[futex](http://en.wikipedia.org/wiki/Futex)技术,当没有其他线程竞争锁时它被优化过.使
用如下简单的例子,测试一个单线程lock和unlock,所有代码在[Github上](https://github.com/shishougang/blog_multithreading/tree/master/mutex_time).

``` c++
pthread_mutex_init(&lock, NULL);
const int kN = 1000000;
for (int i = 0; i < kN; ++i) {
    pthread_mutex_lock(&lock);
    pthread_mutex_unlock(&lock);
}
pthread_mutex_destroy(&lock);
```

插入相应的时间代码,算出10万次的单线程lock/unlock平均时间.在不同的处理
器下,结果如下:

{% img center /images/blog/2014/multithreading/mutex_benchmark.png 450 200 'mutex_benchmark' %}

如果假设一个线程每分钟获取1e5次mutex,并且没有其他线程与它竞争.基于如下
的图,可预计0.2%到0.4%的开销.不算差.在比较低频率下,开销基本忽略不计.之
后[Build own lightweight mutex](http://dreamrunner.org/blog/2014/06/29/qian-tan-mutex-lock#build-own-lightweight-mutex),会利用[semaphore](http://en.wikipedia.org/wiki/Semaphore_%28programming%29)和一个原子操作,实现一个lightweight mutex.

POSIX thread与Windows Critical Section不同,它不仅支持线程间的同步,
还支持进程间的同步.实例代码如下:

```  c++  mutex_between_process.cc
pthread_mutex_t mutex;
pthread_mutexattr_t attrmutex;

/* Initialise attribute to mutex. */
pthread_mutexattr_init(&attrmutex);
pthread_mutexattr_setpshared(&attrmutex, PTHREAD_PROCESS_SHARED);
pthread_mutex_init(&mutex, &attrmutex);

/* Use the mutex. */

/* Clean up. */
pthread_mutex_destroy(pmutex);
pthread_mutexattr_destroy(&attrmutex);
```

## Mutex Contention Benchmark

在测试中,产生一个不断生成随机数的线程,使用自己编制的线程安全的
[Mersenne Twister](http://en.wikipedia.org/wiki/Mersenne_twister)实现
代码.每过一段时间,它获取和释放一个锁,获取和释放锁之间的时间每次是随机的,但
是总的平均时间是提前设计好的.这个随机的过程就是个泊松分布过程,计算出产
生一个随机数的平均时间6.25 ns在2.93 GHz i7上,把它作为运行单位.利用
[Poisson Process](http://wiki.dreamrunner.org/public_html/Algorithms/Theory%20of%20Algorithms/poisson-process.html)
的算法决定运行多少个运行单位在获取和释放锁之间.并利用
[High Resolution Time](http://dreamrunner.org/blog/2014/06/24/high-resolution-time/)API
计算时间.这个线程的代码如下,所有代码在[Github上](https://github.com/shishougang/blog_multithreading/tree/master/mutex_contention):

``` c++
  GetMonotonicTime(&start);
  for (;;) {
    work_units = static_cast<int> (random.PoissonInterval(
        global_state.average_unlock_count) + 0.5f);
    for (int i = 0; i < work_units; ++i) {
      random.Integer();
    }
    thread_stats.workdone += work_units;

    GetMonotonicTime(&end);
    elapsed_time = GetElapsedTime(&start, &end);
    if (elapsed_time >= global_state.time_limit) {
      break;
    }

    // Do some work while holding the lock
    pthread_mutex_lock(&global_state.thread_mutex);
    work_units = static_cast<int> (random.PoissonInterval(
        global_state.average_locked_count) + 0.5f);
    for (int i = 0; i < work_units; ++i) {
      random.Integer();
    }
    thread_stats.workdone += work_units;
    pthread_mutex_unlock(&global_state.thread_mutex);

    thread_stats.iterations++;
    GetMonotonicTime(&end);
    elapsed_time = GetElapsedTime(&start, &end);
    if (elapsed_time >= global_state.time_limit) {
      break;
    }
  }
```

这里模拟获取和释放15000次锁每秒,从1个线程运行到2个线程,最后到4个线
程.并且验证占用锁的时间,从0%到100%的每次运行时间占用锁.把1个线程的完成
的工作量作为基准数据,其他的去除以它,计算相对增益.基本测试方案如下:

``` c++
// Test 15000 locks per second: thread number, lock_interval
    1, 1/15000.0f, 
    2, 1/15000.0f,
    3, 1/15000.0f,
    4, 1/15000.0f,
```

{% img /images/blog/2014/multithreading/lock_benchmark.png lock_benchmark' %}

从图中看出,随着锁占用的时间增加,并行性越来越差,直到最后占用60%以后,单
线程运行的更好.可以说,短时间的占用锁的时间,以10%以内,系统达到很高的并
行性.虽然并不是完美的,但是也接近.锁总体很快.

把这个结果放到实际中,Jeff Preshing在
[这篇](http://preshing.com/20111118/locks-arent-slow-lock-contention-is/)
提到,实际的游戏程序中,15000的锁每秒来自3个线程,占用锁的时间相对2%.在图
中很适中的区域.

## Mutex Frequency Benchmark

尽管一个lightweight mutex有开销,但如上测试在2.40GHz i5上,lock/unlock锁
开销约 **34.2ns** ,因此15000锁每秒开销很低以致不是严重影响结果.那么把
锁的每秒频率提高呢?

只创建2个线程,进行一系列的锁的每秒频率测试在2.40GHz i5上,从占用锁时间
10 ns(1e8/s)到100 us(1e4/s),用单线程的占用锁时间10 ms作为基准工作量,其
他与它比较,测试方案如下:

``` c++
  // Reference
  1, 10e-3f,      // 10 ms        100/s
  
    // Test various lock rates with 2 threads
    2, 10e-9f,      // 10 ns        100000000/s
    2, 31.6e-9f,    // 31.6 ns      31600000/s
    2, 100e-9f,     // 100 ns       10000000/s
    2, 316e-9f,     // 316 ns       3160000/s
    2, 1e-6f,       // 1 us         1000000/s
    2, 3.16e-6f,    // 3.16 us      316000/s
    2, 10e-6f,      // 10 us        100000/s
    2, 31.6e-6f,    // 31.6 us      31600/s
    2, 100e-6f,     // 100 us       10000/s
```

{% img /images/blog/2014/multithreading/frequency_benchmark.png 'frequency_bechmark' %}

如预想一样,对于非常高频率的锁,锁的开销开始减少实际工作量.在网络上,可以
找到很多同样的测试.图中下边的线条,对于这样高的频率,也就是占用锁的时间
很短,就一些CPU的指令,这样的情况下,当锁之间的工作如此简单,那么一个
lock-free的实现更适合.

我们获得了一大块关于锁的性能:从它进行很好的情况,到缓慢应用的情况.在考
虑实际锁的使用情况,不能说所有锁都是慢的.必须承认,很容易乱用锁,但不用太
担心,任何的瓶颈问题都会在细心的profiling中发现.当你考虑锁是如何的稳定,
相对容易的理解它们(与lock-free技术相比),锁有时候其实很好用.

## Build own lightweight mutex

我们也可以实现自己的简单轻量级的mutex,但仅仅作为教育手段,理解mutex一些
内在实现细节,实际现在操作系统都提供轻量级的mutex,千万不要自己实现一个
并实际使用,直接只用操作系统提供的即可.

网络上有很多种方法在用户层写自己的mutex:

* [roll-your-own-lightweight-mutex](http://preshing.com/20120226/roll-your-own-lightweight-mutex/)利用Windows提供的semaphore和atomic操作实现的mutex.
* [Review of many Mutex implementations](http://cbloomrants.blogspot.hk/2011/07/07-15-11-review-of-many-mutex.html)很长的一篇文章,总结了很多种mutex的实现细节.

这里利用
[Benaphore](http://www.haiku-os.org/legacy-docs/benewsletter/Issue1-26.html#Engineering1-26)
技术,在Linux平台上利用[semaphore](http://pubs.opengroup.org/onlinepubs/9699919799/functions/sem_init.html)和[atomic](https://gcc.gnu.org/onlinedocs/gcc-4.1.2/gcc/Atomic-Builtins.html)操作实现自己的C++版本的
lightweight mutex.这里并没有用
[C++11的原子库](http://www.open-std.org/JTC1/sc22/wg21/docs/papers/2007/n2427.html).所
有代码在[Github上](https://github.com/shishougang/blog_multithreading/tree/master/benaphore_mutex).

``` c++
 #include <semaphore.h>
class Benaphore {
 public:
  Benaphore() : counter_(0) {
    sem_init(&semaphore_, 0, 0);
  }
  ~Benaphore() {
    sem_destroy(&semaphore_);
  }
  void Lock() {
    if (__sync_add_and_fetch(&counter_, 1) > 1) {
      sem_wait(&semaphore_);
    }
  }
  void Unlock() {
    if (__sync_sub_and_fetch(&counter_, 1) > 0) {
      sem_post(&semaphore_);
    }
  }
  bool TryLock() {
    return __sync_bool_compare_and_swap(&counter_, 0, 1);
  }
    
 private:
  long counter_;
  sem_t semaphore_;
};
```

[`__sync_add_and_fetch`](https://gcc.gnu.org/onlinedocs/gcc-4.1.2/gcc/Atomic-Builtins.html)
是一个由GCC内部提供的 *atomic read-modify-write (RMW)* 操作,它把1加到
某个数并且返回新的数,在同一时间所有操作由一个线程原子操作完成,其他线程
不能干涉,只能在后等待.这里`counter_`初始化为0,第一个线程调用`Lock`将得
到1从`__sync_add_and_fetch`,然后跳过`sem_wait`,一旦这个线程占用这个锁,
之后线程都将递增`counter_`,获得大于1的数,从而调用`sem_wait`等待.

之后,第一个线程完成自己的操作,调用`Unlock`,`__sync_sub_and_fetch`的返
回值大于1说明有其他线程在等待这个mutex,调用`sem_post`唤醒其他线程.

### 底层分析与性能

上面使用了`__sync_add_and_fetch`,它编译成`lock xadd`指令如下.在没有竞
争下的lock/unlock操作性能与pthread mutex相当.但是在mutex多线程竞争情况
下,这个mutex性能没有pthread mutex好.

{% img /images/blog/2014/multithreading/lightweight_mutex_assembly.png 'lightweight_mutex_assembly' %}

### 增强Mutex支持递归

上面简单的lightweight mutex的局限性是它不能递归.也就是同一个线程试图获
取同样的锁两次以上,将造成死锁(deadlock).递归锁在函数调用自己时很有用.比
如在内存管理代码中,可能会遇到如下代码:

``` c++
Realloc(void* ptr, size_t size)
{
    LOCK;

    if (ptr == NULL)
    {
        return Alloc(size);
    }
    else if (size == 0)
    {
        Free(size);
        return NULL;
    }
    else
        ...
}

Alloc(size_t size)
{
    LOCK;

    ...
}
```

`Lock`是个封装好的C++宏,用来获取锁和自动结果当退出函数.

可以看到,当传递`NULL`给`Realloc`,锁被`Realloc`函数获取,然后第二次被获
取当`Alloc`被调用.

把它扩展成可递归的锁如下,加入2个新成员变量,`owner_`,存储当前占有线程的
ID(TID),和`recursion_`,存储递归的层数.基本代码如下:

``` c++
 #include <semaphore.h>
 #include <pthread.h>
 #define LIGHT_ASSERT(x) { if (!(x)) __builtin_trap(); }

class RecursiveBenaphore {
 public:
  RecursiveBenaphore() : counter_(0), owner_(0), recursion_(0) {
    sem_init(&semaphore_, 0, 0);
  }
  ~RecursiveBenaphore() {
    sem_destroy(&semaphore_);
  }
  void Lock() {
    pthread_t thread_id = pthread_self();
    if (__sync_add_and_fetch(&counter_, 1) > 1) {
      if (!pthread_equal(thread_id, owner_)) {
        sem_wait(&semaphore_);
      }
    }
    owner_ = thread_id;
    recursion_++;
  }
  void Unlock() {
    pthread_t thread_id = pthread_self();
    LIGHT_ASSERT(pthread_equal(thread_id, owner_));
    long recur = --recursion_;
    if (recur == 0) {
      owner_ = 0;
    }
    long result = __sync_sub_and_fetch(&counter_, 1);
    if (result > 0) {
      if (recur == 0) {
        int sem_value;
        sem_getvalue(&semaphore_, &sem_value);
        if (sem_value == 0) {
          sem_post(&semaphore_);
        }
      }
    }
  }
  bool TryLock() {
    pthread_t thread_id = pthread_self();
    if (pthread_equal(thread_id, owner_)) {
      __sync_add_and_fetch(&counter_, 1);
    } else {
      bool result = __sync_bool_compare_and_swap(&counter_, 0, 1);
      if (result == false) {
        return false;
      }
      owner_ = thread_id;
    }
    recursion_++;
    return true;
  }

 private:
  long counter_;
  sem_t semaphore_;
  pthread_t owner_;
  long recursion_;
};
```

如之前一样,第一个线程调用`Lock`,设置`owner_`为自己的TID,增加
`recursion_`到1.如果同一个线程再次调用`Lock`,它将同时增加
`recursion_`和`counter_`.


之后,第一个线程完成自己的操作,调用`Unlock`,同时减少`recursion_`和`counter_`,
仅仅调用`sem_post`唤醒其他线程当`recursion_`减少到`0`.如果
`recursion_`仍然大于0,意味着当前的线程仍然占有此锁在外层程序.

最后进行**压力测试**,建立一些线程,每个随机获取锁,随机的递归层次.代码在
[Github上](https://github.com/shishougang/blog_multithreading/tree/master/benaphore_mutex).

一些细节问题:
* 在`Unlock`中,设置`owner_`为0在调用`__sync_sub_and_fetch`之前,否则可
  能发生死锁(deadlock).比如,有两个线程TID是111和222.
    1. 线程111完成操作调用`Unlock`,先调用`__sync_sub_and_fetch`把`counter_`减到0
    2. 在设置`owner_`为0被中断,线程222得到运行,它调用`Lock`,发现`counter_`为0,跳过`sem_wait`,设置`owner_=222`,完成`Lock`操作.
    3. 线程222被中断调出,线程111重新得到运行,设置`owner_`为0,然后完成`Unlock`操作.
    4. 因为此时`owner_`为0,线程222不能在递归占用锁,一旦它再次获取锁,形成死锁.

* 在`Unlock`中,`recursion_`被拷贝到本地变量一次,之后只本地变量,比如没
  有在`__sync_sub_and_fetch`之后重新读取她.因为在那之后它能被其他线程
  已经改变. 

* `recursion_`和`owner_`没有原子操作.因为它们在调用`Lock`的
  `__sync_add_and_fetch`和调用`Unlock`的`__sync_sub_and_fetch`之间,线
  程占有锁,独占`recursion_`和`owner_`的读写操作,并拥有所有的acquire
  and release semantics.对`recursion_`和`owner_`使用原子操作没必要.因
  为在X86/84的平台上,`__sync_add_and_fetch`生成`lock xadd`的指令,保证
  全部的memory barrier,也就保证acquire and release semantics.

## Mutex VS Spinlock

提到Mutex,往往会提到Spinlock,因为在使用Lock时,会遇到如何在Mutex与Spinlock之
间选择.那么接下来对比一下两者.

### 定义

Mutex: 如果一个线程试图获取一个mutex,但是没有成功,因为mutex已经被占用,
它将进入睡眠,让其他进程运行,直到mutex被其他进程释放.

Spinlock: 如果一个线程试图获取一个Spinlock, 但是没有成功,它将持续试着
去获取它,直到它最终成功获取,因为它将不允许其他线程运行(然而,操作系统将
强制调度其他线程).

### 各自缺点

Mutex: Mutex将使得线程睡眠,然后再唤醒它们,两者都是开销比较大的操作,也
就是context switch的开销.如果锁只是被其他线程占用非常短的时间,那么时间
花在使的线程睡眠并唤醒它可能超过它使用spinlock持续获取锁的时间.

Spinlock: Spinlock持续获取锁,浪费很多CPU时间,如果锁被其他线程占用很长
时间,那么它将浪费很多时间,不如使得线程进入睡眠,让出CPU.[Spinlock的确能优化context switches](http://jfdube.wordpress.com/2011/09/24/lessons-learnt-while-spinning/)
但会在没有
[threads priority inversion](http://en.wikipedia.org/wiki/Priority_inversion)
的平台上产生副作用.(但一个高优先级的线程自旋一个锁来等待一个低优先级的
线程释放这个锁,就会造成死锁).在没有Preemption的Uniprocessor,使用
spinlock是没有意义的,当前只有一个线程运行,没有必要保护关键区域,也没有其他线程同时运行,释放锁
给它.

所以在Linux下,Spinlock在kernel这样实现:

* 没有打开`CONFIG_SMP`和`CONFIG_PREEMPT`,spinlock实现代码是空的.
* 没有打开`CONFIG_SMP`,打开`CONFIG_PREEMPT`,spinlock仅仅是简单的关闭
  preemption,足够来防止任何的
  [races](http://en.wikipedia.org/wiki/Race_condition). 
* 打开`CONFIG_SMP`,打开`CONFIG_PREEMPT`,spinlock实现如下代码,不断检查
  lock是否被其他线程释放: 

``` c
  extern inline void spin_lock(spinlock_t *plock)
  {
    __asm__ __volatile__(
        spin_lock_string
        :"=m" (__dummy_lock(plock)));
  }
  // Macro spin_lock_string expand
  extern inline void spin_lock(spinlock_t *plock)
 {
  1:
    lock ; btsl ,plock;
    jc 2f;
    .section .text.lock,"ax"
  2: 
    testb ,plock;
    rep;nop;
    jne 2b;
    jmp 1b;
    .previous
 }
```

### 总结

| Criteria     | Muutex                                                       | Spinlock                                                           |
|--------------+--------------------------------------------------------------+--------------------------------------------------------------------|
| 机制         | 尝试获取锁.若可得到就占有.若不能,就进入睡眠等待.             | 尝试获取锁.若可得到就占有.若不能,持续尝试直到获取.                 |
| 什么时候使用 | 当线程进入睡眠没有伤害.或需要等待一段足够长的时间才能获取锁. | 当线程不应该进入睡眠如中断处理等.当只需等待非常短的时间就能获取锁. |
| 缺点         | 引起context switch和scheduling开销.                          | 线程不做任何事情在获取到锁前.浪费CPU运行.                          |

[大多数操作系统(包括Solaris,Mac OS X和FreeBSD)使用混合的机制叫"adaptive mutex"或"hybrid mutex"](http://en.wikipedia.org/wiki/Spinlock#Alternatives).一
个hybrid mutex首先行为和spinlock一样,如果不能获取锁,持续尝试获取,但过
了一定的时间,它就和mutex一样,让线程进入睡眠.[^f1].



[^f1]: http://stackoverflow.com/questions/5869825/when-should-one-use-a-spinlock-instead-of-mutex

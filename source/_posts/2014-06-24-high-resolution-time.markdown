---
layout: post
title: "High Resolution Time"
date: 2014-06-24 20:19:36 +0800
comments: true
categories: [C++]
tags: [C++, Time]
keywords: "C++, Time, High Resolution Time"
description: "Compare different Time to determine the high resolution time in different platform"
---

在不同的平台有繁多的Time API，如何选用精准的高精度Time函数来做
performance benchmarking呢？

## Wall-clock time VS CPU time
先理解一些时间的概念。明白不同时间API测量的是什么时间。

[Wall-clock time](http://en.wikipedia.org/wiki/Wall-clock_time),顾名思
义，墙上的钟，代表一个任务从开始到完成所经历的时间。它包含3部分：CPU的
时间，I/O的时间和通信延迟的时间。但wall-clock很少是正确的时钟来使用，
因为它随着时区，和daylightsaving改变，或与NTP同步。而这些特性没有一个
是有益的，如果你用它来调度任务或做performance benchmarking。它仅仅如名
字所言，墙上的一个时钟。

[CPU time](http://en.wikipedia.org/wiki/CPU_time)仅仅统计一个任务从开
始到完成在CPU上所花的时间。CPU time主要包括User time（在user space所花
时间）和System time（在kernel space所花时间）。

以并行程序为例，CPU time就是所有CPU在这个程序所花的时间总和，
Wall-clock time在这种情况可能时间相对短，它只统计任务开始到结束所花时
间。

<!-- more -->

## 不同时钟API对比[^f1]
对于不同的时钟API,主要分析如下特性：

1. API测试的是什么时间？（real, user, system，CPU or wall-clock)
2. API的精度？(s, ms, µs, or faster?)
3. 多久时间这个时钟数字会返转？或有什么策略避免它？
4. 时钟是monotonic的，还是它会随着系统时间改变（比如NTP，time zone，
daylight saving time, by the user, etc)?

Linux和OS X的主要时钟API：

* [time()](http://linux.die.net/man/2/time)返回系统的wall-clock，精度
  到秒。
* [clock()](http://linux.die.net/man/3/clock)返回user和systime总共的时
  间.现在标准要求`CLOCKS_PER_SEC`是`1000000`,使精度最多达到
  1µs.`clock_t`类型平台相关(The range and precision of times
  representable in clock_t and time_t are implementation-defined.) 它
  wrap around一旦达到最大值.(通常是32位的类型,那么~2^32 ticks后,还是比
  较长的时间.)
* [clock_gettime(CLOCK_MONOTONIC,..)](http://linux.die.net/man/3/clock_gettime)
  提供纳秒级的精确度并且是单调的.它的秒和纳秒是分开存储的,所以,任何的
  wrap around将很多年才发生一次.它是个不错的时钟,但OS X平台上没有.
* [getrusage](http://linux.die.net/man/2/getrusage)返回独立的user和
  system时间,并且不会wrap around.精确达到1 µs,
* [gettimeofday](http://linux.die.net/man/2/gettimeofday)返回一个
  wall-clock时间并达到µs精度.但是精度不能保证,因为[依赖于硬件](http://www.lehman.cuny.edu/cgi-bin/man-cgi?gettimeofday+3).
* [mach_absolute_time()](https://developer.apple.com/library/mac/qa/qa1398/_index.html)
  是OS X平台的高精度(ns)计时的一个选择.ns以64位unsigned integer存储,实
  际使用wrap around不是大问题,移植性是问题.

Window的高精度时钟：

[QueryPerformanceFrequency()](http://msdn.microsoft.com/en-us/library/ms644905(VS.85).aspx)
和
[QueryPerformanceCounter()](http://msdn.microsoft.com/en-us/library/ms644904(v=VS.85).aspx).
QueryPerformanceFrequency() 返回计数的频率,QueryPerformanceCounter()返
回当前计数值.和Linux中CLOCK_MONOTONIC一样,它是一个稳定并单调递增计数器,精
准达到纳秒级,并且不会wrap around.

更多参考:

* [gettimeofday() should never be used to measure time](https://blog.habets.se/2010/09/gettimeofday-should-never-be-used-to-measure-time)
* [High-performance Timing on Linux / Windows](http://tdistler.com/2010/06/27/high-performance-timing-on-linux-windows)

## 不同平台High Resolution Time

### Linux
使用
[clock_gettime(CLOCK_MONOTONIC,..)](http://linux.die.net/man/3/clock_gettime)
作为High Resolution Time,编译需加上参数`-lrt`,实例代码如下:

``` c clock_gettime.c
#include <time.h>
#include <stdio.h>

void GetMonotonicTime(struct timespec *ts) {
  clock_gettime(CLOCK_MONOTONIC, ts);
}

double GetElapsedTime(struct timespec *before, struct timespec *after) {
  double delta_s = after->tv_sec - before->tv_sec;
  double delta_ns = after->tv_nsec - before->tv_nsec;
  return delta_s * 1e9 + delta_ns;
}

int main(int argc, char *argv[]) {
  struct timespec before, after;
  GetMonotonicTime(&before);
  double sum = 0.0;
  unsigned int i;
  for (i = 1; i < 100; ++i) {
    sum += 1.0 / i;
  }
  GetMonotonicTime(&after);
  printf("the elapsed time=%e ns\n", GetElapsedTime(&before, &after));
  return 0;
}
```

除了`clock_gettime()`高精度时钟外,还有相对应的高精度的睡眠函数
[clock_nanosleep](http://pubs.opengroup.org/onlinepubs/000095399/functions/clock_nanosleep.html),
实例代码如下:

``` c clock_nanosleep.c
#include <time.h>

int main(int argc, char *argv[])
{
  struct timespec sleep_time;
  sleep_time.tv_sec = 0;
  sleep_time.tv_nsec = 100;
  clock_nanosleep(CLOCK_REALTIME, 0, &sleep_time, NULL);
  return 0;
}
```

### OS X

### 使用`clock_get_time`
``` c clock_get_time.c
#include <time.h>
#include <stdio.h>
#include <mach/clock.h>
#include <mach/mach.h>

void GetMonotonicTime(struct timespec *ts) {
  clock_serv_t cclock;
  mach_timespec_t mts;
  host_get_clock_service(mach_host_self(), SYSTEM_CLOCK, &cclock);
  clock_get_time(cclock, &mts);
  mach_port_deallocate(mach_task_self(), cclock);
  ts->tv_sec = mts.tv_sec;
  ts->tv_nsec = mts.tv_nsec;
}

double GetElapsedTime(struct timespec *before, struct timespec *after) {
  double delta_s = after->tv_sec - before->tv_sec;
  double delta_ns = after->tv_nsec - before->tv_nsec;
  return delta_s * 1e9 + delta_ns;
}

int main(int argc, char *argv[]) {
  struct timespec before, after;
  GetMonotonicTime(&before);
  double sum = 0.0;
  unsigned int i;
  for (i = 1; i < 100; ++i) {
    sum += 1.0 / i;
  }
  GetMonotonicTime(&after);
  printf("the elapsed time=%e ns\n", GetElapsedTime(&before, &after));
  return 0;
}
```

### 使用`mach_absolute_time`
``` c mach_absolute_time.c
int main(int argc, char *argv[]) {
    uint64_t        start;
    uint64_t        end;
    uint64_t        elapsed;
    Nanoseconds     elapsedNano;
    start = mach_absolute_time();
    double sum = 0.0;
    unsigned int i;
    for (i = 1; i < 100; ++i) {
        sum += 1.0 / i;
    }
    end = mach_absolute_time();
    elapsed = end - start;
    // Convert to nanoseconds
    elapsedNano = AbsoluteToNanoseconds( *(AbsoluteTime *) &elapsed );
}
```

### Windows
``` c++ query_performance.cc
#include <iostream>
#include <windows.h> 
using namespace std;

int main()
{
    LARGE_INTEGER frequency;
    LARGE_INTEGER start, end;
    double elapsedTime;

    // get ticks per second
    QueryPerformanceFrequency(&frequency);

    QueryPerformanceCounter(&start);

    //do someting
    double sum = 0.0;
    unsigned int i;
    for (i = 1; i < 100; ++i) {
        sum += 1.0 / i;
    }

    QueryPerformanceCounter(&end);

    // compute and print the elapsed time in millisec
    elapsedTime = (end.QuadPart - start.QuadPart) * 1000.0 / frequency.QuadPart;
    cout << elapsedTime << " ms.\n";
    return 0;
}
```


[^f1]: http://stackoverflow.com/questions/12392278/measure-time-in-linux-getrusage-vs-clock-gettime-vs-clock-vs-gettimeofday

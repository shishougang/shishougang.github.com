---
layout: post
title: "浅谈C++11 multithreading programming"
date: 2014-08-25
comments: true
categories: [C++, Multithreading]
tags: [C++, Multithreading]
keywords: "Multithreading, C++, C++11, process, thread, mutex, condition, future, promise, async, lock"
description: "浅谈C++11 multithreading programming"
---

<div id="outline-container-sec-1" class="outline-2">
<h2 id="sec-1">Overview</h2>
<div class="outline-text-2" id="text-1">
<p>
上一篇<a href="http://dreamrunner.org/blog/2014/08/07/C-multithreading-programming/">浅谈C++ Multithreading Programming</a>主要介绍时下规范好的C++使用
Pthread库和Boost Thread库实现C++多线程编程.这里主要谈谈正在规范的C++11
引入的Thread库和Atomic库,终于自带的C++库能支持高效并可移植的
Multithreading编程.分为2篇,这里先谈谈C++11的<a href="http://en.cppreference.com/w/cpp/thread">Thread的库</a> (并包含对
<a href="http://en.cppreference.com/w/c/thread">C的支持</a>), 后一篇谈谈
C++11的<a href="http://en.cppreference.com/w/cpp/atomic">Atomic操作的库</a>.
</p>

<p>
<a href="https://en.wikipedia.org/wiki/C++11">C++11</a>(之前被成为C++0x)是编程语言C++最新版本的标准.它由 <a href="https://en.wikipedia.org/wiki/International_Organization_for_Standardization">ISO </a>在2011年8月
12日被批准替代<a href="https://en.wikipedia.org/wiki/C%2B%2B03">C++03</a>. C++11标准正在规范中,从<a href="https://isocpp.org/std/the-standard">ISO页面</a> 可以知道如何获得进行中的草稿:
</p>
<ul class="org-ul">
<li><a href="https://isocpp.org/files/papers/N3690.pdf">下载最新进行的pdf版草稿(N3690)</a>
</li>
<li><a href="https://github.com/cplusplus/draft">从Github获取草稿的源文件</a>
</li>
</ul>

<p>
所以本文:
</p>
<ul class="org-ul">
<li>标准内容主要参考如上的N3690版本的C++11标准.
</li>
<li>使用的编译器是GCC4.8,<a href="https://gcc.gnu.org/gcc-4.8/cxx0x_status.html">关于GCC4.8支持C+11的情况</a>.
</li>
<li>源代码之类主要参考<a href="http://www.cplusplus.com/reference/multithreading/">cplusplus</a> 和 <a href="http://en.cppreference.com/w/">cppreference</a>.
</li>
</ul>

<p>
更多有关C++参考最后的<a href="#reference">其他资料</a>.
</p>

<!-- more -->
</div>
</div>
<div id="outline-container-sec-2" class="outline-2">
<h2 id="sec-2">Compile</h2>
<div class="outline-text-2" id="text-2">
<p>
GCC编译支持C++11,使用编译选项 <code>-std=c++11</code> 或 <code>-std=gnu++11</code>, 前者关闭
GNU扩张支持.并加上 <code>-pthread</code> 选项.
</p>

<div class="org-src-container">

<pre class="src src-sh">g++ program.o -o program -std=c++11 -pthread
</pre>
</div>

<p>
如果漏掉 <code>-phtread</code> 选项,编译能通过,当运行出现如下错误:
</p>
<div class="org-src-container">

<pre class="src src-sh">terminate called after throwing an instance of <span style="color: #ffa07a;">'std::system_error'</span>
  what():  Enable multithreading to use std::thread: Operation not permitted
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-3" class="outline-2">
<h2 id="sec-3">Threads</h2>
<div class="outline-text-2" id="text-3">
</div><div id="outline-container-sec-3-1" class="outline-3">
<h3 id="sec-3-1"><code>&lt;thread&gt;</code> 概要</h3>
<div class="outline-text-3" id="text-3-1">
<p>
头文件是 <code>&lt;thread&gt;</code>, 分为两部分: <code>thread</code> 类和在namespace
<code>this_thread</code> 用来管理当前thread的函数.具体见之后的<a href="#thread_header">Header &lt;thread&gt; synopsis</a>.
</p>
</div>
</div>
<div id="outline-container-sec-3-2" class="outline-3">
<h3 id="sec-3-2"><code>thread::id</code> 类</h3>
<div class="outline-text-3" id="text-3-2">
<p>
<code>thread::id</code> 类型的对象为每个执行的线程提供唯一的标识,并为所有并不表示线程执行(默认构造的线程对象)的所有线程对象提供一个唯一的值.
</p>

<p>
<code>thread::id</code> 类没有特别的东西,主要提供方便比较或打印等运算符重载.
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> {
 <span style="color: #00ffff;">public</span>:
  id() noexcept;
};
<span style="color: #98fb98;">bool</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">==</span>(<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">x</span>, <span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #98fb98;">bool</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">!=</span>(<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">x</span>, <span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #98fb98;">bool</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">&lt;</span>(<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">x</span>, <span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #98fb98;">bool</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">&lt;=</span>(<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">x</span>, <span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #98fb98;">bool</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">&gt;</span>(<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">x</span>, <span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #98fb98;">bool</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">&gt;=</span>(<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">x</span>, <span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #00ffff;">template</span>&lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">charT</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">traits</span>&gt;
<span style="color: #98fb98;">basic_ostream</span>&lt;<span style="color: #98fb98;">charT</span>, <span style="color: #98fb98;">traits</span>&gt;&amp;
<span style="color: #00ffff;">operator</span><span style="color: #87cefa;">&lt;&lt;</span> (<span style="color: #98fb98;">basic_ostream</span>&lt;<span style="color: #98fb98;">charT</span>, <span style="color: #98fb98;">traits</span>&gt;&amp; <span style="color: #eedd82;">out</span>, <span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">id</span>);
<span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">Hash support</span>
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">T</span>&gt; <span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">hash</span>;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">typename</span> <span style="color: #98fb98;">T</span>&gt; &lt;&gt; <span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">hash</span>&lt;<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span>&gt;;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-3-3" class="outline-3">
<h3 id="sec-3-3"><code>thread</code> 类</h3>
<div class="outline-text-3" id="text-3-3">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">thread</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">types:</span>
  <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">id</span>;
  <span style="color: #00ffff;">typedef</span> <span style="color: #98fb98;">implementation</span>-defined native_handle_type; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">construct/copy/destroy:</span>
  <span style="color: #87cefa;">thread</span>() noexcept;
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">F</span>, <span style="color: #00ffff;">class</span> ...Args&gt; <span style="color: #00ffff;">explicit</span> <span style="color: #87cefa;">thread</span>(<span style="color: #98fb98;">F</span>&amp;&amp; <span style="color: #eedd82;">f</span>, <span style="color: #98fb98;">Args</span>&amp;&amp;... args);
  ~<span style="color: #87cefa;">thread</span>();
  <span style="color: #87cefa;">thread</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">thread</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #87cefa;">thread</span>(<span style="color: #98fb98;">thread</span>&amp;&amp;) noexcept;
  <span style="color: #98fb98;">thread</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">thread</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">thread</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #98fb98;">thread</span>&amp;&amp;) noexcept;
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">members:</span>
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">thread</span>&amp;) noexcept;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">joinable</span>() <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">join</span>();
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">detach</span>();
  <span style="color: #98fb98;">id</span> <span style="color: #87cefa;">get_id</span>() <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
  <span style="color: #98fb98;">native_handle_type</span> <span style="color: #87cefa;">native_handle</span>(); <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">static members:</span>
  <span style="color: #00ffff;">static</span> <span style="color: #98fb98;">unsigned</span> <span style="color: #87cefa;">hardware_concurrency</span>() noexcept;
};
}
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-3-4" class="outline-3">
<h3 id="sec-3-4">Constructs a thread object</h3>
<div class="outline-text-3" id="text-3-4">
<p>
从如上的 <code>thread</code> 类知道, 构造thread对象:
</p>
<ol class="org-ol">
<li>默认构造构造一个线程对象,但并不代表任何执行线程.
</li>
<li>移动构造从其他线程构造一个thread对象,并设置其他线程为默认构造状态.
</li>
<li>初始化构造创建一个新的thread对象并把它与执行线程相关联.复制/移动所有参数
<code>args..</code> 到thread可访问的内存通过如下函数:
</li>
</ol>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">T</span>&gt;
<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">decay</span>&lt;<span style="color: #98fb98;">T</span>&gt;::<span style="color: #98fb98;">type</span> <span style="color: #87cefa;">decay_copy</span>(<span style="color: #98fb98;">T</span>&amp;&amp; <span style="color: #eedd82;">v</span>) {
    <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">forward</span>&lt;<span style="color: #98fb98;">T</span>&gt;(<span style="color: #eedd82;">v</span>);
}
</pre>
</div>
<p>
求值和复制/移动参数过程丢出的任何exceptions仅在当前线程丢出,不在新线程中.
</p>
<ol class="org-ol">
<li>复制构造复制构造被删除.线程不可被复制.
</li>
</ol>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;utility&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;functional&gt;</span>

<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">cout</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">endl</span>;

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Thread1Fun</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">n</span>) {
  <span style="color: #00ffff;">for</span> (<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span> = 0; i &lt; n; ++i) {
    cout &lt;&lt; <span style="color: #ffa07a;">"Thread 1 executing"</span> &lt;&lt; endl;
  }
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Thread2Fun</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">int</span>&amp; <span style="color: #eedd82;">n</span>) {
  <span style="color: #00ffff;">for</span> (<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span> = 0; i &lt; n; ++i) {
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"Thread 2 executing\n"</span>;
  }
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">kLoops</span> = 5;
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t1</span>;  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">t1 is not a thread</span>
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t2</span>(Thread1Fun, kLoops + 1);  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">pass by value</span>
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t3</span>(Thread2Fun, <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">ref</span>(<span style="color: #eedd82;">kLoops</span>));  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">pass by reference</span>
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t4</span>(<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">move</span>(<span style="color: #eedd82;">t3</span>));
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">t4 is now running f2(). t3 is no longer a thread</span>
  t2.join();
  t4.join();
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-3-5" class="outline-3">
<h3 id="sec-3-5">joinable</h3>
<div class="outline-text-3" id="text-3-5">
<p>
用来检查一个线程对象是否是正在执行的线程.若是,返回 <code>true</code>. 所以默认构造thread对象是不可joinable.
</p>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;chrono&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">cout</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">endl</span>;

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">ThreadFun</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::sleep_for(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::seconds(1));
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t</span>;
  cout &lt;&lt; <span style="color: #ffa07a;">"default construct, joinable: "</span> &lt;&lt; t.joinable() &lt;&lt; endl;

  t = <span style="color: #7fffd4;">std</span>::thread(ThreadFun);
  cout &lt;&lt; <span style="color: #ffa07a;">"initial construct, joinable: "</span> &lt;&lt; t.joinable() &lt;&lt; endl;
  t.join();
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>

<p>
结果:
</p>
<div class="org-src-container">

<pre class="src src-sh">default construct, joinable: 0
initial construct, joinable: 1
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-3-6" class="outline-3">
<h3 id="sec-3-6"><code>get_id</code></h3>
<div class="outline-text-3" id="text-3-6">
<p>
返回thread对象的 <code>std::thread::id</code> 值.
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;chrono&gt;</span>

<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">cout</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">endl</span>;

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">ThreadFun</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::sleep_for(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::seconds(1));
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t1</span>(ThreadFun);
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">id_t1</span> = t1.get_id();
  cout &lt;&lt; <span style="color: #ffa07a;">"thread1's id: "</span> &lt;&lt; id_t1 &lt;&lt; endl;
  t1.join();
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-3-7" class="outline-3">
<h3 id="sec-3-7"><code>native_handle</code></h3>
<div class="outline-text-3" id="text-3-7">
<p>
这个函数是implementation-defined. 它允许提供底层实现细节的访问.但实际使用它是non-portable. 
</p>

<p>
实例: 使用 <code>native_handle</code> 打开在POSIX系统上C++线程的实时调度.
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;pthread.h&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;mutex&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;chrono&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;cstring&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">cout</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">endl</span>;

<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span> <span style="color: #eedd82;">iomutex</span>;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">ThreadFun</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">thread_id</span>) {
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::sleep_for(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::seconds(1));
  <span style="color: #98fb98;">sched_param</span> <span style="color: #eedd82;">sch</span>;
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">policy</span>;
  pthread_getschedparam(pthread_self(), &amp;policy, &amp;sch);
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">lock_guard</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span>&gt; <span style="color: #eedd82;">lk</span>(iomutex);
  cout &lt;&lt; <span style="color: #ffa07a;">"Thread "</span> &lt;&lt; thread_id &lt;&lt; <span style="color: #ffa07a;">" is executing at priority "</span>
       &lt;&lt; sch.sched_priority &lt;&lt; endl;
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t1</span>(ThreadFun, 1), <span style="color: #eedd82;">t2</span>(ThreadFun, 2);
  <span style="color: #98fb98;">sched_param</span> <span style="color: #eedd82;">sch</span>;
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">policy</span>;
  pthread_getschedparam(t1.native_handle(), &amp;policy, &amp;sch);
  sch.sched_priority = 20;
  <span style="color: #00ffff;">if</span> (pthread_setschedparam(t1.native_handle(), SCHED_FIFO, &amp;sch)) {
    cout &lt;&lt; <span style="color: #ffa07a;">"Failed to setschedparam: "</span> &lt;&lt; <span style="color: #7fffd4;">std</span>::strerror(errno) &lt;&lt; endl;
  }
  t1.join();
  t2.join();
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>

<p>
暂时GCC4.8不支持,结果:
</p>
<div class="org-src-container">

<pre class="src src-sh">Failed to setschedparam: Operation not permitted
Thread 1 is executing at priority 0
Thread 2 is executing at priority 0
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-3-8" class="outline-3">
<h3 id="sec-3-8"><code>hardware_concurrency</code> (static)</h3>
<div class="outline-text-3" id="text-3-8">
<p>
返回硬件支持的thread数.这个值仅作为参考.如果这个值不可计算或没有很多的定义,那么实现返回0.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
    <span style="color: #98fb98;">unsigned</span> <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">num</span> = <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">thread</span>::hardware_concurrency();
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; num &lt;&lt; <span style="color: #ffa07a;">" concurrent threads are supported."</span> &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-3-9" class="outline-3">
<h3 id="sec-3-9">swap</h3>
<div class="outline-text-3" id="text-3-9">
<p>
<code>swap</code> 操作用来交换2个线程对象的底层句柄.有2种可选,thread类的成员函数和在std下的全局函数.
</p>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;chrono&gt;</span>

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Thread1Fun</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::sleep_for(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::seconds(1));
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Thread2Fun</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::sleep_for(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::seconds(1));
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t1</span>(Thread1Fun);
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t2</span>(Thread2Fun);
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"thread 1 id: "</span> &lt;&lt; t1.get_id() &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"thread 2 id: "</span> &lt;&lt; t2.get_id() &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;

    <span style="color: #7fffd4;">std</span>::swap(t1, t2);
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"after std::swap(t1, t2):"</span> &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"thread 1 id: "</span> &lt;&lt; t1.get_id() &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"thread 2 id: "</span> &lt;&lt; t2.get_id() &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;

    t1.swap(t2);
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"after t1.swap(t2):"</span> &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"thread 1 id: "</span> &lt;&lt; t1.get_id() &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"thread 2 id: "</span> &lt;&lt; t2.get_id() &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;
    t1.join();
    t2.join();
    <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-3-10" class="outline-3">
<h3 id="sec-3-10">管理当前thread的函数</h3>
<div class="outline-text-3" id="text-3-10">
<p>
在thread的头文件中,加了一个新的namespace <code>this_thread</code> 用来包含一些管理操作当前thread的一些函数.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">void</span> <span style="color: #87cefa;">yield</span>();
</pre>
</div>
<p>
重新调度线程的执行,让其他线程运行.具体行为依赖于实现,与OS的调度机制有关.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #87cefa;">get_id</span>();
</pre>
</div>
<p>
返回当前线程的 <code>thread::id</code> 类型的对象.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">template</span>&lt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span> &gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">sleep_for</span>( <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">sleep_duration</span> );
</pre>
</div>
<p>
阻塞当前线程的执行至少相对时间 <code>sleep_duration</code>.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">template</span>&lt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span> &gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">sleep_until</span>( <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>,<span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">sleep_time</span> );
</pre>
</div>
<p>
阻塞当前线程的执行直到绝对时间 <code>sleep_time</code> 到达.
</p>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;chrono&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;mutex&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;atomic&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;ctime&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">cout</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">endl</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">system_clock</span>;

<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">bool</span>&gt; <span style="color: #87cefa;">ready</span>(<span style="color: #7fffd4;">false</span>);

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Thread1Fun</span>() {
  <span style="color: #00ffff;">while</span> (!ready) {
    <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::yield();
  }
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">id</span> = <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::get_id();
  cout &lt;&lt; <span style="color: #ffa07a;">"thread "</span> &lt;&lt; id &lt;&lt; <span style="color: #ffa07a;">"go to sleep"</span> &lt;&lt; endl;
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::sleep_for(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::seconds(1));
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Thread2Fun</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #eedd82;">id</span> = <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::get_id();
  cout &lt;&lt; <span style="color: #ffa07a;">"thread "</span> &lt;&lt; id &lt;&lt; <span style="color: #ffa07a;">"is running"</span> &lt;&lt; endl;
  ready = <span style="color: #7fffd4;">true</span>;

  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">time_t</span> <span style="color: #eedd82;">tt</span> = <span style="color: #7fffd4;">system_clock</span>::<span style="color: #98fb98;">to_time_t</span>(<span style="color: #7fffd4;">system_clock</span>::<span style="color: #98fb98;">now</span>());
  <span style="color: #00ffff;">struct</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">tm</span> *<span style="color: #eedd82;">ptm</span> = <span style="color: #7fffd4;">std</span>::localtime(&amp;tt);
  ptm-&gt;tm_sec += 2;
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::sleep_until(<span style="color: #7fffd4;">system_clock</span>::<span style="color: #98fb98;">from_time_t</span>(<span style="color: #eedd82;">mktime</span>(ptm)));
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t1</span>(Thread1Fun);
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t2</span>(Thread2Fun);
  t1.join();
  t2.join();
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>
</div>

<div id="outline-container-sec-4" class="outline-2">
<h2 id="sec-4">Mutual exclusion</h2>
<div class="outline-text-2" id="text-4">
</div><div id="outline-container-sec-4-1" class="outline-3">
<h3 id="sec-4-1"><code>&lt;mutex&gt;</code> 概要</h3>
<div class="outline-text-3" id="text-4-1">
<p>
头文件 <code>&lt;mutex&gt;</code> 分为: mutexes,locks和一些特殊函数. 
具体见之后的<a href="#mutex_header">Header &lt;mutex&gt; synopsis</a>.
</p>

<ul class="org-ul">
<li><b>Mutexes</b> 是<a href="#lockable_types">lockable types</a>,用来对关键区域代码访问保护: <a href="#mutex_class"><code>mutex</code></a>,
  <a href="#recursive_mutex_class"><code>recursive_mutex</code></a>, <a href="#timed_mutex_class"><code>timed_mutex</code></a>, <a href="#recursive_timed_mutex_class"><code>recursive_timed_mutex</code></a>.
</li>
<li><b>Locks</b> 是用来管理mutex的对象,并对mutex的lifetime自我管理:<a href="#lock_guard_class"><code>lock_guard</code></a>, <a href="#unique_lock_class"><code>unique_lock</code></a>.
</li>
<li><b>Functions</b> 可以同时锁多个mutexes(<a href="#try_lock_func"><code>try_lock</code></a>, <a href="#lock_func"><code>lock</code></a>),并使某个函数只被调用一次(<a href="#call_once_func"><code>call_once</code></a>).
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-4-2" class="outline-3">
<h3 id="sec-4-2">Lockable types</h3>
<div class="outline-text-3" id="text-4-2">
<p>
<a id="lockable_types" name="lockable_types"></a>
</p>
{% img /images/blog/2014/c++11/lockable_type.png  'lockable_type' %}

<p>
C++11为mutex定义了不同类型的要求,如上图的层次,往右要求逐渐加强.
</p>
</div>

<div id="outline-container-sec-4-2-1" class="outline-4">
<h4 id="sec-4-2-1">BasicLockable</h4>
<div class="outline-text-4" id="text-4-2-1">
<p>
BasicLockable 概念描述了最少特性类型,也就是满足(若m是BasicLockable类型
):
</p>
<ul class="org-ul">
<li><code>m.lock()</code>
</li>
<li><code>m.unlock()</code>
</li>
</ul>

<p>
所以所有mutex都满足BasicLockable类型: <code>mutex</code>, <code>recursive_mutex</code>,
<code>timed_mutex</code>, <code>recursive_timed_mutex</code>, <code>unique_lock</code>.
</p>
</div>
</div>

<div id="outline-container-sec-4-2-2" class="outline-4">
<h4 id="sec-4-2-2">Lockable</h4>
<div class="outline-text-4" id="text-4-2-2">
<p>
Lockable 概念扩展了 BasicLockable 概念,并支持 <code>try_lock</code>. 
</p>

<p>
所以这些mutex满足Lockable类型: <code>mutex</code>, <code>recursive_mutex</code>,
<code>timed_mutex</code>, <code>recursive_timed_mutex</code>.
</p>
</div>
</div>

<div id="outline-container-sec-4-2-3" class="outline-4">
<h4 id="sec-4-2-3">TimedLockable</h4>
<div class="outline-text-4" id="text-4-2-3">
<p>
TimedLockable 概念扩展了 Lockable 概念,并支持 <code>try_lock_for</code> 和
<code>try_lock_until</code>. 
</p>

<p>
所以这些mutex满足TimedLockable类型: <code>timed_mutex</code>,
<code>recursive_timed_mutex</code>.
</p>
</div>
</div>
</div>
<div id="outline-container-sec-4-3" class="outline-3">
<h3 id="sec-4-3"><code>mutex</code> 类</h3>
<div class="outline-text-3" id="text-4-3">
<p>
<a id="mutex_class" name="mutex_class"></a>
<code>mutex</code> 类提供了一个不可递归的排它锁.基本接口可以从如下类中参考.
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">mutex</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #98fb98;">constexpr</span> <span style="color: #87cefa;">mutex</span>() noexcept;
  ~<span style="color: #87cefa;">mutex</span>();
  <span style="color: #87cefa;">mutex</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">mutex</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">mutex</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">mutex</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">lock</span>();
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock</span>();
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">unlock</span>();
  <span style="color: #00ffff;">typedef</span> <span style="color: #98fb98;">implementation</span>-defined native_handle_type; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
  <span style="color: #98fb98;">native_handle_type</span> <span style="color: #87cefa;">native_handle</span>(); <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
};
}
</pre>
</div>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;vector&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;mutex&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">cout</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">endl</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">vector</span>;

<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">g_value</span> = 0;
<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span> <span style="color: #eedd82;">count_mutex</span>;

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Increase</span>() {
  <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">kLoops</span> = 100;
  <span style="color: #00ffff;">for</span> (<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span> = 0; i &lt; kLoops; ++i) {
    count_mutex.lock();
    g_value++;
    count_mutex.unlock();
  }
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">argc</span>, <span style="color: #98fb98;">char</span> *<span style="color: #eedd82;">argv</span>[]) {
  <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">kNumThreads</span> = 5;
  <span style="color: #98fb98;">vector</span>&lt;<span style="color: #7fffd4;">std</span>::thread&gt; <span style="color: #eedd82;">threads</span>;
  <span style="color: #00ffff;">for</span> (<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span> = 0; i &lt; kNumThreads; ++i) {
    threads.push_back(<span style="color: #7fffd4;">std</span>::thread(Increase));
  }
  <span style="color: #00ffff;">for</span> (<span style="color: #00ffff;">auto</span> &amp;<span style="color: #eedd82;">thread</span> : threads) {
    thread.join();
  }
  cout &lt;&lt; <span style="color: #ffa07a;">"value = "</span> &lt;&lt; g_value &lt;&lt; endl;
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-4-4" class="outline-3">
<h3 id="sec-4-4"><code>recursive_mutex</code> 类</h3>
<div class="outline-text-3" id="text-4-4">
<p>
<a id="recursive_mutex_class" name="recursive_mutex_class"></a>可递归的排它锁.如下基本接口如 <code>mutex</code> 基本一样.
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">recursive_mutex</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #87cefa;">recursive_mutex</span>();
  ~<span style="color: #87cefa;">recursive_mutex</span>();
  <span style="color: #87cefa;">recursive_mutex</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">recursive_mutex</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">recursive_mutex</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">recursive_mutex</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">lock</span>();
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock</span>() noexcept;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">unlock</span>();
  <span style="color: #00ffff;">typedef</span> <span style="color: #98fb98;">implementation</span>-defined native_handle_type; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
  <span style="color: #98fb98;">native_handle_type</span> <span style="color: #87cefa;">native_handle</span>(); <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
};
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-4-5" class="outline-3">
<h3 id="sec-4-5"><code>timed_mutex</code> 类</h3>
<div class="outline-text-3" id="text-4-5">
<p>
<a id="timed_mutex_class" name="timed_mutex_class"></a>
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">timed_mutex</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #87cefa;">timed_mutex</span>();
  ~<span style="color: #87cefa;">timed_mutex</span>();
  <span style="color: #87cefa;">timed_mutex</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">timed_mutex</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">timed_mutex</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">timed_mutex</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">lock</span>();
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock</span>();
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>&gt;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock_for</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>&gt;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock_until</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>);
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">unlock</span>();
  <span style="color: #00ffff;">typedef</span> <span style="color: #98fb98;">implementation</span>-defined native_handle_type; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
  <span style="color: #98fb98;">native_handle_type</span> <span style="color: #87cefa;">native_handle</span>(); <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
};
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-4-6" class="outline-3">
<h3 id="sec-4-6"><code>recursive_timed_mutex</code> 类</h3>
<div class="outline-text-3" id="text-4-6">
<p>
<a id="recursive_timed_mutex_class" name="recursive_timed_mutex_class"></a>
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">recursive_timed_mutex</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #87cefa;">recursive_timed_mutex</span>();
  ~<span style="color: #87cefa;">recursive_timed_mutex</span>();
  <span style="color: #87cefa;">recursive_timed_mutex</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">recursive_timed_mutex</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">recursive_timed_mutex</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">recursive_timed_mutex</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">lock</span>();
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock</span>() noexcept;
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>&gt;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock_for</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>&gt;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock_until</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>);
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">unlock</span>();
  <span style="color: #00ffff;">typedef</span> <span style="color: #98fb98;">implementation</span>-defined native_handle_type; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
  <span style="color: #98fb98;">native_handle_type</span> <span style="color: #87cefa;">native_handle</span>(); <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
};
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-4-7" class="outline-3">
<h3 id="sec-4-7">Mutex Exception safety</h3>
<div class="outline-text-3" id="text-4-7">
<p>
基本保证: 当exception被以上 mutex 的成员函数抛出时,这些mutex对象保持有效状态. 如果是 <code>lock</code> 操作被exception, lock不会被抛出exception的线程所拥有.
</p>

<p>
抛出的是一个 <code>system_error</code> exception, 导致的基本情况是:
</p>
<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="left" />

<col  class="left" />

<col  class="left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="left">exception 类型</th>
<th scope="col" class="left">error情况</th>
<th scope="col" class="left">描述</th>
</tr>
</thead>
<tbody>
<tr>
<td class="left"><code>system_error</code></td>
<td class="left"><code>errc::resource_deadlock_would_occur</code></td>
<td class="left">deadlock被检测到</td>
</tr>

<tr>
<td class="left"><code>system_error</code></td>
<td class="left"><code>errc::operation_not_permitted</code></td>
<td class="left">线程没有权利做这个操作</td>
</tr>

<tr>
<td class="left"><code>system_error</code></td>
<td class="left"><code>errc::device_or_resource_busy</code></td>
<td class="left">native handle已经被锁</td>
</tr>
</tbody>
</table>
</div>
</div>
<div id="outline-container-sec-4-8" class="outline-3">
<h3 id="sec-4-8"><code>lock_guard</code> 类</h3>
<div class="outline-text-3" id="text-4-8">
<p>
<a id="lock_guard_class" name="lock_guard_class"></a>
</p>

<p>
之前的mutex必须写明lock和unlock调用,如果在lock和unlock之间产生
exception,那么必须在exception处理中不能忘记处理unlock.当只是在一个关键区域内需要mutex保护,使用这样的mutex既不方便也容易忘记unlock而造成死锁.
</p>

<p>
引入对之前的mutex的封装后的 <code>lock_guard</code> 和 <code>unique_lock</code> ,提供易用性的 <a href="http://en.wikipedia.com/wiki/Resource_Acquisition_Is_Initialization">RAII-style</a> 机制来获取锁在一段区域内.
</p>

<p>
lock guard 是一个用来管理一个 mutex 对象,并保持锁住它的对象.
</p>

<p>
在构造时,mutex 对象被调用的线程锁住,然后在析构时,mutex 被解锁.它是最简单的lock,并且作为自动作用范围直到它的作用区域结束时特别有用.通过这种方法,它保证 mutex 对象得到解锁即使在exception被抛出时.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Mutex</span>&gt;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">lock_guard</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #00ffff;">typedef</span> <span style="color: #98fb98;">Mutex</span> <span style="color: #98fb98;">mutex_type</span>;
  <span style="color: #00ffff;">explicit</span> <span style="color: #87cefa;">lock_guard</span>(<span style="color: #98fb98;">mutex_type</span>&amp; <span style="color: #eedd82;">m</span>);
  <span style="color: #87cefa;">lock_guard</span>(<span style="color: #98fb98;">mutex_type</span>&amp; <span style="color: #eedd82;">m</span>, <span style="color: #98fb98;">adopt_lock_t</span>);
  ~<span style="color: #87cefa;">lock_guard</span>();
  <span style="color: #87cefa;">lock_guard</span>(<span style="color: #98fb98;">lock_guard</span> <span style="color: #00ffff;">const</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">lock_guard</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #98fb98;">lock_guard</span> <span style="color: #00ffff;">const</span>&amp;) = <span style="color: #00ffff;">delete</span>;
 <span style="color: #00ffff;">private</span>:
  <span style="color: #98fb98;">mutex_type</span>&amp; <span style="color: #eedd82;">pm</span>; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">exposition only</span>
};
}
</pre>
</div>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;mutex&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;stdexcept&gt;</span>

<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span> <span style="color: #eedd82;">mtx</span>;

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">PrintEven</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">x</span>) {
  <span style="color: #00ffff;">if</span> (x % 2 == 0) {
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; x &lt;&lt; <span style="color: #ffa07a;">" is even\n"</span>;
  } <span style="color: #00ffff;">else</span> {
    <span style="color: #00ffff;">throw</span>(<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">logic_error</span>(<span style="color: #ffa07a;">"not even"</span>));
  }
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">PrintThreadEvenId</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">id</span>) {
  <span style="color: #00ffff;">try</span> {
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">lock_guard</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span>&gt; <span style="color: #eedd82;">lck</span>(mtx);
    PrintEven(id);
  } <span style="color: #00ffff;">catch</span> (<span style="color: #7fffd4;">std</span>::logic_error&amp;) {
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"[exception caught]"</span> &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;
  }
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">threads</span>[10];
  <span style="color: #00ffff;">for</span> (<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span> = 0; i &lt; 10; ++i) {
    threads[i] = <span style="color: #7fffd4;">std</span>::<span style="color: #eedd82;">thread</span>(PrintThreadEvenId, i+1);
  }
  <span style="color: #00ffff;">for</span> (<span style="color: #00ffff;">auto</span>&amp; <span style="color: #eedd82;">th</span> : threads) {
    th.join();
  }
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-4-9" class="outline-3">
<h3 id="sec-4-9"><code>unique_lock</code> 类</h3>
<div class="outline-text-3" id="text-4-9">
<p>
<a id="unique_lock_class" name="unique_lock_class"></a>
</p>

<p>
<code>unique_lock</code> 与上面的 <code>lock_guard</code> 基本差不多,同样是 <a href="http://en.wikipedia.com/wiki/Resource_Acquisition_Is_Initialization">RAII-style</a> 机制来获取锁在一段区域内的对象.
</p>

<p>
但 <code>lock_guard</code> 非常简单,只提供构造自动拥有锁和析构释放锁,如果需要一些其他的操作,那么就需要更复杂和接口更多的类来处理, <code>lock_guard</code> 能满足如此要求. 它类基本接口如下.
</p>
</div>

<div id="outline-container-sec-4-9-1" class="outline-4">
<h4 id="sec-4-9-1">class</h4>
<div class="outline-text-4" id="text-4-9-1">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Mutex</span>&gt;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">unique_lock</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #00ffff;">typedef</span> <span style="color: #98fb98;">Mutex</span> <span style="color: #98fb98;">mutex_type</span>;
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">30.4.2.2.1, construct/copy/destroy:</span>
  <span style="color: #87cefa;">unique_lock</span>() noexcept;
  <span style="color: #00ffff;">explicit</span> <span style="color: #87cefa;">unique_lock</span>(<span style="color: #98fb98;">mutex_type</span>&amp; <span style="color: #eedd82;">m</span>);
  <span style="color: #87cefa;">unique_lock</span>(<span style="color: #98fb98;">mutex_type</span>&amp; <span style="color: #eedd82;">m</span>, <span style="color: #98fb98;">defer_lock_t</span>) noexcept;
  <span style="color: #87cefa;">unique_lock</span>(<span style="color: #98fb98;">mutex_type</span>&amp; <span style="color: #eedd82;">m</span>, <span style="color: #98fb98;">try_to_lock_t</span>);
  <span style="color: #87cefa;">unique_lock</span>(<span style="color: #98fb98;">mutex_type</span>&amp; <span style="color: #eedd82;">m</span>, <span style="color: #98fb98;">adopt_lock_t</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>&gt;
  <span style="color: #87cefa;">unique_lock</span>(<span style="color: #98fb98;">mutex_type</span>&amp; <span style="color: #eedd82;">m</span>, <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>&gt;
  <span style="color: #87cefa;">unique_lock</span>(<span style="color: #98fb98;">mutex_type</span>&amp; <span style="color: #eedd82;">m</span>, <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>);
  ~<span style="color: #87cefa;">unique_lock</span>();
  <span style="color: #87cefa;">unique_lock</span>(<span style="color: #98fb98;">unique_lock</span> <span style="color: #00ffff;">const</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">unique_lock</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #98fb98;">unique_lock</span> <span style="color: #00ffff;">const</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #87cefa;">unique_lock</span>(<span style="color: #98fb98;">unique_lock</span>&amp;&amp; <span style="color: #eedd82;">u</span>) noexcept;
  <span style="color: #98fb98;">unique_lock</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #98fb98;">unique_lock</span>&amp;&amp; u) noexcept;
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">30.4.2.2.2, locking:</span>
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">lock</span>();
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock</span>();
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>&gt;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock_for</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>&gt;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">try_lock_until</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>);
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">unlock</span>();
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">30.4.2.2.3, modifiers:</span>
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">unique_lock</span>&amp; <span style="color: #eedd82;">u</span>) noexcept;
  <span style="color: #98fb98;">mutex_type</span> *<span style="color: #87cefa;">release</span>() noexcept;
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">30.4.2.2.4, observers:</span>
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">owns_lock</span>() <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
  <span style="color: #00ffff;">explicit</span> <span style="color: #00ffff;">operator</span> <span style="color: #98fb98;">bool</span> () <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
  <span style="color: #98fb98;">mutex_type</span>* <span style="color: #87cefa;">mutex</span>() <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
 <span style="color: #00ffff;">private</span>:
  <span style="color: #98fb98;">mutex_type</span> *<span style="color: #eedd82;">pm</span>; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">exposition only</span>
  <span style="color: #98fb98;">bool</span> <span style="color: #eedd82;">owns</span>; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">exposition only</span>
};
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Mutex</span>&gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">unique_lock</span>&lt;<span style="color: #98fb98;">Mutex</span>&gt;&amp; <span style="color: #eedd82;">x</span>, <span style="color: #98fb98;">unique_lock</span>&lt;<span style="color: #98fb98;">Mutex</span>&gt;&amp; <span style="color: #eedd82;">y</span>) noexcept;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-4-9-2" class="outline-4">
<h4 id="sec-4-9-2">Constructor</h4>
<div class="outline-text-4" id="text-4-9-2">
<p>
在<a href="#mutex_header">mutex header概要</a>中可以看到有不同的构造函数,其中一类 <code>unique_lock</code> 构造传入不同的类型:
</p>
<ul class="org-ul">
<li><code>defer_lock</code> : 不去获取mutex,只有要和mutex一样,手动去lock它.
</li>
<li><code>try_to_lock</code> : 相当于在构造时,调用 <code>try_lock</code>, 不阻塞,之后可通过成员函数 <code>bool owns_lock()</code> 或直接操作符 <code>explicit operator bool()
  const</code> 判断是否获取锁成功.
</li>
<li><code>adopt_lock_t</code> : 认为调用的线程已经占有这个锁m.已经占有这个锁了,为什么要去创建一个 <code>unique_lock</code> 去包含它呢? 因为可以利用 <code>unique_lock</code>
中途接手管理这个锁m, 比如想用 <a href="http://en.wikipedia.com/wiki/Resource_Acquisition_Is_Initialization">RAII-style</a> 机制管理它,使它exception
safe等.
</li>
</ul>

<p>
这些类型在源代码定义基本如下:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">defer_lock_t</span> { };
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">try_to_lock_t</span> { };
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">adopt_lock_t</span> { };
constexpr <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">defer_lock_t</span> <span style="color: #eedd82;">defer_lock</span> = <span style="color: #7fffd4;">std</span>::<span style="color: #87cefa;">defer_lock_t</span>();
constexpr <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">try_to_lock_t</span> <span style="color: #eedd82;">try_to_lock</span> = <span style="color: #7fffd4;">std</span>::<span style="color: #87cefa;">try_to_lock_t</span>();
constexpr <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">adopt_lock_t</span> <span style="color: #eedd82;">adopt_lock</span> = <span style="color: #7fffd4;">std</span>::<span style="color: #87cefa;">adopt_lock_t</span>();
</pre>
</div>

<p>
余下的构造:
</p>
<ul class="org-ul">
<li><code>unique_lock();</code> :仅仅创建一个 <code>nique_lock</code> 对象,不和任何mutex相关联.
</li>
<li><code>nique_lock(unique_lock&amp;&amp; other);</code> : 通过other的内容来构造
  <code>nique_lock</code>  对像,使得other不和任何mutex相关连联.
</li>
<li><code>explicit unique_lock(mutex_type&amp; m);</code> : 通过 <code>m.lock()</code> 来构造与m相关联的 <code>unique_lock</code> 对象.
</li>
<li><code>unique_lock(mutex_type&amp; m, const std::chrono::duration&lt;Rep,Period&gt;&amp;
  timeout_duration);</code> : 通过 <code>m.try_lock_for(timeout_duration)</code> 来构造与m相关联的 <code>unique_lock</code> 对象.
</li>
<li><code>unique_lock( mutex_type&amp; m, const
  std::chrono::time_point&lt;Clock,Duration&gt;&amp; timeout_time);</code> : 通过
<code>m.try_lock_until(timeout_time)</code> 来构造与m相关联的 <code>unique_lock</code> 对象.
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-4-9-3" class="outline-4">
<h4 id="sec-4-9-3">实例</h4>
<div class="outline-text-4" id="text-4-9-3">
<p>
利用 <code>defer_lock</code>, 不去获取 mutex, 只创建与它相关联的 <code>unique_lock</code> 对象,之后用 <code>lock()</code> 同时去获取两个锁,防止死锁.
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;mutex&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;chrono&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">cout</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">endl</span>;

<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">Box</span> {
  <span style="color: #00ffff;">explicit</span> <span style="color: #87cefa;">Box</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">num</span>) : num_things{num} {}
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">num_things</span>;
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span> <span style="color: #eedd82;">m</span>;
};

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Transfer</span>(<span style="color: #98fb98;">Box</span> *<span style="color: #eedd82;">from</span>, <span style="color: #98fb98;">Box</span> *<span style="color: #eedd82;">to</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">num</span>) {
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">don't actually take the locks yet</span>
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">unique_lock</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span>&gt; <span style="color: #eedd82;">lock1</span>(from-&gt;m, <span style="color: #7fffd4;">std</span>::defer_lock);
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">unique_lock</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span>&gt; <span style="color: #eedd82;">lock2</span>(to-&gt;m, <span style="color: #7fffd4;">std</span>::defer_lock);
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">lock both unique_locks without deadlock</span>
  <span style="color: #7fffd4;">std</span>::lock(lock1, lock2);
  from-&gt;num_things -= num;
  to-&gt;num_things += num;
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">'from.m' and 'to.m' mutexes unlocked in 'unique_lock' dtors</span>
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #98fb98;">Box</span> <span style="color: #eedd82;">acc1</span>(100);
  <span style="color: #98fb98;">Box</span> <span style="color: #eedd82;">acc2</span>(50);
  cout &lt;&lt; <span style="color: #ffa07a;">"acc1 num = "</span> &lt;&lt; acc1.num_things &lt;&lt;
      <span style="color: #ffa07a;">" ,acc2 num = "</span> &lt;&lt; acc2.num_things &lt;&lt; endl;
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t1</span>(Transfer, &amp;acc1, &amp;acc2, 10);
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t2</span>(Transfer, &amp;acc2, &amp;acc1, 5);
  t1.join();
  t2.join();
  cout &lt;&lt; <span style="color: #ffa07a;">"after transfer: "</span> &lt;&lt; <span style="color: #ffa07a;">"acc1 num = "</span> &lt;&lt; acc1.num_things &lt;&lt;
      <span style="color: #ffa07a;">" ,acc2 num = "</span> &lt;&lt; acc2.num_things &lt;&lt; endl;
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>
</div>

<div id="outline-container-sec-4-10" class="outline-3">
<h3 id="sec-4-10"><code>lock_guard</code> VS <code>unique_lock</code></h3>
<div class="outline-text-3" id="text-4-10">
<p>
<code>lock_guard</code> 和 <code>unique_lock</code> 很大程序上很相似,都是 <a href="http://en.wikipedia.com/wiki/Resource_Acquisition_Is_Initialization">RAII-style</a> 机制来封装一个mutex的锁, <code>lock_guard</code> 可以说是 <code>unique_lock</code> 更严格并拥有限制的接口的版本.
</p>

<p>
如何合适的选择两者的使用呢? 如果 <code>lock_guard</code> 对于情况A足够,那么就使用它. 不仅仅是从效率(efficiency)考虑,更是从想要表达的功能(functionality)
考虑. 使用 <code>lock_guard</code> 不仅避免了不需要的其他接口的开销,更是对读代码者表达它的意图,你将永远都不需要解锁这个guard.
</p>

<p>
所以你先考虑使用 <code>lock_guard</code>, 除非你需要 <code>unique_lock</code> 的功能. 比如
<code>condition_variable</code> 就需要传入一个 <code>unique_lock</code> 对象.
</p>
</div>
</div>

<div id="outline-container-sec-4-11" class="outline-3">
<h3 id="sec-4-11"><code>try_lock</code> 和 <code>lock</code></h3>
<div class="outline-text-3" id="text-4-11">
<p>
<a id="try_lock_func" name="try_lock_func"></a>
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">template</span>&lt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Lockable1</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Lockable2</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">LockableN</span>... &gt;
<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">try_lock</span>(<span style="color: #98fb98;">Lockable1</span>&amp; <span style="color: #eedd82;">lock1</span>, <span style="color: #98fb98;">Lockable2</span>&amp; <span style="color: #eedd82;">lock2</span>, <span style="color: #98fb98;">LockableN</span>&amp; <span style="color: #eedd82;">lockn</span>... );
</pre>
</div>

<p>
按对象lock1, lock2, &#x2026;, lockn 从头到尾的顺序尝试去获取每个锁. 如果某个 <code>try_lock</code> 失败, unlock 所有对象并返回. 返回值:
</p>
<ul class="org-ul">
<li>成功: -1.
</li>
<li>失败: 以0为起始点的获取锁失败的对象次序数(0对于lock1, 1对于lock2, ..).
</li>
</ul>
<p>
<a id="lock_func" name="lock_func"></a>
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">template</span>&lt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Lockable1</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Lockable2</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">LockableN</span>... &gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">lock</span>( <span style="color: #98fb98;">Lockable1</span>&amp; <span style="color: #eedd82;">lock1</span>, <span style="color: #98fb98;">Lockable2</span>&amp; <span style="color: #eedd82;">lock2</span>, <span style="color: #98fb98;">LockableN</span>&amp; <span style="color: #eedd82;">lockn</span>... );
</pre>
</div>

<p>
占有传入的锁lock1, lock2, &#x2026;, lockn,使用 <b>防止死锁算饭</b> 来防止死锁.
</p>

<p>
对于传入对象按照不特定的顺序调用它们的成员函数 <code>lock</code> , <code>try_lock</code>,
<code>unlock</code> ,确保最后所有的锁被获取成功在函数返回时.
</p>
</div>
</div>

<div id="outline-container-sec-4-12" class="outline-3">
<h3 id="sec-4-12"><code>call_once</code></h3>
<div class="outline-text-3" id="text-4-12">
<p>
<a id="call_once_func" name="call_once_func"></a>
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">class</span> <span style="color: #98fb98;">once_flag</span>;
<span style="color: #00ffff;">template</span>&lt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Callable</span>, <span style="color: #00ffff;">class</span>... Args &gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">call_once</span>( <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">once_flag</span>&amp; <span style="color: #eedd82;">flag</span>, <span style="color: #eedd82;">Callable</span>&amp;&amp; f, <span style="color: #eedd82;">Args</span>&amp;&amp;... args );
</pre>
</div>
<p>
为了让一段代码只被多个线程只执行一次, mutex 文件中中包含了这个保证只调用一次的接口.
</p>

<p>
<code>once_flag</code> 对象是辅助 <code>call_once</code> 的,作为多个线程共同执行这段的标识,
所以这些个线程必须传入同一个 <code>once_flag</code> 对象.
</p>

<p>
它并对 <b>exception</b> 做一定的处理,如果 <code>call_once</code> 执行的函数以exception
退出,那么exception会抛给调用者.这次已exception退出的执行并不算一次,之后其他函数仍可以继续调用它一次.
</p>

<p>
如下的实例, t1 和 t2线程抛出exception, t3仍然运行一次, t4无论是怎样,都得不到运行.
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;mutex&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">cout</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">endl</span>;

<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">once_flag</span> <span style="color: #eedd82;">flag</span>;

<span style="color: #00ffff;">inline</span> <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">MayThrowFunction</span>(<span style="color: #98fb98;">bool</span> <span style="color: #eedd82;">do_throw</span>) {
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">only one instance of this function can be run simultaneously</span>
  <span style="color: #00ffff;">if</span> (do_throw) {
    cout &lt;&lt; <span style="color: #ffa07a;">"throw"</span> &lt;&lt; endl;  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">this message may be printed from 0 to 3 times</span>
    <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">if function exits via exception, another function selected</span>
    <span style="color: #00ffff;">throw</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">exception</span>();
  }
  cout &lt;&lt; <span style="color: #ffa07a;">"once"</span> &lt;&lt; endl;  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">printed exactly once, it's guaranteed that</span>
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">there are no messages after it</span>
}

<span style="color: #00ffff;">inline</span> <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">DoOnce</span>(<span style="color: #98fb98;">bool</span> <span style="color: #eedd82;">do_throw</span>) {
  <span style="color: #00ffff;">try</span> {
    <span style="color: #7fffd4;">std</span>::call_once(flag, MayThrowFunction, do_throw);
  }
  <span style="color: #00ffff;">catch</span> (...) {
  }
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t1</span>(DoOnce, <span style="color: #7fffd4;">true</span>);
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t2</span>(DoOnce, <span style="color: #7fffd4;">true</span>);
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t3</span>(DoOnce, <span style="color: #7fffd4;">false</span>);
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t4</span>(DoOnce, <span style="color: #7fffd4;">true</span>);
  t1.join();
  t2.join();
  t3.join();
  t4.join();
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>
</div>
<div id="outline-container-sec-5" class="outline-2">
<h2 id="sec-5">Condition variables</h2>
<div class="outline-text-2" id="text-5">
</div><div id="outline-container-sec-5-1" class="outline-3">
<h3 id="sec-5-1"><code>&lt;condition_variable&gt;</code> 概要</h3>
<div class="outline-text-3" id="text-5-1">
<p>
<code>&lt;condition_variable&gt;</code> 头文件主要包含两个 <code>condition_variable</code> 类, 一个全局函数.
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">condition_variable</span>;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">condition_variable_any</span>;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">notify_all_at_thread_exit</span>(<span style="color: #98fb98;">condition_variable</span>&amp; <span style="color: #eedd82;">cond</span>, <span style="color: #98fb98;">unique_lock</span>&lt;mutex&gt; <span style="color: #eedd82;">lk</span>);
<span style="color: #00ffff;">enum</span> <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">cv_status</span> { <span style="color: #eedd82;">no_timeout</span>, <span style="color: #eedd82;">timeout</span> };
}
</pre>
</div>
</div>
<div id="outline-container-sec-5-1-1" class="outline-4">
<h4 id="sec-5-1-1"><code>cv_status</code></h4>
<div class="outline-text-4" id="text-5-1-1">
<p>
Condition variables与mutex之类在等待timeout时,返回的不一样,mutex之类放回 <code>bool</code> 类型, 而Condition variables特意为它定义了 <code>enum</code> 类型:
<code>no_timeout</code> 和 <code>timeout</code>, 来判断等待是否成功.
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">enum</span> <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">cv_status</span> { <span style="color: #eedd82;">no_timeout</span>, <span style="color: #eedd82;">timeout</span> };
</pre>
</div>

<ul class="org-ul">
<li><code>cv_status::no_timeout</code> The function returned without a timeout (i.e.,
it was notified).
</li>
<li><code>cv_status::timeout</code> The function returned because it reached its
time limit (timeout).
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-5-1-2" class="outline-4">
<h4 id="sec-5-1-2"><code>notify_all_at_thread_exit</code></h4>
<div class="outline-text-4" id="text-5-1-2">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">void</span> <span style="color: #87cefa;">notify_all_at_thread_exit</span>(<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">condition_variable</span>&amp; <span style="color: #eedd82;">cond</span>,
                                <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">unique_lock</span>&lt;<span style="color: #7fffd4;">std</span>::mutex&gt; <span style="color: #eedd82;">lk</span>);
</pre>
</div>
<p>
<code>&lt;condition_variable&gt;</code> 头文件中有这个函数,它提供机制notify其他线程在调用这个函数的线程退出时. 它相当于操作(并包括清理所有 <code>thread_local</code> 对象):
</p>
<div class="org-src-container">

<pre class="src src-c++">lk.unlock();
cond.notify_all();
</pre>
</div>

<p>
虽然可以在调用线程的最后同样调用如上两句代码,但意图没有表现出来,表明
cond的notify必须在线程退出时调用,后面维护者可能会在这之后继续添加代码.
<code>notify_all_at_thread_exit</code> 用一句调用替代两个调用,既不用在函数最后去调用它,而且表明它的意图.
</p>

<p>
它的操作流程如下:
</p>
<ol class="org-ol">
<li>之前获取的锁lk的拥有权被转移到cond的内部.
</li>
<li>当此线程退出时, cond被notified通过:
</li>
</ol>
<div class="org-src-container">

<pre class="src src-c++">lk.unlock();
cond.notify_all();
</pre>
</div>

<p>
<b>Notes</b>
</p>
<ul class="org-ul">
<li>如果 <code>lk.mutex()</code> 没有被当前线程锁住,调用此函数导致undefined behavior.
</li>
<li>如果 <code>lk.mutex()</code> 的 mutex 不是其他线程使用来等待 condition variable
的同一个的话, 调用此函数导致undefined behavior.
</li>
</ul>
</div>
</div>
</div>

<div id="outline-container-sec-5-2" class="outline-3">
<h3 id="sec-5-2"><code>condition_variable</code> 类</h3>
<div class="outline-text-3" id="text-5-2">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">condition_variable</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #87cefa;">condition_variable</span>();
  ~<span style="color: #87cefa;">condition_variable</span>();
  <span style="color: #87cefa;">condition_variable</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">condition_variable</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">condition_variable</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">condition_variable</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">notify_one</span>() noexcept;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">notify_all</span>() noexcept;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">wait</span>(<span style="color: #98fb98;">unique_lock</span>&lt;mutex&gt;&amp; <span style="color: #eedd82;">lock</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Predicate</span>&gt;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">wait</span>(<span style="color: #98fb98;">unique_lock</span>&lt;mutex&gt;&amp; <span style="color: #eedd82;">lock</span>, <span style="color: #98fb98;">Predicate</span> <span style="color: #eedd82;">pred</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>&gt;
  <span style="color: #98fb98;">cv_status</span> <span style="color: #87cefa;">wait_until</span>(<span style="color: #98fb98;">unique_lock</span>&lt;mutex&gt;&amp; <span style="color: #eedd82;">lock</span>,
                       <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Predicate</span>&gt;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">wait_until</span>(<span style="color: #98fb98;">unique_lock</span>&lt;mutex&gt;&amp; <span style="color: #eedd82;">lock</span>,
                  <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>,
                  <span style="color: #eedd82;">Predicate</span> pred);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>&gt;
  <span style="color: #98fb98;">cv_status</span> <span style="color: #87cefa;">wait_for</span>(<span style="color: #98fb98;">unique_lock</span>&lt;mutex&gt;&amp; <span style="color: #eedd82;">lock</span>,
                     <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Predicate</span>&gt;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">wait_for</span>(<span style="color: #98fb98;">unique_lock</span>&lt;mutex&gt;&amp; <span style="color: #eedd82;">lock</span>,
                <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>,
                <span style="color: #eedd82;">Predicate</span> pred);
  <span style="color: #00ffff;">typedef</span> <span style="color: #98fb98;">implementation</span>-defined native_handle_type; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
  <span style="color: #98fb98;">native_handle_type</span> <span style="color: #87cefa;">native_handle</span>(); <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">See 30.2.3</span>
};
}
</pre>
</div>
<p>
Condition Variable的基本概念可以从之前篇<a href="http://dreamrunner.org/blog/2014/08/07/C-multithreading-programming/#sec-5-4">浅谈C++ Multithreading
 Programming</a>中获取.
</p>

<p>
<code>condition_variable</code> 类的 <code>void wait(unique_lock&lt;mutex&gt;&amp; lock,
Predicate pred);</code> 接口:
</p>
<ul class="org-ul">
<li>需要传入 <code>unique_lock</code>.
</li>
<li><code>pred</code> 函数, 如果predicate返回 <code>false</code> ,等待. 相当于:
</li>
</ul>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">while</span> (!pred()) {
    wait(lock);
}
</pre>
</div>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;string&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;mutex&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;condition_variable&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">string</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">cout</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">endl</span>;

<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span> <span style="color: #eedd82;">m</span>;
<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">condition_variable</span> <span style="color: #eedd82;">cv</span>;
<span style="color: #98fb98;">string</span> <span style="color: #eedd82;">data</span>;
<span style="color: #98fb98;">bool</span> <span style="color: #eedd82;">g_ready</span> = <span style="color: #7fffd4;">false</span>;
<span style="color: #98fb98;">bool</span> <span style="color: #eedd82;">g_processed</span> = <span style="color: #7fffd4;">false</span>;

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">WorkerThread</span>() {
    <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">Wait until main() sends data</span>
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">unique_lock</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span>&gt; <span style="color: #eedd82;">lk</span>(m);
    cv.wait(lk, []{<span style="color: #00ffff;">return</span> g_ready;});

    <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">after the wait, we own the lock.</span>
    cout &lt;&lt; <span style="color: #ffa07a;">"Worker thread is processing data"</span> &lt;&lt; endl;
    data += <span style="color: #ffa07a;">" after processing"</span>;

    <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">Send data back to main()</span>
    g_processed = <span style="color: #7fffd4;">true</span>;
    cout &lt;&lt; <span style="color: #ffa07a;">"Worker thread signals data processing completed"</span> &lt;&lt; endl;

    <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">Manual unlocking is done before notifying, to avoid</span>
    <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">that the waiting thread gets blocked again.</span>
    lk.unlock();
    cv.notify_one();
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">worker</span>(WorkerThread);
     data = <span style="color: #ffa07a;">"Example data"</span>;
    <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">send data to the worker thread</span>
    {
        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">lock_guard</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span>&gt; <span style="color: #eedd82;">lk</span>(m);
        g_ready = <span style="color: #7fffd4;">true</span>;
        cout &lt;&lt; <span style="color: #ffa07a;">"main() signals data ready for processing"</span> &lt;&lt; endl;
    }
    cv.notify_one();

    <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">wait for the worker</span>
    {
        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">unique_lock</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span>&gt; <span style="color: #eedd82;">lk</span>(m);
        cv.wait(lk, []{<span style="color: #00ffff;">return</span> g_processed;});
    }
    cout &lt;&lt; <span style="color: #ffa07a;">"Back in main(), data = "</span> &lt;&lt; data &lt;&lt; <span style="color: #ffa07a;">'\n'</span>;
    worker.join();
    <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-5-3" class="outline-3">
<h3 id="sec-5-3"><code>condition_variable_any</code> 类</h3>
<div class="outline-text-3" id="text-5-3">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">condition_variable_any</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #87cefa;">condition_variable_any</span>();
  ~<span style="color: #87cefa;">condition_variable_any</span>();
  <span style="color: #87cefa;">condition_variable_any</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">condition_variable_any</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">condition_variable_any</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">condition_variable_any</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">notify_one</span>() noexcept;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">notify_all</span>() noexcept;
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Lock</span>&gt;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">wait</span>(<span style="color: #98fb98;">Lock</span>&amp; <span style="color: #eedd82;">lock</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Lock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Predicate</span>&gt;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">wait</span>(<span style="color: #98fb98;">Lock</span>&amp; <span style="color: #eedd82;">lock</span>, <span style="color: #98fb98;">Predicate</span> <span style="color: #eedd82;">pred</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Lock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>&gt;
  <span style="color: #98fb98;">cv_status</span> <span style="color: #87cefa;">wait_until</span>(<span style="color: #98fb98;">Lock</span>&amp; <span style="color: #eedd82;">lock</span>, <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Lock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Predicate</span>&gt;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">wait_until</span>(<span style="color: #98fb98;">Lock</span>&amp; <span style="color: #eedd82;">lock</span>, <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>,
                  <span style="color: #eedd82;">Predicate</span> pred);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Lock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>&gt;
  <span style="color: #98fb98;">cv_status</span> <span style="color: #87cefa;">wait_for</span>(<span style="color: #98fb98;">Lock</span>&amp; <span style="color: #eedd82;">lock</span>, <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Lock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Predicate</span>&gt;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">wait_for</span>(<span style="color: #98fb98;">Lock</span>&amp; <span style="color: #eedd82;">lock</span>, <span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>,
                <span style="color: #eedd82;">Predicate</span> pred);
};
}
</pre>
</div>

<p>
<code>condition_variable_any</code> 是 <code>condition_variable</code> 的一个通用版,它可以等待任何满足 BasicLockable 要求Lock类型的对象.其他与 <code>condition_variable</code>
一样.
</p>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;condition_variable&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;chrono&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;vector&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">cout</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">endl</span>;

<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">condition_variable_any</span> <span style="color: #eedd82;">cv</span>;
<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span> <span style="color: #eedd82;">cv_m</span>;  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">This mutex is used for three purposes:</span>
                  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">1) to synchronize accesses to i</span>
                  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">2) to synchronize accesses to std::cout</span>
                  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">3) for the condition variable cv</span>
<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">g_wait_val</span> = 0;

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">WaitVal</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">id</span>) {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">unique_lock</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span>&gt; <span style="color: #eedd82;">lk</span>(cv_m);
  cout &lt;&lt; <span style="color: #ffa07a;">"thread "</span> &lt;&lt; id &lt;&lt; <span style="color: #ffa07a;">" Waiting... "</span> &lt;&lt; endl;
  cv.wait(lk, []{<span style="color: #00ffff;">return</span> g_wait_val == 1;});
  cout &lt;&lt; <span style="color: #ffa07a;">"...finished waiting,"</span> &lt;&lt; <span style="color: #ffa07a;">"thread "</span> &lt;&lt; id &lt;&lt; endl;
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Signals</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::sleep_for(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::seconds(1));
  {
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">lock_guard</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span>&gt; <span style="color: #eedd82;">lk</span>(cv_m);
    cout &lt;&lt; <span style="color: #ffa07a;">"Notifying..."</span> &lt;&lt; endl;
  }
  cv.notify_all();
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">this_thread</span>::sleep_for(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::seconds(1));
  {
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">lock_guard</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">mutex</span>&gt; <span style="color: #eedd82;">lk</span>(cv_m);
    g_wait_val = 1;
    cout &lt;&lt; <span style="color: #ffa07a;">"Notifying again..."</span> &lt;&lt; endl;
  }
  cv.notify_all();
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">vector</span>&lt;<span style="color: #7fffd4;">std</span>::thread&gt; <span style="color: #eedd82;">threads</span>;
  <span style="color: #00ffff;">for</span> (<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span> = 0; i &lt; 3; ++i) {
    threads.emplace_back(WaitVal, i);
  }
  threads.emplace_back(Signals);
  <span style="color: #00ffff;">for</span> (<span style="color: #00ffff;">auto</span>&amp; <span style="color: #eedd82;">t</span> : threads) {
        t.join();
  }
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-5-4" class="outline-3">
<h3 id="sec-5-4"><code>condition_variable</code> VS <code>condition_variable_any</code></h3>
<div class="outline-text-3" id="text-5-4">
<p>
引自N3690 §30.5[thread.condition]:
</p>

<p>
Class <code>condition_variable</code> provides a condition variable that can only
wait on an object of type <code>unique_lock&lt;mutex&gt;</code> , allowing maximum
efficiency on some platforms. Class <code>condition_variable_any</code> provides a
general condition variable that can wait on objects of user-supplied
lock types.
</p>

<p>
<code>condition_variable</code> 只与 <code>unique_lock&lt;mutex&gt;</code> 类型对象关联,在某些平台上,它可以更好的得到特定的优化,如果不需要
<code>condition_variable_any</code> 的灵活性, 选更高效的 <code>condition_variable</code> 对象使用.
</p>
</div>
</div>
</div>
<div id="outline-container-sec-6" class="outline-2">
<h2 id="sec-6">Future</h2>
<div class="outline-text-2" id="text-6">
</div><div id="outline-container-sec-6-1" class="outline-3">
<h3 id="sec-6-1"><code>&lt;future&gt;</code> 概要</h3>
<div class="outline-text-3" id="text-6-1">
<p>
如果要异步的获取一个函数的运行结果, 可以创建一个线程,并利用Condition
varialbes 来同步线程间使得另外线程正确获取到这个结果. 但C++11的
<code>future</code> 库使得这一过程更方便, 它提供接口使程序在一个线程中获取一个在同一个或其他线程中运行的函数的结果(值或异常), (这些类使用并不限制在
multi-threaded 程序中,同样可以在 single-threaded 使用.
</p>

<p>
<a href="#future_header">future的概要</a>主要分为:
</p>
<ul class="org-ul">
<li>运行函数提供共享结果的Providers类: <code>promise</code> 和 <code>packaged_task</code> .
</li>
<li>获取共享结果的Futures类: <code>future</code> 和 <code>shared_future</code> .
</li>
<li>Error handling: <code>future_error</code> , <code>future_errc</code> 等.
</li>
<li>Providers提供函数: <code>async</code> .
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-6-2" class="outline-3">
<h3 id="sec-6-2">Error handling</h3>
<div class="outline-text-3" id="text-6-2">
</div><div id="outline-container-sec-6-2-1" class="outline-4">
<h4 id="sec-6-2-1"><code>future_error</code> 类</h4>
<div class="outline-text-4" id="text-6-2-1">
{% img /images/blog/2014/c++11/future_error.png  'future_error' %}

<p>
<code>future_error</code> 类定义对future对象非法操作抛出异常的对象类型. 也就是专门为future库中接口出现异常提供特定的异常类.
</p>

<p>
从上图类图可知,这个类继承自 <a href="http://www.cplusplus.com/logic_error"><code>logic_error</code></a> , 并添加获取<a href="http://www.cplusplus.com/error_code"> <code>error_code</code></a> 的成员函数 <code>code</code> , 获取exception信息的 <code>what</code> 成员函数.
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">future_error</span> : <span style="color: #00ffff;">public</span> <span style="color: #98fb98;">logic_error</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #87cefa;">future_error</span>(<span style="color: #98fb98;">error_code</span> <span style="color: #eedd82;">ec</span>); <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">exposition only</span>
  <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">error_code</span>&amp; <span style="color: #87cefa;">code</span>() <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
  <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">char</span>* <span style="color: #87cefa;">what</span>() <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
};
}
<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">error_code</span>&amp; <span style="color: #87cefa;">code</span>() <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
</pre>
</div>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;future&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">empty</span>;
  <span style="color: #00ffff;">try</span> {
    <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">n</span> = empty.get();
  } <span style="color: #00ffff;">catch</span> (<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future_error</span>&amp; <span style="color: #eedd82;">e</span>) {
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"Caught a future_error with code \""</span> &lt;&lt; e.code()
              &lt;&lt; <span style="color: #ffa07a;">"\"\nMessage: \""</span> &lt;&lt; e.what() &lt;&lt; <span style="color: #ffa07a;">"\"\n"</span>;
  }
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-6-2-2" class="outline-4">
<h4 id="sec-6-2-2"><code>future_errc</code></h4>
<div class="outline-text-4" id="text-6-2-2">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">enum</span> <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">future_errc</span> {
    <span style="color: #eedd82;">broken_promise</span>             = <span style="color: #ff7f24;">/* </span><span style="color: #ff7f24;">implementation-defined */</span>,
    <span style="color: #eedd82;">future_already_retrieved</span>   = <span style="color: #ff7f24;">/* </span><span style="color: #ff7f24;">implementation-defined */</span>,
    <span style="color: #eedd82;">promise_already_satisfied</span>  = <span style="color: #ff7f24;">/* </span><span style="color: #ff7f24;">implementation-defined */</span>,
    <span style="color: #eedd82;">no_state</span>                   = <span style="color: #ff7f24;">/* </span><span style="color: #ff7f24;">implementation-defined */</span>
};
</pre>
</div>

<p>
这个enum class定义了future抛出异常的<a href="http://en.cppreference.com/w/cpp/error/error_condition">error condition</a>. <code>future_errc</code> 的值可以用来创建 <code>error_condition</code> 对象, 并与 <code>future_error</code> 的成员函数
<code>code</code> 返回的值对比, 决定所抛出异常的类型.
</p>

<p>
所以 <code>&lt;future&gt;</code> 另外有两个函数提供它们之间的转换:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">error_code</span> <span style="color: #87cefa;">make_error_code</span>( <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future_errc</span> <span style="color: #eedd82;">e</span> );
<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">error_condition</span> <span style="color: #87cefa;">make_error_condition</span>( <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future_errc</span> <span style="color: #eedd82;">e</span> );
<span style="color: #00ffff;">template</span>&lt;&gt;
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">is_error_condition_enum</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future_errc</span>&gt; : <span style="color: #7fffd4;">std</span>::true_type;
</pre>
</div>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;future&gt;</span>

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">prom</span>;

  <span style="color: #00ffff;">try</span> {
    prom.get_future();
    prom.get_future();
    <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">throws std::future_error with future_already_retrieved</span>
  }
  <span style="color: #00ffff;">catch</span> (<span style="color: #7fffd4;">std</span>::future_error&amp; e) {
    <span style="color: #00ffff;">if</span> (e.code() ==
        <span style="color: #7fffd4;">std</span>::make_error_condition(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">future_errc</span>::future_already_retrieved)) {
      <span style="color: #7fffd4;">std</span>::cerr &lt;&lt; <span style="color: #ffa07a;">"[future already retrieved]\n"</span>;
    } <span style="color: #00ffff;">else</span> {
      <span style="color: #7fffd4;">std</span>::cerr &lt;&lt; <span style="color: #ffa07a;">"[unknown exception]\n"</span>;
    }
  }
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-6-2-3" class="outline-4">
<h4 id="sec-6-2-3"><code>future_status</code></h4>
<div class="outline-text-4" id="text-6-2-3">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">enum</span> <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">future_status</span> {
    <span style="color: #eedd82;">ready</span>,
    <span style="color: #eedd82;">timeout</span>,
    <span style="color: #eedd82;">deferred</span>
};
</pre>
</div>

<p>
<code>future</code> 和 <code>shared_future</code> 类中属于wait类型的接口返回的状态.
</p>
<ul class="org-ul">
<li>deferred: 返回这个类型是因为共享状态(shared state)含有的一个deferred
函数.(见<a href="#async">async函数</a>)
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-6-2-4" class="outline-4">
<h4 id="sec-6-2-4"><code>future_category</code></h4>
<div class="outline-text-4" id="text-6-2-4">
<p>
用来识别future error种类.
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">error_category</span>&amp; <span style="color: #87cefa;">future_category</span>();
</pre>
</div>

<p>
这个函数返回一个 <code>error_category</code> 类型的静态对象,拥有如下特性:
</p>
<ul class="org-ul">
<li>它的 <code>name</code> 成员函数返回指向字符串"future"的指针.
</li>
</ul>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;future&gt;</span>

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">prom</span>;
  <span style="color: #00ffff;">try</span> {
    prom.get_future();
    prom.get_future();
    <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">throws a std::future_error of the future category</span>
  }
  <span style="color: #00ffff;">catch</span> (<span style="color: #7fffd4;">std</span>::future_error&amp; e) {
    <span style="color: #00ffff;">if</span> (e.code().category() == <span style="color: #7fffd4;">std</span>::future_category()) {
      <span style="color: #7fffd4;">std</span>::cerr &lt;&lt; <span style="color: #ffa07a;">"future_error of the future category thrown\n"</span>;
    }
  }
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>
</div>

<div id="outline-container-sec-6-3" class="outline-3">
<h3 id="sec-6-3"><code>template promise</code></h3>
<div class="outline-text-3" id="text-6-3">
<p>
模版类 promise 提供一种方便的方法存储一个值或异常,之后可以异步的被
future对象获取(同一个或其他线程).
</p>

<p>
promise对象在共享状态(shared state)存储值的操作 <b>synchronizes-with</b> 在其他函数中成功获取这个共享状态的返回值(如 <code>future::get</code> ).
</p>
</div>
<div id="outline-container-sec-6-3-1" class="outline-4">
<h4 id="sec-6-3-1">class</h4>
<div class="outline-text-4" id="text-6-3-1">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">promise</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #87cefa;">promise</span>();
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Allocator</span>&gt;
  <span style="color: #87cefa;">promise</span>(<span style="color: #98fb98;">allocator_arg_t</span>, <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">Allocator</span>&amp; <span style="color: #eedd82;">a</span>);
  <span style="color: #87cefa;">promise</span>(<span style="color: #98fb98;">promise</span>&amp;&amp; <span style="color: #eedd82;">rhs</span>) noexcept;
  <span style="color: #87cefa;">promise</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">promise</span>&amp; <span style="color: #eedd82;">rhs</span>) = <span style="color: #00ffff;">delete</span>;
  ~<span style="color: #87cefa;">promise</span>();
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">assignment</span>
  <span style="color: #98fb98;">promise</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #98fb98;">promise</span>&amp;&amp; rhs) noexcept;
  <span style="color: #98fb98;">promise</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">promise</span>&amp; <span style="color: #eedd82;">rhs</span>) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">promise</span>&amp; <span style="color: #eedd82;">other</span>) noexcept;
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">retrieving the result</span>
  <span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">R</span>&gt; <span style="color: #87cefa;">get_future</span>();
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">setting the result</span>
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">set_value</span>(<span style="color: #98fb98;">see</span> <span style="color: #eedd82;">below</span> );
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">set_exception</span>(<span style="color: #98fb98;">exception_ptr</span> <span style="color: #eedd82;">p</span>);
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">setting the result with deferred notification</span>
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">set_value_at_thread_exit</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">R</span>&amp; <span style="color: #eedd82;">r</span>);
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">set_value_at_thread_exit</span>(<span style="color: #98fb98;">see</span> <span style="color: #eedd82;">below</span> );
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">set_exception_at_thread_exit</span>(<span style="color: #98fb98;">exception_ptr</span> <span style="color: #eedd82;">p</span>);
};
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">R</span>&gt;&amp; <span style="color: #eedd82;">x</span>, <span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">R</span>&gt;&amp; <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Alloc</span>&gt;
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">uses_allocator</span>&lt;<span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">R</span>&gt;, <span style="color: #98fb98;">Alloc</span>&gt;;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-6-3-2" class="outline-4">
<h4 id="sec-6-3-2"><code>set_value</code> and <code>set_value_at_thread_exit</code></h4>
<div class="outline-text-4" id="text-6-3-2">
<p>
<code>set_value</code> 接口存储值到shared state,并使state准备好.这个操作是原子性的. 而 <code>set_value_at_thread_exit</code> 接口如名字,调用后不会马上设置值到
shared state中,只在当前函数退出时.
</p>

<p>
使用 <code>get_future</code> 返回与它相关联同一个shared state的future对象.
</p>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;functional&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;future&gt;</span>

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Print</span>(<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">int</span>&gt;&amp; <span style="color: #eedd82;">fut</span>) {
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">(synchronizes with getting the future)</span>
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">x</span> = fut.get();
  <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"value: "</span> &lt;&lt; x &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">prom</span>;
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">fut</span> = prom.get_future();
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t1</span>(Print, <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">ref</span>(<span style="color: #eedd82;">fut</span>));
  prom.set_value(10);  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">fulfill promise</span>
  t1.join();
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-6-3-3" class="outline-4">
<h4 id="sec-6-3-3"><code>set_exception</code> and <code>set_exception_at_thread_exit</code></h4>
<div class="outline-text-4" id="text-6-3-3">
<p>
这两个接口与上面 <code>set_value</code> 和  <code>set_value_at_thread_exit</code> 一样, 只是保存的是exception.
</p>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;future&gt;</span>

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">result</span>;

  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">t</span>([&amp;]{
      <span style="color: #00ffff;">try</span> {
        <span style="color: #00ffff;">throw</span> <span style="color: #7fffd4;">std</span>::runtime_error(<span style="color: #ffa07a;">"Example"</span>);
      } <span style="color: #00ffff;">catch</span>(...) {
        <span style="color: #00ffff;">try</span> {
          <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">store anything thrown in the promise</span>
          result.set_exception(<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">current_exception</span>());
        } <span style="color: #00ffff;">catch</span>(...) {}  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">set_exception() may throw too</span>
      }
    });

  <span style="color: #00ffff;">try</span> {
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; result.get_future().get();
  } <span style="color: #00ffff;">catch</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">exception</span>&amp; <span style="color: #eedd82;">e</span>) {
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"Exception from the thread: "</span> &lt;&lt; e.what() &lt;&lt; <span style="color: #7fffd4;">std</span>::endl;
  }
  t.join();
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>
</div>

<div id="outline-container-sec-6-4" class="outline-3">
<h3 id="sec-6-4"><code>template packaged_task</code></h3>
<div class="outline-text-3" id="text-6-4">
<p>
<code>packaged_task</code> 与 <code>promise</code> 类似,都是提供异步获取值的方法,不同是
<code>promise</code> 直接设置值, 而 <code>packaged_task</code> 封装一个可调用的元素,并把这个可调用任务的返回值异步到shared state中.
</p>
</div>
<div id="outline-container-sec-6-4-1" class="outline-4">
<h4 id="sec-6-4-1">class</h4>
<div class="outline-text-4" id="text-6-4-1">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">template</span>&lt;<span style="color: #00ffff;">class</span>&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">packaged_task</span>; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">undefined</span>
<span style="color: #00ffff;">template</span>&lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>, <span style="color: #00ffff;">class</span>... ArgTypes&gt;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">packaged_task</span>&lt;R(<span style="color: #eedd82;">ArgTypes</span>...)&gt; {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">construction and destruction</span>
  packaged_task() noexcept;
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">F</span>&gt;
  <span style="color: #00ffff;">explicit</span> <span style="color: #87cefa;">packaged_task</span>(<span style="color: #98fb98;">F</span>&amp;&amp; <span style="color: #eedd82;">f</span>);
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">F</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Allocator</span>&gt;
  <span style="color: #00ffff;">explicit</span> <span style="color: #87cefa;">packaged_task</span>(<span style="color: #98fb98;">allocator_arg_t</span>, <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">Allocator</span>&amp; <span style="color: #eedd82;">a</span>, <span style="color: #98fb98;">F</span>&amp;&amp; <span style="color: #eedd82;">f</span>);
  ~packaged_task();
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">no copy</span>
  packaged_task(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">packaged_task</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">packaged_task</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">packaged_task</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">move support</span>
  <span style="color: #87cefa;">packaged_task</span>(<span style="color: #98fb98;">packaged_task</span>&amp;&amp; <span style="color: #eedd82;">rhs</span>) noexcept;
  <span style="color: #98fb98;">packaged_task</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #98fb98;">packaged_task</span>&amp;&amp; rhs) noexcept;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">packaged_task</span>&amp; <span style="color: #eedd82;">other</span>) noexcept;
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">valid</span>() <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">result retrieval</span>
  <span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">R</span>&gt; <span style="color: #87cefa;">get_future</span>();
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">execution</span>
  <span style="color: #98fb98;">void</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">()</span>(ArgTypes... );
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">make_ready_at_thread_exit</span>(ArgTypes...);
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">reset</span>();
};
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>, <span style="color: #00ffff;">class</span>... ArgTypes&gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">packaged_task</span>&lt;R(ArgTypes...)&gt;&amp; <span style="color: #eedd82;">x</span>, <span style="color: #98fb98;">packaged_task</span>&lt;R(ArgTypes...)&gt;&amp; <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Alloc</span>&gt;
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">uses_allocator</span>&lt;<span style="color: #98fb98;">packaged_task</span>&lt;<span style="color: #98fb98;">R</span>&gt;, <span style="color: #98fb98;">Alloc</span>&gt;;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-6-4-2" class="outline-4">
<h4 id="sec-6-4-2">construct and use</h4>
<div class="outline-text-4" id="text-6-4-2">
<p>
<code>packaged_task</code> 的创建与 <code>thread</code> 类似, 它可以:
</p>
<ul class="org-ul">
<li>Lambda表达式.
</li>
<li>Bind一个函数.
</li>
<li>直接传入函数.
</li>
</ul>

<p>
运行:
</p>
<ul class="org-ul">
<li>因为它重载了操作符 <code>()</code> , 可以直接运行如: <code>task()</code> .
</li>
<li>可以 <code>move</code> 给一个线程运行.
</li>
</ul>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;cmath&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;future&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;functional&gt;</span>

<span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">unique function to avoid disambiguating the std::pow overload set</span>
<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">FunPow</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">x</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">y</span>) {
  <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">std</span>::pow(x, y);
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">TaskLambda</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">packaged_task</span>&lt;<span style="color: #98fb98;">int</span>(<span style="color: #98fb98;">int</span>, <span style="color: #98fb98;">int</span>)&gt; <span style="color: #eedd82;">task</span>([](<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">a</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">b</span>) {
      <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">std</span>::pow(a, b);
    });
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">result</span> = task.get_future();
  task(2, 9);
  <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"task_lambda:\t"</span> &lt;&lt; result.get() &lt;&lt; <span style="color: #ffa07a;">'\n'</span>;
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">TaskBind</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">packaged_task</span>&lt;<span style="color: #98fb98;">int</span>()&gt; <span style="color: #eedd82;">task</span>(<span style="color: #7fffd4;">std</span>::bind(FunPow, 2, 11));
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">result</span> = task.get_future();
  task();
  <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"task_bind:\t"</span> &lt;&lt; result.get() &lt;&lt; <span style="color: #ffa07a;">'\n'</span>;
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">TaskThread</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">packaged_task</span>&lt;<span style="color: #98fb98;">int</span>(<span style="color: #98fb98;">int</span>, <span style="color: #98fb98;">int</span>)&gt; <span style="color: #eedd82;">task</span>(FunPow);
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">result</span> = task.get_future();
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">task_td</span>(<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">move</span>(<span style="color: #eedd82;">task</span>), 2, 10);
  task_td.join();
  <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"task_thread:\t"</span> &lt;&lt; result.get() &lt;&lt; <span style="color: #ffa07a;">'\n'</span>;
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  TaskLambda();
  TaskBind();
  TaskThread();
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-6-4-3" class="outline-4">
<h4 id="sec-6-4-3">reset</h4>
<div class="outline-text-4" id="text-6-4-3">
<p>
<code>packaged_task</code> 的 <code>reset</code> 接口, 重置状态,舍弃之前运行的结果.相当于: <code>*this = packaged_task(std::move(f))</code> .
</p>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;cmath&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;thread&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;future&gt;</span>

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">packaged_task</span>&lt;<span style="color: #98fb98;">int</span>(<span style="color: #98fb98;">int</span>, <span style="color: #98fb98;">int</span>)&gt; <span style="color: #eedd82;">task</span>([](<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">a</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">b</span>) {
        <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">std</span>::pow(a, b);
    });
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">result</span> = task.get_future();
    task(2, 9);
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"2^9 = "</span> &lt;&lt; result.get() &lt;&lt; <span style="color: #ffa07a;">'\n'</span>;

    task.reset();
    result = task.get_future();
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">thread</span> <span style="color: #eedd82;">task_td</span>(<span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">move</span>(<span style="color: #eedd82;">task</span>), 2, 10);
    task_td.join();
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"2^10 = "</span> &lt;&lt; result.get() &lt;&lt; <span style="color: #ffa07a;">'\n'</span>;
}
</pre>
</div>
</div>
</div>
</div>

<div id="outline-container-sec-6-5" class="outline-3">
<h3 id="sec-6-5"><code>template future</code> 类</h3>
<div class="outline-text-3" id="text-6-5">
<p>
模版类 <code>future</code> 是用来异步获取共享状态里的结果. <code>future</code> 类是独占的,不能与其他 <code>future</code> 共享异步的获取结果. 若要多个 <code>future</code> 共享异步结果,
使用之后的 <code>shared_future</code> 类.
</p>

<p>
有效的与共享状态相关联的future对象,由如下函数构造:
</p>
<ul class="org-ul">
<li><code>async</code> .
</li>
<li><code>promise::get_future</code> .
</li>
<li><code>package_task::get_future</code> .
</li>
</ul>

<p>
它的接口:
</p>
<ul class="org-ul">
<li><code>share</code> : 转换 shared state 从 *this 到一个 <code>shared_future</code> 对象.
</li>
<li><code>get</code> : 返回shared state的值, 若未准备好,调用者阻塞等待它准备好.
</li>
<li><code>wait</code> : 阻塞等待结果直到有效.
</li>
<li><code>wait_for</code> 和 <code>wait_until</code> : 等待一段时间, 并通过 <code>future_status</code> 判断等待后的状态.
</li>
</ul>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">future</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #87cefa;">future</span>() noexcept;
  <span style="color: #87cefa;">future</span>(<span style="color: #98fb98;">future</span> &amp;&amp;) noexcept;
  <span style="color: #87cefa;">future</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">future</span>&amp; <span style="color: #eedd82;">rhs</span>) = <span style="color: #00ffff;">delete</span>;
  ~<span style="color: #87cefa;">future</span>();
  <span style="color: #98fb98;">future</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">future</span>&amp; <span style="color: #eedd82;">rhs</span>) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">future</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #98fb98;">future</span>&amp;&amp;) noexcept;
  <span style="color: #98fb98;">shared_future</span>&lt;<span style="color: #98fb98;">R</span>&gt; <span style="color: #87cefa;">share</span>();
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">retrieving the value</span>
  see <span style="color: #98fb98;">below</span> <span style="color: #87cefa;">get</span>();
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">functions to check state</span>
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">valid</span>() <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">wait</span>() <span style="color: #00ffff;">const</span>;
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>&gt;
  <span style="color: #98fb98;">future_status</span> <span style="color: #87cefa;">wait_for</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>) <span style="color: #00ffff;">const</span>;
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>&gt;
  <span style="color: #98fb98;">future_status</span> <span style="color: #87cefa;">wait_until</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>) <span style="color: #00ffff;">const</span>;
};
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-6-6" class="outline-3">
<h3 id="sec-6-6"><code>template shared_future</code> 类</h3>
<div class="outline-text-3" id="text-6-6">
<p>
模版类 <code>shared_future</code> 与 <code>future</code> 基本一样, 不同就是多个
<code>shared_future</code> 对象可以共享异步结果.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">shared_future</span> {
 <span style="color: #00ffff;">public</span>:
  <span style="color: #87cefa;">shared_future</span>() noexcept;
  <span style="color: #87cefa;">shared_future</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">shared_future</span>&amp; <span style="color: #eedd82;">rhs</span>);
  <span style="color: #87cefa;">shared_future</span>(<span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">R</span>&gt;&amp;&amp;) noexcept;
  <span style="color: #87cefa;">shared_future</span>(<span style="color: #98fb98;">shared_future</span>&amp;&amp; <span style="color: #eedd82;">rhs</span>) noexcept;
  ~<span style="color: #87cefa;">shared_future</span>();
  <span style="color: #98fb98;">shared_future</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">shared_future</span>&amp; <span style="color: #eedd82;">rhs</span>);
  <span style="color: #98fb98;">shared_future</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #98fb98;">shared_future</span>&amp;&amp; rhs) noexcept;
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">retrieving the value</span>
  see <span style="color: #98fb98;">below</span> <span style="color: #87cefa;">get</span>() <span style="color: #00ffff;">const</span>;
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">functions to check state</span>
  <span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">valid</span>() <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">noexcept</span>;
  <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">wait</span>() <span style="color: #00ffff;">const</span>;
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>&gt;
  <span style="color: #98fb98;">future_status</span> <span style="color: #87cefa;">wait_for</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>) <span style="color: #00ffff;">const</span>;
  <span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>&gt;
  <span style="color: #98fb98;">future_status</span> <span style="color: #87cefa;">wait_until</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>) <span style="color: #00ffff;">const</span>;
};
}
</pre>
</div>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;future&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;chrono&gt;</span>

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">void</span>&gt; <span style="color: #eedd82;">ready_promise</span>, <span style="color: #eedd82;">t1_ready_promise</span>, <span style="color: #eedd82;">t2_ready_promise</span>;
  <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">shared_future</span>&lt;<span style="color: #98fb98;">void</span>&gt; <span style="color: #eedd82;">ready_future</span>(ready_promise.get_future());
  <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::high_resolution_clock&gt; <span style="color: #eedd82;">start</span>;

  <span style="color: #00ffff;">auto</span> <span style="color: #98fb98;">fun1</span> = [&amp;]() -&gt; <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">double</span>, <span style="color: #7fffd4;">std</span>::milli&gt; {
    t1_ready_promise.set_value();
    ready_future.wait();  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">waits for the signal from main()</span>
    <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::<span style="color: #7fffd4;">high_resolution_clock</span>::now() - start;
  };

  <span style="color: #00ffff;">auto</span> <span style="color: #98fb98;">fun2</span> = [&amp;]() -&gt; <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">double</span>, <span style="color: #7fffd4;">std</span>::milli&gt; {
    t2_ready_promise.set_value();
    ready_future.wait();  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">waits for the signal from main()</span>
    <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::<span style="color: #7fffd4;">high_resolution_clock</span>::now() - start;
  };

  <span style="color: #00ffff;">auto</span> <span style="color: #98fb98;">result1</span> = <span style="color: #7fffd4;">std</span>::async(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">launch</span>::async, fun1);
  <span style="color: #00ffff;">auto</span> <span style="color: #98fb98;">result2</span> = <span style="color: #7fffd4;">std</span>::async(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">launch</span>::async, fun2);

  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">wait for the threads to become ready</span>
  t1_ready_promise.get_future().wait();
  t2_ready_promise.get_future().wait();

  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">the threads are ready, start the clock</span>
  start = <span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">chrono</span>::<span style="color: #7fffd4;">high_resolution_clock</span>::now();

  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">signal the threads to go</span>
  ready_promise.set_value();

  <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"Thread 1 received the signal "</span>
            &lt;&lt; result1.get().count() &lt;&lt; <span style="color: #ffa07a;">" ms after start\n"</span>
            &lt;&lt; <span style="color: #ffa07a;">"Thread 2 received the signal "</span>
            &lt;&lt; result2.get().count() &lt;&lt; <span style="color: #ffa07a;">" ms after start\n"</span>;
  <span style="color: #00ffff;">return</span> 0;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-6-7" class="outline-3">
<h3 id="sec-6-7">template async 函数</h3>
<div class="outline-text-3" id="text-6-7">
<p>
<a id="async" name="async"></a>
模版函数 <code>asnyc</code> 异步运行函数f,并返回一个 <code>future</code> 对象来获取这个函数调用的结果.
</p>
</div>
<div id="outline-container-sec-6-7-1" class="outline-4">
<h4 id="sec-6-7-1">Launching policy for async</h4>
<div class="outline-text-4" id="text-6-7-1">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">enum</span> <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">launch</span> : <span style="color: #ff7f24;">/* </span><span style="color: #ff7f24;">unspecified */</span> {
    async =    <span style="color: #ff7f24;">/* </span><span style="color: #ff7f24;">unspecified */</span>,
    deferred = <span style="color: #ff7f24;">/* </span><span style="color: #ff7f24;">unspecified */</span>,
    <span style="color: #ff7f24;">/* </span><span style="color: #ff7f24;">implementation-defined */</span>
};
</pre>
</div>

<p>
函数 <code>async</code> 有不同的策略来运行函数:
</p>
<ul class="org-ul">
<li><code>launch::async</code> :创建一个新的线程来调用函数ｆ.
</li>
<li><code>launch::deferred</code> :调用函数f延迟(deferred)到返回的future的shared
state被访问时(wait或get).
</li>
<li><code>launch::async|launch::deferred</code> :函数自动选择策略运行.与系统的库实现有关.
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-6-7-2" class="outline-4">
<h4 id="sec-6-7-2">async</h4>
<div class="outline-text-4" id="text-6-7-2">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">F</span>, <span style="color: #00ffff;">class</span>... Args&gt;
<span style="color: #98fb98;">future</span>&lt;<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">result_of</span>&lt;<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">decay</span>&lt;<span style="color: #98fb98;">F</span>&gt;::<span style="color: #98fb98;">type</span>(<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">decay</span>&lt;Args&gt;::<span style="color: #98fb98;">type</span>...)&gt;::<span style="color: #98fb98;">type</span>&gt;
<span style="color: #87cefa;">async</span>(<span style="color: #98fb98;">F</span>&amp;&amp; <span style="color: #eedd82;">f</span>, <span style="color: #98fb98;">Args</span>&amp;&amp;... args);
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">F</span>, <span style="color: #00ffff;">class</span>... Args&gt;
<span style="color: #98fb98;">future</span>&lt;<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">result_of</span>&lt;<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">decay</span>&lt;<span style="color: #98fb98;">F</span>&gt;::<span style="color: #98fb98;">type</span>(<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">decay</span>&lt;<span style="color: #98fb98;">Args</span>&gt;::<span style="color: #98fb98;">type</span>...)&gt;::<span style="color: #98fb98;">type</span>&gt;
<span style="color: #87cefa;">async</span>(<span style="color: #98fb98;">launch</span> <span style="color: #eedd82;">policy</span>, <span style="color: #98fb98;">F</span>&amp;&amp; <span style="color: #eedd82;">f</span>, <span style="color: #98fb98;">Args</span>&amp;&amp;... args);
</pre>
</div>

<p>
第一个接口没有 <code>policy</code> 作为传入参数, 相当于
<code>async(std::launch::async | std::launch::deferred, f, args...)</code>
</p>

<p>
实例:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;iostream&gt;</span>  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">NOLINT</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;vector&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;algorithm&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;numeric&gt;</span>
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;future&gt;</span>

<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">typename</span> <span style="color: #98fb98;">RAIter</span>&gt;
<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">ParallelSum</span>(<span style="color: #98fb98;">RAIter</span> <span style="color: #eedd82;">beg</span>, <span style="color: #98fb98;">RAIter</span> <span style="color: #eedd82;">end</span>) {
  <span style="color: #00ffff;">auto</span> <span style="color: #98fb98;">len</span> = <span style="color: #7fffd4;">std</span>::distance(beg, end);
  <span style="color: #00ffff;">if</span> (len &lt; 1000)
    <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">std</span>::accumulate(beg, end, 0);

  <span style="color: #98fb98;">RAIter</span> <span style="color: #eedd82;">mid</span> = beg + len/2;
  <span style="color: #00ffff;">auto</span> <span style="color: #98fb98;">handle</span> = <span style="color: #7fffd4;">std</span>::async(<span style="color: #7fffd4;">std</span>::<span style="color: #7fffd4;">launch</span>::async,
                           <span style="color: #98fb98;">ParallelSum</span>&lt;<span style="color: #98fb98;">RAIter</span>&gt;, mid, end);
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">sum</span> = ParallelSum(beg, mid);
  <span style="color: #00ffff;">return</span> sum + handle.get();
}

<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">main</span>() {
    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">vector</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">v</span>(10000, 1);
    <span style="color: #7fffd4;">std</span>::cout &lt;&lt; <span style="color: #ffa07a;">"The sum is "</span> &lt;&lt; ParallelSum(v.begin(), v.end()) &lt;&lt; <span style="color: #ffa07a;">'\n'</span>;
}
</pre>
</div>
</div>
</div>
</div>
</div>

<div id="outline-container-sec-7" class="outline-2">
<h2 id="sec-7">Header synopsis</h2>
<div class="outline-text-2" id="text-7">
</div><div id="outline-container-sec-7-1" class="outline-3">
<h3 id="sec-7-1"><code>&lt;thread&gt;</code></h3>
<div class="outline-text-3" id="text-7-1">
<p>
<a id="thread_header" name="thread_header"></a>
基本概要如下(§30.3 [thread.threads] of N3690):
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">Header &lt;thread&gt; synopsis</span>
<span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">thread</span>;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">thread</span>&amp; <span style="color: #eedd82;">x</span>, <span style="color: #98fb98;">thread</span>&amp; <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">this_thread</span> {
<span style="color: #7fffd4;">thread</span>::<span style="color: #98fb98;">id</span> <span style="color: #87cefa;">get_id</span>() noexcept;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">yield</span>() noexcept;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Clock</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Duration</span>&gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">sleep_until</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">time_point</span>&lt;<span style="color: #98fb98;">Clock</span>, <span style="color: #98fb98;">Duration</span>&gt;&amp; <span style="color: #eedd82;">abs_time</span>);
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Rep</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Period</span>&gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">sleep_for</span>(<span style="color: #00ffff;">const</span> <span style="color: #7fffd4;">chrono</span>::<span style="color: #98fb98;">duration</span>&lt;<span style="color: #98fb98;">Rep</span>, <span style="color: #98fb98;">Period</span>&gt;&amp; <span style="color: #eedd82;">rel_time</span>);
}
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-7-2" class="outline-3">
<h3 id="sec-7-2"><code>&lt;mutex&gt;</code></h3>
<div class="outline-text-3" id="text-7-2">
<p>
<a id="mutex_header" name="mutex_header"></a>
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">Header &lt;mutex&gt; synopsis</span>
<span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">mutex</span>;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">recursive_mutex</span>;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">timed_mutex</span>;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">recursive_timed_mutex</span>;
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">defer_lock_t</span> { };
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">try_to_lock_t</span> { };
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">adopt_lock_t</span> { };
constexpr <span style="color: #98fb98;">defer_lock_t</span> <span style="color: #eedd82;">defer_lock</span> { };
constexpr <span style="color: #98fb98;">try_to_lock_t</span> <span style="color: #eedd82;">try_to_lock</span> { };
constexpr <span style="color: #98fb98;">adopt_lock_t</span> <span style="color: #eedd82;">adopt_lock</span> { };
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Mutex</span>&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">lock_guard</span>;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Mutex</span>&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">unique_lock</span>;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Mutex</span>&gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">unique_lock</span>&lt;<span style="color: #98fb98;">Mutex</span>&gt;&amp; <span style="color: #eedd82;">x</span>, <span style="color: #98fb98;">unique_lock</span>&lt;<span style="color: #98fb98;">Mutex</span>&gt;&amp; <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">L1</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">L2</span>, <span style="color: #00ffff;">class</span>... L3&gt; <span style="color: #98fb98;">int</span> <span style="color: #87cefa;">try_lock</span>(<span style="color: #98fb98;">L1</span>&amp;, <span style="color: #98fb98;">L2</span>&amp;, <span style="color: #98fb98;">L3</span>&amp;...);
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">L1</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">L2</span>, <span style="color: #00ffff;">class</span>... L3&gt; <span style="color: #98fb98;">void</span> <span style="color: #87cefa;">lock</span>(<span style="color: #98fb98;">L1</span>&amp;, <span style="color: #98fb98;">L2</span>&amp;, <span style="color: #98fb98;">L3</span>&amp;...);
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">once_flag</span> {
  <span style="color: #98fb98;">constexpr</span> <span style="color: #87cefa;">once_flag</span>() noexcept;
  <span style="color: #87cefa;">once_flag</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">once_flag</span>&amp;) = <span style="color: #00ffff;">delete</span>;
  <span style="color: #98fb98;">once_flag</span>&amp; <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">once_flag</span>&amp;) = <span style="color: #00ffff;">delete</span>;
};
<span style="color: #00ffff;">template</span>&lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Callable</span>, <span style="color: #00ffff;">class</span> ...Args&gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">call_once</span>(<span style="color: #98fb98;">once_flag</span>&amp; <span style="color: #eedd82;">flag</span>, <span style="color: #98fb98;">Callable</span> <span style="color: #eedd82;">func</span>, <span style="color: #98fb98;">Args</span>&amp;&amp;... args);
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-7-3" class="outline-3">
<h3 id="sec-7-3"><code>&lt;future&gt;</code></h3>
<div class="outline-text-3" id="text-7-3">
<p>
<a id="future_header" name="future_header"></a>
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">namespace</span> <span style="color: #7fffd4;">std</span> {
<span style="color: #00ffff;">enum</span> <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">future_errc</span> {
<span style="color: #eedd82;">broken_promise</span> = implementation-defined ,
<span style="color: #eedd82;">future_already_retrieved</span> = implementation-defined ,
<span style="color: #eedd82;">promise_already_satisfied</span> = implementation-defined ,
<span style="color: #eedd82;">no_state</span> = implementation-defined
};
<span style="color: #00ffff;">enum</span> <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">launch</span> : <span style="color: #98fb98;">unspecified</span> {
<span style="color: #eedd82;">async</span> = unspecified ,
<span style="color: #eedd82;">deferred</span> = unspecified ,
<span style="color: #eedd82;">implementation</span>-defined
};
<span style="color: #00ffff;">enum</span> <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">future_status</span> {
<span style="color: #eedd82;">ready</span>,
<span style="color: #eedd82;">timeout</span>,
<span style="color: #eedd82;">deferred</span>
};
<span style="color: #00ffff;">template</span> &lt;&gt; <span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">is_error_code_enum</span>&lt;<span style="color: #98fb98;">future_errc</span>&gt; : <span style="color: #00ffff;">public</span> <span style="color: #98fb98;">true_type</span> { };
<span style="color: #98fb98;">error_code</span> <span style="color: #87cefa;">make_error_code</span>(<span style="color: #98fb98;">future_errc</span> <span style="color: #eedd82;">e</span>) noexcept;
<span style="color: #98fb98;">error_condition</span> <span style="color: #87cefa;">make_error_condition</span>(<span style="color: #98fb98;">future_errc</span> <span style="color: #eedd82;">e</span>) noexcept;
<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">error_category</span>&amp; <span style="color: #87cefa;">future_category</span>() noexcept;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">future_error</span>;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">promise</span>;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">R</span>&amp;&gt;;
<span style="color: #00ffff;">template</span> &lt;&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">void</span>&gt;;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">R</span>&gt;&amp; <span style="color: #eedd82;">x</span>, <span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">R</span>&gt;&amp; <span style="color: #eedd82;">y</span>) noexcept;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Alloc</span>&gt;
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">uses_allocator</span>&lt;<span style="color: #98fb98;">promise</span>&lt;<span style="color: #98fb98;">R</span>&gt;, <span style="color: #98fb98;">Alloc</span>&gt;;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">future</span>;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">R</span>&amp;&gt;;
<span style="color: #00ffff;">template</span> &lt;&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">future</span>&lt;<span style="color: #98fb98;">void</span>&gt;;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">shared_future</span>;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">shared_future</span>&lt;<span style="color: #98fb98;">R</span>&amp;&gt;;
<span style="color: #00ffff;">template</span> &lt;&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">shared_future</span>&lt;<span style="color: #98fb98;">void</span>&gt;;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span>&gt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">packaged_task</span>; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">undefined</span>
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>, <span style="color: #00ffff;">class</span>... ArgTypes&gt;
<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">packaged_task</span>&lt;R(<span style="color: #eedd82;">ArgTypes</span>...)&gt;;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>&gt;
<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">swap</span>(<span style="color: #98fb98;">packaged_task</span>&lt;R(ArgTypes...)&gt;&amp;, <span style="color: #98fb98;">packaged_task</span>&lt;R(ArgTypes...)&gt;&amp;) noexcept;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">R</span>, <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">Alloc</span>&gt;
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">uses_allocator</span>&lt;<span style="color: #98fb98;">packaged_task</span>&lt;<span style="color: #98fb98;">R</span>&gt;, <span style="color: #98fb98;">Alloc</span>&gt;;
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">F</span>, <span style="color: #00ffff;">class</span>... Args&gt;
<span style="color: #98fb98;">future</span>&lt;<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">result_of</span>&lt;<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">decay</span>&lt;<span style="color: #98fb98;">F</span>&gt;::<span style="color: #98fb98;">type</span>(<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">decay</span>&lt;Args&gt;::<span style="color: #98fb98;">type</span>...)&gt;::<span style="color: #98fb98;">type</span>&gt;
<span style="color: #87cefa;">async</span>(<span style="color: #98fb98;">F</span>&amp;&amp; <span style="color: #eedd82;">f</span>, <span style="color: #98fb98;">Args</span>&amp;&amp;... args);
<span style="color: #00ffff;">template</span> &lt;<span style="color: #00ffff;">class</span> <span style="color: #98fb98;">F</span>, <span style="color: #00ffff;">class</span>... Args&gt;
<span style="color: #98fb98;">future</span>&lt;<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">result_of</span>&lt;<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">decay</span>&lt;<span style="color: #98fb98;">F</span>&gt;::<span style="color: #98fb98;">type</span>(<span style="color: #00ffff;">typename</span> <span style="color: #7fffd4;">decay</span>&lt;<span style="color: #98fb98;">Args</span>&gt;::<span style="color: #98fb98;">type</span>...)&gt;::<span style="color: #98fb98;">type</span>&gt;
<span style="color: #87cefa;">async</span>(<span style="color: #98fb98;">launch</span> <span style="color: #eedd82;">policy</span>, <span style="color: #98fb98;">F</span>&amp;&amp; <span style="color: #eedd82;">f</span>, <span style="color: #98fb98;">Args</span>&amp;&amp;... args);
}
</pre>
</div>
</div>
</div>
</div>

<div id="outline-container-sec-8" class="outline-2">
<h2 id="sec-8">其他资料</h2>
<div class="outline-text-2" id="text-8">
<p>
<a id="reference" name="reference"></a>
</p>
</div>
<div id="outline-container-sec-8-1" class="outline-3">
<h3 id="sec-8-1">Books</h3>
<div class="outline-text-3" id="text-8-1">
<ul class="org-ul">
<li>Scott Meyers的<a href="http://www.artima.com/shop/overview_of_the_new_cpp"> Overview of the New C++ (C++11/14)</a>
</li>
</ul>
</div>
</div>

<div id="outline-container-sec-8-2" class="outline-3">
<h3 id="sec-8-2">Online resources</h3>
<div class="outline-text-3" id="text-8-2">
<ul class="org-ul">
<li>Scott Meyers的<a href="http://www.aristeia.com/C++11/C++11FeatureAvailability.htm">Summary of C++11 Feature Availability in gcc and MSVC</a>
</li>
<li><a href="http://en.cppreference.com/w/cpp">C++11 on cppreference</a>
</li>
<li><a href="http://www.cplusplus.com/reference/multithreading/">C++11 on cplusplus</a>
</li>
<li>Bjarne Stroustrup的<a href="http://www.stroustrup.com/C++11FAQ.html">C++11 FAQ</a>
</li>
<li><a href="https://en.wikipedia.org/wiki/C++11">C++11 Wiki</a>
</li>
<li><a href="https://github.com/cplusplus/draft">C++ standards drafts on GitHub</a>
</li>
<li><a href="http://en.cppreference.com/w/c/thread">C documentation</a> for Thread support library
</li>
</ul>
</div>
</div>
</div>

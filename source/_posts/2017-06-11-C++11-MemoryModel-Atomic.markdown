---
layout: post
title: "C++11 Memory Model and Atomic"
date: 2017-06-11 23:47:41 +0800
comments: true
categories: [Multithreading]
tags: [Multithreading, C++]
keywords: "Multithreading, C++, Memory Reordering, Memory Model, Atomic"
description: "C++11 Memory Model and Atomic"
---
<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">C++11 Atomic</a></li>
<li><a href="#sec-2">Memory Model and Order</a></li>
<li><a href="#sec-3">More</a></li>
</ul>
</div>
</div>

<div id="outline-container-sec-1" class="outline-2">
<h2 id="sec-1">C++11 Atomic<sup><a id="fnr.1" name="fnr.1" class="footref" href="#fn.1">1</a></sup></h2>
<div class="outline-text-2" id="text-1">
<p>
C++11 Atomic可简单分为4部分:
</p>
<ol class="org-ol">
<li><code>atomic</code> 类
</li>
<li>对 <code>atomic</code> 类型的操作函数
</li>
<li><code>atomic_flag</code> 类
</li>
<li>内存序列同步相关操作
</li>
</ol>


<!-- more -->
</div>

<div id="outline-container-sec-1-1" class="outline-3">
<h3 id="sec-1-1"><code>atomic</code> 类</h3>
<div class="outline-text-3" id="text-1-1">
<p>
主要分为四种模板类:
</p>
<ol class="org-ol">
<li>基本 <code>std::atomic</code>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">template</span>&lt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">T</span> &gt;
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">atomic</span>;
</pre>
</div>
</li>
<li>整形(Integral)的特化
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">template</span>&lt;&gt;
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">atomic</span>&lt;Integral&gt;;
</pre>
</div>
</li>
<li>bool的特化
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">template</span>&lt;&gt;
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">bool</span>&gt;;
</pre>
</div>
</li>
<li>指针的特化
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">template</span>&lt; <span style="color: #00ffff;">class</span> <span style="color: #98fb98;">T</span> &gt;
<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">T</span>*&gt;;
</pre>
</div>
</li>
</ol>

<p>
bool和integral类型:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #7fffd4;">std</span>::atomic_bool        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">bool</span>&gt;

<span style="color: #7fffd4;">std</span>::<span style="color: #eedd82;">atomic_char</span>        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">char</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_schar       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">signed</span> <span style="color: #98fb98;">char</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_uchar       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">unsigned</span> <span style="color: #98fb98;">char</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_short       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">short</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_ushort      <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">unsigned</span> <span style="color: #98fb98;">short</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_int <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">int</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">unsigned</span> <span style="color: #98fb98;">int</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_long        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">long</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_ulong       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">unsigned</span> <span style="color: #98fb98;">long</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_llong       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">long</span> <span style="color: #98fb98;">long</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_ullong      <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">unsigned</span> <span style="color: #98fb98;">long</span> <span style="color: #98fb98;">long</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_char16_t    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;char16_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_char32_t    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;char32_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_wchar_t     <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #98fb98;">wchar_t</span>&gt;
<span style="color: #7fffd4;">std</span>::atomic_int8_t      <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int8_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint8_t     <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint8_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int16_t     <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int16_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint16_t    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint16_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int32_t     <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int32_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint32_t    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint32_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int64_t     <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int64_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint64_t    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint64_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int_least8_t        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int_least8_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint_least8_t       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint_least8_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int_least16_t       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int_least16_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint_least16_t      <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint_least16_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int_least32_t       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int_least32_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint_least32_t      <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint_least32_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int_least64_t       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int_least64_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint_least64_t      <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint_least64_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int_fast8_t <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int_fast8_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint_fast8_t        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint_fast8_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int_fast16_t        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int_fast16_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint_fast16_t       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint_fast16_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int_fast32_t        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int_fast32_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint_fast32_t       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint_fast32_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_int_fast64_t        <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::int_fast64_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uint_fast64_t       <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uint_fast64_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_intptr_t    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::intptr_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uintptr_t   <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uintptr_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_size_t      <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::size_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_ptrdiff_t   <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::ptrdiff_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_intmax_t    <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::intmax_t&gt;
<span style="color: #7fffd4;">std</span>::atomic_uintmax_t   <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">atomic</span>&lt;<span style="color: #7fffd4;">std</span>::uintmax_t&gt;
</pre>
</div>

<p>
基本模板类定义:
</p>
<div class="org-src-container">

<pre class="src src-sh">template &lt; class T &gt; struct atomic {
    bool is_lock_free() const volatile;
    bool is_lock_free() const;
    void store(T, <span style="color: #eedd82;">memory_order</span> = memory_order_seq_cst) volatile;
    void store(T, <span style="color: #eedd82;">memory_order</span> = memory_order_seq_cst);
    T load(<span style="color: #eedd82;">memory_order</span> = memory_order_seq_cst) const volatile;
    T load(<span style="color: #eedd82;">memory_order</span> = memory_order_seq_cst) const;
    operator  T() const volatile;
    operator  T() const;
    T exchange(T, <span style="color: #eedd82;">memory_order</span> = memory_order_seq_cst) volatile;
    T exchange(T, <span style="color: #eedd82;">memory_order</span> = memory_order_seq_cst);
    bool compare_exchange_weak(T &amp;, T, memory_order, memory_order) volatile;
    bool compare_exchange_weak(T &amp;, T, memory_order, memory_order);
    bool compare_exchange_strong(T &amp;, T, memory_order, memory_order) volatile;
    bool compare_exchange_strong(T &amp;, T, memory_order, memory_order);
    bool compare_exchange_weak(T &amp;, T, <span style="color: #eedd82;">memory_order</span> = memory_order_seq_cst) volatile;
    bool compare_exchange_weak(T &amp;, T, <span style="color: #eedd82;">memory_order</span> = memory_order_seq_cst);
    bool compare_exchange_strong(T &amp;, T, <span style="color: #eedd82;">memory_order</span> = memory_order_seq_cst) volatile;
    bool compare_exchange_strong(T &amp;, T, <span style="color: #eedd82;">memory_order</span> = memory_order_seq_cst);
    atomic() = default;
    constexpr atomic(T);
    atomic(const atomic &amp;) = delete;
    atomic &amp; <span style="color: #eedd82;">operator</span>=(const atomic &amp;) = delete;
    atomic &amp; <span style="color: #eedd82;">operator</span>=(const atomic &amp;) <span style="color: #eedd82;">volatile</span> = delete;
    T <span style="color: #eedd82;">operator</span>=(T) volatile;
    T <span style="color: #eedd82;">operator</span>=(T);
};
</pre>
</div>

<p>
Integral 特有的函数:
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">integral</span> <span style="color: #87cefa;">fetch_add</span>(<span style="color: #98fb98;">integral</span>, memory_order = memory_order_seq_cst) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #87cefa;">fetch_add</span>(<span style="color: #98fb98;">integral</span>, memory_order = memory_order_seq_cst);

<span style="color: #98fb98;">integral</span> <span style="color: #87cefa;">fetch_sub</span>(<span style="color: #98fb98;">integral</span>, memory_order = memory_order_seq_cst) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #87cefa;">fetch_sub</span>(<span style="color: #98fb98;">integral</span>, memory_order = memory_order_seq_cst);

<span style="color: #98fb98;">integral</span> <span style="color: #87cefa;">fetch_and</span>(<span style="color: #98fb98;">integral</span>, memory_order = memory_order_seq_cst) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #87cefa;">fetch_and</span>(<span style="color: #98fb98;">integral</span>, memory_order = memory_order_seq_cst);

<span style="color: #98fb98;">integral</span> <span style="color: #87cefa;">fetch_or</span>(<span style="color: #98fb98;">integral</span>, memory_order = memory_order_seq_cst) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #87cefa;">fetch_or</span>(<span style="color: #98fb98;">integral</span>, memory_order = memory_order_seq_cst);

<span style="color: #98fb98;">integral</span> <span style="color: #87cefa;">fetch_xor</span>(<span style="color: #98fb98;">integral</span>, memory_order = memory_order_seq_cst) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #87cefa;">fetch_xor</span>(<span style="color: #98fb98;">integral</span>, memory_order = memory_order_seq_cst);

<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">++</span>(<span style="color: #98fb98;">int</span>) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">++</span>(<span style="color: #98fb98;">int</span>);
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">--</span>(<span style="color: #98fb98;">int</span>) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">--</span>(<span style="color: #98fb98;">int</span>);
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">++</span>() <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">++</span>();
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">--</span>() <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">--</span>();
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">+=</span>(<span style="color: #98fb98;">integral</span>) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">+=</span>(<span style="color: #98fb98;">integral</span>);
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">-=</span>(<span style="color: #98fb98;">integral</span>) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">-=</span>(<span style="color: #98fb98;">integral</span>);
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">&amp;=</span>(<span style="color: #98fb98;">integral</span>) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">&amp;=</span>(<span style="color: #98fb98;">integral</span>);
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">|=</span>(<span style="color: #98fb98;">integral</span>) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">|=</span>(<span style="color: #98fb98;">integral</span>);
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">^=</span>(<span style="color: #98fb98;">integral</span>) <span style="color: #00ffff;">volatile</span>;
<span style="color: #98fb98;">integral</span> <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">^=</span>(<span style="color: #98fb98;">integral</span>);
</pre>
</div>

<p>
指针特有的函数
</p>
<div class="org-src-container">

<pre class="src src-c++">T* fetch_add(ptrdiff_t, memory_order = memory_order_seq_cst) <span style="color: #00ffff;">volatile</span>;
T* fetch_add(ptrdiff_t, memory_order = memory_order_seq_cst);

T* fetch_sub(ptrdiff_t, memory_order = memory_order_seq_cst) <span style="color: #00ffff;">volatile</span>;
T* fetch_sub(ptrdiff_t, memory_order = memory_order_seq_cst);

  T* <span style="color: #00ffff;">operator</span>=(<span style="color: #98fb98;">T</span>*) <span style="color: #00ffff;">volatile</span>;
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">=</span>(<span style="color: #98fb98;">T</span>*);
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">++</span>(<span style="color: #98fb98;">int</span>) <span style="color: #00ffff;">volatile</span>;
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">++</span>(<span style="color: #98fb98;">int</span>);
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">--</span>(<span style="color: #98fb98;">int</span>) <span style="color: #00ffff;">volatile</span>;
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">--</span>(<span style="color: #98fb98;">int</span>);
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">++</span>() <span style="color: #00ffff;">volatile</span>;
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">++</span>();
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">--</span>() <span style="color: #00ffff;">volatile</span>;
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">--</span>();
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">+=</span>(<span style="color: #98fb98;">ptrdiff_t</span>) <span style="color: #00ffff;">volatile</span>;
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">+=</span>(<span style="color: #98fb98;">ptrdiff_t</span>);
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">-=</span>(<span style="color: #98fb98;">ptrdiff_t</span>) <span style="color: #00ffff;">volatile</span>;
  <span style="color: #98fb98;">T</span>* <span style="color: #00ffff;">operator</span><span style="color: #87cefa;">-=</span>(<span style="color: #98fb98;">ptrdiff_t</span>);
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-1-2" class="outline-3">
<h3 id="sec-1-2"><code>atomic</code> 类型的操作函数</h3>
<div class="outline-text-3" id="text-1-2">
<p>
除了 <code>atomic</code> 类的成员函数,也提供了对其操作的函数:
</p>

<ul class="org-ul">
<li><code>atomic_is_lock_free</code>: checks if the atomic type's operations are
lock-free
</li>
<li><code>atomic_store</code> and <code>atomic_store_explicit</code>: atomically replaces the
value of the atomic object with a non-atomic argument
</li>
<li><code>atomic_load</code> and <code>atomic_load_explicit</code>: atomically obtains the
value stored in an atomic object
</li>
<li><code>atomic_exchange</code> and <code>atomic_exchange_explicit</code>: atomically
replaces the value of the atomic object with non-atomic argument and
returns the old value of the atomic
</li>
<li><code>atomic_compare_exchange_weak</code>
<code>atomic_compare_exchange_weak_explicit</code>
<code>atomic_compare_exchange_strong</code>
<code>atomic_compare_exchange_strong_explicit</code>: atomically compares the
value of the atomic object with non-atomic argument and performs
atomic exchange if equal or atomic load if not
</li>
<li><code>atomic_fetch_add</code>
<code>atomic_fetch_add_explicit</code>: adds a non-atomic value to an atomic
object and obtains the previous value of the atomic 
</li>
<li><code>atomic_fetch_sub</code>
<code>atomic_fetch_sub_explicit</code>: subtracts a non-atomic value from an
atomic object and obtains the previous value of the atomic 
</li>
<li><code>atomic_fetch_and</code>
<code>atomic_fetch_and_explicit</code>: replaces the atomic object with the
result of logical AND with a non-atomic argument and obtains the
previous value of the atomic 
</li>
<li><code>atomic_fetch_or</code>
<code>atomic_fetch_or_explicit</code>: replaces the atomic object with the
result of logical OR with a non-atomic argument and obtains the
previous value of the atomic 
</li>
<li><code>atomic_fetch_xor</code>
<code>atomic_fetch_xor_explicit</code>: replaces the atomic object with the
result of logical XOR with a non-atomic argument and obtains the
previous value of the atomic 
</li>
</ul>
</div>
</div>

<div id="outline-container-sec-1-3" class="outline-3">
<h3 id="sec-1-3"><code>atomic_flag</code> 类</h3>
<div class="outline-text-3" id="text-1-3">
<p>
<code>atomic_flag</code> 是一种原子布尔类型，不同于 <code>std::atomic&lt;bool&gt;</code>, 不提供load
或store操作,只支持两种操作， <code>test_and_set</code> 和 <code>clear</code> 。
</p>

<div class="org-src-container">

<pre class="src src-c++">atomic_flag() noexcept = <span style="color: #00ffff;">default</span>;
atomic_flag (<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">atomic_flag</span>&amp;<span style="color: #eedd82;">T</span>) = <span style="color: #00ffff;">delete</span>;
</pre>
</div>

<p>
<code>std::atomic_flag</code> 只有默认构造函数，拷贝构造函数已被禁用. 一般使用
<code>ATOMIC_FLAG_INIT</code> 初始化为clear状态.
</p>
</div>
</div>

<div id="outline-container-sec-1-4" class="outline-3">
<h3 id="sec-1-4">内存序列同步相关操作</h3>
<div class="outline-text-3" id="text-1-4">
<ul class="org-ul">
<li><code>memory_order</code>: defines memory ordering constraints for the given
atomic operation 
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">enum</span> <span style="color: #98fb98;">memory_order</span> {
    <span style="color: #eedd82;">memory_order_relaxed</span>,
    <span style="color: #eedd82;">memory_order_consume</span>,
    <span style="color: #eedd82;">memory_order_acquire</span>,
    <span style="color: #eedd82;">memory_order_release</span>,
    <span style="color: #eedd82;">memory_order_acq_rel</span>,
    <span style="color: #eedd82;">memory_order_seq_cst</span>
};
</pre>
</div>
</li>
<li><code>kill_dependency</code>: removes the specified object from the
<code>std::memory_order_consume</code> dependency tree
</li>
<li><code>atomic_thread_fence</code>: Establishes memory synchronization ordering
of non-atomic and relaxed atomic accesses, as instructed by order,
without an associated atomic operation.
</li>
<li><code>atomic_signal_fence</code>: Establishes memory synchronization ordering
of non-atomic and relaxed atomic accesses, as instructed by order,
between a thread and a signal handler executed on the same thread.
This is equivalent to std::atomic_thread_fence, except no CPU
instructions for memory ordering are issued. Only reordering of the
instructions by the compiler is suppressed as order instructs. 
</li>
</ul>
</div>
</div>
</div>

<div id="outline-container-sec-2" class="outline-2">
<h2 id="sec-2">Memory Model and Order</h2>
<div class="outline-text-2" id="text-2">
<p>
在<a href="http://dreamrunner.org/blog/2014/06/28/qian-tan-memory-reordering/">浅谈Memory Reordering</a>中提及编译开发者和处理器制造商遵循的中心内存排序准则是: 不能改变单线程程序的行为. 从而产生了:
</p>
<ul class="org-ul">
<li>Memory ordering at compile time: 编译优化造成
</li>
<li>Memory ordering at processor time: CPU允许乱序机器指令优化造成
</li>
</ul>

<p>
在多核多线程时代，当多线程共享某一变量时，不同线程对共享变量的读写就应该格外小心，不适当的乱序执行可能导致程序运行错误。所以必须对编译器和
CPU 作出一定的约束才能合理正确地优化你的程序，这个约束就是 <b>内存模型
(Memory Model)</b> .
</p>

<p>
或者说,程序转化成机器指令执行时并不按照之前的原始代码顺序执行,所以内存模型是程序员、编译器，CPU 之间的准则约束,遵守这一准则约束后,大家各自做优化, 从而尽可能提高程序的性能。
</p>

<p>
<a href="https://en.wikipedia.org/wiki/Memory_model_(programming)">wiki上的Memory model</a>给出一个比较抽象的描述: In computing, a memory
model describes the interactions of threads through memory and their
shared use of the data.
</p>

<p>
C++11 中规定了 6 种访存次序(Memory Order)，如下：
</p>
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">enum</span> <span style="color: #98fb98;">memory_order</span> {
    <span style="color: #eedd82;">memory_order_relaxed</span>,
    <span style="color: #eedd82;">memory_order_consume</span>,
    <span style="color: #eedd82;">memory_order_acquire</span>,
    <span style="color: #eedd82;">memory_order_release</span>,
    <span style="color: #eedd82;">memory_order_acq_rel</span>,
    <span style="color: #eedd82;">memory_order_seq_cst</span>
};
</pre>
</div>

<p>
上面C++11 Atomic涉及 <code>memory_order</code> 的接口, 默认值是
<code>std::memory_order_seq_cst</code> .
</p>

<p>
可以把上述6种访存次序(内存序)分为3类，顺序一致性模型
(<code>memory_order_seq_cst</code>)，Acquire-Release 模型
(<code>memory_order_consume</code>, <code>memory_order_acquire</code>,
<code>memory_order_release</code>, <code>memory_order_acq_rel</code>) 和 Relax 模型
(<code>memory_order_relaxed</code>). 
</p>

<ul class="org-ul">
<li><code>memory_order_relaxed</code>: all reorderings are okay<sup><a id="fnr.2" name="fnr.2" class="footref" href="#fn.2">2</a></sup>
</li>
<li><code>memory_order_acquire</code>: guarantees that subsequent loads are not
moved before the current load or any preceding loads.
</li>
<li><code>memory_order_release</code>: preceding stores are not moved past the
current store or any subsequent stores.
</li>
<li><code>memory_order_acq_rel</code>: combines the two previous guarantees.
</li>
<li><code>memory_order_consume</code>: potentially weaker form of
memory_order_acquire that enforces ordering of the current load
before other operations that are data-dependent on it (for instance,
when a load of a pointer is marked memory_order_consume, subsequent
operations that dereference this pointer won’t be moved before it
(yes, even that is not guaranteed on all platforms!).
</li>
<li><code>memory_order_scq_cst</code>: 是 <code>memory_order_acq_rel</code> 的加强版，除了有
<code>acq_rel</code> 语义，还保证是<a href="https://en.wikipedia.org/wiki/Sequential_consistency">sequencially-consistent</a>.
</li>
</ul>
</div>
</div>

<div id="outline-container-sec-3" class="outline-2">
<h2 id="sec-3">More</h2>
<div class="outline-text-2" id="text-3">
<ul class="org-ul">
<li><a href="https://github.com/forhappy/Cplusplus-Concurrency-In-Practice/blob/master/zh/chapter8-Memory-Model/web-resources.md">C++ 多线程与内存模型资料汇总</a>
</li>
<li>Herb Sutter的talk
<ul class="org-ul">
<li><a href="https://channel9.msdn.com/Shows/Going+Deep/Cpp-and-Beyond-2012-Herb-Sutter-atomic-Weapons-1-of-2">Atomic Weapons 1</a>
</li>
<li><a href="https://channel9.msdn.com/Shows/Going+Deep/Cpp-and-Beyond-2012-Herb-Sutter-atomic-Weapons-1-of-2">Atomic Weapon 2</a>
</li>
</ul>
</li>
<li><a href="https://bartoszmilewski.com/2008/12/01/c-atomics-and-memory-ordering/">C++ atomics and memory ordering</a>
</li>
</ul>
</div>
</div>
<div id="footnotes">
<h2 class="footnotes">Footnotes: </h2>
<div id="text-footnotes">

<div class="footdef"><sup><a id="fn.1" name="fn.1" class="footnum" href="#fnr.1">1</a></sup> <p class="footpara">
<a href="http://en.cppreference.com/w/cpp/atomic">http://en.cppreference.com/w/cpp/atomic</a>
</p></div>

<div class="footdef"><sup><a id="fn.2" name="fn.2" class="footnum" href="#fnr.2">2</a></sup> <p class="footpara">
<a href="https://bartoszmilewski.com/2008/12/01/c-atomics-and-memory-ordering/">https://bartoszmilewski.com/2008/12/01/c-atomics-and-memory-ordering/</a>
</p></div>


</div>
</div>

---
layout: post
title: "Algorithm Design Manual Chapter 3"
date: 2014-06-04
comments: true
categories: [Algorithm]
tags: [Algorithm]
description: "The Algorithm Design Manual Chapter 3 Notes and Answers"
keywords: "algorithm"
---

<div id="outline-container-sec-1" class="outline-2">
<h2 id="sec-1">Book Notes</h2>
<div class="outline-text-2" id="text-1">
</div><div id="outline-container-sec-1-1" class="outline-3">
<h3 id="sec-1-1">Contiguous vs. Linked Data Structures</h3>
<div class="outline-text-3" id="text-1-1">
<ul class="org-ul">
<li>Contiguously-allocated structuresare composed of single slabs of
memory, and include arrays, matrices, heaps, and hash tables.
</li>
<li>Linked data structuresare composed of distinct chunks of memory
bound together bypointers, and include lists, trees, and graph
adjacency lists.
</li>
</ul>

<!-- more -->
</div>
</div>
<div id="outline-container-sec-1-2" class="outline-3">
<h3 id="sec-1-2">Arrays</h3>
<div class="outline-text-3" id="text-1-2">
<p>
Advantages of contiguously-allocated arrays include:
</p>
<ul class="org-ul">
<li>Constant-time access given the index– Because the index of each
element maps directly to a particular memory address, we can access
arbitrary data items instantly provided we know the index.
</li>
<li>Space efficiency– Arrays consist purely of data, so no space is
wasted with links or other formatting information. Further,
end-of-record information is not needed because arrays are built
from fixed-size records.
</li>
<li>Memory locality– A common programming idiom involves iterating
through all the elements of a data structure. Arrays are good for
this because they exhibit excellent memory locality. Physical
continuity between successive data accesses helps exploit the
high-speedcache memory on modern computer architectures.
</li>
</ul>

<p>
The downside of arrays is that we cannot adjust their size in the middle of
a program’s execution.
</p>

<p>
Actually, we can efficiently enlarge arrays as we need them, through the miracle
of dynamic arrays. The apparent waste in this procedure involves the recopying of the old contents
on each expansion. Thus, each of thenelements move only two times on average, and the total work
of managing the dynamic array is the sameO(n) as it would have been if a single
array of sufficient size had been allocated in advance! The primary thing lost using dynamic arrays is the guarantee that each array
access takes constant time <i>in the worst case</i>.
</p>
</div>
</div>

<div id="outline-container-sec-1-3" class="outline-3">
<h3 id="sec-1-3">Pointers and Linked Structures</h3>
<div class="outline-text-3" id="text-1-3">
<p>
The relative advantages of linked lists over static arrays include:
</p>
<ul class="org-ul">
<li>Overflow on linked structures can never occur unless the memory is
actually full.
</li>
<li>Insertions and deletions aresimplerthan for contiguous (array)
lists.
</li>
<li>With large records, moving pointers is easier and faster than moving
the items themselves.
</li>
</ul>

<p>
while the relative advantages of arrays include:
</p>
<ul class="org-ul">
<li>Linked structures require extra space for storing pointer fields.
</li>
<li>Linked lists do not allow efficient random access to items.
</li>
<li>Arrays allow better memory locality and cache performance than
random pointer jumping.
</li>
</ul>
</div>
</div>
</div>

<div id="outline-container-sec-2" class="outline-2">
<h2 id="sec-2">Exercises</h2>
<div class="outline-text-2" id="text-2">
</div><div id="outline-container-sec-2-1" class="outline-3">
<h3 id="sec-2-1">1</h3>
<div class="outline-text-3" id="text-2-1">
<p>
A common problem for compilers and text editors is determining whether the
parentheses in a string are balanced and properly nested. For example, the string
((())())() contains properly nested pairs of parentheses, which the strings )()( and
()) do not. Give an algorithm that returns true if a string contains properly nested
and balanced parentheses, and false if otherwise. For full credit, identify the position
of the first offending parenthesis if the string is not properly
nested and balanced.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;string&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">string</span>;
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;stack&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">stack</span>;

<span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">BalancedParentheses</span>(<span style="color: #98fb98;">string</span> <span style="color: #eedd82;">parentheses</span>, <span style="color: #98fb98;">int</span> *<span style="color: #eedd82;">pos</span>) {
  <span style="color: #98fb98;">stack</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">stk</span>;
  <span style="color: #00ffff;">const</span> <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">kLeftPar</span> = 1;
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span>;
  <span style="color: #00ffff;">for</span> (i = 0; i &lt; parentheses.size(); ++i) {
    <span style="color: #00ffff;">if</span> (parentheses[i] == <span style="color: #ffa07a;">'('</span>) {
      stk.push(kLeftPar);
    } <span style="color: #00ffff;">else</span> {
      <span style="color: #00ffff;">if</span> (stk.empty()) {
        *pos = i;
        <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">false</span>;
      }
      stk.pop();
    }
  }
  <span style="color: #00ffff;">if</span> (!stk.empty()) {
    *pos = --i;
    <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">false</span>;
  }
  <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">true</span>;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-2-2" class="outline-3">
<h3 id="sec-2-2">2</h3>
<div class="outline-text-3" id="text-2-2">
<p>
Write a program to reverse the direction of a given singly-linked list. In other
words, after the reversal all pointers should now point backwards. Your algorithm
should take linear time.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">Node</span> {
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">value</span>;
  <span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">next</span>;
  <span style="color: #87cefa;">Node</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">in_value</span>, <span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">Node</span>* <span style="color: #eedd82;">in_next</span>) : value(in_value), <span style="color: #98fb98;">next</span>(<span style="color: #eedd82;">in_next</span>) {
  }
};

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">ReverseLinkedList</span>(<span style="color: #98fb98;">Node</span> **<span style="color: #eedd82;">head</span>) {
  <span style="color: #00ffff;">if</span> (!head || *head == <span style="color: #7fffd4;">NULL</span>) {
    <span style="color: #00ffff;">return</span>;
  }
  <span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">prev</span>, *<span style="color: #eedd82;">p</span>, *<span style="color: #eedd82;">next</span>;
  prev = *head;
  p = prev-&gt;next;
  prev-&gt;next = <span style="color: #7fffd4;">NULL</span>;
  <span style="color: #00ffff;">while</span> (p != <span style="color: #7fffd4;">NULL</span>) {
    next = p-&gt;next;
    p-&gt;next = prev;
    prev = p;
    p = next;
  }
  *head = prev;
}
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-2-3" class="outline-3">
<h3 id="sec-2-3">3</h3>
<div class="outline-text-3" id="text-2-3">
<p>
We have seen how dynamic arrays enable arrays to grow while still achieving
constant-time amortized performance. This problem concerns extending dynamic
arrays to let them both grow and shrink on demand.
</p>

<p>
(a) Consider an underflow strategy that cuts the array size in half whenever the
array falls below half full. Give an example sequence of insertions and deletions
where this strategy gives a bad amortized cost.
</p>

<p>
(b) Then, give a better underflow strategy than that suggested above, one that
achieves constant amortized cost per deletion.
</p>

<ol class="org-ol">
<li>容量是6的数组，当有3个元素是，insertion，然后delete。它不断收缩和扩展容量。
</li>
<li>当元素个数是总个数的1/4时，把容量收缩成1/2。
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-4" class="outline-3">
<h3 id="sec-2-4">4</h3>
<div class="outline-text-3" id="text-2-4">
<p>
Design a dictionary data structure in which search, insertion, and deletion can
all be processed inO(1) time in the worst case. You may assume the set elements
are integers drawn from a finite set 1,2, .., n, and initialization
can take O(n)time.
</p>

<p>
因为元素个数是有限集合中的数，用bit array 表示每个数。
</p>
</div>
</div>

<div id="outline-container-sec-2-5" class="outline-3">
<h3 id="sec-2-5">5</h3>
<div class="outline-text-3" id="text-2-5">
<p>
Find the overhead fraction (the ratio of data space over total space) for each
of the following binary tree implementations on n nodes:
</p>

<p>
(a) All nodes store data, two child pointers, and a parent pointer. The data field
requires four bytes and each pointer requires four bytes.
</p>

<p>
(b) Only leaf nodes store data; internal nodes store two child pointers. The data
field requires four bytes and each pointer requires two bytes.
</p>

<ol class="org-ol">
<li>所有点都一样： 4/(4+4*3) = 1/4
</li>
<li>满树中，若页节点个数是n，那么内部节点个数是n-1,
4*n/(4*n + 4*(n-1)) = n/(2n-1)
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-6" class="outline-3">
<h3 id="sec-2-6">6</h3>
<div class="outline-text-3" id="text-2-6">
<p>
Describe how to modify any balanced tree data structure such that search,
insert, delete, minimum, and maximum still take O(logn) time each, but successor
and predecessor now take O(1) time each. Which operations have to be modified
to support this?
</p>

<p>
在树节点中添加指向successor和predecessor的指针。不影响操作search,
minimum, 和 maximum。只需在insert和delete操作相应更新指向successor和predecessor的指针。
</p>
</div>
</div>
<div id="outline-container-sec-2-7" class="outline-3">
<h3 id="sec-2-7">7</h3>
<div class="outline-text-3" id="text-2-7">
<p>
Suppose you have access to a balanced dictionary data structure, which
supports each of the operations search, insert, delete, minimum,
maximum, successor, and predecessor in O(logn) time. Explain how to
modify the insert and delete operations so they still take O(logn) but
now minimum and maximum take O(1) time. (Hint: think in terms of using
the abstract dictionary operations, instead of mucking about with
pointers and the like.)
</p>

<p>
存储max和min这两个数。
</p>
<ul class="org-ul">
<li>insert时，新元素与这个两数对比并相应更新。
</li>
<li>delete时，若是min元素被delete，用它的successor更新；若是max元素被
delete，用它的predecessor更新。
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-2-8" class="outline-3">
<h3 id="sec-2-8">8</h3>
<div class="outline-text-3" id="text-2-8">
<p>
Design a data structure to support the following operations:
</p>
<ul class="org-ul">
<li>insert(x,T) – Insert item x into the set T.
</li>
<li>delete(k,T) – Delete the kth smallest element from T.
</li>
<li>member(x,T) – Return true iff x∈T.
</li>
</ul>
<p>
All operations must take O(logn) time on an n-element set.
</p>

<p>
Balanced binary tree.
</p>
</div>
</div>
<div id="outline-container-sec-2-9" class="outline-3">
<h3 id="sec-2-9">9</h3>
<div class="outline-text-3" id="text-2-9">
<p>
A concatenate operation takes two sets S1 and S2, where every key in S1
is smaller than any key in S2, and merges them together. Give an
algorithm to concatenate two binary search trees into one binary
search tree. The worst-case running time should be O(h), where h is the
maximal height of the two trees.
</p>

<p>
S1中的所有元素小于S2,用O（logn）的时间找出S2的最小元素，然后S1成为它的左子树，S2成为它的右子树，组成新的搜索树。
</p>
</div>
</div>
<div id="outline-container-sec-2-10" class="outline-3">
<h3 id="sec-2-10">10</h3>
<div class="outline-text-3" id="text-2-10">
<p>
In the bin-packing problem, we are given n metal objects, each weighing
between zero and one kilogram. Our goal is to find the smallest number
of bins that will hold the n objects, with each bin holding one
kilogram at most.
</p>

<ul class="org-ul">
<li>The best-fit heuristicfor bin packing is as follows. Consider the
objects in the order in which they are given. For each object, place
it into the partially filled bin with the smallest amount of extra
room after the object is inserted.. If no such bin exists, start a new
bin. Design an algorithm that implements the best-fit heuristic
(taking as input the n weights w1,w2, &#x2026;, wn and outputting the
number of bins used) in O(nlogn)time.
</li>

<li>Repeat the above using the worst-fit heuristic, where we put the next
object in the partially filled bin with the largest amount of extra
room after the object is inserted.
</li>
</ul>

<p>
使用BST。主要找到能容纳这个元素的最小bin，若所有bin都小于这个元素大小，就插入一个新的。
</p>
<div class="org-src-container">

<pre class="src src-c++">min_node = <span style="color: #7fffd4;">NULL</span>;
<span style="color: #00ffff;">while</span> node != <span style="color: #7fffd4;">NULL</span>:
    <span style="color: #00ffff;">if</span> (node-&gt;weight &gt;= w &amp;&amp; node-&gt;left &lt; w) {
      min_node = node;
      <span style="color: #00ffff;">break</span>;
    } <span style="color: #00ffff;">else</span> <span style="color: #00ffff;">if</span> (node-&gt;left &gt;= w) {
      node = node-&gt;left;
    } <span style="color: #00ffff;">else</span> {
      node = node-&gt;right;
    }
<span style="color: #00ffff;">if</span> (min_node == <span style="color: #7fffd4;">NULL</span>) {
  bst-&gt;insert(<span style="color: #00ffff;">new</span> <span style="color: #98fb98;">node</span>(w));
} <span style="color: #00ffff;">else</span> {
  bst-&gt;<span style="color: #00ffff;">delete</span>(min_node);
  min_node-&gt;weight -= w;
  bst-&gt;insert(min_node);
}
</pre>
</div>

<p>
最大堆使用。每次选最大容量的bin。若最大bin小于这个元素大小，就插入一个新的。
</p>
</div>
</div>

<div id="outline-container-sec-2-11" class="outline-3">
<h3 id="sec-2-11">11</h3>
<div class="outline-text-3" id="text-2-11">
<p>
Suppose that we are given a sequence of n values x1,x2, &#x2026;, xn and seek
to quickly answer repeated queries of the form: given i and j, find the
smallest value in xi,&#x2026;,xj.
</p>

<p>
(a) Design a data structure that uses O(n<sup>2</sup>) space and answers queries in O(1)
time.
</p>

<p>
(b) Design a data structure that uses O(n) space and answers queries
in O(logn) time. For partial credit, your data structure can
use O(nlogn) space and have O(logn) query time.
</p>

<ol class="org-ol">
<li>n*n的矩阵，i,j中存的就是i-j的最小元素。
</li>

<li>使用<a href="http://en.wikipedia.org/wiki/Cartesian_tree">Cartesian tree</a>或<a href="http://en.wikipedia.org/wiki/Treap">Treap</a>。
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-12" class="outline-3">
<h3 id="sec-2-12">12</h3>
<div class="outline-text-3" id="text-2-12">
<p>
Suppose you are given an input set S of n numbers, and a black box
that if given any sequence of real numbers and an integer k instantly
and correctly answers whether there is a subset of input sequence
whose sum is exactly k. Show how to use the black box O(n) times to
find a subset of S that adds up to k.
</p>

<div class="org-src-container">

<pre class="src src-c++">R = S
<span style="color: #00ffff;">for</span> i = 1 to n:
  <span style="color: #00ffff;">if</span> bb(R/{si}) <span style="color: #98fb98;">is</span> <span style="color: #eedd82;">True</span>:
      R = R / {si}
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-2-13" class="outline-3">
<h3 id="sec-2-13">13</h3>
<div class="outline-text-3" id="text-2-13">
<p>
Let A[1..n] be an array of real numbers. Design an algorithm to perform
any sequence of the following operations:
</p>

<p>
• Add(i,y)– Add the value y to the ith number.
</p>

<p>
• Partial-sum(i)– Return the sum of the first i numbers
</p>

<p>
There are no insertions or deletions; the only change is to the values
of the numbers. Each operation should take O(logn) steps. You may use
one additional array of size n as a work space.
</p>

<p>
建立叶节点数ｎ的balanced binary tree，ｎ个叶节点依次存储A[1..n]，书的内节点存储子树的和。
</p>
<ol class="org-ol">
<li>Add(i,y)，比较ｉ与n/2，决定左子树还是右子树，依次遍历到叶节点，并增加相应子树和，最后找到第ｉ个元素相加。
</li>
<li>Partial-sum(i)，比较ｉ与n/2，决定左子树还是右子树，每当遍历右子树，加上左子树的和，最后到叶节点，得到总的和。
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-14" class="outline-3">
<h3 id="sec-2-14">14</h3>
<div class="outline-text-3" id="text-2-14">
<p>
Extend the data structure of the previous problem to support insertions and
deletions. Each element now has both a key and a value. An element is accessed
by its key. The addition operation is applied to the values, but the
elements are accessed by its key. The Partial sum operation is
different.
</p>

<ul class="org-ul">
<li>Add(k,y)– Add the value y to the item with key k.
</li>
<li>Insert(k,y)– Insert a new item with key k and value y.
</li>
<li>Delete(k)– Delete the item with key k.
</li>
<li>Partial-sum(k)– Return the sum of all the elements currently in the
set whose key is less than y,
</li>
</ul>

<p>
The worst case running time should still be O(nlogn) for any sequence
of O(n) operations.
</p>

<p>
建立以key排序的平衡搜索二叉树，并每个节点中添加一个左子树和的值。
</p>

<ul class="org-ul">
<li>Add(k,y)：随着搜索key k，依次加左子树和，最后key k加上y。
</li>
<li>Insert(k,y)：随着搜索key k插入位置，依次加左子树和，最后插入key k的元素。
</li>
<li>Delete(k)：：随着搜索key k，依次减少左子树和，最后删除key k元素。
</li>
<li>Partial-sum(k)：随着搜索key k，依次加上左子树的和（因为左边的元素是小于的元素）。
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-2-15" class="outline-3">
<h3 id="sec-2-15">15</h3>
<div class="outline-text-3" id="text-2-15">
<p>
Design a data structure that allows one to search, insert, and delete
an integer X in O(1) time (i.e. , constant time, independent of the
total number of integers stored). Assume that 1≤X≤n and that there
are m+n units of space available, where m is the maximum number of
integers that can be in the table at any one time. (Hint: use two
arrays A[1..n] and B[1..m].) You are not allowed to initialize
either A or B, as that would take O(m) or O(n) operations. This means
the arrays are full of random garbage to begin with, so you must be
very careful.
</p>

<p>
与<a href="http://dreamrunner.org/blog/2014/05/10/column1/">Programming Pearls</a>的Column课后题一样。
</p>

<p>
建立两个数组A[1..n]，B[1..m]和一个表示元素个数的变量k。
</p>

<ol class="org-ol">
<li>insert X: k = k + 1，A[X] = k, B[k] = X;
</li>
<li>search X: return (A[X] &lt;= k) &amp;&amp; B[A[X]] == X;
</li>
<li>delete X: 把A[X]与末端A[B[k]]交换，A[B[k]] = A[X], B[A[X]] = B[k];
k = k - 1;
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-16" class="outline-3">
<h3 id="sec-2-16">18</h3>
<div class="outline-text-3" id="text-2-16">
<p>
What method would you use to look up a word in a dictionary?
</p>

<p>
Hash Table.
</p>
</div>
</div>

<div id="outline-container-sec-2-17" class="outline-3">
<h3 id="sec-2-17">19</h3>
<div class="outline-text-3" id="text-2-17">
<p>
Imagine you have a closet full of shirts. What can you do to organize
your shirts for easy retrieval?
</p>

<p>
以颜色排序，并二分搜索查找。
</p>
</div>
</div>
<div id="outline-container-sec-2-18" class="outline-3">
<h3 id="sec-2-18">20</h3>
<div class="outline-text-3" id="text-2-18">
<p>
Write a function to find the middle node of a singly-linked list.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">Node</span> {
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">value</span>;
  <span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">next</span>;
};

<span style="color: #98fb98;">Node</span>* <span style="color: #87cefa;">FindMidNode</span>(<span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">head</span>) {
  <span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">p</span>, *<span style="color: #eedd82;">q</span>;
  p = head;
  q = head;
  i = 0;
  <span style="color: #00ffff;">while</span> (p != <span style="color: #7fffd4;">NULL</span>) {
    i++;
    p = p-&gt;next;
    <span style="color: #00ffff;">if</span> (i == 2) {
      q = q-&gt;next;
      i = 0;
    }
  }
  <span style="color: #00ffff;">return</span> q;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-2-19" class="outline-3">
<h3 id="sec-2-19">21</h3>
<div class="outline-text-3" id="text-2-19">
<p>
Write a function to compare whether two binary trees are identical.
Identical trees have the same key value at each position and the same
structure.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">Node</span> {
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">value</span>;
  <span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">left</span>;
  <span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">right</span>;
};

<span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">CompareBinaryTree</span>(<span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">head_m</span>, <span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">head_n</span>) {
  <span style="color: #00ffff;">if</span> (head_m == <span style="color: #7fffd4;">NULL</span> &amp;&amp; head_n == <span style="color: #7fffd4;">NULL</span>) {
    <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">true</span>;
  }
  <span style="color: #00ffff;">if</span> (head_m == <span style="color: #7fffd4;">NULL</span> || head_n == <span style="color: #7fffd4;">NULL</span>) {
    <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">false</span>;
  }
  <span style="color: #00ffff;">return</span> (head_m-&gt;value == head_n-&gt;value) &amp;&amp;
      CompareBinaryTree(head_m-&gt;left, head_n-&gt;left) &amp;&amp;
      CompareBinaryTree(head_m-&gt;right, head_n-&gt;right);
}
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-2-20" class="outline-3">
<h3 id="sec-2-20">22</h3>
<div class="outline-text-3" id="text-2-20">
<p>
Write a program to convert a binary search tree into a linked list
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">Node</span> {
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">value</span>;
  <span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">next</span>;
};

<span style="color: #00ffff;">struct</span> <span style="color: #98fb98;">TNode</span> {
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">value</span>;
  <span style="color: #98fb98;">TNode</span> *<span style="color: #eedd82;">left</span>;
  <span style="color: #98fb98;">TNode</span> *<span style="color: #eedd82;">right</span>;
  <span style="color: #87cefa;">TNode</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">value_in</span>) {
    value = value_in;
    left = <span style="color: #7fffd4;">NULL</span>;
    right = <span style="color: #7fffd4;">NULL</span>;
  }
};

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">InsertToList</span>(<span style="color: #98fb98;">Node</span> **<span style="color: #eedd82;">head</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">value</span>) {
  <span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">new_node</span> = <span style="color: #00ffff;">new</span> <span style="color: #98fb98;">Node</span>;
  new_node-&gt;value = value;
  new_node-&gt;next = *head;
  *head = new_node;
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">ConvertTreeToList</span>(<span style="color: #00ffff;">const</span> <span style="color: #98fb98;">TNode</span> *<span style="color: #eedd82;">root</span>, <span style="color: #98fb98;">Node</span> **<span style="color: #eedd82;">head</span>) {
  <span style="color: #00ffff;">if</span> (root == <span style="color: #7fffd4;">NULL</span>) {
    <span style="color: #00ffff;">return</span>;
  }
  ConvertTreeToList(root-&gt;right, head);
  InsertToList(head, root-&gt;value);
  ConvertTreeToList(root-&gt;left, head);
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-2-21" class="outline-3">
<h3 id="sec-2-21">23</h3>
<div class="outline-text-3" id="text-2-21">
<p>
Implement an algorithm to reverse a linked list. Now do it without
recursion.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">void</span> <span style="color: #87cefa;">ReverseLinkedList</span>(<span style="color: #98fb98;">Node</span> **<span style="color: #eedd82;">head</span>) {
  <span style="color: #00ffff;">if</span> (!head || *head == <span style="color: #7fffd4;">NULL</span>) {
    <span style="color: #00ffff;">return</span>;
  }
  <span style="color: #98fb98;">Node</span> *<span style="color: #eedd82;">prev</span>, *<span style="color: #eedd82;">p</span>, *<span style="color: #eedd82;">next</span>;
  prev = *head;
  p = prev-&gt;next;
  prev-&gt;next = <span style="color: #7fffd4;">NULL</span>;
  <span style="color: #00ffff;">while</span> (p != <span style="color: #7fffd4;">NULL</span>) {
    next = p-&gt;next;
    p-&gt;next = prev;
    prev = p;
    p = next;
  }
  *head = prev;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-2-22" class="outline-3">
<h3 id="sec-2-22">24</h3>
<div class="outline-text-3" id="text-2-22">
<p>
What is the best data structure for maintaining URLs that have been visited by
a Web crawler? Give an algorithm to test whether a given URL has already been
visited, optimizing both space and time.
</p>

<p>
Hash Table.
</p>
</div>
</div>
<div id="outline-container-sec-2-23" class="outline-3">
<h3 id="sec-2-23">26</h3>
<div class="outline-text-3" id="text-2-23">
<p>
Reverse the words in a sentence—i.e., “My name is Chris” becomes “Chris is
name My.” Optimize for time and space.
</p>

<ol class="org-ol">
<li>reverse 每个单词;
</li>
<li>reverse 整句。
</li>
</ol>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">void</span> <span style="color: #87cefa;">Reverse</span>(<span style="color: #98fb98;">char</span> *<span style="color: #eedd82;">begin</span>, <span style="color: #98fb98;">char</span> *<span style="color: #eedd82;">end</span>) {
  <span style="color: #98fb98;">char</span> <span style="color: #eedd82;">temp</span>;
  <span style="color: #00ffff;">while</span> (begin &lt; end) {
    temp = *begin;
    *begin = *end;
    *end = temp;
    begin++;
    end--;
  }
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">ReverseWords</span>(<span style="color: #98fb98;">char</span> *<span style="color: #eedd82;">str</span>) {
  <span style="color: #98fb98;">char</span> *<span style="color: #eedd82;">word_begin</span>;
  word_begin = <span style="color: #7fffd4;">NULL</span>;
  <span style="color: #98fb98;">char</span> *<span style="color: #eedd82;">p</span>;
  p = str;
  <span style="color: #00ffff;">while</span> (*p != <span style="color: #ffa07a;">'\0'</span>) {
    <span style="color: #00ffff;">if</span> (word_begin == <span style="color: #7fffd4;">NULL</span> &amp;&amp; *p != <span style="color: #ffa07a;">' '</span>) {
      word_begin = p;
    }
    <span style="color: #00ffff;">if</span> (word_begin != <span style="color: #7fffd4;">NULL</span> &amp;&amp; (*(p+1) == <span style="color: #ffa07a;">' '</span> || *(p+1) == <span style="color: #ffa07a;">'\0'</span>)) {
      Reverse(word_begin, p);
      word_begin = <span style="color: #7fffd4;">NULL</span>;
    }
    ++p;
  }
  Reverse(str, p - 1);
}
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-2-24" class="outline-3">
<h3 id="sec-2-24">27</h3>
<div class="outline-text-3" id="text-2-24">
<p>
Determine whether a linked list contains a loop as quickly as possible
without using any extra storage. Also, identify the location of the
loop.
</p>

<p>
利用两个指针，一个快指针和一个慢指针，快的每次都比慢的多前进一个节点，如果存在loop,快的总会与慢的相重叠。
</p>

<p>
loop的起始点：
</p>
<ol class="org-ol">
<li>当快的与慢的指针相重叠时，验证有loop，之后慢的指针不动，通过快的指针计算出loop的长度
</li>
<li>重新从链表头开始，快指针比慢指针先前进loop的长度距离，提增慢和快指针，直到第一次相遇，相遇点就是loop的起始点。
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-25" class="outline-3">
<h3 id="sec-2-25">28</h3>
<div class="outline-text-3" id="text-2-25">
<p>
You have an unordered array X of n integers. Find the array M containing
n elements where Mi is the product of all integers in X except for Xi. You may
not use division. You can use extra memory. (Hint: There are solutions
faster than O(n<sup>2</sup>).)
</p>

<p>
对数组X扫描2次计算出如下2组数组：
</p>

$$
\begin{align}
P_{0} = 1; P_{k}=X_{k}P_{k-1}=\prod_{i=1}^{k}X_{i} \newline
Q_{n+1} = 1; Q_{k}=X_{k}Q_{k+1}=\prod_{i=k}^{n}X_{i}
\end{align}
$$


<p>
所以得到M：
</p>

$$
\begin{align}
M_{i} = P_{i-1} Q_{i+1}, i\in[1,n]
\end{align}
$$
</div>
</div>
<div id="outline-container-sec-2-26" class="outline-3">
<h3 id="sec-2-26">29</h3>
<div class="outline-text-3" id="text-2-26">
<p>
Give an algorithm for finding an ordered word pair (e.g., “New
York”) occurring with the greatest frequency in a given webpage.
Which data structures would you use? Optimize both time and space.
</p>

<p>
Hash Table.
</p>
</div>
</div>
</div>

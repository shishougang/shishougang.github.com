---
layout: post
title: "Algorithm Design Manual Chapter 4"
date: 2014-06-09
comments: true
categories: [Algorithm]
tags: [Algorithm]
description: "The Algorithm Design Manual Chapter 4 Notes and Answers"
keywords: "algorithm"
---

<div id="outline-container-sec-1" class="outline-2">
<h2 id="sec-1">Book Notes</h2>
<div class="outline-text-2" id="text-1">
</div><div id="outline-container-sec-1-1" class="outline-3">
<h3 id="sec-1-1">4.3 Heapsort: Fast Sorting via Data Structures</h3>
<div class="outline-text-3" id="text-1-1">
</div><div id="outline-container-sec-1-1-1" class="outline-4">
<h4 id="sec-1-1-1">Where in the Heap?</h4>
<div class="outline-text-4" id="text-1-1-1">
<p>
Problem: Given an array-based heap on n elements and a real number x,
efficiently determine whether the kth smallest element in the heap is
greater than or equal to x. Your algorithm should be O(k) in the
worst-case, independent of the size of the heap. Hint: you do not have
to find the kth smallest element; you need only determine its
relationship to x.
</p>

<p>
Solution: There are at least two different ideas that lead to correct
but inefficient algorithms for this problem:
</p>

<ol class="org-ol">
<li>Call extract-minktimes, and test whether all of these are less
thanx. This explicitly sorts the firstkelements and so gives us
more information than the desired answer, but it takes O(klogn) time
to do so.
</li>
<li>The kth smallest element cannot be deeper than the kth level of the
heap, since the path from it to the root must go through elements
of decreasing value. Thus we can look at all the elements on the
first k levels of the heap, and count how many of them are less
thanx, stopping when we either find k of them or run out of
elements. This is correct, but takes O(min(n,2<sup>k</sup>-1)) time, since
the top k elements have 2<sup>k</sup>-1 elements.
</li>
</ol>

<p>
An O(k) solution can look at only k elements smaller than x, plus at
most O(k) elements greater than x. Consider the following recursive
procedure, called at the root with i= 1 with count=k:
</p>

<!-- more -->


<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">int</span> <span style="color: #87cefa;">heap_compare</span>(<span style="color: #98fb98;">priority_queue</span> *<span style="color: #eedd82;">q</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">count</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">x</span>)
{
  <span style="color: #00ffff;">if</span> ((count &lt;= 0) || (i &gt; q-&gt;n)) <span style="color: #00ffff;">return</span>(count);
  <span style="color: #00ffff;">if</span> (q-&gt;q[i] &lt; x) {
    count = heap_compare(q, pq_young_child(i), count-1, x);
    count = heap_compare(q, pq_young_child(i)+1, count, x);
  }
  <span style="color: #00ffff;">return</span>(count);
}
</pre>
</div>

<p>
If the root of the min-heap is ≥ x, then no elements in the heap can
be less than x, as by definition the root must be the smallest
element. This procedure searches the children of all nodes of weight
smaller than x until either (a) we have found k of them, when it returns
0, or (b) they are exhausted, when it returns a value greater than
zero. Thus it will find enough small elements if they exist.
</p>

<p>
But how long does it take? The only nodes whose children we look at
are those &lt; x, and at most k of these in total. Each have at most
visited two children, so we visit at most 3k nodes, for a total time
of O(k).
</p>
</div>
</div>
</div>

<div id="outline-container-sec-1-2" class="outline-3">
<h3 id="sec-1-2">4.5 Mergesort: Sorting by Divide-and-Conquer</h3>
<div class="outline-text-3" id="text-1-2">
<p>
Mergesort is a great algorithm for sorting linked lists, because it
does not rely on random access to elements as does heapsort or
quicksort. Its primary disadvantage is the need for an auxilliary
buffer when sorting arrays. It is easy to merge two sorted linked
lists without using any extra space, by just rearranging the pointers.
However, to merge two sorted arrays (or portions of an array), we need
use a third array to store the result of the merge to avoid stepping
on the component arrays
</p>
</div>
</div>
<div id="outline-container-sec-1-3" class="outline-3">
<h3 id="sec-1-3">4.9 Binary Search and Related Algorithms</h3>
<div class="outline-text-3" id="text-1-3">
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">int</span> <span style="color: #87cefa;">binary_search</span>(<span style="color: #98fb98;">item_type</span> <span style="color: #eedd82;">s</span>[], <span style="color: #98fb98;">item_type</span> <span style="color: #eedd82;">key</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">low</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">high</span>)
{
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">middle</span>; <span style="color: #ff7f24;">/* </span><span style="color: #ff7f24;">index of middle element */</span>
  <span style="color: #00ffff;">if</span> (low &gt; high) <span style="color: #00ffff;">return</span> (-1); <span style="color: #ff7f24;">/* </span><span style="color: #ff7f24;">key not found */</span>
  middle = (low+high)/2;
  <span style="color: #00ffff;">if</span> (s[middle] == key) <span style="color: #00ffff;">return</span>(middle);
  <span style="color: #00ffff;">if</span> (s[middle] &gt; key)
    <span style="color: #00ffff;">return</span> (binary_search(s,key,low,middle-1));
  <span style="color: #00ffff;">else</span>
    <span style="color: #00ffff;">return</span> (binary_search(s,key,middle+1,high));
}
</pre>
</div>
</div>

<div id="outline-container-sec-1-3-1" class="outline-4">
<h4 id="sec-1-3-1">Counting Occurrences</h4>
<div class="outline-text-4" id="text-1-3-1">
<p>
This algorithm runs inO(lgn+s), wheresis the number of occurrences of
the key. This can be as bad as linear if the entire array consists of
identical keys. A faster algorithm results by modifying binary search
to search for the boundary of the block containing k, instead of
kitself. Suppose we delete the equality test
</p>

<p>
<code>if (s[middle] == key) return(middle);</code>
</p>

<p>
from the implementation above and return the index <code>low</code> instead of
<code>−1</code> on each unsuccessful search. All searches will now be
unsuccessful, since there is no equality test. The search will proceed
to the right half whenever the key is compared to an identical array
element, eventually terminating at the <b>right boundary</b>. Repeating the
search after reversing the direction of the binary comparison will
lead us to the <b>left boundary</b>. Each search takes O(lgn) time, so we can
count the occurrences in logarithmic time regardless of the size of
the block.
</p>
</div>
</div>
<div id="outline-container-sec-1-3-2" class="outline-4">
<h4 id="sec-1-3-2">One-Sided Binary Search</h4>
<div class="outline-text-4" id="text-1-3-2">
<p>
Now suppose we have an array A consisting of a run of 0’s, followed
by an unbounded run of 1’s, and would like to identify the exact
point of transition between them. Binary search on the array would
provide the transition point in lgn tests, if we had a bound non the
number of elements in the array. In the absence of such
a bound, we can test repeatedly at larger intervals (<code>A[1], A[2],
A[4], A[8], A[16],...</code>) until we find a first nonzero value. Now we
have a window containing the target and can proceed with binary
search. This <i>one-sided binary search</i> finds the transition pointpusing at
most 2lgp comparisons, regardless of how large the array actually is.
</p>
</div>
</div>
<div id="outline-container-sec-1-3-3" class="outline-4">
<h4 id="sec-1-3-3">Square and Other Roots</h4>
<div class="outline-text-4" id="text-1-3-3">
<p>
First, observe that the square root ofn≥1 must be at least 1 and at
most n. Let <code>l = 1</code> and <code>r = n</code>. Consider the midpoint of this
interval, <code>m=(l+r)/2</code>. How does m<sup>2</sup> compare to n? If n≥m<sup>2</sup> , then the
square root must be greater than m, so the algorithm repeats with
<code>l=m</code>. If n&lt;m<sup>2</sup> , then the square root must be less than m, so the
algorithm repeats with <code>r=m</code>. 
</p>

<p>
Suppose that we start with values l and r such that f(l)&gt;0 and f(r)&lt;0.
If f is a continuous function, there must exist a root between l and
r. Depending upon the sign of f(m), where <code>m=(l+r)/2</code>, we can cut this
window containing the root in half with each test and stop soon as our
estimate becomes sufficiently accurate.
</p>
</div>
</div>
</div>

<div id="outline-container-sec-1-4" class="outline-3">
<h3 id="sec-1-4">4.10 Divide-and-Conquer</h3>
<div class="outline-text-3" id="text-1-4">
<p>
divide-and-conquer recurrences of the form T(n)=aT(n/b)+f(n)
</p>

1. If $f(n) = O(n^{log_{b}^{a-\epsilon}})$ for some constant $\epsilon
   > 0$, then $T(n) = \Theta(n^{log_{b}^a})$. <br> 
2. If $f(n) = O(n^{log_{b}^{a}})$, then $T(n) =
   \Theta(n^{log_{b}^a}lgn)$.  <br> 
3. If $f(n) = O(n^{log_{b}^{a+\epsilon}})$ for some constant $\epsilon
   > 0$ and if $af(n/b) \leq cf(n)$ for some $c<1$, then $T(n) =
   \Theta(f(n))$.  <br> 
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
The Grinch is given the job of partitioning 2n players into two teams
of n players each. Each player has a numerical rating that measures
how good he/she is at the game. He seeks to divide the players as
unfairly as possible, so as to create the biggest possible talent
imbalance between team A and team B. Show how the Grinch can do the
job in O(nlogn) time.
</p>

<p>
用个O(nlogn)的排序算法对2n个队根据实力排序，前n个作为一队，后n个作为一队。
</p>
</div>
</div>

<div id="outline-container-sec-2-2" class="outline-3">
<h3 id="sec-2-2">2</h3>
<div class="outline-text-3" id="text-2-2">
<p>
For each of the following problems, give an algorithm that finds the
desired numbers within the given amount of time. To keep your answers
brief, feel free to use algorithms from the book as subroutines. For
the example,S={6,13,19,3,8}, 19−3 maximizes the difference, while 8−6
minimizes the difference.
</p>


<p>
(a) Let S be an unsorted array of n integers. Give an algorithm that
finds the pair x, y∈S that maximizes|x−y|. Your algorithm must run in
O(n) worst-case time.
</p>

<p>
(b) Let S be a sorted array of n integers. Give an algorithm that finds
the pair x, y∈S that maximizes |x−y|. Your algorithm must run in O(1)
worst-case time.
</p>

<p>
(c) Let S be an unsorted array of n integers. Give an algorithm that finds
the pair x, y∈S that minimizes |x−y|, for x &ne; y. Your algorithm must run
in O(nlogn) worst-case time.
</p>

<p>
(d) Let S be a sorted array of n integers. Give an algorithm that finds the pair
x, y∈S that minimizes |x−y|, for x &ne; y. Your algorithm must run in O(n)
worst-case time.
</p>


<ul class="org-ul">
<li>(a) 扫描S一次获得最小和最大值.
</li>
<li>(b) 取首尾数。
</li>
<li>(c) O(nlogn)的算法排序，扫描排序好的S，获得最小差的相邻元素对。
</li>
<li>(d) 扫描排序好的S，获得最小差的相邻元素对。
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-2-3" class="outline-3">
<h3 id="sec-2-3">3</h3>
<div class="outline-text-3" id="text-2-3">
<p>
Take a sequence of 2n real numbers as input. Design an O(nlogn)
algorithm that partitions the numbers intonpairs, with the property
that the partition minimizes the maximum sum of a pair. For example,
say we are given the numbers (1,3,5,9). The possible partitions are
((1,3),(5,9)), ((1,5),(3,9)), and ((1,9),(3,5)). The pair sums for
these partitions are (4,14), (6,12), and (10,8). Thus the third
partition has 10 as its maximum sum, which is the minimum over the
three partitions.
</p>

<ol class="org-ol">
<li>O(nlogn)的算法排序
</li>
<li><div class="org-src-container">

<pre class="src src-c++">start = 0;
end = 2n - 1;
<span style="color: #00ffff;">while</span> (start &lt; end) {
  pair(S[star], S[end]);
  start++;
  end--;
</pre>
</div>
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-4" class="outline-3">
<h3 id="sec-2-4">4</h3>
<div class="outline-text-3" id="text-2-4">
<p>
Assume that we are given n pairs of items as input, where the first item
is a and the second item is one of three colors (red, blue, or
yellow). Further assume that the items are sorted by number. Give
an O(n) algorithm to sort the items by color (all reds before all blues
before all yellows) such that the numbers for identical colors stay
sorted. For example: (1,blue), (3,red), (4,blue), (6,yellow), (9,red)
should become (3,red), (9,red), (1,blue), (4,blue), (6,yellow).
</p>

<ol class="org-ol">
<li>创建3个分别存储red，blue，yellow的数组;
</li>
<li>扫描input，依次按颜色装入不同的数组;
</li>
<li>分别从red，blue，yellow的数组中输出结果。
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-5" class="outline-3">
<h3 id="sec-2-5">5</h3>
<div class="outline-text-3" id="text-2-5">
<p>
The mode of a set of numbers is the number that occurs most frequently
in the set. The set (4,6,2,4,3,1) has a mode of 4. Give an efficient
and correct algorithm to compute the mode of a set of n numbers.
</p>

<ul class="org-ul">
<li>O(nlogn): O(nlogn)排序，扫描Set一遍得到频率最大的数。
</li>
<li>O(n): 使用hash map扫描一遍存储数字频率，扫描hash map得到频率最大数。
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-2-6" class="outline-3">
<h3 id="sec-2-6">6</h3>
<div class="outline-text-3" id="text-2-6">
<p>
Given two sets S1 and S2 (each of size n), and a number x, describe an
O(nlogn) algorithm for finding whether there exists a pair of
elements, one from S1 and one from S2, that add up to x. (For partial
credit, give a Θ(n<sup>2</sup>) algorithm for this problem.)
</p>

<ol class="org-ol">
<li>从S1中减去n，O(nlogn)排序S1和S2,然后能否找出相同的元素（binary search或扫描比较）。
</li>
<li>Sort and Scan
<div class="org-src-container">

<pre class="src src-sh">sort S1<span style="color: #00ffff;"> in</span> O(nlogn)
sort S2<span style="color: #00ffff;"> in</span> O(nlogn)
<span style="color: #eedd82;">begin</span> = 0;
<span style="color: #eedd82;">end</span> = n - 1;
<span style="color: #00ffff;">while</span> (begin &lt; n &amp;&amp; end &gt;=0) {
          <span style="color: #00ffff;">if</span> ((S1[begin] + S2[end]) &lt; X) {
                 begin++;
          }
          <span style="color: #00ffff;">else if</span> ((S1[begin] + S2[end]) &gt; X) {
                 end--;
          } <span style="color: #00ffff;">else</span> {
              <span style="color: #00ffff;">return </span><span style="color: #b0c4de;">true</span>;
          }
}
<span style="color: #00ffff;">return </span><span style="color: #b0c4de;">false</span>;
</pre>
</div>
</li>
<li>Binary Search
<ul class="org-ul">
<li>O(nlogn)排序S1
</li>
<li>X-S2[i]去binary search排序好的S1，是否找到元素。
</li>
</ul>
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-7" class="outline-3">
<h3 id="sec-2-7">7</h3>
<div class="outline-text-3" id="text-2-7">
<p>
Outline a reasonable method of solving each of the following problems.
Give the order of the worst-case complexity of your methods.
</p>

<ol class="org-ol">
<li>You are given a pile of thousands of telephone bills and thousands
of checks sent in to pay the bills. Find out who did not pay.
</li>

<li>You are given a list containing the title, author, call number and
publisher of all the books in a school library and another list of
30 publishers. Find out how many of the books in the library were
published by each company.
</li>

<li>You are given all the book checkout cards used in the campus
library during the past year, each of which contains the name of
the person who took out the book. Determine how many distinct
people checked out at least one book.
</li>
</ol>

<p>
都使用Hash Table，O(n)
</p>
</div>
</div>
<div id="outline-container-sec-2-8" class="outline-3">
<h3 id="sec-2-8">8</h3>
<div class="outline-text-3" id="text-2-8">
<p>
Given a set of S containing n real numbers, and a real number x. We
seek an algorithm to determine whether two elements of S exist whose
sum is exactly x.
</p>

<ul class="org-ul">
<li>Assume that S is unsorted. Give an O(nlogn) algorithm for the problem.
</li>
<li>Assume that S is sorted. Give an O(n) algorithm for the problem.
</li>
</ul>

<p>
(1):
Binary search
</p>
<div class="org-src-container">

<pre class="src src-sh">sort S<span style="color: #00ffff;"> in</span> O(nlogn);
<span style="color: #00ffff;">for</span> (int <span style="color: #eedd82;">i</span> = 0; i &lt; n; ++i) {
        binarysearch S[i]<span style="color: #00ffff;"> in</span> S[i+1,n]
}
</pre>
</div>

<p>
Scan
</p>
<div class="org-src-container">

<pre class="src src-sh">sort S<span style="color: #00ffff;"> in</span> O(nlogn);
<span style="color: #eedd82;">i</span> = 0;
<span style="color: #eedd82;">j</span> = n - 1;
<span style="color: #00ffff;">while</span> (i &lt; j) {
  <span style="color: #00ffff;">if</span> (s[i] + s[j] &lt; X) {
    i++;
  } <span style="color: #00ffff;">else if</span> (s[i] + s[j] &gt; X) {
    j--;
  } <span style="color: #00ffff;">else</span> {
    <span style="color: #00ffff;">break</span>;
  }
}
</pre>
</div>

<p>
(2)
</p>
<div class="org-src-container">

<pre class="src src-c++">i = 0;
j = n - 1;
<span style="color: #00ffff;">while</span> (i &lt; j) {
  <span style="color: #00ffff;">if</span> (s[i] + s[j] &lt; X) {
    i++;
  } <span style="color: #00ffff;">else</span> <span style="color: #00ffff;">if</span> (s[i] + s[j] &gt; X) {
    j--;
  } <span style="color: #00ffff;">else</span> {
    <span style="color: #00ffff;">break</span>;
  }
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-2-9" class="outline-3">
<h3 id="sec-2-9">9</h3>
<div class="outline-text-3" id="text-2-9">
<p>
Give an efficient algorithm to compute the union of sets A and B,
where n = max( | A | , | B | ). The output should be an array of
distinct elements that form the union of the sets, such that they
appear more than once in the union.
</p>

<ul class="org-ul">
<li>Assume that A and B are unsorted. Give an O(nlogn) algorithm for the
problem.
</li>

<li>Assume that A and B are sorted. Give an O(n) algorithm for the problem.
</li>

<li>O(nlogn)对Ａ和Ｂ排序，然后用2的O(n)的方法。
</li>
<li>若Ａ和Ｂ以升序排序
<div class="org-src-container">

<pre class="src src-sh"><span style="color: #b0c4de;">set</span> U to empty;
int <span style="color: #eedd82;">i</span> = 0;
int <span style="color: #eedd82;">j</span> = 0;
<span style="color: #00ffff;">while</span> (i &lt; na &amp;&amp; j &lt; na) {
  <span style="color: #00ffff;">if</span> (A[i] &lt; B[j]) {
    add A[i] into U;
    i++;
  } <span style="color: #00ffff;">else</span> (A[i] &gt; B[j]) {
      add B[j] into U;
      j++;
    }
  <span style="color: #00ffff;">else</span> {
     add A[i] into U;
    i++;
    j++;
  }
}
<span style="color: #00ffff;">if</span> (i &lt; na) {
  <span style="color: #00ffff;">while</span> (i &lt; na) {
    add A[i] into U;
    i++;
  }
<span style="color: #00ffff;">if</span> (j &lt; nb) {
  <span style="color: #00ffff;">while</span> (j &lt; nb) {
   add B[j] into U;
      j++;
    }
}
</pre>
</div>
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-2-10" class="outline-3">
<h3 id="sec-2-10">10</h3>
<div class="outline-text-3" id="text-2-10">
<p>
Given a set S of n integers and an integer T, give an O(n<sup>k − 1</sup>logn)
algorithm to test whether k of the integers in S add up to T.
</p>

<ol class="org-ol">
<li>O(nlogn）对数组排序
</li>
<li>(k-1)个数的组合有n<sup>k-1</sup>，并计算k-1个数的和sum
</li>
<li>用binary search在数组中搜索T-sum
</li>
</ol>
</div>
</div>

<div id="outline-container-sec-2-11" class="outline-3">
<h3 id="sec-2-11">11</h3>
<div class="outline-text-3" id="text-2-11">
<p>
Design an O(n) algorithm that, given a list of n elements, finds all
the elements that appear more than n / 2 times in the list. Then,
design an O(n) algorithm that, given a list of n elements, finds all
the elements that appear more than n / 4 times.
</p>

<p>
Hash Table 可以解决。或
</p>
</div>

<div id="outline-container-sec-2-11-1" class="outline-4">
<h4 id="sec-2-11-1">Find the elements that appear more than n / 2 times</h4>
<div class="outline-text-4" id="text-2-11-1">
<p>
数组中最多有一个数超过重复n/2次，并且排序后的第ceiling(n/2)个数必定是这个数。
</p>
<ol class="org-ol">
<li>method1
<ul class="org-ul">
<li>利用<a href="http://wiki.dreamrunner.org/public_html/Algorithms/Theory%20of%20Algorithms/Median%20Problem.html#sec-5">BFPRT</a> 以O(n)的复杂度找到第ceiling(n/2)个小数;
</li>
<li>扫描数组，计数这个数的重复数是否大于n/2.
</li>
</ul>
</li>
<li>method2
<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;stack&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">stack</span>;

<span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">FindMoreThanHalf</span>(<span style="color: #98fb98;">int</span> *<span style="color: #eedd82;">array</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">n</span>, <span style="color: #98fb98;">int</span> *<span style="color: #eedd82;">res</span>) {
  <span style="color: #98fb98;">stack</span>&lt;<span style="color: #98fb98;">int</span>&gt; <span style="color: #eedd82;">stk</span>;
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span>;
  <span style="color: #00ffff;">for</span> (i = 0; i &lt; n; ++i) {
    <span style="color: #00ffff;">if</span> (stk.empty()) {
      stk.push(array[i]);
    } <span style="color: #00ffff;">else</span> {
      <span style="color: #00ffff;">if</span> (stk.top() == array[i]) {
        stk.push(array[i]);
      } <span style="color: #00ffff;">else</span> {
        stk.pop();
      }
    }
  }
  <span style="color: #00ffff;">if</span> (stk.empty()) {
    <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">false</span>;
  }
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">candidate</span> = stk.top();
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">times</span> = 0;
  <span style="color: #00ffff;">for</span> (i = 0; i &lt; n; ++i) {
    <span style="color: #00ffff;">if</span> (array[i] == candidate) {
      times++;
    }
  }
  <span style="color: #00ffff;">if</span> (times &gt; n / 2) {
    *res = candidate;
    <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">true</span>;
  }
  <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">false</span>;
}
</pre>
</div>
</li>
</ol>
</div>
</div>

<div id="outline-container-sec-2-11-2" class="outline-4">
<h4 id="sec-2-11-2">Find the elements that appear more than n / 4 times</h4>
<div class="outline-text-4" id="text-2-11-2">
<ul class="org-ul">
<li>method1
<ol class="org-ol">
<li>利用<a href="http://wiki.dreamrunner.org/public_html/Algorithms/Theory%20of%20Algorithms/Median%20Problem.html#sec-5">BFPRT</a> 以O(n)的复杂度找到中间数，验证中中间数是否重复
n/4(O(n));
</li>
<li>以中间元素划分数组为两部分(O(n));
</li>
<li>在上下半部分n/2中重复n/4次数的元素，同第一个问题一样找(O(n));
</li>
</ol>
</li>
<li>method2
<ol class="org-ol">
<li>初始3个空的槽，想对应的槽的3个计数为0;
</li>
<li>对于数组中每个元素：
<ul class="org-ul">
<li>若等于其中任何一个槽中数，增加计数;
</li>
<li>若有槽空，放入这个槽，并计数为1;
</li>
<li>否则，对所有槽内数的计数减1
</li>
</ul>
</li>
<li>对槽内剩下的数，扫描一遍数组，计算它们重复次数是否符合要求。
</li>
</ol>
</li>
</ul>
</div>
</div>
</div>
<div id="outline-container-sec-2-12" class="outline-3">
<h3 id="sec-2-12">12</h3>
<div class="outline-text-3" id="text-2-12">
<p>
Devise an algorithm for finding the k smallest elements of an unsorted
set of n integers in O(n + klogn).
</p>

<ol class="org-ol">
<li>O(n)的复杂度建立一个最小堆;
</li>
<li>连续k次取出最小值，最后得到第k个最小值。
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-13" class="outline-3">
<h3 id="sec-2-13">13</h3>
<div class="outline-text-3" id="text-2-13">
<p>
You wish to store a set of n numbers in either a max-heap or a sorted
array. For each application below, state which data structure is
better, or if it does not matter. Explain your answers.
</p>

<ol class="org-ol">
<li>Want to find the maximum element quickly.
</li>
<li>Want to be able to delete an element quickly.
</li>
<li>Want to be able to form the structure quickly.
</li>
<li>Want to find the minimum element quickly.
</li>

<li>都开销O(1)。
</li>
<li>若知道删除的地方，max-heap花费O(logn)，sorted array花费O(n)。若不知道删除的地方，max-heap花费O(n)查找，删除花费O(logn); sorted
array binary search花费O(logn)，删除花费O(n)。
</li>
<li>max-heap花费O(n);sorted array花费O(logn)。
</li>
<li>max-heap花费O(n);sorted array花费O(1)。
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-14" class="outline-3">
<h3 id="sec-2-14">14</h3>
<div class="outline-text-3" id="text-2-14">
<p>
Give an O(nlogk)-time algorithm that merges k sorted lists with a
total of n elements into one sorted list. (Hint: use a heap to speed
up the elementary O(kn)-time algorithm).
</p>

<ol class="org-ol">
<li>扫描k组sorted lists组成一个大小k的min-heap;
</li>
<li>从min-heap中取出最小值放入结果list。
</li>
</ol>
</div>
</div>

<div id="outline-container-sec-2-15" class="outline-3">
<h3 id="sec-2-15">15</h3>
<div class="outline-text-3" id="text-2-15">
<p>
(a) Give an efficient algorithm to find the second-largest key among n
keys. You can do better than 2n − 3 comparisons. (b) Then, give an
efficient algorithm to find the third-largest key among n keys. How
many key comparisons does your algorithm do in the worst case? Must
your algorithm determine which key is largest and second-largest in
the process?
</p>

<ul class="org-ul">
<li>找第二大元素：大小为2个的数组初始化为第一二个元素，之后每个元素与这数组对比，剔除最小的，最后数组内2个元组对比得到最大和第二大元素，一共比较2(n-2)+1=2n-3，找出第二大元素。
</li>
<li>找第三大元素：同样已大小为3的数组，最后比较数3(n-3)+2=3n-7。
</li>
</ul>

<p>
<a href="http://wiki.dreamrunner.org/public_htmlAlgorithms/Theory%20of%20Algorithms/Selection%20Problem.html#sec-4">Random Selection</a>可以找出任意的第几大值，平均时间复杂度：O(n)，比较次数将是n的倍数，最坏时间复杂度可以达到：O(nlogn)。
</p>

<p>
<a href="http://wiki.dreamrunner.org/public_html/Algorithms/Theory%20of%20Algorithms/Selection%20Problem.html#sec-6">Tournament Algorithm</a>找第二大元素比较次数O(n+logn);找第k个最大元素，比较次数为O(n+klogn)。
</p>
</div>
</div>

<div id="outline-container-sec-2-16" class="outline-3">
<h3 id="sec-2-16">16</h3>
<div class="outline-text-3" id="text-2-16">
<p>
Use the partitioning idea of quicksort to give an algorithm that
finds the median element of an array of n integers in expected O(n)
time. (Hint: must you look at both sides of the partition?)
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">unsigned</span> <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">seed</span> = time(<span style="color: #7fffd4;">NULL</span>);
<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">randint</span>(<span style="color: #98fb98;">int</span> <span style="color: #eedd82;">m</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">n</span>) {
  <span style="color: #00ffff;">return</span> m + rand_r(&amp;seed) / (RAND_MAX / (n + 1 - m) + 1);
}

<span style="color: #98fb98;">void</span> <span style="color: #87cefa;">RandomSelectionK</span>(<span style="color: #98fb98;">int</span> *<span style="color: #eedd82;">array</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">l</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">u</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">k</span>) {
  <span style="color: #00ffff;">if</span> (l &gt;= u) {
    <span style="color: #00ffff;">return</span>;
  }
  swap(array[l], array[randint(l, u)]);
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">pivot</span> = array[l];
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span> = l;
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">j</span> = u + 1;
  <span style="color: #00ffff;">while</span> (<span style="color: #7fffd4;">true</span>) {
    <span style="color: #00ffff;">do</span> {
      ++i;
    } <span style="color: #00ffff;">while</span> (i &lt;= u &amp;&amp; array[i] &lt; pivot);
    <span style="color: #00ffff;">do</span> {
      --j;
    } <span style="color: #00ffff;">while</span> (array[j] &gt; pivot);
    <span style="color: #00ffff;">if</span> (i &gt; j) {
      <span style="color: #00ffff;">break</span>;
    }
    swap(array[i], array[j]);
  }
  swap(array[l], array[j]);
  <span style="color: #00ffff;">if</span> (j &lt; k) {
    RandomSelectionK(array, j + 1, u, k);
  } <span style="color: #00ffff;">else</span> <span style="color: #00ffff;">if</span> (j &gt; k) {
    RandomSelectionK(array, l, j - 1, k);
  }
}
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-2-17" class="outline-3">
<h3 id="sec-2-17">17</h3>
<div class="outline-text-3" id="text-2-17">
The median of a set of n values is the $\lceil n/2 \rceil$ th smallest
value. <br>
1. Suppose quicksort always pivoted on the median of the current
   sub-array. How many comparisons would Quicksort make then in the
   worst case? <br>

2. Suppose quicksort were always to pivot on the $\lceil n/3 \rceil$ th
   smallest value of the current sub-array. How many comparisons would
   be made then in the worst case? <br>

<p>
f(n) = 2*f(n/2) + n ==&gt; f(n) = 2<sup>k</sup> * f(n/2<sup>k</sup>) + kn = (n+2)logn
f(n) = f(n/3) + f(2n/3) + n ==&gt; f(n) = O(nlogn)
</p>
</div>
</div>

<div id="outline-container-sec-2-18" class="outline-3">
<h3 id="sec-2-18">18</h3>
<div class="outline-text-3" id="text-2-18">
<p>
Suppose an array A consists of n elements, each of which is red,
white, or blue. We seek to sort the elements so that all the reds come
before all the whites, which come before all the blues The only
operation permitted on the keys are
</p>

<ul class="org-ul">
<li>Examine(A,i) &#x2013; report the color of the ith element of A.
</li>
<li>Swap(A,i,j) &#x2013; swap the ith element of A with the jth element.
</li>
</ul>
<p>
Find a correct and efficient algorithm for red-white-blue sorting.
There is a linear-time solution.
</p>

<p>
2次扫描。
</p>
<ul class="org-ul">
<li>第一次：把red和white当成一样，用quick的partition分开与blue。
</li>
<li>第二次：只区分red和white的子区间。   
</li>
</ul>
</div>
</div>

<div id="outline-container-sec-2-19" class="outline-3">
<h3 id="sec-2-19">21</h3>
<div class="outline-text-3" id="text-2-19">
<p>
Stable sorting algorithms leave equal-key items in the same relative
order as in the original permutation. Explain what must be done to
ensure that mergesort is a stable sorting algorithm.
</p>

<p>
在合并时元素相等时选index小的元素在前。
</p>
</div>
</div>

<div id="outline-container-sec-2-20" class="outline-3">
<h3 id="sec-2-20">22-23</h3>
<div class="outline-text-3" id="text-2-20">
<p>
Show that n positive integers in the range 1 to k can be sorted in
O(nlogk) time. The interesting case is when k &lt; &lt; n.
</p>

<p>
We seek to sort a sequence S of n integers with many duplications,
such that the number of distinct integers in S is O(logn). Give an
O(nloglogn) worst-case time algorithm to sort such sequences.
</p>

<p>
balanced binary search tree.
</p>
</div>
</div>

<div id="outline-container-sec-2-21" class="outline-3">
<h3 id="sec-2-21">24</h3>
<div class="outline-text-3" id="text-2-21">
<p>
Let A[1..n] be an array such that the first \(n-\sqrt n\)  elements are
already sorted (though we know nothing about the remaining elements).
Give an algorithm that sorts A in substantially better than nlogn
steps.
</p>

+ $O(\sqrt{n}log(\sqrt{n})$ 排序后面的 $\sqrt{n}$ 个元素。<br>
+ O(n)去mergesort前半部分和后半部分。
</div>
</div>

<div id="outline-container-sec-2-22" class="outline-3">
<h3 id="sec-2-22">25</h3>
<div class="outline-text-3" id="text-2-22">
<p>
Assume that the array A[1..n] only has numbers from \(\{1,\ldots, n^2\}\)
but that at most loglogn of these numbers ever appear. Devise an
algorithm that sorts A in substantially less than O(nlogn).
</p>

<p>
和23一样，用balanced binary search tree，树的高度不超过loglogn,最后的复杂度O(n*logloglogn)。
</p>
</div>
</div>
<div id="outline-container-sec-2-23" class="outline-3">
<h3 id="sec-2-23">27</h3>
<div class="outline-text-3" id="text-2-23">
<p>
Let P be a simple, but not necessarily convex, polygon and q an
arbitrary point not necessarily in P. Design an efficient algorithm
to find a line segment originating from q that intersects the maximum
number of edges of P. In other words, if standing at point q, in what
direction should you aim a gun so the bullet will go through the
largest number of walls. A bullet through a vertex of P gets credit
for only one wall. An O(nlogn) algorithm is possible.
</p>

<ol class="org-ol">
<li>以ｑ为中心点，顺时针旋转，Ｐ中所有边随着顺时针旋转都有一个起始点
(head)和结束点（end），计算它们的极角（polar angle）; O(n)
</li>
<li>对所有head和end按照angle大小排序，若相等，head在前; O(nlogn)
</li>
<li>扫描这个排序好的队列，遇到head加1,遇到end减1,最后算出这个区间的最大值。O(n)
</li>
</ol>
</div>
</div>
<div id="outline-container-sec-2-24" class="outline-3">
<h3 id="sec-2-24">30</h3>
<div class="outline-text-3" id="text-2-24">
<p>
A company database consists of 10,000 sorted names, 40% of whom are known as good customers and who together account for 60% of the accesses to the database. There are two data structure options to consider for representing the database:
</p>
<ol class="org-ol">
<li>Put all the names in a single array and use binary search.
</li>
<li>Put the good customers in one array and the rest of them in a
second array.
</li>
</ol>

<p>
Only if we do not find the query name on a binary search of the first
array do we do a binary search of the second array. Demonstrate which
option gives better expected performance. Does this change if linear
search on an unsorted array is used instead of binary search for both
options?
</p>

<ul class="org-ul">
<li>single array: log10000=4
</li>
<li>two array: 0.6*log4000+0.4*(log4000+log6000) = 5.11
</li>
</ul>
<p>
single array is better.
</p>

<ul class="org-ul">
<li>single array: 10000
</li>
<li>two array: 0.6*4000+0.4*6000 = 6400
</li>
</ul>
<p>
two array is better.
</p>
</div>
</div>
<div id="outline-container-sec-2-25" class="outline-3">
<h3 id="sec-2-25">31</h3>
<div class="outline-text-3" id="text-2-25">
<p>
Suppose you are given an array A of n sorted numbers that has been
circularly shifted k positions to the right. For example,
{35,42,5,15,27,29} is a sorted array that has been circularly shifted
k = 2 positions, while {27,29,35,42,5,15} has been shifted k = 4
positions.
</p>

<ol class="org-ol">
<li>Suppose you know what k is. Give an O(1) algorithm to find the
largest number in A.
</li>

<li>Suppose you do not know what k is. Give an O(lgn) algorithm to find
the largest number in A. For partial credit, you may give an O(n)
algorithm.
</li>
</ol>


<div class="org-src-container">

<pre class="src src-c++"><span style="color: #00ffff;">if</span> (k == 0) {
  <span style="color: #00ffff;">return</span> A[n-1];
} <span style="color: #00ffff;">else</span> {
  <span style="color: #00ffff;">return</span> A[k-1];
}
</pre>
</div>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">int</span> <span style="color: #87cefa;">FindLargestNumber</span>(<span style="color: #98fb98;">int</span> *<span style="color: #eedd82;">array</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">l</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">h</span>) {
  <span style="color: #00ffff;">if</span> (array[l] &lt; array[h]) {
    <span style="color: #00ffff;">return</span> array[h];
  }
  <span style="color: #00ffff;">if</span> (l == h) {
    <span style="color: #00ffff;">return</span> array[h];
  }
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">mid</span>;
  mid = (l + h) / 2;
  <span style="color: #00ffff;">if</span> ((mid + 1 &lt;= h) &amp;&amp; array[mid] &gt; array[mid + 1]) {
    <span style="color: #00ffff;">return</span> array[mid];
  }
  <span style="color: #00ffff;">if</span> ((mid - 1 &gt;= l) &amp;&amp; array[mid - 1] &gt; array[mid]) {
    <span style="color: #00ffff;">return</span> array[mid - 1];
  }
  <span style="color: #00ffff;">if</span> (array[mid] &lt; array[h]) {
    <span style="color: #00ffff;">return</span> FindLargestNumber(array, l, mid - 1);
  } <span style="color: #00ffff;">else</span> {
    <span style="color: #00ffff;">return</span> FindLargestNumber(array, mid + 1, h);
  }
}
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-2-26" class="outline-3">
<h3 id="sec-2-26">32</h3>
<div class="outline-text-3" id="text-2-26">
<p>
Consider the numerical 20 Questions game. In this game, Player 1
thinks of a number in the range 1 to n. Player 2 has to figure out
this number by asking the fewest number of true/false questions.
Assume that nobody cheats.
</p>

<ol class="org-ol">
<li>What is an optimal strategy if n is known?
</li>
<li>What is a good strategy if n is not known?
</li>
</ol>


<ol class="org-ol">
<li>binary search.
</li>
<li>2<sup>i</sup>随机选一个i，若数小，增加到2<sup>i+1</sup>,若大就二分搜索。
</li>
</ol>
</div>
</div>

<div id="outline-container-sec-2-27" class="outline-3">
<h3 id="sec-2-27">33</h3>
<div class="outline-text-3" id="text-2-27">
<p>
Suppose that you are given a sorted sequence of distinct integers .
Give an O(lgn) algorithm to determine whether there exists an i index
such as ai = i. For example, in { − 10, − 3,3,5,7}, a3 = 3. In
{2,3,4,5,6,7}, there is no such i.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">CheckEqualIndex</span>(<span style="color: #98fb98;">int</span> *<span style="color: #eedd82;">array</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">l</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">h</span>) {
  <span style="color: #00ffff;">while</span> (l &lt;= h) {
    <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">mid</span> = (l + h) / 2;
    <span style="color: #00ffff;">if</span> (array[mid] &gt; (mid + 1)) {
      h = mid - 1;
    } <span style="color: #00ffff;">else</span> <span style="color: #00ffff;">if</span> (array[mid] &lt; (mid + 1)) {
      l = mid + 1;
    } <span style="color: #00ffff;">else</span> {
      <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">true</span>;
    }
  }
  <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">false</span>;
}
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-2-28" class="outline-3">
<h3 id="sec-2-28">34</h3>
<div class="outline-text-3" id="text-2-28">
<p>
Suppose that you are given a sorted sequence of distinct integers ,
drawn from 1 to m where n &lt; m. Give an O(lgn) algorithm to find an
integer  that is not present in a. For full credit, find the smallest
such integer.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">int</span> <span style="color: #87cefa;">FindMissingElement</span>(<span style="color: #98fb98;">int</span> *<span style="color: #eedd82;">array</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">l</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">h</span>) {
  <span style="color: #00ffff;">while</span> (l &lt;= h) {
    <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">mid</span> = (l + h) / 2;
    <span style="color: #00ffff;">if</span> (array[mid] &gt; (mid + 1)) {
      h = mid - 1;
    } <span style="color: #00ffff;">else</span> <span style="color: #00ffff;">if</span> (array[mid] &lt;= (mid + 1)) {
      l = mid + 1;
    }
  }
  <span style="color: #00ffff;">return</span> l + 1;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-2-29" class="outline-3">
<h3 id="sec-2-29">35</h3>
<div class="outline-text-3" id="text-2-29">
<p>
Let M be an n*m  integer matrix in which the entries of each row are
sorted in increasing order (from left to right) and the entries in
each column are in increasing order (from top to bottom). Give an
efficient algorithm to find the position of an integer x in M, or to
determine that x is not there. How many comparisons of x with matrix
entries does your algorithm use in worst case?
</p>

<p>
O(m+n)
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">bool</span> <span style="color: #87cefa;">FindElement</span>(<span style="color: #98fb98;">int</span> **<span style="color: #eedd82;">array</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">x</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">n</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">m</span>, <span style="color: #98fb98;">int</span> *<span style="color: #eedd82;">pos_x</span>, <span style="color: #98fb98;">int</span> *<span style="color: #eedd82;">pos_y</span>) {
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">row</span> = 0, <span style="color: #eedd82;">col</span> = m - 1;
  <span style="color: #00ffff;">while</span> (row &lt; n &amp;&amp; col &gt;= 0) {
    <span style="color: #00ffff;">if</span> (array[row][col] == x) {
      *pos_x = row;
      *pos_y = col;
      <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">true</span>;
    } <span style="color: #00ffff;">else</span> <span style="color: #00ffff;">if</span> (array[row][col] &gt; x) {
      col--;
    } <span style="color: #00ffff;">else</span> {
      row++;
    }
  }
  <span style="color: #00ffff;">return</span> <span style="color: #7fffd4;">true</span>;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-2-30" class="outline-3">
<h3 id="sec-2-30">36</h3>
<div class="outline-text-3" id="text-2-30">
<p>
Consider an n*n  array A containing integer elements (positive, negative,
and zero). Assume that the elements in each row of A are in strictly
increasing order, and the elements of each column of A are in strictly
decreasing order. (Hence there cannot be two zeroes in the same row or
the same column.) Describe an efficient algorithm that counts the
number of occurrences of the element 0 in A. Analyze its running time.
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #98fb98;">int</span> <span style="color: #87cefa;">CountZero</span>(<span style="color: #98fb98;">int</span> **<span style="color: #eedd82;">array</span>, <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">n</span>) {
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">row</span> = n - 1, <span style="color: #eedd82;">col</span> = n - 1;
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">count</span> = 0;
  <span style="color: #00ffff;">while</span> (row &gt;=0 &amp;&amp; col &gt;= 0) {
    <span style="color: #00ffff;">if</span> (array[row][col] == 0) {
      count++;
      row--;
    } <span style="color: #00ffff;">else</span> <span style="color: #00ffff;">if</span>(array[row][col] &gt; 0) {
      col--;
    } <span style="color: #00ffff;">else</span> {
      row--;
    }
  }
  <span style="color: #00ffff;">return</span> count;
}
</pre>
</div>
</div>
</div>
<div id="outline-container-sec-2-31" class="outline-3">
<h3 id="sec-2-31">40</h3>
<div class="outline-text-3" id="text-2-31">
<p>
If you are given a million integers to sort, what algorithm would you
use to sort them? How much time and memory would that consume?
</p>

<ol class="org-ol">
<li>一个整数４字节，10<sup>9</sup>*4=4G,需要4G的内存，可以用快排等O(nlogn)的排序算法．
</li>
<li>用bitmap,需要10<sup>9</sup>/8=128M的内存.
</li>
<li>若内存有限,就external merge sort,利用外部存储多进行几次.
</li>
</ol>
</div>
</div>

<div id="outline-container-sec-2-32" class="outline-3">
<h3 id="sec-2-32">41</h3>
<div class="outline-text-3" id="text-2-32">
<p>
Describe advantages and disadvantages of the most popular sorting
algorithms.
</p>

<p>
<b>Merge sort:</b>
</p>
<ul class="org-ul">
<li>优点:适合链表,适合外排.
</li>
<li>缺点:需要多余的内存来保存合并的数据.
</li>
</ul>

<p>
<b>Insertion/Selection sort:</b>
</p>
<ul class="org-ul">
<li>优点:简单实现.
</li>
<li>缺点:太慢,当数据很大时,运行不实际.
</li>
</ul>

<p>
<b>Heap sort:</b>
</p>
<ul class="org-ul">
<li>优点:不需要递归,适合大数据.
</li>
<li>缺点:时常慢于merge sort和quick sort.
</li>
</ul>

<p>
<b>Quick sort:</b>
</p>
<ul class="org-ul">
<li>优点:很快.
</li>
<li>缺点:递归,最坏情况比较慢.
</li>
</ul>
</div>
</div>
<div id="outline-container-sec-2-33" class="outline-3">
<h3 id="sec-2-33">42</h3>
<div class="outline-text-3" id="text-2-33">
<p>
Implement an algorithm that takes an input array and returns only the
unique elements in it.
</p>

<p>
排序,然后扫描输出.O(nlogn).
</p>
</div>
</div>
<div id="outline-container-sec-2-34" class="outline-3">
<h3 id="sec-2-34">43</h3>
<div class="outline-text-3" id="text-2-34">
<p>
You have a computer with only 2Mb of main memory. How do you use it to
sort a large file of 500 Mb that is on disk?
</p>

<p>
利用<a href="http://en.wikipedia.org/wiki/External_sorting">external merge sort</a>.
</p>
</div>
</div>

<div id="outline-container-sec-2-35" class="outline-3">
<h3 id="sec-2-35">44</h3>
<div class="outline-text-3" id="text-2-35">
<p>
Design a stack that supports push, pop, and retrieving the minimum
element in constant time. Can you do this?
</p>

<p>
只有一个stack办不到.如果两个stack,可以利用另外一个stack存储最小值.
</p>
</div>
</div>

<div id="outline-container-sec-2-36" class="outline-3">
<h3 id="sec-2-36">45</h3>
<div class="outline-text-3" id="text-2-36">
<p>
Given a search string of three words, find the smallest snippet of the
document that contains all three of the search words&#x2014;i.e., the
snippet with smallest number of words in it. You are given the index
positions where these words occur in the document, such as word1: (1,
4, 5), word2: (3, 9, 10), and word3: (2, 6, 15). Each of the lists are
in sorted order, as above.
</p>

<ol class="org-ol">
<li>选取每个字母index的首个元素作为起始方案。
</li>
<li>如何改进它的长度：a.增加最小的位置，b.减小最大的位置，这里只能增加最小的位置。
</li>
<li>用heap来保存位置，每次取出最小的位置为O(logk).
</li>
</ol>

<p>
复杂度：O(nlogk)，n是所有字母的位置个数，k是字母个数。这里k=3,所以O(n)
</p>

<div class="org-src-container">

<pre class="src src-c++"><span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;queue&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">priority_queue</span>;
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;utility&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">make_pair</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">pair</span>;
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;vector&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">vector</span>;
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;algorithm&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">max</span>;
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">min</span>;
<span style="color: #b0c4de;">#include</span> <span style="color: #ffa07a;">&lt;limits&gt;</span>
<span style="color: #00ffff;">using</span> <span style="color: #7fffd4;">std</span>::<span style="color: #98fb98;">numeric_limits</span>;


<span style="color: #98fb98;">int</span> <span style="color: #87cefa;">FindSmallestSnippet</span>(<span style="color: #98fb98;">vector</span>&lt;<span style="color: #98fb98;">vector</span>&lt;<span style="color: #98fb98;">int</span>&gt; &gt; &amp;<span style="color: #eedd82;">index_positions</span>) {
  <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">max-priority, select smallest position, use -index_positions[i][j], (i,j)</span>
  <span style="color: #98fb98;">priority_queue</span>&lt;<span style="color: #98fb98;">pair</span>&lt;<span style="color: #98fb98;">int</span>, <span style="color: #98fb98;">pair</span>&lt;<span style="color: #98fb98;">int</span> ,<span style="color: #98fb98;">int</span>&gt; &gt; &gt; <span style="color: #eedd82;">queue</span>;
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">max_pos</span> = 0; <span style="color: #ff7f24;">// </span><span style="color: #ff7f24;">the max pos of  the snippet</span>
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">i</span>;
  <span style="color: #00ffff;">for</span> (i = 0; i &lt; index_positions.size(); ++i) {
    <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">pos</span> = index_positions[i][0];
    max_pos = max(max_pos, pos);
    queue.push(make_pair(-pos, make_pair(i, 0)));
  }
  <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">smallest_len</span> = <span style="color: #7fffd4;">numeric_limits</span>&lt;<span style="color: #98fb98;">int</span>&gt;::max();
  <span style="color: #00ffff;">while</span> (queue.size() == index_positions.size()) {
    <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">min_pos</span> = -queue.top().first;
    smallest_len = min(smallest_len, max_pos - min_pos + 1);
    <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">word_pos</span> = queue.top().second.first;
    <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">index</span> = queue.top().second.second;
    queue.pop();
    ++index;
    <span style="color: #00ffff;">if</span> (index &lt; index_positions[word_pos].size()) {
      <span style="color: #98fb98;">int</span> <span style="color: #eedd82;">next_pos</span> = index_positions[word_pos][index];
      max_pos = max(max_pos, next_pos);
      queue.push(make_pair(-next_pos, make_pair(word_pos, index)));
    }
  }
  <span style="color: #00ffff;">return</span> smallest_len;
}
</pre>
</div>
</div>
</div>

<div id="outline-container-sec-2-37" class="outline-3">
<h3 id="sec-2-37">46</h3>
<div class="outline-text-3" id="text-2-37">
<p>
You are given 12 coins. One of them is heavier or lighter than the
rest. Identify this coin in just three weighings.
</p>

<ol class="org-ol">
<li>分3组,每组4个,其中两组称重,若相等,重的在第三组.若不等,重的在重的那一组.
</li>
<li>重的那组分4组,每组1个,第一组和第二组称重,谁重就重的那个.
</li>
<li>若step2相等,剩下第三组和第四组称重,谁重就重的那个.
</li>
</ol>
</div>
</div>
</div>

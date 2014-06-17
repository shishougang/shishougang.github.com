---
layout: post
title: "The Last Thing D Needs总结"
date: 2014-06-01 16:24:47 +0800
comments: true
categories: [C++]
tags: [C++]
---

* Will be replaced with the ToC, excluding the "Contents" header
{:toc}


[Effective C++](http://www.amazon.com/gp/product/0321334876?ie=UTF8&tag=aristeia.com-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=0321334876)
系列的作者[Scott Meyers](http://www.aristeia.com/)在Dconf中[The Last Thing D Needs](http://www.ustream.tv/recorded/47947981)聊了些C++的
特性，稍微总结一下。


## Initialization

``` c++ Initialization
int x1;         // unknown, initial(pay for it)
int x2;         // (at global scope) 0, no run time cost
static int x3;  // 0, static initialization
int *px = new int;  // heap memory, unknown, has run time cost
{
    int x4;    // unknown, has run time cost 
}
int a1[100];   // unknown
int a2[100];   // (at global scope) 0
static int a3[100];  // 0
std::vector<int> v(100);  // 0, use run time cost
```

<!-- more -->

## Type Deduction
``` c++ Type Deduction
const int cx = 0;
auto my_cx1 = cx;          // int, new independent value
decltype(cx) my_cx2 = cx;  // const int, standard said

template<typname T>
void f1(T param);
f1(cx);                    // T's type, int, same rules with auto

template<typename T>
void f2(T& param);
f2(cx);                   //T's type, const int, reference a chunk of memory, preserve the const

template<typename T>
void f3(T&& param);
f3(cx);                  //T's type, const int&, perfect argument forwarding, a special rule

const int cx = 0;
auto lam= [cx] {cx = 10;};       //error!
class UpToTheCompiler {
private:
  ??? cx;                      //const int
  ...
};

const int cx = 0;
auto lam= [cx = cx] {cx = 10;};     //error!
class UpToTheCompiler {
private:
  ??? cx;                          //int (but acts like const int)
  ...
public:
  void operator() const
  {cx = 0;}
};

const int cx = 0;
auto lam1= [cx = cx] mutable {cx = 10;};     //error!
auto lam2= [cx = cx]() mutable {cx = 10;};     //correct
class UpToTheCompiler {
private:
  ??? cx;                          //int (but acts like int)
  ...
};
```

For
{% codeblock %}
const int cx = 0;
{% endcodeblock %}
type deduction for cx yields:

<style>
table,th,td
{
border:1px solid black;
}
</style>


<table border="1" style="width:500px">
<tr>
<th> Context </th>
<th> Type </th>
</tr>

<tr>
<td> auto </td>
<td> int </td>
</tr>

<tr>
<td> decltype </td>
<td>  const int</td>
</tr>

<tr>
<td> template(T parameter)  </td>
<td> int </td>
</tr>

<tr>
<td> template(T& parameter)  </td>
<td> const int </td>
</tr>

<tr>
<td> template(T&& parameter)  </td>
<td> const int& </td>
</tr>

<tr>
<td> lambda (by-value capture) </td>
<td> const int  </td>
</tr>

<tr>
<td> lambda (int capture) </td>
<td>  int</td>
</tr>
</table>



``` c++ Type Deduction
//all do the same thing
int x1 = 0;
int x2(0);
int x3 = {0};
int x4 {0};

auto x1 = 0;  // int
auto x2(0);   // int
auto x3 = {0};// initializer_list<int>
auto x4 {0};  // initializer_list<int>

template <typname T>
void f(T param);
f({0});       // error! "{0}" has no type
```

## Inheritance
``` c++ inheritance
class Base {
public:
  void doBaseWork();
};
class Derived : public Base {
public:
  void doDerivedWord() {
    doBaseWord();               //ok
  }
};

template <typename T>
class Base {
public:
  void doBaseWork();
};
template <typename T>
class Derived : public Base<T> {
public:
  void doDerivedWord() {
    doBaseWord();               //no compile, later specialized version
  }
};

template <>
class Base<int> ();  // no doBasework

Derived<int> d;
d.doDerivedWord();  // fail
```

In essence, the <strong>One Definition Rule</strong> states that the same entity should have the exact same definition throughout an application, otherwise the effects are undefined.

The fundamental problem is that the code that doesn't see the specialized version of your class template member function might still compile, is likely to link, and sometimes might even run. This is because in the absence of (a forward declaration of) the explicit specialization, the non-specialized version kicks in, likely implementing a generic functionality that works for your specialized type as well.

## Computational Complexity
``` c++ computational Complexity
std::vector<int> v;
...
std::sort(v.begin(), v.end());   // O(nlogn)

std::list<int> li;
...
std::sort(li.begin(), li.end());  // not compile, list doesnot have random access iterator

auto it1 =
std::binary_search(v.begin(), v.end(), 10);  // O(logn)

auto it2 =
std::binary_search(li.begin(), li.end(), 10);  // O(n), officially(number of compares): O(logn)
```

## APIs

```c++ example
std::set<int> si;
...
si.erase(14);    // eliminate all 14s from si
```

* set             -->  erase
* multiset        -->     erase
* map             -->     erase
* multimap        -->     erase
* unordered_set   -->     erase
* unordered_multiset -->  erase
* unordered_map      -->  erase
* unordered_multimap -->  erase
* list               -->  remove
* forward_list       -->  remove

Sorts can be stable or unstable. Which are guaranteed to be stable?
* sort --> not guaranteed
* stable_sort  --> guaranteed
* list::sort --> guaranteed


## Specifications
Five sequence containers:

* array --> No
* deque --> Yes
* forward_list  --> No(fulfill of 1 of 16)
* list  --> Yes
* vector -- > Yes



## Essential and Accidental Complexity
Essential Complexity: due to inherent design tensions.

* Simplicity and regularity vs expressiveness.
* Abstraction and portability vs efficiency.
* New approaches vs compatibility with legacy systems.
* Expressiveness vs ability to issue good diagnostics.

*Essential Complexity*

``` c++ Point
struct Point {
  int x, y;
};
```
What is the type of Point::x?

``` c++ Point
Point p;
const Point &cp = p;
```
What is the type of cp.x?

C++ soluction:

``` c++
decltype(cp.x) = int
decltype((cp.x)) = const int&
```

``` c++ inheritance
template <typename T>
class Base {
public:
  void doBaseWork();
};
template <typename T>
class Derived : public Base<T> {
public:
  void doDerivedWord() {
    doBaseWrd();               //okay?
  }
};
```

Assume typo and diagnose now?

* Wrong if later specialization offers doBaseWrk.


Assume later specialization and defer lookup until instantiation?

* If typo, imposes diagnostics for library errors on clients.

C++ solution:

* Template author has control
    * doBaseWrk() -> lookup name when parsing template.
    * this->doBaseWrk() -> lookup name when instantiating template.
    
*Accidental Complexity*

* ints are sometimes initialized to 0.
* By-value lambda capture somtimes retains the constness of what's captured.
* mutable lambdas must declare a parameter list, but non-mutable lambdas don't
* Braced initializers (e.g."{0}") sometimes have a type.
* Computation complexity guarantees usually meaningful.
* Elimination all container elements with a given value usually means
  calling ``erase``.
* ``sort`` is sometimes stable.
* Container "requirements" are sometimes required.

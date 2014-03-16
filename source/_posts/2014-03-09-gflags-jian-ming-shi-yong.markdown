---
layout: post
title: "Gflags 简明使用"
date: 2014-03-09 11:53:54 +0800
comments: true
categories: C++
tags: gflags C++
---

## 简介
Google的gflags是一套命令行参数处理的开源库。比getopt更方便，更功能强大，从C++的库更好的支持C++（如C++的string类型）。包括[C++的版本](https://code.google.com/p/gflags/)和[python的版本](https://code.google.com/p/python-gflags/)。 这里只针对C++版本，python版本的使用类似。主要内容参考与翻译自官方文档：http://gflags.googlecode.com/svn/trunk/doc/gflags.html

你能从[这里下载](/downloads/code/2014/cmake_gflags_example.zip)本文章的源代码工程。

<!-- more -->

## example源代码
先看example源代码，然后逐步介绍。

``` c++ example.cc
#include <gflags/gflags.h>

DEFINE_bool(big_menu, true, "Include 'advanced' options in the menu listing");
DEFINE_string(languages, "english,french,german", "comma-separated list of languages to offer in the 'lang' menu");

int main(int argc, char **argv) {
  google::ParseCommandLineFlags(&argc, &argv, true);

  cout << "argc=" << argc << endl;
  if (FLAGS_big_menu) {
    cout << "big menu is ture" << endl;
  } else {
    cout << "big menu is flase" << endl;
  }

  cout << "languages=" << FLAGS_languages << endl;
  return 0;
}
```

### 运行程序
* 直接运行

``` bash run
  ➜  bin  ./sample 
  argc=1
  big menu is ture
  languages=english,french,german
```
* help命令

``` bash run
  ➜  bin  ./sample --help
  sample: Warning: SetUsageMessage() never called

  Flags from /home/shougang/workspace/drive/Google/cmake_cpp_gflags/src/sample.cc:
    -big_menu (Include 'advanced' options in the menu listing) type: bool
      default: true
    -languages (comma-separated list of languages to offer in the 'lang' menu)
      type: string default: "english,french,german"



  Flags from src/gflags.cc:
    -flagfile (load flags from file) type: string default: ""
  .........

  ➜  bin  ./sample --helpshort 
  sample: Warning: SetUsageMessage() never called

  Flags from /home/shougang/workspace/drive/Google/cmake_cpp_gflags/src/sample.cc:
    -big_menu (Include 'advanced' options in the menu listing) type: bool
      default: true
    -languages (comma-separated list of languages to offer in the 'lang' menu)
      type: string default: "english,french,german"
```
    

## 在程序里定义参数
### 包含头文件

``` c++ header_file
 #include <gflags/gflags.h>
```

### 利用gflag提供的宏定义参数
该宏的3个参数分别为命令行参数名，参数默认值，参数的帮助信息。

``` c++ define_flags
DEFINE_bool(big_menu, true, "Include 'advanced' options in the menu listing");
DEFINE_string(languages, "english,french,german", "comma-separated list of languages to offer in the 'lang' menu");
```
gflags暂时支持如下参数的类型：

``` sh supported_types
DEFINE_bool: boolean
DEFINE_int32: 32-bit integer
DEFINE_int64: 64-bit integer
DEFINE_uint64: unsigned 64-bit integer
DEFINE_double: double
DEFINE_string: C++ string
```

## 访问参数 ##

通过FLAGS_name像正常变量一样访问标志参数。在这个程序中，通过
`FLAGS_big_menu`和`FLAGS_languages`访问它们。

## 不同文件访问参数 ##

如果想再另外一个不是定义这个参数的文件访问这个参数的话，以参数
`FLAGS_big_menu`为例，用宏`DECLARE_bool(big_menu）`来声明引入这个参数。
这个宏相当于做了`extern FLAGS_big_menu`.

## 整合一起，初始化所有参数 ##

定义号参数后，最后要告诉执行程序去处理命令行传入的参数，使得
`FLAGS_*`参数们得到正确赋值。

通常就是再`main()`函数中调用;

``` c++ set_up_flag
google::ParseCommandLineFlags(&argc, &argv, true);
```
`argc`和`argv`就是main的入口参数，因为这个函数会改变他们的值，所以都是
以指针传入。

第三个参数被称为`remove_flags`。如果它是`true`,`ParseCommandLineFlags`会
从`argv`中移除标识和它们的参数，相应减少`argc`的值。然后argv只保留命令
行参数。

相反，`remove_flags`是`false`,`ParseCommandLineFlags`会保留`argc`不变，
但将会重新调整它们的顺序，使得标识再前面。

Note: `./sample --big_menu=false arg1`中再`big_menu`是标识，`false`是
它的参数，`arg1`是命令行参数。



## 命令行设置参数
gflags提供多种命令行设置参数。

`string`和`int`之类，可以用如下方式：

``` bash set_languages
app_containing_foo --languages="chinese,japanese,korean"
app_containing_foo -languages="chinese,japanese,korean"
app_containing_foo --languages "chinese,japanese,korean"
app_containing_foo -languages "chinese,japanese,korean"
```
对于`boolean`的标识来说，用如下方式:

``` bash set_boolean
app_containing_foo --big_menu
app_containing_foo --nobig_menu
app_containing_foo --big_menu=true
app_containing_foo --big_menu=false
```

和`getopt()`一样，`--`将会终止标识的处理。所以在`foo -f1 1 -- -f2 2`中，
`f1`被认为是一个标识，但`f2`不会。


## 特殊标识

``` bash special_flags
--help  显示文件中所有标识的完整帮助信息
--helpfull  和-help一样，
--helpshort  只显示当前执行文件里的标志
--helpxml  以xml凡是打印，方便处理
--version  打印版本信息，由google::SetVersionString()设定
--flagfile  -flagfile=f从文件f中读取命令行参数
...
```
具体见：http://gflags.googlecode.com/svn/trunk/doc/gflags.html

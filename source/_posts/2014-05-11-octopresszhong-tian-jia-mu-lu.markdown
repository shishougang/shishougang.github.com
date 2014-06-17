---
layout: post
title: "Octopress中添加目录"
date: 2014-05-11 17:01:34 +0800
comments: true
categories: Web
tags: Octopress

---
* content
{:toc}

## 目的
为Blog加入目录，方便读者快速浏览主题和选择主题。搜索发现
[文章1](http://brizzled.clapper.org/blog/2012/02/04/generating-a-table-of-contents-in-octopress/)
使用jQuery来实现，比较复杂，和
[文章2](http://blog.riemann.cc/2013/04/10/table-of-contents-in-octopress/#)
使用kramdown和Octoptress本身的样式来生成目录。

<!-- more -->

## 生成文章目录

### 使用Kramdown
Kramdown能自动为文章生成目录[^f1],所以使用Kramdown作为你的Octopress转
换程序，并且它支持Latex写公式，[如何用krramdown替换rdiscount](http://dreamrunner.org/blog/2014/03/09/octopresszhong-shi-yong-latexxie-shu-xue-gong-shi/)。


### 在博文中开头加入

```
* Will be replaced with the ToC, excluding the "Contents" header
{:toc}
```

### 添加样式

``` scss sass/custom/_styles.scss
#markdown-toc:before {
  content: "Table of Contents";
  font-weight: bold;
}
ul#markdown-toc {
  list-style: none;
  float: right;
  @include shadow-box;
  background-color: white;
}
```

### 只在文章里显示
因为目录的链接只针对当前文章，如果使用`<!-- more -->`只显示部分文章在
主页上，那么点击目录链接就会有问题，所以在主页隐去目录。

``` scss sass/custom/_styles.scss
.blog-index #markdown-toc {
  display: none;
}
```

### 效果
效果就如这篇文章。

[^f1]: http://kramdown.gettalong.org/converter/html.html#toc

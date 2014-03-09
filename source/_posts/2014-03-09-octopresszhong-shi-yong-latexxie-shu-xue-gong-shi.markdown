---
layout: post
title: "Octopress中使用Latex写数学公式"
date: 2014-03-09 19:41:06 +0800
comments: true
categories: Web
tags: Octopress LaTex MathJax
---

Octopress默认不支持LaTex写数学公式，这里修改Octopress使其支持。

## 测试

### 整段LaTex公式
{% codeblock lang:latex %}
$$
\begin{align}
\mbox{Union: } & A\cup B = \{x\mid x\in A \mbox{ or } x\in B\} \\
\mbox{Concatenation: } & A\circ B  = \{xy\mid x\in A \mbox{ and } y\in B\} \\
\mbox{Star: } & A^\star  = \{x_1x_2\ldots x_k \mid  k\geq 0 \mbox{ and each } x_i\in A\} \\
\end{align}
$$
{% endcodeblock %}

$$
\begin{align}
\mbox{Union: } & A\cup B = \{x\mid x\in A \mbox{ or } x\in B\} \\
\mbox{Concatenation: } & A\circ B  = \{xy\mid x\in A \mbox{ and } y\in B\} \\
\mbox{Star: } & A^\star  = \{x_1x_2\ldots x_k \mid  k\geq 0 \mbox{ and each } x_i\in A\} \\
\end{align}
$$

### 内嵌LaTex公式
{% codeblock lang:latex %}
If $a^2=b$ and $b=2$, then the solution must be
either $a=+\sqrt{2}$ or $a=-\sqrt{2}$.
{% endcodeblock %}

If $a^2=b$ and $b=2$, then the solution must be
either $a=+\sqrt{2}$ or $a=-\sqrt{2}$.

<!-- more -->

## 设置

### 1.用[kramdown](http://kramdown.gettalong.org/)代替rdiscount ###
+ 安装

``` bash
gem install kramdown
```

+ 修改``_config.yml``
把``_config.yml``中所有``rdiscount``替换成``kramdown``。

``` diff
--- a/_config.yml
+++ b/_config.yml
@@ -34,8 +34,8 @@ destination: public
 plugins: plugins
 code_dir: downloads/code
 category_dir: blog/categories
-markdown: rdiscount
-rdiscount:
+markdown: kramdown
+kramdown:
   extensions:
     - autolink
     - footnotes
```

+ 在``Gemfile``中把``gem 'ridiscount'``改成``gem 'kramdown in Gemfile``

``` diff
diff --git a/Gemfile b/Gemfile
index cd8ce57..e1d8d30 100644
--- a/Gemfile
+++ b/Gemfile
@@ -3,7 +3,7 @@ source "https://rubygems.org"
 group :development do
   gem 'rake', '~> 0.9'
   gem 'jekyll', '~> 0.12'
-  gem 'rdiscount', '~> 2.0.7'
+  gem 'kramdown'
   gem 'pygments.rb', '~> 0.3.4'
   gem 'RedCloth', '~> 4.2.9'
```


### 2.添加MathJax配置
在``/source/_includes/custom/head.html``文件里添加[^fn1]：

``` javascript
<!-- mathjax config similar to math.stackexchange -->
<script type="text/x-mathjax-config">
MathJax.Hub.Config({
  jax: ["input/TeX", "output/HTML-CSS"],
  tex2jax: {
    inlineMath: [ ['$', '$'] ],
    displayMath: [ ['$$', '$$']],
    processEscapes: true,
    skipTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code']
  },
  messageStyle: "none",
  "HTML-CSS": { preferredFont: "TeX", availableFonts: ["STIX","TeX"] }
});
</script>
<script src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML" type="text/javascript"></script>
```

### 3.修复MathJax右击页面空白bug[^fn2]

``` diff
diff --git a/sass/base/_theme.scss b/sass/base/_theme.scss
index c35136d..3ee3999 100644
--- a/sass/base/_theme.scss
+++ b/sass/base/_theme.scss
@@ -74,7 +74,7 @@ html {
   background: $page-bg image-url('line-tile.png') top left;
 }
 body {
-  > div {
+  > div#main {
     background: $sidebar-bg $noise-bg;
     border-bottom: 1px solid $page-border-bottom;
     > div {
```
     
## 更多信息

* [kramdown语法](http://kramdown.gettalong.org/)
* [kramdown数学模块](http://kramdown.gettalong.org/syntax.html#math-blocks)


[^fn1]: http://www.idryman.org/blog/2012/03/10/writing-math-equations-on-octopress/
[^fn2]: http://luikore.github.com/2011/09/good-things-learned-from-octopress/


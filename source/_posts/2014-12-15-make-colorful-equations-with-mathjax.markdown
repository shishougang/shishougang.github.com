---
layout: post
title: "Make colorful equations with mathjax"
date: 2014-12-15 22:18:35 +0800
comments: true
categories: Web
tags: Octopress LaTex MathJax
keywords: Octopress LaTex MathJax
description: Colorful equations with mathjax
---

$$
\begin{align}
\definecolor{x}{RGB}{114,0,172}
\definecolor{mean}{RGB}{45,177,93}
\definecolor{var}{RGB}{251,0,29}
\definecolor{e}{RGB}{18,110,213}

f(\color{x} x,\color{mean} \mu,\color{var} \sigma \color{black} ) =
\frac{1}{\color{var}\sigma \color{black} \sqrt{2\pi}} \color{e}
e \color{black} ^{- \frac{( {\color{x}x} - {\color{mean} \mu})^2}
{2{ \color{var} \sigma}^2}}
\end{align}
$$

其中,<font color="2DB15D"> $\mu$ </font> 是分布的均值或期望值,
而<font color="FB001D"> $\sigma$ </font> 是它的标准差, 
<font color="FB001D"> $\sigma^2$ </font>则是方差.

<!-- more -->

## 加载Mathjax Color extension

``` diff
--- a/head.html
+++ b/head.html
@@ -13,7 +13,8 @@
     skipTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code']
   },
   messageStyle: "none",
-  "HTML-CSS": { preferredFont: "TeX", availableFonts: ["STIX","TeX"] }
+  "HTML-CSS": { preferredFont: "TeX", availableFonts: ["STIX","TeX"] },
+  TeX: { extensions: ["color.js"] }
 });
 </script>
 <script src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML" type="text/javascript"></script>
```

## 使用

使用 ``\definecolor`` 和 ``\color`` 来为公式添加颜色如下:

``` javascript
\begin{align}
\definecolor{x}{RGB}{114,0,172}
\definecolor{mean}{RGB}{45,177,93}
\definecolor{var}{RGB}{251,0,29}
\definecolor{e}{RGB}{18,110,213}

f(\color{x} x,\color{mean} \mu,\color{var} \sigma \color{black} ) =
\frac{1}{\color{var}\sigma \color{black} \sqrt{2\pi}} \color{e}
e \color{black} ^{- \frac{( {\color{x}x} - {\color{mean} \mu})^2}
{2{ \color{var} \sigma}^2}}
\end{align}
```

MathJax的 ``\definecolor`` 不支持 ``HTML`` 的颜色颜色空间,所以手动在它
们之间转换颜色,文字部分如下:

``` html
其中,<font color="2DB15D"> $\mu$ </font> 是分布的均值或期望值,
而<font color="FB001D"> $\sigma$ </font> 是它的标准差, 
<font color="FB001D"> $\sigma^2$ </font>则是方差.
```

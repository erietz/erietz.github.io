---
title: "First post"
---

# Welcome

This is a test post. Everything appears to be working smoothly!

In order to get $\LaTeX$ to work, I had to create a folder `_includes/head` with
a file `custom.html` with the following content.

``` html
{% if page.mathjax %}
<script type="text/javascript" async
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
</script>
{% endif %}

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    extensions: ["tex2jax.js"],
    jax: ["input/TeX", "output/HTML-CSS"],
    tex2jax: {
      inlineMath: [ ['$','$'], ["\\(","\\)"] ],
      displayMath: [ ['$$','$$'], ["\\[","\\]"] ],
      processEscapes: true
    },
    "HTML-CSS": { availableFonts: ["TeX"] }
  });
</script> 
```

This solution did not break the main theme because `custom.html` is meant for
this purpose. Now I just have to at `mathjax: true` to posts to get mathjax.

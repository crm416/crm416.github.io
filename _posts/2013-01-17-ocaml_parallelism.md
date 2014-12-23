---
layout: post
title:  "True Parallelism in OCaml"
date:   2013-01-17
permalink: ocaml_parallelism
---

# True Parallelism in OCaml

OCaml provides a nice [library for multi-threading](http://caml.inria.fr/pub/docs/manual-ocaml-4.00/libref/Thread.html). Problem is, according to my professor, under the hood, **OCaml doesn't actually employ any parallelism at all!** In truth, the compiler just interleaves instructions in a way that has the same computational effect as multi-threading, barring the 2x speed-up.

On the side, I've been working on an alternative to the small Futures module we used in class. Futures are very similar to threads but safer and easier to use. The interface itself is composed of a **create** method, which takes as argument an expression to compute and performs said computation on a new thread; as well as a **force** method, which blocks the main thread until the Future has finished its computation.

<!--break-->

{% anchor h2 %}Processes{% endanchor %}

This alternative aims to operate at a lower level than would typically be done in OCaml and circumvent the language's lack of true multi-threading. To do so, it runs the desired computation on a separate UNIX process using some of [these features](http://ocamlunix.forge.ocamlcore.org). **Rather than trying to run two programs from within the same process, then, it seeks to run a single program, in two separate processes.**

{% anchor h2 %}Preserving Type Safety{% endanchor %}

One difficulty that I encountered along the way was preserving type-safety. To transfer information from the forked thread to the main thread (i.e., to return the result of the Future's computation), I use the [Marshal module](http://caml.inria.fr/pub/docs/manual-ocaml/libref/Marshal.html), which allows you to encode arbitrary data structures as sequences of bytes. However, the documentation includes the following, essential warning: **Warning: marshaling is currently not type-safe**. In reality, if you're trying to Marshall some expression *e* of type *'a*, you need to somehow pass type *'a* to the output function. That is, the Marshal module needs to know the output type of the data it's trying to decode. To handle that, I had to strictly enforce the type of the output computation as follows:

{% highlight ocaml %}
let future (f:'a -> 'b) (x:'a) : 'b future =
...
    let result : 'b = Marshal.from_channel (in_channel_of_descr fd_in) in
    ...
{% endhighlight %}

Notice that type *'b*, the desired output of the function *f*, is explicitly enforced as the output of the Marshal operation.

{% anchor h2 %}Thread Pools{% endanchor %}

One issue: I haven't gotten around to implementing a [thread pool](http://en.wikipedia.org/wiki/Thread_pool_pattern) for the Futures module. That is, if you run some massive computation that requires too many threads, you run into all sorts of errors. On my machine, running the *Mergesort* demo with a list of size 1000 results in a crash (this seems to be roughly the threshold).

Besides that, the package seems to be working, and the speed-up approaches 2x as I increase the size of the input to various functions. Give it a try: all the code is on [GitHub](https://github.com/crm416/ocaml-futures).
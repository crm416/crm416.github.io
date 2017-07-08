---
layout: post
page_title: "Compiling to JavaScript: A Case-by-Case Guide to the *Scripts"
title: "Compiling to JS: Comparing TypeScript, CoffeeScript, etc."
date: 2013-09-19
permalink: compiling-to-js/
---

It seems like all the cool languages these days are compiling to JavaScript. (I joke, but replace 'cool' with 'relevant' and you might have a reasonable heuristic for evaluating the modernity of a programming language.)

[Jeremy Ashkenas](https://github.com/jashkenas), the creator of CoffeeScript, has a great [list](https://github.com/jashkenas/coffee-script/wiki/List-of-languages-that-compile-to-JS) of what seems like hundreds of languages, each of which helps prove my point.

<!--break-->

Why is this all-the-rage, you ask?

Firstly, in my opinion, when we say that a language compiles to JavaScript, we could really be talking about two different approaches:

1. **Long-standing languages (e.g., Python) that can compile down into JavaScript using a tool devoted to that very task (e.g., [these](https://github.com/jashkenas/coffee-script/wiki/List-of-languages-that-compile-to-JS##python) Python-to-JS compilers)**. In this case, the tool has been created not to explicitly replace JavaScript per se, but rather to allow programmers to write more of their code in a single language. (_Note: these libraries are often used because developers want to avoid using JavaScript due to personal dislike. In that way, you could say that these tools do replace JavaScript. But they weren't built with that as the primary goal._)

2. **Languages whose _sole purpose_ is to _compile to JavaScript_ (e.g., [TypeScript](http://www.typescriptlang.org))**. These languages came long after JavaScript, and only exist because of it. They don't really have their own VMs, etc.: they can only be run by compiling to JavaScript. **In this case, the language has been created because developers have qualms with Javascript**. And in some ways, these could be seen as higher-level languages: they claim to have some improvement of JavaScript and then compile down to it. I'll call these **\*Scripts**.

Each of these variants were conceived by different creators with different goals in mind. They offer their own strengths, their own weaknesses, their own biases, their own opinions, and so forth. (_Note: in most of these languages, you could include valid JavaScript in your source code without any problems._)

In this post, I'd like to give readers some insight into why they might choose one of these languages over (1) JavaScript, and (2) the other \*Scripts in contention.

{% anchor h2 %}CoffeeScript{% endanchor %}
I see [CoffeeScript](http://coffeescript.org) as the poster child of the \*Scripts. Really, CoffeeScript aims to make your code more concise and more readable. The syntax doesn't use any of the '{' and '(' and ';' that plague JavaScript code, instead opting to use whitespace (a lá Python). Again, similar to Python, it's got great comprehensions that require 10x more JavaScript code to implement.

Here's an example of these list comprehensions:

{% highlight coffeescript %}
even_nums = (i for i in [0..10] when i % 2 == 0)
odd_nums = (i for i in [0..10] when i not in even_nums)

console.log even_nums ## prints '0, 2, 4, 6, 8'
console.log odd_nums ## prints '1, 3, 5, 7, 9'
{% endhighlight %}

If this doesn't look impressive on its own, check out the corresponding JavaScript:

{% highlight javascript %}
(function() {
  var even_nums, i, odd_nums,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  even_nums = (function() {
    var _i, _results;
    _results = [];
    for (i = _i = 1; _i <= 10; i = ++_i) {
      if (i % 2 === 0) {
        _results.push(i);
      }
    }
    return _results;
  })();

  odd_nums = (function() {
    var _i, _results;
    _results = [];
    for (i = _i = 1; _i <= 10; i = ++_i) {
      if (__indexOf.call(even_nums, i) < 0) {
        _results.push(i);
      }
    }
    return _results;
  })();

  console.log(even_nums);

  console.log(odd_nums);

}).call(this);
{% endhighlight %}

Why use CoffeeScript? It's just a pleasure. The syntax takes away the worst parts of JavaScript. The language appears more functional and less disgusting.

{% anchor h2 %}TypeScript{% endanchor %}

[TypeScript](http://www.typescriptlang.org) is a Microsoft project that aims to add static typing and a better module and interface system to JavaScript. Essentially, you can define classes and interfaces (very easily) and then enforce type safety at compile time, saving you tens of hours of awful JavaScript debugging.

One might claim that **CoffeeScript : Python :: TypeScript : OCaml**.

Lets see this type safety in action:

{% highlight ts %}
interface Point {
    x: number;
    y: number;
}

/* Calculate a Point's distance from the origin. */
function distance(a: Point): number {
    var squared_distance: number = a.x*a.x + a.y*a.y;
    return Math.sqrt(squared_distance);
}

var not_point: number = 15;
distance(not_point);
// type error: parameter does not match any signature of call target

var point: Point = {
    x: 3,
    y: 4
};
distance(point);
// success! returns '5'

var bad_point: Point = {
    x: 3
};
// type error: missing property 'y' from type Point
{% endhighlight %}


TypeScript also amplifies some of the functional flavor of JavaScript (albeit, less-so than CoffeeScript), mainly by adding the 'Fat Arrow' `(arg) => { // use arg }` lambdas. For example:

{% highlight javascript %}
document.addEventListener(myevent, (e) => {
    // Handle the event...
})
{% endhighlight %}

(_Note: the 'Fat Arrow' is part of [ECMAScript 6 specification](http://wiki.ecmascript.org/doku.php?id=harmony:arrow_function_syntax) and thus will eventually be supported by all JavaScript engines. [Firefox](http://robcee.net/2013/fat-arrow-functions-in-javascript/) already supports it._)

So, why use TypeScript? If you're a fan of type safety and a static type system, it's a no-brainer. And for large projects, it can be a life-saver. At the same time, it retains some of JavaScript's verbosity. You do end up with plenty of `})})};`-style code. In the end, it's a matter of preference.

{% anchor h2 %}LiveScript{% endanchor %}
[LiveScript](http://livescript.net) is even _more_ functional than CoffeeScript. To keep the analogies going, we might say that **CoffeeScript : Python :: TypeScript : OCaml :: LiveScript : Haskell**, or something like that.

As in CoffeeScript, LiveScript uses whitespace and newlines as delimiters, rather than the brackets of JavaScript.

I actually see LiveScript and CoffeeScript as a bit of a toss-up. If you're _really_ into functional programming, you might prefer LiveScript. For example, one differentiating factor: LiveScript allows for [function currying](http://en.wikipedia.org/wiki/Currying) (i.e., partial application of functions). Watch us define the `increment` function as adding one:

{% highlight livescript %}
add = (x, y) --> x + y
add 11, 9       ##=> 20
increment = add 1
increment 11    ##=> 12
{% endhighlight %}

In general, LiveScript has a strong functional lean. If that's for you, check it out.

{% anchor h2 %}RedScript{% endanchor %}

[RedScript](http://redscript.org) appeared on HackerNews recently, and although it certainly hasn't reached widespread adoption, I've included it here because I think it's a good example of how people are developing different 'flavors' of JavaScript.

At its core, RedScript wants to be a Ruby-flavored JavaScript. This makes it very easy to extend our analogy! **CoffeeScript : Python :: TypeScript : OCaml :: LiveScript : Haskell :: RedScript : Ruby**. For example, here's some valid RedScript that strongly resembles Ruby:

{% highlight ruby %}
for i in 0..5
  puts i
end
{% endhighlight %}

Actually, I lied: this not only "strongly resembles" Ruby—it _is_ [valid](http://www.tutorialspoint.com/ruby/ruby_loops.htm) Ruby.

If you're a Rubyist, try RedScript. It's as simple as that.

{% anchor h2 %}Conclusion{% endanchor %}

The languages described here are just a subset of the compile-to-JS family. But even with these four examples, we see:

* Function currying
* Static typing/type safety
* Whitespace vs. bracket delimiting

… and more.

JavaScript is a cool language. I love the community and I enjoy using it. But the development of these higher-level languages is cool too. If anything, they further emphasize the importance and relevance of JavaScript: without JavaScript, these languages would cease to run.

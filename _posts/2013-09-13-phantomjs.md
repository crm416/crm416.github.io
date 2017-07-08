---
layout: post
title: "Getting Started with PhantomJS: Common Gotchas for Beginners"
short_title: "PhantomJS: Common Gotchas for Beginners"
date: 2013-09-13
permalink: phantomjs/
description: "Considering PhantomJS? Save yourself hours of troublesome debugging and indecipherable error messages by avoiding these common errors, mistakes, and misunderstandings."
---

Over the summer, I had a pet project to automate [Helium.js](https://github.com/geuis/helium-css), a tool for identifying unused style elements in your CSS. Currently, in order to generate a Helium report, you need to add some JavaScript to your webpage, open up your web browser, navigate to the page, and click on some buttons.

My goal was to automate the process using a headless browser _(that is, a browser that runs without a GUI, allowing you to navigate the web and interact with web pages from your terminal)_. In this case, I chose to use [PhantomJS](http://phantomjs.org).

I had a mixed experience. Headless browsing is notoriously difficult to debug, and this case was no different: errors were tough to reproduce, results were inconsistent, and producing informative output was challenging.

Once I got past the initial difficulties, however, PhantomJS was an impressive tool—hats off to the creators, as always.

In this post, I'd like to describe some of the common "gotchas" that I've found associated with PhantomJS and walk through their solutions. (I call them "common" due to: 1. my own experience, and 2. finding similar questions/issues documented on StackOverflow.)

<!--break-->

_Note: that PhantomJS is often used in tandem with [CasperJS](http://casperjs.org); it's possible that some of what follows is made easier with Casper, namely, navigating webpages. But I think these gotchas are still valid, even in the face of Casper._

{% anchor h2 %}Code Context{% endanchor %}

Perhaps the first gotcha is that there are really two contexts in your PhantomJS program: firstly, the PhantomJS program itself; secondly, the webpage open in your headless browser, i.e., access to the DOM. (This is important for subsequent gotchas.)

What's the difference? Well, the PhantomJS code you write is used to control your browser automation at a high level. Think of it as the user of your browser. It can open up a webpage, save things to the filesystem, etc. However, any JavaScript that's executed in the actual webpage (i.e., interacting with the DOM) is a whole world of its own. In this sense, the PhantomJS program is ["sandboxed"](https://github.com/ariya/phantomjs/wiki/Quick-Start#code-evaluation).

A litmus test: if you're using jQuery, you're in the latter context.

{% anchor h2 %}Page.evaluate{% endanchor %}

With that in mind, one of the first questions that I asked myself, when using PhantomJS: "How can I execute JavaScript _on_ the given webpage itself?" In other words, I wanted to somehow mess around with the webpage using jQuery, and I couldn't figure out how to actually execute code in the context of the page.

The [solution](https://github.com/ariya/phantomjs/wiki/Quick-Start#code-evaluation): `page.evaluate` (where `page` is the variable representing the current page "open" in your headless browser).

`page.evaluate` takes, as argument, a function to-be executed in the context of the webpage. This is incredibly useful. Further, `page.evaluate` can return a result from the webpage back to your PhantomJS program. Say, for example, that you'd like to grab the text of an element on the current page with ID "foo":

{% highlight js %}
var foo = page.evaluate(function() {
    return $("#foo").text;
});
{% endhighlight %}

You could then use `foo` in your PhantomJS program, successfully extracting the value from the webpage. _Note: return values are limited to simple objects, rather than, say, functions._

{% anchor h2 %}IncludeJs and InjectJs{% endanchor %}

Actually, the code snippet above might not work as expected. I'll repeat it here for clarity:

{% highlight js %}
var foo = page.evaluate(function() {
    return $("#foo").text;
});
{% endhighlight %}

The problem? The active webpage might not have jQuery loaded.

Luckily, you can use PhantomJS to inject/include JavaScript files in the current webpage using two functions: `page.injectJs` and `page.includeJs`. The difference between the two is quite nuanced. There's a good discussion [here](https://groups.google.com/forum/#!topic/phantomjs/G4xcnSLrMw8) for those interested, but essentially, `page.injectJs` pauses execution until the script is loaded, while `page.includeJs` loads the script like any other. _Note: both accept callbacks._

Here's the revised code (credit to the [PhantomJS docs](https://github.com/ariya/phantomjs/wiki/Page-Automation)):

{% highlight js %}
page.includeJs("http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js", function() {
    var foo = page.evaluate(function() {
        return $("#foo").text;
    });
    // do what you gotta do with 'foo'
    // ...
});
{% endhighlight %}

{% anchor h2 %}Console.logging from your web browser{% endanchor %}

Similarly, I was often frustrated by the inability to display information logged by my webpage. Recall the split between the context of your PhantomJS program and the webpage open in your headless browser. Well, if you type `console.log("Hello, World!")` in your PhantomJS program, that will be printed to your terminal. If, however, your webpage tries to log the same message, it will pass by unnoticed! So if your webpage prints a bunch of traces to the console, you'll never see 'em.

Specifically, **the following code does nothing** because "Hello, World!" is printed in the context of the browser:

{% highlight js %}
page.evaluate(function() {
    console.log("Hello, World!")
});
{% endhighlight %}

So, what if you want to log messages to your terminal from within your webpage? The trick is to use the `page.onConsoleMessage` event and echo any messages printed in the browser out to your terminal. Try this:

{% highlight js %}
page.onConsoleMessage = function(msg) {
    console.log(msg);
};
{% endhighlight %}

For more, see my [StackOverflow answer](http://stackoverflow.com/questions/18115888/phantomjs-not-returning-results/18131369#18131369).

{% anchor h2 %}waitFor.js{% endanchor %}

PhantomJS beginners constantly ask how they can wait for something to appear on their webpage before acting. For example, maybe they want a banner to appear and then extract some text from it. Say "#foo" is now a div that loads a few seconds after the page has appeared. If you simply use the following code, you'll get unexpected results, as the banner may not be loaded at the time of query:

{% highlight js %}
var page = require('webpage').create();
page.open('http://www.sample.com', function() {
    var foo = page.evaluate(function() {
        return $("#foo").text;
    });
    // ...
    phantom.exit();
});
{% endhighlight %}

Instead, you should use [waitFor.js](https://github.com/ariya/phantomjs/blob/master/examples/waitfor.js), a nice JavaScript snippet provided by the PhantomJS guys. This function is pretty simple, but very, very useful. Essentially, it queries the page every few seconds (the exact interval is an optional parameter), executing a user-specified function when a certain condition has been met. Expanding on the previous example, our code might look like the following (excluding the lengthy definition of [waitFor](https://github.com/ariya/phantomjs/blob/master/examples/waitfor.js)):

{% highlight js %}
var page = require('webpage').create();
page.open('http://www.sample.com', function() {
    waitFor(function() {
            // Check in the page if a specific element is now visible
            return page.evaluate(function() {
                return $("#foo").is(":visible");
            });
        }, function() {
           var foo = page.evaluate(function() {
                return $("#foo").text;
            });
            // ...
            phantom.exit();
        });
    });
});
{% endhighlight %}

{% anchor h2 %}Going Forward{% endanchor %}

There's a lot more to PhantomJS than I've managed to go through in this post. And I'm personally excited to check out CasperJS at some point in the future, which seems great as well (in particular, for unit testing). But hopefully the tips and gotchas described in this post can be helpful for beginners.

---
layout: post
title:  "A Dynamic Graphing Interface for iOS"
date:   2012-11-13
permalink: ios_graphing
---

# A Dynamic Graphing Interface for iOS

This weekend was HackPrinceton, our school’s biannual hackathon run by the E Club (find out more [here](http://hackprinceton.com "HackPrinceton"), including the list of [winners](http://hackprinceton.com/results/ "HackPrinceton results")!). Unfortunately, a commitment on Saturday precluded my full-fledged participation; however, I managed to pump out a small tool on Friday: a dynamic graphing (note: **graphing**, not graphical) interface for iOS.

I’m not exactly sure how I’m going to use it, but the essence of the class is that it allows the client to create 3-D bar graphs (similar to Excel’s 3-D graphing modes) and feed the graphs data over time; as the data is received, the graphs resize themselves and adjust the axes as necessary.

Each bar is drawn individually with the Core Graphics library: first, the bar is drawn as a rectangle and, subsequently, the darker components are drawn around the initial bar to create perspective. The most challenging aspect of the project was implementing an appropriate resizing technique: for example, if a bar grows, you can’t just increase its height—if you do, it’ll stretch out and, in particular, the pieces of the bar used to generate perspective (especially the dark bit at the very top) will get stretched out and distorted. Instead, I used dynamic resizing with cap insets, i.e., the following steps:

1.  Create the bar as a generic UIView.
2.  Casted it to a UIImage with this code:


{% highlight objc %}
UIGraphicsBeginImageContext(bar.bounds.size);
[bar.layer renderInContext:UIGraphicsGetCurrentContext()];
UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();
UIImage *barImage = [viewImage resizableImageWithCapInsets:UIEdgeInsetsMake(bar.backdrop_size + 5, 0, bar.backdrop_size + 5, 0)];
{% endhighlight %}

Note above: you must ensure proper cap insets. In this case, the aim is to avoid stretching out the bar's perspective on the top and bottom; thus, we pad it with cap insets above and below—this enforces that only the middle section of the bar will be stretched out whenever the frame expands.

Finally, after creating the correct UIImage, just put it into a UIImageView and add it as a subview.

I’ve open-sourced the project [here](https://github.com/crm416/iOS-Elements "My Github"); hopefully I’ll get around to adding line graphs and some other features—or, better yet, finding a use for the class within an application!

Here's a demo:

<center><iframe width="400" height="300" src="http://www.youtube.com/embed/BG7eRU9of4Y?wmode=transparent&autohide=1&egm=0&hd=1&iv_load_policy=3&modestbranding=1&rel=0&showinfo=0&showsearch=0" frameborder="0" allowfullscreen></iframe></center>
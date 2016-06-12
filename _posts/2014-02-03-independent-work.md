---
layout: post
title:  "A Guide to CS Independent Work at Princeton"
date:   2014-02-03
permalink: independent-work/
---

# A Guide to CS Independent Work at Princeton

Last Spring, I did a semester of independent work (IW) with professor [David Walker](https://www.cs.princeton.edu/~dpw/). My project was focused on rule optimization in Software-Defined Networks (more [here](/intro_to_sdn/)), and it was probably the greatest learning experience of my Princeton career (so far).

I worked hard, and I learned a ton—not just about SDNs, but about the research process in general.

[Every COS major](http://iw.cs.princeton.edu/11-12/#Important_Information_for_Everyone) will do IW at some point. The COS Department has a decent guide [here](http://iw.cs.princeton.edu/11-12/), but after comparing and contrasting my experience with those of my friends, I wanted to jot down some notes about what worked and what didn't.

<!--break-->

Without further ado:

{% anchor h2 %}Optimize for the advisor, rather than the topic{% endanchor %}

I can't emphasize this enough: your advisor can _make_ or _break_ your experience. I was fortunate enough to have a great advisor who'd also been my professor the previous semester (in [COS 326](http://www.cs.princeton.edu/~dpw/courses/cos326-12/info.php)), but I have friends whose advisors showed little interest in their projects and met with them very rarely (more on this in a second).

When deciding on an advisor, start by thinking about the professors who've impressed you as _educators_: Who's shown attentiveness in the classroom? Who's been helpful during Office Hours? Who's done a great job of explaining difficult concepts?

"But what if I don't like Professor [X]'s field?", you might ask. In response: I knew nothing about SDNs prior to Spring 2013, but I was pretty sure that Professor Walker would be a good advisor. So I went with it.

Shockingly, the questions above are much more important than "Who teaches a subject I like?" You should look at IW as a chance to live and breathe the research process for a semester, rather than a chance to learn more about a topic that sounds cool. You can have both, of course; but if you have to choose, go for the former.

A great advisor in a mediocre field (in terms of your own interest) will prove a much more enjoyable experience than a crummy advisor in a field you love but can't break into.

{% anchor h2 %}Favor professor-suggested projects{% endanchor %}

If you're lucky, your advisor will have a project or two in-mind when you approach him or her. Try and stick to one of these. If the professor suggested the project, odds are they're in a good position to advise on it. If, instead, you suggest something out of left field, they might not be as familiar with the topic and thus slightly less useful as advisors.

{% anchor h2 %}Schedule weekly meetings with your advisor{% endanchor %}

This sounds like a no-brainer—but it's crucial. At the beginning of the semester, schedule a one-hour (or thirty minute) standing, weekly meeting with your advisor.

If you try to schedule a meeting ad-hoc every week:

1. You'll waste a ton of time on dreaded back-and-forth emailing.
2. You'll miss each other every couple of weeks. It's only natural.
3. You'll put off your work. With a standing meeting, you can set goals every week and know where you need to be in seven day's time. It does wonders for motivation. With spontaneous meetings, you'll procrastinate and push back your deadlines, knowing that you can hold-off on scheduling a meeting until you have something to show your advisor.

I really wanted to emphasize this point, so I'll exaggerate a little: This is the single greatest thing you can do to ensure a good IW experience.


{% anchor h2 %}Budget time for setting up your development environment{% endanchor %}

I didn't, and it put me behind on my scheduled goals. This could be the largest programming project you've ever undertaken individually (lines of code is a bad metric, but I wrote something like 3500). Budget time to set up source control, your dev environment, etc.

That said, I was working in [OCaml](http://ocaml.org), and I'd never used [OPAM](http://opam.ocamlpro.com) or [OMake](http://omake.metaprl.org/index.html) or [OUnit](http://ounit.forge.ocamlcore.org) before, so there was an unusual amount of overhead.

{% anchor h2 %}Papers are cryptic—email their authors{% endanchor %}

Every paper covers the vanilla case (if you're lucky). I've had papers completely ignore or exclude key definitions (by assuming their readers had read a previously published paper). I've come to _expect_ papers to disregard any mention of corner cases or input checking.

In short: papers are cryptic. Authors want to get the key ideas across, not guide you towards implementation. In fairness: that's just not their end-goal, so why would they note every little detail of the algorithm? It would only make the paper harder to understand for first-time readers.

I've spent countless hours slamming my head against the table trying to figure out why some code (based on an academic paper) wasn't working.

One such time came way after my IW (in December 2013). I was trying to implement a minimal enclosing triangle algorithm for [COS 451](http://www.cs.princeton.edu/courses/archive/fall13/cos451/) based on [this paper](http://prografix.narod.ru/source/orourke1986.pdf). After days of frustration, I emailed one of the authors, who got back to me within 24-hours. I had the algorithm working with just one minor change to two lines of code ([here's the result](https://github.com/crm416/point-location/blob/master/min_triangle.py), in all its glory). _(If you're interested, I wrote more on that project [here](http://www.toptal.com/python/computational-geometry-in-python-from-theory-to-implementation))._

The lesson: don't be afraid to email authors. They're human beings. In fact, they're a lot like your professors (or even your preceptors). Who knows—they'll might even be a bit flattered that you're interested in their work.

{% anchor h2 %}Don't be afraid to interact with graduate students and other professors{% endanchor %}

This one is even easier. Throughout the semester, I had help from [Nanxi Kang](http://www.cs.princeton.edu/~nkang/), [Cole Schlesinger](http://www.cs.princeton.edu/~cschlesi/), [Jennifer Rexford](http://www.cs.princeton.edu/~jrex/) (one of the leading SDN academics), and even [Nate Foster](http://www.cs.cornell.edu/~jnfoster/) (at Cornell) and [Arjun Guha](https://people.cs.umass.edu/~arjun/) (now at UMass-Amherst).

Everyone wants you to succeed, and (almost) everyone is friendly, so don't be afraid to ask others for help or allow your professor to connect you with graduate students and other colleagues.

Research is a collaborative process; embrace it.

{% anchor h2 %}Organization is key{% endanchor %}

At the end of the semester, you'll have to create both a poster and a 20+-page paper summarizing your findings and the process by which you reached them.

If you don't remain organized throughout the semester, you'll pay the price. Have the foresight to track _every_ paper you use.

My system:

1. Keep a folder ('Papers') with every single paper you read (as a PDF).
2. Give each PDF a memorable name (e.g., "Minimizing ternary rule sets").
3. Optional: Keep a Word Document or Evernote note with the title of each paper and a short description, as well as the URL to the original document.

When it comes time to write, you'll be glad you kept things neat and tidy.

{% anchor h2 %}In conclusion{% endanchor %}

Do independent work. It's an awesome experience and one of the things that makes Princeton a truly special place—so take advantage of the opportunity.

That said, don't walk into it blindly. It's feasible that your IW experience ends up a nightmare (bad advisor + bad project = a bad time). Combine a great advisor (someone who will respect you and mentor you) with your own hard work and you'll learn more than any course could ever teach you.

_Thanks to [David Dohan](https://github.com/dmrd) for his helpful comments in the editing of this post._
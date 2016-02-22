---
layout: post
title: "Reviewing Code from Both Sides"
date: 2016-02-22
description: "Code review is critical to our engineering culture at Khan Academy. But where you look at code can greatly influence your comments."
permalink: code-review
---

# Reviewing Code from Both Sides

At Khan Academy, code review is a key step in our engineering workflow—we use it as a mechanism for quality control, context sharing, and more. (See: [Code reviews at Khan Academy](https://sites.google.com/a/khanacademy.org/forge/for-developers/code-review-policy#TOC-Why-have-code-reviews-) for more.)

In making the jump from university (I graduated in June) to Real Engineering™, code review was one of my weak points. I hardly knew anything about it. At school, you never review code. On the job, you're reviewing daily.

With five months of consistent reviewing under my belt, I've begun to notice that _where_ I read code influences the types of observations I can and am compelled to make.

<!--break-->

In particular: reading code in a code review tool (we use [Phabricator](http://phabricator.org/)) leads me to make different observations than when reading code in an IDE.

### Reviewing in Phabricator

When reviewing in Phabricator, my comments tend towards smaller issues, be they style nits or more serious edits that nonetheless span just a handful of lines.

Since the visible code is confined to the changed lines, it can be challenging to see the big picture; as such, the tenor of the review is often that of 'Thumbs up on the general structure, but we should iron out these wrinkles'.

Yet, as a result of this focused presentation, simple oversights (leftover `console.log` statements et al.) are made much more obvious in the review tool than in an IDE, since they're surrounded by just a handful of changed lines and/or highlighted in green, rather than camouflaged within thousand-line files.

### Reviewing in an IDE

When reviewing in Android Studio (my IDE of 'choice' these days), I find it easier to identify opportunities for higher-level refactors and broader structural changes, since I can see the changed files in full, navigate with ease, and, more generally, rely on the same instincts I use when _writing_ code.

In the familiar interface of the IDE, I'm able to put myself in the _author's_ shoes by moving things around, seeing how they fit together, and so forth. Better yet, I can actually try out my suggestions before presenting them to the author. This leads to fewer 'Maybe we could...'-style caveats.

As an added bonus: an IDE can also point out changes that your eyes would be strained to detect, like the ability to convert an instance variable to a local variable (though these should probably be caught by a linter anyway).

### A Wholistic Review

Of course, these are generalizations, and as I've grown, the lines have blurred. (In particular, my ability to make high-level observations on the basis of a Phrabicator-read alone has improved—a progression that's also been influenced by my increased familiarity with our codebase.)

Nonetheless, reading code from these two perspectives together has helped me deliver more wholistic reviews, as both sets of comments are useful in their own ways.

My (loose) rule for the past few weeks has thus been to read through any non-trivial changes in both environments. This cuts both ways in that:

- When writing code, I skim it on Phabricator myself (with `arc diff --preview`) before submitting the change for review.
- When reviewing code, I patch the change in locally (with `arc patch {$ID}`) and mess around with it in the IDE before submitting my comments.

The result: ***fewer missteps as an author and more substantive feedback as a reviewer***.

Code review can be an intimidating and unfamiliar practice, especially to engineers coming straight out of school. If that resonates with you, try adopting this rule—put yourself in the reviewer's shoes when writing code, and the author's shoes when reading it—and see what comes out.

<p class="note">Thanks to <a target="_blank" href="http://www.shubhro.com">Shubhro Saha</a> for providing feedback on an earlier draft of this post.</p>
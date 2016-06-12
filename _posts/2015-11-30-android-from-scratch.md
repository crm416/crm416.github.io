---
layout: post
title: "Learning Android in a Production Setting"
date: 2015-11-30
permalink: learning-android/
description: "A few months ago, I started working on the Android team at Khan Academy—with no prior Android experience. In this post, I wanna share some of the lessons I learned ramping up on Android in a production setting."
---

# Learning Android in Production

Back in August, a few weeks before I'd joined [Khan Academy](https://www.khanacademy.org) full-time, our Head of Engineering, [Ben Kamens](http://bjk5.com/), shot me an email asking if I had any interest in working on the [Android](https://play.google.com/store/apps/details?id=org.khanacademy.android) team.

I'd never touched Android before, but I was pleasantly surprised to see that email, since the vision of bringing Khan Academy to Android devices had intrigued me for a while. If you imagine a world in which every student, everywhere has access to a free, world-class tutor in their pocket, Android is a big part of it. Joining the team struck me as a fantastic opportunity for impact.

So, I conveyed my excitement to Ben; but I couldn't help but ask:

> Is it an issue that I have no experience developing on Android?

In his response, Ben explained that this move would be part of a long-term effort to scale up Khan Academy's Android expertise. And that it was expected that there'd be a significant learning curve to getting me up and running on the platform.

Three months later, and I've built out new features, fixed nasty bugs, and grown to the point where I can meaningfully contribute to our team's technical discussions, as an Android voice. All having started from scratch in mid-September.

It's a wonderfully weird feeling.

<!--break-->

{% anchor h2 %}Ramping up{% endanchor %}

In this post, **I'd like to draw on some of the lessons I've learned from my experience—that of ramping up on Android development in the context of a _professional_, _production_ application**; one that consisted of thousands of lines of code and relied on dozens of then-mysterious technologies on the day I arrived.

Learning a new technology is always challenging. There are moments of confusion and moments of frustration. And learning a new technology in the context of a mature codebase (rather than a toy app, or a tutorial, or a side project) brings with it its own set of challenges—its own moments of confusion and frustration.

My hope is that following the tips in this post will make that process a little easier, both for Android developers and the wider engineering community, since some of these lessons generalize.

(Oh, and as a caveat: My best resource, by far, has been my wonderful colleagues at Khan Academy, who have gone out of their way to help me ramp up. I can't thank them enough for all their help, from the pairing sessions to the code reviews to the pats on the back. The best advice I can give any learner is to surround yourself with great people. But for the rest of this post, I'll try to stick to things that are actionable on an individual level.)

{% anchor h2 %}The On-Demand Learning Problem{% endanchor %}

To start, I'd like to draw a distinction between what I see as two very different learning scenarios.

The first is that of **on-demand learning**, in which one is trying to learn how to do something specific to solve a present or even pressing problem, like implement a specific feature or fix a specific bug.

The second is that of **ongoing** or **regular learning**, where findings typically don't lead to direct action, but instead contribute to a broader or deeper understanding of a platform or concept.

When you're new to a codebase, on-demand learning often (but not always) consists of: (1) reading an issue or feature spec, (2) grokking the existing code, and (3) Googling for explanations, answers, or, at a minimum, hints that will help you solve the problem.

(Ongoing learning can, of course, take many different forms, such as: monitoring digests, listening to conference talks, etc.)

Unfortunately, in Android-land, the quality of resources available for on-demand learning is very much lacking. **In other words: when you've hit a wall and you're looking for a specific answer, it's often difficult to track one down online**.

To me, this complaint stems from the _fragmentation_ of the Android API. Many of the top-ranking StackOverflow answers and blog posts that I find are several years old, advocating for solutions that have since been deprecated. Others still rely on newer API features that are unuseable if you want to support a reasonable minimum SDK version. The fragmentation cuts both ways.

As a separate point: learning in this kind of on-demand style, especially via StackOverflow posts, tends to promote something of a lackluster understanding of a problem, or even a [cargo cultish](https://en.wikipedia.org/wiki/Cargo_cult_programming) adoption of a solution (I've certainly found myself guilty of this).

If you are taking the Google approach, then, the ideal situation is that one of the few high-quality blogs (like [Dan Lew's](http://blog.danlew.net/)) has covered the topic you're working on and provided a realistic, elegant solution with strong backwards compatibility and a focus on foundational understanding. Of course, that's something of a rarity.

{% anchor h3 %}What's up, Docs?{% endanchor %}

The other natural place to turn to for this kind of on-demand insight would be the Android docs. And they're decent, albeit fragmented in their own way, given that there's [Training](https://developer.android.com/training/index.html), [API Guides](https://developer.android.com/guide/index.html), the [Class Overviews](https://developer.android.com/reference/android/app/ActionBar.html) in the API reference, and the [Developer Blog](http://android-developers.blogspot.com/).

While the docs and their related resources _can_ be very useful, in my experience, they often focus either too heavily on a single, toy use-case (e.g., using `CoordinatorLayout` with an `AppBarLayout`—but never with anything else), or spend much of their time describing what something does, rather than _how_ it does it (this is especially true of the Developer Blog, where I tend to find announcements of new API features, but few deep dives).

I don't want to sell the docs too short—I've found some satisfying answers in well-written Class Overviews, and when you _do_ find a good piece of documentation, the understanding it imparts will usually beat out that of a StackOverflow answer—but they're far from sufficient in _every_ case.

{% anchor h3 %}Going Straight to the Source{% endanchor %}

Luckily for us, Android is [open source](https://source.android.com/source/index.html). Which means that whenever you're confused, you have the option to step into the source and figure things out on your own, bypassing Google and/or the docs altogether.

The benefits of having open, unfettered access to the platform source code simply cannot be overstated (especially if you agree with my comments above). Grepping through the source is a habit that you should get into early on, since it only becomes easier over time. And it's worth stating explicitly: **reading the source is not just a great way to learn, but rather, the _only_ way to attain _true_ mastery over a concept**.

In that light, I'd recommend reading the source not as a last resort, but as an **initial attack vector** (in tandem with, perhaps, the API reference).

I've even gone as far as considering the unrigorous, catchall Googling of a problem statement (e.g., "How to listen for scrollview end scroll event") to be a bad habit. It's a hard one to kick as a beginner, but preferring a combination of documentation and source will promote long-term, deep understanding, rather than piecemeal or bespoke knowledge acquisiton. (Plus, though you may not expect it: it'll often save you time over the StackOverflow 'shortcut'.)

I typically access the Android source through Android Studio directly ('Find Usages' will take you there, and will even decompile classes from the [Design Support Library](http://android-developers.blogspot.com/2015/05/android-design-support-library.html)). Alternatively, [AndroidXRef](http://androidxref.com/) is useful for performing generalized symbol search across the Android Open Source Project, as is Roman Nurik's [Android SDK Search](https://chrome.google.com/webstore/detail/android-sdk-search/hgcbffeicehlpmgmnhnkjbjoldkfhoin?hl=en) Chrome plugin, which adds SDK search functionality to your Chrome Omnibox.

{% anchor h2 %}Ongoing Learning: Conference Talks & Podcasts{% endanchor %}

In addition to relying more and more on the source (and less and less on Google), I've also put a premium on engaging in ongoing learning efforts from Week 1.

For me, this has taken the form of (1) **watching conference talks** and (2) **listening to podcasts**. Since these mediums consist of long-form content, and the resources tend to be more recent, they can go deep and focus on realistic scenarios.

In particular, I've cranked through a bunch of the talks from [Droidcon 2015](https://www.youtube.com/watch?v=s3Zc6KvyYvU) and episodes of the [Fragmented podcast](fragmentedpodcast.com) (especially those featuring guests like [Jake Wharton](http://fragmentedpodcast.com/episodes/6/), [Hadi Hariri](http://fragmentedpodcast.com/episodes/20/), and [Dan Lew](http://fragmentedpodcast.com/episodes/3/)). Both are great resources.

(My colleagues have also recommended subscribing to <a href="http://androidweekly.net/" target="_blank">Android Weekly</a> and monitoring <a href="https://www.reddit.com/r/androiddev" target="_blank">/r/androiddev</a>, though these aren't practices that I've regularized yet.)

**Engaging with this kind of material on a consistent, ongoing basis—from an early date—has been the best investment I've made during the learning process**. While this approach won't scale well to solving a specific problem (you typically won't want to interrupt your debugging session by watching a one-hour video), it's incredibly useful for accelerating your learning curve more generally.

In fact, if you're ramping up in a professional setting, **I'd recommend that you start consuming this stuff as early as possible**. While it may seem strange to recommend expert-level content to a platform beginner, this technique does have a few interesting effects, including:

1. **Familiarizing you with a ton of platform-specific vocabulary, concepts, tools, and practices**.

    There's a ton of value in the simple act of listening to Android experts talk about Android. Certain technologies, tools, or concepts get mentioned repeatedly, like [Dagger](https://google.github.io/dagger/), [ButterKnife](https://jakewharton.github.io/butterknife/), [AppCompat](https://developer.android.com/tools/support-library/features.html#v7-appcompat), etc. You begin to notice, and their use-cases and usefulnesses start to take shape in your mind.
2. **Giving you a deep understanding of an array of topics**.

    That is, whichever topics are explicitly covered by the speakers. This knowledge tends to come in handy down the road, if not immediately. When I had to implement some complex click-interception behavior, I was pretty glad I'd seen [_Making Sense of the Touch System_](https://www.youtube.com/watch?v=usBaTHZdXSI) the week before.
3. **Helping you identify Android experts**.

    The bar tends to be high for appearing at a conference or on a podcast, so the individuals involved are often worth following.

If you find the right resources, you can create an incredible feedback loop whereby listening to experts will help you improve as a developer, and improving as a developer will make what they have to say more accessible and more interesting.

{% anchor h2 %}Tooling{% endanchor %}

Every new technology seems to bring with it additional tools to be mastered. Thankfully, with Android, there's really just one: [Android Studio](https://developer.android.com/tools/studio/index.html).

{% anchor h3 %}Mastering Android Studio{% endanchor %}

If you've worked with the IntelliJ IDEA platform before, then you'll Android Studio to be familiar. If you haven't, then let me just say: it's incredible. And its navigational and refactoring commands will make you so, so much more productive. (I say this as a Sublime convert.)

As a newcomer, some of the practices I've tried to instill in my own development process (a few of which I credit to [Fragmented](fragmentedpodcast.com)) include:

- **Avoiding the mouse/trackpad** and, instead, relying on keyboard shortcuts for navigation and the like. (The [Key promoter](https://plugins.jetbrains.com/plugin/4455?pr=clion) plugin can be useful for discouraging mouse reliance.)
- **Using targeted search commands** ('Search by File', 'Search by Class', 'Search by Symbol', etc.) in lieu of the default 'Find' action.
- **Abusing 'Find Usages'/'Find Declaration'**. I personally use this command non-stop (either by right-clicking or with Apple + B on OS X), which has the nice side effect of encouraging me to go as deep as the Android Source when debugging.
- **Disabling tabs**, either through the settings pane or by entering Zen Mode, to encourage heavier reliance on navigational shortcuts, like 'Last Edit Location' and 'Recently Edited Files'. (This tip comes from [Jake Wharton](http://fragmentedpodcast.com/episodes/6/).)

Familiarizing yourself with this one tool will take you a very, very long way. Even prominent Android developers Jake Wharton and Dan Lew use relatively vanilla setups (per their [Fragmented](fragmentedpodcast.com) interviews), so, evidently, there's little need to go deep into the woods with arcane tools or plugins.

_Aside: Beyond Android Studio, the only other software I use is [Genymotion](genymotion.com) (a replacement for the default Android emulator) and, occasionally, [Stetho](https://facebook.github.io/stetho/) (a debug bridge built by Facebook that lets you debug your app via Chrome DevTools)._

{% anchor h3 %}Cutting Down on Build Time{% endanchor %}

Finally, I want to recommend that newcomers—especially those learning in a production setting—focus on cutting down build time.

When you're working on a big app, builds will not only eat up a few minutes of your time, but can often serve as painful distractions, interrupting your Flow and encouraging you to context switch (also known as the 'Oh, I'll just open up Twitter while the app is building' problem).

While it's unlikely that you'll be rewriting your build system, there are simpler ways for beginners to make their lives easier here. For example, you might consider:

- Setting up a test activity (or even an entire test application) to render an in-progress UI component with stub data.
- Writing unit tests that can run without building to a device (e.g., by testing your SDK-agnostic code in an SDK-agnostic way, or using tools like [Robolectric](robolectric.org)).

This is something I wish I'd done better—I've spent a ton of time waiting around for our app to build when an upfront investment (i.e., to setup a test activity or test app) would've paid off tenfold.

_Aside: [Instant Run](https://sites.google.com/a/android.com/tools/tech-docs/instant-run) may solve this problem yet, though there's still something to be said for testing your code in isolated environments._

{% anchor h2 %}What's Next{% endanchor %}

Two weeks ago, we had our Khan Academy mobile team summit, where we took some time as a team to brainstorm, strategize, and catch up. As we began to form our vision for the year ahead, I was struck by the distinct feeling that, for me, the training wheels are off. And to feel that way after just a few weeks is pretty great. (Again: thanks and credit to my team for making that possible.)

But—I'm still not sure that I'd consider myself an 'Android engineer'. That's not to say that I'm yet to earn the title, but rather, that this experience has underscored the feeling I have that I don't need to be a '[blank] engineer'; that new things are learnable, given the right mindset.

For the foreseeable future, though, I'll be all Android, all the time. So stay tuned.

<p class="note">Thanks to <a target="_blank" href="http://www.shubhro.com">Shubhro Saha</a> and Ben Komalo for providing feedback on earlier drafts of this post.</p>

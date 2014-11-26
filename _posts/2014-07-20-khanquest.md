---
layout: post
title: "KhanQuest: Bringing Khan Academy-based Learning to a Fantasy Video Game"
date: 2014-07-20
permalink: khanquest
---

# KhanQuest: A Young Person's Illustrated Video Game

Thus marks the end of the Third Annual "Healthy Hackathon", Khan Academy's weekend-long celebration, which featured [awesome improvements to our CS platform](https://www.youtube.com/watch?v=Pq0OSkFhmhk), [awesome (and hilarious) fundraising efforts](https://znd-vowels-dot-khan-academy.appspot.com/buy-a-vowel), and [awesome (and hilarious) music videos](https://twitter.com/pamelafox/status/489968073915387905#), to name but a few of the fantastic hacks.

<i>P.S.: If you hate words and just want to play KhanQuest, click <a href="http://khan.github.io/KhanQuest/" target="_blank">here</a>.</i>

<!--break-->

{% anchor h2 %}Aside: Hackathons Can Be Healthy?{% endanchor %}

What separates the "Healthy Hackathon" from your typical hackathon is, well, everything about it. I'm not a big fan of the "competitive" hackathon, where hundreds of hackers stay up all night drinking Red Bull, racing to slap together the best crowd pleaser and "win" (see: the [Cash-omatic](http://greylocku.com/hackfest/#prizes)). But I digress!

In more concrete terms, what sets Khan Academy's Healthy Hackathon apart is that:

1. There is no staying up all night: Everyone is kicked out at midnight, lest they face the wrath of the Nerf gun. From then, the office doors remain locked until 9:30am.
2. There is no (or, very limited) junk food: All the catered food errs towards "healthy".
3. There is no "winning" and there are no "judges": Everyone gets a raffle ticket for participating, with additional tickets doled out for cool hacks via anonymous voting. The prizes also err more towards gag (think: favorite company board games) than prestige.

It's an opportunity to go off in a new direction among friends and work on something exciting that you'd otherwise defer or put off. That can lead to software that ships and software that doesn't, both of which are totally fine. In fact, one of the guiding principles of the hackathon is that your "hack" doesn't have to involve code.

You can read more on [Ben Kamens' blog](http://bjk5.com/post/56123354891/how-we-ran-the-second-khan-academy-healthy-hackathon) (note: his post describes the Second Annual "Healthy Hackathon", but I'll update the link soon).

{% anchor h2 %}KhanQuest{% endanchor %}

This year, my colleague [Zach Gotsch](https://github.com/zgotsch) rallied a few of us together on Thursday evening around a simple idea: take Khan Academy's core learning mechanics and philosophies, and wrap them within a fantasy video game (think _Pokemon_ meets _Final Fantasy_ meets _Harry Potter_). The team consisted of myself, Zach, [Joel Burget](http://joelburget.com/healthy-hackathon/), [Desmond Brand](http://desmondbrand.com/), [Jack Toole](https://github.com/jacktoole1), and [Michelle Todd](https://twitter.com/himichelletodd), with a special shoutout to [Elizabeth Lin](http://www.elizabethylin.com/about/) for lending her (unreal) design skills.

After a few solid days of hacking, we demoed **"KhanQuest"**. All the code is available on [GitHub](https://github.com/Khan/KAQuest), and you play it immediately (at your own risk) @ <a href="http://khan.github.io/KhanQuest/" target="_blank">this link</a>.

It's totally imperfect, and we love it.

The core plot line: our beloved Salman Khan has been kidnapped by an evil warlock (I think?), and it's your job as the trusty delivery boy/girl (who happens to look like some sort of mage) to save him, learning the requisite magic along the way.

Here's an extended screencast (with commentary):

<div style="text-align: center">
<iframe src="//player.vimeo.com/video/101366825" width="500" height="368" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
</div>

_(Confession: I had to crop out ~30 seconds of me struggling with a basic geometry problem around 3:10.)_

{% anchor h3 %}Game Mechanics{% endanchor %}

The mapping between game and Khan Academy mechanic actually worked out pretty well:

- Each subject within mathematics mapped to a type of spell (e.g., geometry mapped to fire spells, while algebra mapped to frost spells).
- Each exercise within a subject mapped to a specific spell (e.g., calculating the area of a triangle mapped to "Fireball").
- Completing a question on Khan Academy mapped to casting a spell (e.g., successfully calculating the area of a triangle mapped to casting "Fireball").

To bake in some of Khan Academy's learning philosophies, we also added a few minor tweaks:

- **Spells temporarily grew in strength as they _weren't_ used**. This sounds unintuitive, but the goal was to encourage players to go back and review (or tackle more difficult exercises), while giving them some payoff for doing so. For example, if you moved past basic addition, we'd want to make sure that you'd retained mastery of this basic skill even as you began to work on multiplication (or geometry or algebra). By giving a small boost to the basic addition spell that incremented over time, you'd be incentivized to go back at some point in the future and review that exercise, which would then reset this incremental boost.
- **Random monster encounters encouraged practice**. While boss battles would encourage you to master _new_ skills, random encounters with spiders, wolves, and other classic video-game enemies would encourage you to build on your abilities.

At the end of the weekend, the game was playable through the first few levels, complete with monster encounters, a variety of spells, dialog, and more.

However, there was _plenty_ that we didn't get around to implementing. Be sure to check out [Joel's blog post](http://joelburget.com/healthy-hackathon/) for a better discussion of (existing) bugs and flaws, as well as the challenges we faced.

{% anchor h3 %}Technology{% endanchor %}

After settling on a browser-based game, we went all-in on [React](http://facebook.github.io/react/) (Khan Academy is one of the larger production users (see, e.g., [Perseus](https://github.com/Khan/perseus)), so we all had some experience with it) and built the entire game under the [Flux](http://facebook.github.io/react/docs/flux-overview.html) architecture. Flux was entirely new to me and very fun to learn (hackathons are always a great time to experiment, especially when they're not made 'competitive')—here's hoping I can use it again the near future.

One of my more demoable contributions was the implementation of fun HTML5 Canvas-based effects to simulate snowfall, rainfall, fog, and spell casting (see below, or the embedded video above for the weather effects), the code for which can be found [here](https://github.com/Khan/KhanQuest/blob/master/src/sprites/animation.jsx).

<img src="/~crmarsh/static/img/fire.gif" alt="Fire animation" class="center">

Beyond that, I also took care of a grab-bag of UI implementations (e.g., the spellbook and transition animations), game mechanics (e.g., the 'unused spells grow in strength' behavior), and core features (e.g., [Perseus](https://github.com/Khan/perseus) exercise rendering via the Khan Academy API).

{% anchor h2 %}Going Forward{% endanchor %}

As I mentioned, the game is now online <a href="http://khan.github.io/KhanQuest/" target="_blank">here</a>. It's still in the incredibly rough form we left it in when we demoed, and in all likelihood, that won't change. You'll run into bugs and console errors; but hey, even the healthiest of hackathons inspire last-minute fixes and monkey-patching!

Jokes aside, I consider this my best hackathon experience yet—one that I'll look back on very fondly. And amidst the [explanations of yak shaving](http://i.minus.com/ibaDjk7AeIcvxv.gif) and [extended metaphors for software development](https://www.youtube.com/watch?v=1IAXrxlDK6c), we pumped out some (reasonably) good code and a (reasonably) fun game. Three cheers for healthy hacking!

_P.S.: In parting, I leave you with a hilarious GIF from an early rendition of the game._

<img src="/~crmarsh/static/img/map-glitch.gif" alt="Map glitch" class="center">


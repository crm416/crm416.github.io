---
layout: post
title: "Writing a Reproducible Test Plan"
date: 2016-06-12
description: "A focus on reproducibility tends to result in the most high-value test plans."
permalink: test-plans/
---

In my [last post](http://www.crmarsh.com/code-review), I wrote about improving as a code reviewer. In this post, I'll focus on a skill that, like code reviewing, is: (1) an important part of Real Engineering™, and (2) almost completely foreign to engineers coming straight out of school.

That is: **writing a good test plan**.

If your team uses Phabricator, then every diff should prompt you to include a [test plan](https://secure.phabricator.com/book/phabricator/article/differential_test_plans/), which Phab defines as: "a repeatable list of steps which document what you have done to verify the behavior of a change."

To me, the operative term is **repeatable** (though I prefer the term "reproducible", since the goal isn't to have it be repeated necessarily, but rather, to construct it in a way such that it _could_ be repeated). I don't want focus here on how to test thoroughly (which is an interesting topic in itself, but too ambitious to cover in a single post); rather, I want to focus on how to write a test plan that is _reproducible_, both by you, your reviewers, and any team members who may be unfamiliar with the code, be it today or far in the futureure (which is, coincidentally, our own bar at Khan Academy).

But first—why bother?

{% anchor h2 %}Why Reproducibility?{% endanchor %}

There are some obvious and non-obvious motivations for focusing on reproducibility in your test plan. The obvious, of course, is that a reproducible test plan allows your reviewers, along with any future readers, to... reproduce the plan (i.e., if they'd like to verify correctness, whether in the context of a code review or a refactor).

But there are also some less-obvious externalities that come with a focus on reproducibility. Namely, that:

1. A focus on reproducibility will force you to _actually_ run through the plan. If you're expected to include specific details (e.g., the specific URL of the specific page on which you tested your change), then you need to go collect them, which is best done by running through the plan. **A focus on reproducibility can thus serve as a mechanism for keeping yourself honest in your own testing.**
2. A focus on reproducibility will better reveal _how_ you tested your change. Reproducible plans tend to be detailed plans—writing "Make sure that it works" is neither reproducible nor detailed. If your reviewers or future readers are wondering about behavior on a particular edge case, but it's covered in your reproducible test plan, that's a good sign. Similarly, if it's _not_ covered, then by virtue of its exclusion within an otherwise detailed and reproducible plan, they'll know to poke around.

{% anchor h2 %}Towards Reproducibility{% endanchor %}

So, how do we get there?

Listing every step you take, in excruciating detail, is insufficient. The key is to provide detail where necessary and in the right quantity. Cutting corners is a good and necessary step; but you should strive to cut the right ones.

Here are some of the guidelines I try to keep in mind when writing my own test plans.

{% anchor h3 %}Make it copy-pasteable{% endanchor %}

In composing my own test plans, I tend to draw the line at _how_ to do things, rather at _what_ to do—outlining the processes, along with the intended actions.

For example:

- "Build the Perseus framework into Webapp" is a description of what I want to do, but it does't tell the reviewer how to do it. And assuming that an engineer stumbling upon the diff knows how to do that may be an unsafe assumption. So, I typically annotate steps like that with the appropriate command, e.g.: "Build Perseus into Webapp (run `make subperseus` from the Perseus repo)".
- "Navigate to an exercise page" is a description of what to do, but, again, doesn't tell the reviewer how to do it. Sure, the reader could figure it out eventually. But it becomes a one-click process when you modify the line to "Navigate to an exercise page (e.g., `localhost:8080/...`)". This also removes any ambiguity as to _which_ exercise page you tested.
- In the event that the code needs to be modified in some way so as to comprehensively test its behavior (e.g., by introducing additional logging that shouldn't make it to production, or replicating an error state with a `throw`), clarity is again key. Writing "Modify the code to throw an error" leaves it to the reviewer to figure out where and how the modifications should be made, while including a specific command to put at a specific line number in a specific file makes it effortless. Better yet, I've had engineers at Khan Academy include Git patches in their test plans.

The irony is that, unlike programming, reproducing a test plan should involve as much copy-pasting as possible. Your goal, as the author, is to remove the onus of "how" from the reviewer's shoulders.

{% anchor h3 %}Minimize context requirements{% endanchor %}

Part of writing a reproducible test plan is making it clear what's actually being tested, and what the desired changes should be vis-à-vis the previous state of the codebase.

This may sound obvious, but, for example, if you're fixing a bug, then of course your test plan by default won't include the bug occurring—since your goal was to fix it.

A reader stumbling upon your test plan should be able to grok what's being tested. A few ways to make that easier:

- Document the previous, fixed behavior in the test plan. For example, along with "Click the button; verify that the modal appears at the top", you could include: "(previously, the modal would appear at the bottom)".
- For UI-focused changes, include screenshots or even screencaps. (I use [LICEcap](http://www.cockos.com/licecap/) to quickly record GIFs.) As both an author and a reviewer, I find this to be a _tremendously_ valuable practice. A picture speaks a thousand words, etc., etc.
- Though these may be better placed in the revision summary itself, including links to relevant Asana tasks or Fabric issues is also a great practice, as it creates a trail of breadcrumbs for any future Git archaeologist.

{% anchor h3 %}Leave it in a good state{% endanchor %}

Your final test plan should reflect the final state of the diff.

The nature of a reproducible test plan is such that it requires detail. And the nature of a good code review is such that details can change.

Of course, if functionality changes across the lifecycle of the code review, then the test plan should be updated to match the new behavior. But more subtly, as files change, any line numbers or filenames referenced in the test plan should be kept up-to-date as well. Shipping a stale test plan will devalue it in the eyes of any future readers and introduce doubt into the integrity of the changes.

{% anchor h2 %}The Reproducibility Mindset{% endanchor %}

Writing a reproducible plan requires empathy. Your natural tendency, especially when working in the same codebase for an extended period of time, is to assume that others will have the context and capabilities that you have at present. Of course, this is a faulty assumption—even you might struggle to reproduce your own test plans months down the road.

**It's telling that I often find myself writing my best, most reproducible test plans when I'm in a part of the codebase that is relatively unfamiliar to me.** Since I'm newly discovering the relevant testing mechanisms, code paths, and behaviors for the first time, my inclination is to include all of the information that I _didn't_ have coming into the change. The odds are good that future readers may similarly lack context.

As with so much else in software engineering, empathy is key. When you put yourself in the shoes of a newcomer to the codebase and empathize with your future readers, the test plan will flow.

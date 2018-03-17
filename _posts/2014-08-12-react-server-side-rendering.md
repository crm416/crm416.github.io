---
layout: post
title: Rendering React Components on the Server
date: 2014-08-12
description: "A guide to server-side rendering with React, starting from first principles."
permalink: react-ssr/
---

I love working with React. Like, a little too much (no thanks to my (amazing) internship at Khan Academy, where we use React in buckets).

For a recent side project, I wanted to render my React components on the server, rather than the client (this is often abbreviated as "server-side rendering", or SSR, for short).

Typical motivations for rendering on the server include:

1. [Faster page loads](http://openmymind.net/2012/5/30/Client-Side-vs-Server-Side-Rendering/): by rendering on the server, you get to send down a complete webpage, cut out an HTTP request, etc.
2. [More reliable SEO](http://googlewebmastercentral.blogspot.com/2007/11/spiders-view-of-web-20.html): any crawler that navigates to your site will see a complete page filled with content, rather than an empty page that requires JavaScript execution.

(This isn't to say that SSR is strictly better than client-side rendering; it's just different.)

SSR is totally doable with React; but a lot of the SSR-related resources out there seem to assume prior knowledge. I thought I'd share what I've learned.

<!--break-->

{% anchor h2 %}The Basics{% endanchor %}

{% anchor h3 %}Static markup{% endanchor %}

Let's start with the static case, in which the rendered components we send to the client won't need to re-render in any way.

React provides a method, `renderComponentToStaticMarkup`, that takes a React component and returns its HTML markup as a string. This is super useful for server-side rendering, as you can simply pass the method output into a templating engine and send the client the resulting HTML page. For example, if you're using Handlebars, you can render your component to static markup and send it down in the `markup` variable as such:

```html
<div>{{ "{{{ markup " }}}}}</div>
```

{% anchor h3 %}Reactive components{% endanchor %}

But it's rare that you really want your components to be static. Why's that? Static components can't respond to non-trivial user interaction, update `state`, re-render, etc. They're totally passive and, err, static.

For React components to behave as you'd expect (with updates and re-renders), they need an actual react.js instance to be aware of their existence so as to handle event binding, manage `prop` and `state` changes, and reflect these changes in the DOM. Without it, all you have is static, non-responsive markup.

Thankfully, React provides a second method, `renderComponentToString`, that again returns a string of HTML markup, but this time enables our generated components to react to interactions on the client-side as necessary.

How so? **The key is to (ostensibly) re-render the component on the client as soon as the page has loaded**. Bear with me.

{% anchor h3 %}An Example{% endanchor %}

Let's say that we have a React component, `Item`, with one prop (called `initialCount`) and one piece of state (called `count`). The component initializes `count` with `initialCount` and increments it on-click. Here's a bare-bones version:

```js
var Item = React.createClass({
    getInitialState: function() {
        return {
            count: this.props.initialCount
        };
    },

    _increment: function() {
        this.setState({ count: this.state.count + 1 });
    },

    render: function() {
        return <div onClick={this._increment}>
            {this.state.count}
        </div>;
    }
});
```

We want to render this component on the server, which might look like (for example's sake, I'll assume Express and Handlebars):

```js
var React = require('react');
...
var markup = React.renderComponentToString(
    Item({ initialCount: 7 })
);
res.render('template', {
    markup: markup
});
```

Then, in our template, we'd have:

```html
<div id="container">{{ "{{{ markup " }}}}}</div>
```

If we stopped here, then on page load, we'd see the number '7'—but our component wouldn't update on-click. Why? As I mentioned, we haven't made our client-side React instance aware of the component, so it can't handle re-renders. But the problem comes even before an attempt to `setState`: since React handles the binding of events to components, our `onClick` handler won't be passed down in the static markup (take a look), and thus won't be triggered at all.

To get this component under control, we'll need a call in the browser that looks something like this (assuming `React` and `Item` are available as globals):

```js
var container = document.getElementById('container');
var component = Item({ initialCount: 7 });
React.renderComponent(component, container);
```

With that, we can click on our rendered component and the count will increment: events are bound, as they would be if we'd rendered client-side, and the DOM updates to reflect our changes.

The magic of it all: as long as we render `Item` with the _same props_ and into the _same node_ on both the client and server, **React won't actually re-render the component** (which would be less performant)—it's smart enough to realize that the rendered `Item` already exists in the DOM and simply note that it _may_ need to be re-rendered in the future.

This is the best of both worlds: **we get all the benefits of server-side rendering while maintaining truly reactive React components**.

{% anchor h3 %}Syncing Props{% endanchor %}

A key phrase there: we need to render `Item` with the same props on the client and server (as evidenced by the last code snippet, above). That's a little frustrating, but not terribly difficult to do. A few viable approaches include:

1. _Passing the initial props down through templating_.

    There's a good example of this behavior in Michael Hart's [react-server-example](https://github.com/mhart/react-server-example) repo, but here's the basic idea:

    ```js
    var props = { initialCount: 7 };
    var markup = React.renderComponentToString(Item(props));
    res.send(
        '<div id="container">' + markup + '</div>' +
        '<script>
            var container = document.getElementById("container");
            var component = Item(' + JSON.stringify(props) + ');
            React.renderComponent(component, container);
         </script>'
    );
    ```

    Note: For each of these examples, to avoid XSS attacks (as per [Ben Alpert's blog post](http://benalpert.com/2012/08/03/preventing-xss-json.html)), you should use a `safeStringify` function, rather than `JSON.stringify`. There's a JavaScript implementation [here](https://github.com/mhart/react-server-example/blob/master/server.js#L96).

2. _Passing the initial props down in a `<script>` tag with `type="application/json"`_.

    Again, the standard approach would be to handle this step with your templating engine:

    ```html
    <div id="container">{{ "{{{ markup " }}}}}</div>
    <script id="props" type="application/json">
        {{ "{{{ jsonifiedProps " }}}}}
    </script>
    <script>
        var container = document.getElementById("container");
        var props = JSON.parse(document.getElementById("props").innerHTML);
        React.renderComponent(Item(props), container);
    </script>
    ```

    Given that the second `<script>` tag is now totally independent of anything we passed in to our templating engine, we could follow Andrey Popp's [example](https://github.com/andreypopp/react-quickstart/blob/master/client.js#L101) by removing the second `<script>` tag and appending our `item.jsx` file with:

    ```js
    if (typeof window !== 'undefined') {
        var container = document.getElementById("container");
        var props = JSON.parse(document.getElementById("props").innerHTML);
        React.renderComponent(Item(props), container);
    }
    ```

3. _Passing the initial props down in a `<script>` tag on the component itself_.

    This is a twist on approach \#2 that, while somewhat unorthdox, has its merits. Back to the `Item` example, our `render` function could be written as follows:

    ```js
    render: function() {
        var json = safeStringify(this.props);
        var propStore = <script type="application/json"
            id={propStoreID}
            dangerouslySetInnerHTML={{ "{{__html: json" }}}}>
        </script>;

        return <div onClick={this._increment}>
            {propStore}
            {this.state.count}
        </div>;
    }
    ```

    The `dangerouslySetInnerHTML` attribute is used to [avoid escaping issues](http://facebook.github.io/react/docs/jsx-gotchas.html#html-entities). It's a little messy, but not too bad.

    The upside of this approach: it avoids mixing `props` into the templating step. Further, if you move the client-side `React.renderComponent` call into your JSX file by following the `if (typeof window !== 'undefined')` pattern, you can package _all_ of your server-side rendering logic within React, which is a big plus.

    As an aside: I use an `SSRWrapper` React component that takes care of both the `<script type="application/json">` injection and client-side `React.renderComponent` call, allowing me to write carefree components.

4. _Passing the initial props down as a `window`-level variable._ Relatively straightforward, given the explanations above.

{% anchor h3 %}Browserifying{% endanchor %}

One other thing: of course, your client page will need to have access to the actual JSX files that make up your React components (along with React itself). This is typically done by creating a Browserify (or Webpack) bundle and adding a `<script>` tag to your React component that loads said bundle.

So, in addition to any changes we made in the previous section, we might modify our `render` to look like:

```js
render: function() {
    return <div onClick={this._increment}>
        <script src="/bundles/item.js"></script>
        {this.state.count}
    </div>;
}
```

(We could also put this `<script>` tag elsewhere on the page through templating—whatever's easiest. Once again, I use my `SSRWrapper` component to abstract this step away.)

On the server, we have to make `item.js` available as a bundle. I use the excellent [browserify-middleware](https://github.com/ForbesLindesay/browserify-middleware), for which the Express-side logic might look like:

```js
var browserify = require('browserify-middleware');
var reactify = require('reactify');
browserify.settings('transform', ['reactify']);
app.get('/bundles/item.js', browserify('./jsx/item.jsx'));
```

It's often useful to create a shared bundle for React, as well as an individual bundle for each of your React components, in which case you might modify the snippet above to include:

```js
...
var shared = ['react'];
router.get('/bundles/shared.js', browserify(shared));
app.get('/bundles/item.js', browserify('./jsx/item.jsx', {
    external: shared
}));
```

{% anchor h2 %}How does it all work?{% endanchor %}

Now that we have a good sense for how to render server-side, it's worth stepping through some React source to understand _why_ it works this way.

If you inspect a React component that's been rendered on the server (i.e., generated with `renderComponentToString`), you'll notice that it has an unfamiliar attribute, `data-react-checksum`, which you won't have seen on client-side components. For example, after it's been passed down from the server, our `Item` component might look like:

```html
<div id="container">
    <div data-reactid=".feh782p6o0" data-react-checksum="75238508">
        7
    </div>
</div>
```

Walking through the React source for `renderComponentToString`, we see the following:

```js
function renderComponentToString(component) {
    ...
    var componentInstance = instantiateReactComponent(component);
    var markup = componentInstance.mountComponent(id, transaction, 0);
    return ReactMarkupChecksum.addChecksumToMarkup(markup);
}
```

Stepping one level deeper into the `addChecksumToMarkup` function reveals that `data-react-checksum` is an [Adler-32](http://en.wikipedia.org/wiki/Adler-32) checksum generated from the HTML markup and appended to any component rendered server-side.

Later, we call `renderComponent` on the client-side. With new components (i.e., those that haven't been seen before by our React instance, like the ones we generated on the server), a call to `renderComponent` eventually tests for `canReuseMarkup`:

```js
// `markup` is the HTML markup that would be generated by our component
// `element` is the DOM node into which it would be rendered
canReuseMarkup: function(markup, element) {
    var existingChecksum = element.getAttribute(
        ReactMarkupChecksum.CHECKSUM_ATTR_NAME
    );
    existingChecksum = existingChecksum && parseInt(existingChecksum, 10);
    var markupChecksum = adler32(markup);
    return markupChecksum === existingChecksum;
}
```

If this test passes, then instead of rendering anything, React simply takes note of the component.

So, what's happening here is actually quite simple:

- On the server, React appends a checksum for the rendered components to its outermost DOM node.
- When a new component is passed to React on the client, it first checks for the existing HTML markup at the target DOM node and grabs the Adler-32 checksum appended by the server.
- This value is compared to the checksum that would be generated by the provided React component and its props.
- If the values are equivalent, no rendering is necessary, and thus no rendering is performed.

For example, if we render `Item({ initialCount: 5 })` on the server, it'll turn it into HTML markup, calculate a checksum, and append it to the outermost DOM node. Then, when we call `React.renderComponent(Item({ initialCount: 5 }), container)` on the client, it checks if the markup generated by `Item({ initialCount: 5 })` matches the checksum (which it does) and simply returns (rather than re-rendering).

{% anchor h2 %}Gotchas{% endanchor %}

A few things to keep in mind:

- When rendering on the server, `getDefaultProps`, `getInitialState`, and `componentWillMount` are the only React lifecycle methods that get run (see, e.g., the note on `componentDidMount` in the [docs](http://facebook.github.io/react/docs/component-specs.html#mounting-componentdidmount)). Be aware!

- If you're using Handlebars, you'll need triple `{` around your markup, otherwise it won't be interpreted as raw HTML (see "HTML Escaping" in the [docs](http://handlebarsjs.com/)).
- Again, if you're using Handlebars, be sure to do:

    ```html
    <div>{{ "{{{ markup " }}}}}</div>
    ```

    As opposed to, e.g.:

    ```html
    <div>
      {{ "{{{ markup " }}}}}
    </div>
    ```

    React is somewhat space-sensitive: if you opt for the latter and try to render your component into the outermost `<div>`, React will infer that the `firstChild` of the `<div>` is actually a [newline character](https://developer.mozilla.org/en-US/docs/Web/API/Node.firstChild), rather than your rendered component. As a result, it'll completely re-render it. This is a [known issue](https://github.com/facebook/react/issues/996), but the fix isn't live yet.
- To avoid re-rendering, the markup generated by the client and server must be _completely_ identical. That means, for example, that you can't pass down the initial props in a `<script>` tag _only_ on the server; otherwise, the checksums won't match up. As a rule of thumb, avoid any checks for `(typeof window !== 'undefined')` or whatnot when writing rendering-related code.

{% anchor h2 %}Resources & Acknowledgements{% endanchor %}

Here are some resources I found helpful (and referenced above):

- Andrey Popp's [ReactAsync](https://github.com/andreypopp/react-async/tree/master/example) examples.
- Andrey Popp's [react-quickstart](https://github.com/andreypopp/react-quickstart) guide.
- Michael Hart's [react-server-example](https://github.com/mhart/react-server-example) repo.
- Pete Hunt's [react-server-rendering-example](https://github.com/petehunt/react-server-rendering-example) repo.

Finally, thanks to [Ben Alpert](http://benalpert.com/) ([@soprano](https://twitter.com/soprano)) for his feedback on a draft of this post.
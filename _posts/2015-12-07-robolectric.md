---
layout: post
title: "Getting Up and Running with Robolectric"
date: 2015-12-07
description: "A collection of tips and tricks for getting around your Robolectric integration battles."
permalink: configuring-robolectric
---

# Getting Up and Running with Robolectric

[Robolectric](http://robolectric.org/) is a useful tool for testing code that touches parts of the Android SDK _without having to build to a device_, made possible by Robolectric's reimplementation and "de-fanging" of parts of the Android SDK, which allows them to run on a regular JVM, rather than an emulator.

I recently integrated Robolectric into our app at [Khan Academy](https://play.google.com/store/apps/details?id=org.khanacademy.android)—we've been looking into ways to let us write more and more efficient tests, and Robolectric fit the bill nicely (at least for some cases—many tests are best left as functional or integration tests; but I won't get into that here).

Setup was relatively painless, but I did hit a few snags along the way. In this post, I'll outline those snags—and how we got around them—to save you time and effort in your own Robolectric integration battle.

{% anchor h2 %}Config{% endanchor %}

When using Robolectric with Gradle, you need to annotate your test suites like so:

```java
@RunWith(RobolectricGradleTestRunner.class)
@Config(constants = BuildConfig.class)
public class FooTest {
    ...
}
```

Unfortunately, our basic debug build didn't play well with Robolectric for two reasons:

1. Robolectric tests against your `targetSdkVersion`. We target API 22, which Robolectric doesn't support yet (although API 22 support is already available in [3.1-SNAPSHOT](https://github.com/robolectric/robolectric/pull/2030)).
2. Robolectric relies on your `applicationId` to locate your resource and asset directories, and gets tripped up if your debug build uses a custom application ID (e.g., we use `org.khanacademy.android.debug`, rather than `org.khanacademy.android`).

Fortunately, you can override these defaults explicitly in the `@Config` annotation:

```java
@RunWith(RobolectricGradleTestRunner.class)
@Config(constants = BuildConfig.class, packageName = "org.khanacademy.android", sdk = 21)
public class FooTest {
    ...
}
```

{% anchor h3 %}Reuse{% endanchor %}

To guard against these values getting out of sync across our tests, we first extracted them into custom fields on our `BuildConfig` class. This was done by modifying our `build.gradle` to make use of the nifty `buildConfigField` argument:

```groovy
buildTypes {
    debug {
        applicationIdSuffix ".debug"
        proguardFile 'proguard/debug.pro'

        // Extra fields used to configure Robolectric test suites.
        buildConfigField "int", "TEST_TARGET_SDK_VERSION", "21"
        buildConfigField "String", "CANONICAL_APPLICATION_ID", "\"org.khanacademy.android\""
    }
    ...
}
```

Our test suite then became:

```java
@RunWith(RobolectricGradleTestRunner.class)
@Config(
        constants = BuildConfig.class,
        packageName = BuildConfig.CANONICAL_APPLICATION_ID,
        sdk = BuildConfig.TEST_TARGET_SDK_VERSION
)
public class FooTest {
    ...
}
```

Finally, we extracted these annotations out into a separate `BaseRobolectricTest.java` class, to avoid the need to duplicate them across the codebase, giving us:

```java
/**
 * Base class for all {@link Robolectric} test suites.
 */
@RunWith(RobolectricGradleTestRunner.class)
@Config(
        constants = BuildConfig.class,
        packageName = BuildConfig.CANONICAL_APPLICATION_ID,
        sdk = BuildConfig.TEST_TARGET_SDK_VERSION
)
public abstract class BaseRobolectricTest {}
```

This in turn made our test classes as simple as:

```java
public class FooTest extends BaseRobolectricTest {
    ...
}
```

Not bad.

Alternatively, Robolectric supports the use of a [global configuration file](http://robolectric.blogspot.com/2013/05/configuring-robolectric-20.html) to achieve a similar goal. But our solution felt a little cleaner to me, since it co-located all of our `BuildConfig` reads (plus, the global config file isn't very well documented—I couldn't get it to register with Robolectric, much less figure out which fields were configurable from within it).

{% anchor h2 %}Creating a Test Application{% endanchor %}

We wanted to initialize a different set of application dependencies when running our Robolectric tests. This set would be distinct from the application dependencies we use when running a Debug build, so we couldn't merely base our dependency set on the value of `BuildConfig.DEBUG`.

Robolectric provides a dead-simple solution: if your application class is `Application.java`, and you put a `TestApplication.java` in your classpath, Robolectric will use the `Test*.java` variant instead. Note that your `Test*.java` variant should subclass the base application.

(Of course, the name of your application is irrelevant—Robolectric will substitute the `Test*.java` variant of any class that subclasses `android.app.Application`, so it could just as well be `FooApp.java` and `TestFooApp.java`.)

In our case, we extracted our dependency initialization code into an overridable method, `initializeDependencies`, and created a `TestApplication.java`, like so:

```java
public class TestApplication extends Application {
    @Override
    protected void initializeDependencies() {
        getApplicationComponent().initializeTestDependencies();
    }
}
```

Note that you'll probably want to add something like this to your Proguard configuration:

```groovy
-dontwarn class org.khanacademy.android.TestApplication { *; }
```

{% anchor h3 %}The New Application Lifecycle{% endanchor %}

The only other Application-related hitch we ran into: by default, Robolectric calls `onCreate` before and `onTerminate` after every test case. This was causing us problems, since `onTerminate` isn't part of the standard Application lifecycle, as you can see from the JavaDoc:

```java
/**
 * This method is for use in emulated process environments.  It will
 * never be called on a production Android device, where processes are
 * removed by simply killing them; no user code (including this callback)
 * is executed when doing so.
 */
public void onTerminate() {
}
```

So we hadn't had any reason to implement it in the past and, as such, some of our singletons went haywire on successive `onCreate` calls.

There are two viable workarounds here:

1. Add an `onTerminate` method to your `TestApplication` to clean up anything that needs cleaning up.
2. Have your `TestApplication` implement `TestApplicationLifecycle` and stub out the lifecycle hooks, so as to prevent Robolectric from calling `onCreate` and `onTerminate` multiple times in the first place.

I opted for the former, since it was simpler and seemed slightly more true to life (i.e., since it calls `onCreate` before each test).

{% anchor h2 %}Shadows{% endanchor %}

The last snag I ran into was that some of our `checkState` calls expected parts of the Android SDK to behave slightly differently from the vanilla Robolectric configuration.

Specifically, our app expected `Environment.getExternalStorageState()` to return `MEDIA_MOUNTED` for certain directories (such that we would be able to write to them), whereas Robolectric, by default, returns `MEDIA_REMOVED`.

Thankfully, Robolectric again made it pretty easy to work around this constraint using "Shadows". In brief: Robolectric uses "Shadow" classes to ["modify or extend the behavior of classes"](http://robolectric.org/extending/) in the Android SDK—they're similar to mocks or spies.

Since Robolectric already shadows the `Environment` class with its own `ShadowEnvironment` class, we just had to configure it before starting up our Application:

```java
ShadowEnvironment.setExternalStorageState(Environment.MEDIA_MOUNTED);
```

I expect that other apps might require similar configuration changes.

{% anchor h2 %}Miscellanea{% endanchor %}

Before closing, a few final tricks and tips:

- Robolectric doesn't support the shadowing of activities that are defined as non-static inner classes. So, if you, like me, weirdly try to use an inner activity while you're trying to integrate Robolectric, that may be why your setup is broken!
- In writing our initial Robolectric tests, we've made use of a `TestActivity` that just renders an empty `FrameLayout`:

    ```java
    public class TestActivity extends RxActionBarActivity {
        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(new FrameLayout(this));
        }
    }
    ```
   I think this is a wise approach (as opposed to, e.g., using your primary activity), since it encourages true _unit_ testing, in that you're then incentivized to create small, isolated test cases.
- Robolectric [doesn't play well](https://stackoverflow.com/questions/28762624/com-crashlytics-android-crashlyticsmissingdependencyexception-during-gradle-tes) with Crashlytics + Fabric—if you're using that combo, you might run into an error along the lines of:

    ```
    This app relies on Crashlytics. Please sign up for access at https://fabric.io/sign_up, install an Android build tool and ask a team member to invite you to this app's organization.
    ```

    If you're initializing Crashlytics in unit test mode (which probably isn't a great idea in the first place), a quick workaround is to initialize it in [disabled mode](https://stackoverflow.com/questions/30488575/crashlytics-deprecated-method-disabled), with:

    ```java
    CrashlyticsCore core = new CrashlyticsCore
            .Builder()
            .disabled(BuildConfig.DEBUG)
            .build();
    return new Crashlytics
            .Builder()
            .core(core)
            .build();
    ```

    Crashlytics will then stub out its method calls, which leads to sane behavior in the context of unit testing.

Happy testing!

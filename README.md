# Motion Transitioning

> Light-weight API for building UIViewController transitions.

[![Build Status](https://travis-ci.org/material-motion/transitioning-objc.svg?branch=develop)](https://travis-ci.org/material-motion/transitioning-objc)
[![codecov](https://codecov.io/gh/material-motion/transitioning-objc/branch/develop/graph/badge.svg)](https://codecov.io/gh/material-motion/transitioning-objc)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/MotionTransitioning.svg)](https://cocoapods.org/pods/MotionTransitioning)
[![Platform](https://img.shields.io/cocoapods/p/MotionTransitioning.svg)](http://cocoadocs.org/docsets/MotionTransitioning)
[![Docs](https://img.shields.io/cocoapods/metrics/doc-percent/MotionTransitioning.svg)](http://cocoadocs.org/docsets/MotionTransitioning)

This library standardizes the way transitions are built on iOS so that with a single line of code
you can pick the custom transition you want to use:

```swift
let viewController = MyViewController()
viewController.transitionController.transition = CustomTransition()
present(modalViewController, animated: true)
```

```objc
MyViewController *viewController = [[MyViewController alloc] init];
viewController.mdm_transitionController.transition = [[CustomTransition alloc] init];
[self presentViewController:viewController animated:true completion:nil];
```

The easiest way to make a transition with this library is to create a class that conforms to the
`Transition` protocol:

```swift
final class CustomTransition: NSObject, Transition {
  func start(with context: TransitionContext) {
    CATransaction.begin()

    CATransaction.setCompletionBlock {
      context.transitionDidEnd()
    }

    // Add animations...

    CATransaction.commit()
  }
}
```

```objc
@interface CustomTransition: NSObject <MDMTransition>
@end

@implementation CustomTransition

- (void)startWithContext:(id<MDMTransitionContext>)context {
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    [context transitionDidEnd];
  }];

  // Add animations...

  [CATransaction commit];
}

@end
```

## Installation

### Installation with CocoaPods

> CocoaPods is a dependency manager for Objective-C and Swift libraries. CocoaPods automates the
> process of using third-party libraries in your projects. See
> [the Getting Started guide](https://guides.cocoapods.org/using/getting-started.html) for more
> information. You can install it with the following command:
>
>     gem install cocoapods

Add `MotionTransitioning` to your `Podfile`:

    pod 'MotionTransitioning'

Then run the following command:

    pod install

### Usage

Import the framework:

    @import MotionTransitioning;

You will now have access to all of the APIs.

## Example apps/unit tests

Check out a local copy of the repo to access the Catalog application by running the following
commands:

    git clone https://github.com/material-motion/transitioning-objc.git
    cd transitioning-objc
    pod install
    open MotionTransitioning.xcworkspace

## Guides

1. [Architecture](#architecture)
2. [How to create a simple transition](#how-to-create-a-simple-transition)
3. [How to customize presentation](#how-to-customize-presentation)
4. [How to customize navigation controller transitions](#how-to-customize-navigation-controller-transitions)

### Architecture

> Background: Transitions in iOS are customized by setting a `transitioningDelegate` on a view
> controller. When a view controller is presented, UIKit will ask the transitioning delegate for an
> animation, interaction, and presentation controller. These controllers are then expected to
> implement the transition's motion.

MotionTransitioning provides a thin layer atop these protocols with the following advantages:

- Every view controller has its own **transition controller**. This encourages choosing the
  transition based on the context.
- Transitions are represented in terms of **backward/forward** rather than from/to. When presenting,
  we're moving forward. When dismissing, we're moving backward. This makes it easier to refer to
  each "side" of a transition consistently.
- Transition objects can customize their behavior by conforming to more `TransitionWith*` protocols.
  This protocol-oriented design is more Swift-friendly than a variety of optional methods on a
  protocol.
- But most importantly: **this library handles the plumbing, allowing you to focus on the motion**.

### How to create a simple transition

In this guide we'll create scaffolding for a simple transition.

#### Step 1: Define a new Transition type

Transitions must be `NSObject` types that conform to the `Transition` protocol.

The sole method we're expected to implement, `start`, is invoked each time the view controller is
presented or dismissed.

```swift
final class FadeTransition: NSObject, Transition {
  func start(with context: TransitionContext) {

  }
}
```

#### Step 2: Invoke the completion handler once all animations are complete

If using Core Animation explicitly:

```swift
final class FadeTransition: NSObject, Transition {
  func start(with context: TransitionContext) {
    CATransaction.begin()

    CATransaction.setCompletionBlock {
      context.transitionDidEnd()
    }

    // Your motion...

    CATransaction.commit()
  }
}
```

If using UIView implicit animations:

```swift
final class FadeTransition: NSObject, Transition {
  func start(with context: TransitionContext) {
    UIView.animate(withDuration: context.duration, animations: {
      // Your motion...

    }, completion: { didComplete in
      context.transitionDidEnd()
    })
  }
}
```

#### Step 3: Implement the motion

With the basic scaffolding in place, you can now implement your motion.

### How to customize presentation

You'll customize the presentation of a transition when you need to do any of the following:

- Add views, such as dimming views, that live beyond the lifetime of the transition.
- Change the destination frame of the presented view controller.

#### Step 1: Subclass UIPresentationController

You must subclass UIPresentationController in order to implement your custom behavior. If the user
of your transition can customize any presentation behavior then you'll want to define a custom
initializer.

> Note: Avoid storing the transition context in your presentation controller. Presentation
> controllers live for as long as their associated view controller, while the transition context is
> only valid while a transition is active. Each presentation and dismissal will receive its own
> unique transition context. Storing the context in the presentation controller would keep the
> context alive longer than it's meant to.

Override any `UIPresentationController` methods you'll need in order to implement your motion.

```swift
final class MyPresentationController: UIPresentationController {
}
```

#### Step 2: Implement TransitionWithPresentation on your transition

This ensures that your transition implement the required methods for presentation.

Presentation will only be customized if you return `.custom` from the
`defaultModalPresentationStyle` method and a non-nil `UIPresentationController` subclass from the
`presentationController` method.

```swift
extension VerticalSheetTransition: TransitionWithPresentation {
  func defaultModalPresentationStyle() -> UIModalPresentationStyle {
    return .custom
  }

  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController,
                              source: UIViewController?) -> UIPresentationController? {
    return MyPresentationController(presentedViewController: presented, presenting: presenting)
  }
}
```

#### Optional Step 3: Implement Transition on your presentation controller

If your presentation controller needs to animate anything, you can conform to the `Transition`
protocol in order to receive a `start` invocation each time a transition begins. The presentation
controller's `start` will be invoked before the transition's `start`.

> Note: It's possible for your presentation controller and your transition to have different ideas
> of when a transition has completed, so consider which object should be responsible for invoking
> `transitionDidEnd`. The `Transition` object is usually the one that calls this method.

```swift
extension MyPresentationController: Transition {
  func start(with context: TransitionContext) {
    // Your motion...
  }
}
```

### How to customize navigation controller transitions

`UINavigationController` ignores the `transitioningDelegate` property on any view
controller pushed onto or popped off of the stack, instead relying on its delegate instance to
customize any transitions. This means that our `transitionController`  will be
ignored by a navigation controller.

In order to customize individual push/pop transitions with the `transitionController`, you
can make use of the `TransitionNavigationControllerDelegate` singleton class. If you
assign a shared delegate to your navigation controller's delegate, your navigation controller
will honor the animation and interaction settings defined by your individual view controller's
`transitionController`.

```swift
navigationController.delegate = TransitionNavigationControllerDelegate.sharedDelegate()

// Subsequent pushes and pops will honor the pushed/popped view controller's
// transitionController settings as though the view controllers were being
// presented/dismissed.
```

## Contributing

We welcome contributions!

Check out our [upcoming milestones](https://github.com/material-motion/transitioning-objc/milestones).

Learn more about [our team](https://material-motion.github.io/material-motion/team/),
[our community](https://material-motion.github.io/material-motion/team/community/), and
our [contributor essentials](https://material-motion.github.io/material-motion/team/essentials/).

## License

Licensed under the Apache 2.0 license. See LICENSE for details.

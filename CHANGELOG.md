# 7.0.1

This patch release fixes a bug on iOS 13 where the presented view controller would not be added to
the view hierarchy.

## Source changes

* [Always add the toView to the container. (#68)](https://github.com/material-motion/motion-transitioning-objc/commit/0a9568b21375bb5e04e5cf10123eaa06b63f80bd) (featherless)


# 7.0.0

This major release drops official support for iOS 8.

## Non-source changes

* [Drop support for iOS 8 (#65)](https://github.com/material-motion/motion-transitioning-objc/commit/7be635014d25dead64862822df899d46fda4f248) (featherless)

# 6.0.0

This major release upgrades the bazel dependencies and workspace. This change is breaking for anyone
using bazel to build this library. In order to use this library with bazel, you will also need to
upgrade your workspace versions to match the ones now used in this library's `WORKSPACE` file.

## Source changes

* [Add missing import (#60)](https://github.com/material-motion/motion-transitioning-objc/commit/7708bb26c383b88f79a60a8737a26d12cdea498d) (Louis Romero)

## Non-source changes

* [Update bazel workspace to latest versions. (#63)](https://github.com/material-motion/motion-transitioning-objc/commit/09350359468b6e5de09634a67130491761d8fffc) (featherless)

# 5.0.0

This major change introduces a breaking API change for Swift clients.

## Breaking changes

**Swift only**: The UIViewController extension property `transitionController` has been renamed to `mdm_transitionController`.

## Source changes

* [[breaking] Rename the transitionController Swift API to mdm_transitionController. (#59)](https://github.com/material-motion/motion-transitioning-objc/commit/7b3f0c28bc43ed25248fad2e197228fc815b0909) (featherless)

## API changes

### UIViewController

**renamed (swift)** method: `transitionController` to `mdm_transitionController`.

# 4.0.2

This patch release fixes a bug where the frames of custom presented views would be incorrectly set
to the view controller's frame.

## Source changes

* [Add support for transitions with custom presented views. (#55)](https://github.com/material-motion/motion-transitioning-objc/commit/2564bfdf42a2ba7c550656b95bc7dc98019468bb) (featherless)

## Non-source changes

* [Standardize the kokoro and bazel files. (#51)](https://github.com/material-motion/motion-transitioning-objc/commit/588b63dfae7471f3377041caa08496ef1fa74ced) (featherless)

# 4.0.1

This patch release resolves a build warning and migrates the project's continuous integration to
bazel and kokoro.

## Source changes

* [Replace arc with bazel and kokoro build runner for continuous integration. (#47)](https://github.com/material-motion/motion-transitioning-objc/commit/a40eb1667a4c5c9b13e3770c1bd98f0ca15d5b7d) (featherless)
* [Reorder if statement to avoid nullability warning. (#48)](https://github.com/material-motion/motion-transitioning-objc/commit/0406d3c933574b0b9f3d7a0ae1cc3e7556640ccb) (ianegordon)

# 4.0.0

This major release adds support for composable transitions. See the catalog app for a variety of
examples making use of this new functionality.

## Fixed issues

- [Transitions would not complete if the presentation controller didn't implement the startWithContext method](https://github.com/material-motion/transitioning-objc/pull/45)

## Breaking changes

- `MDMTransitionWithFallback`'s return value is now nonnull. If you depended on the nil behavior,
you must now conform to the new protocol `MDMTransitionWithFeasibility` and return `NO` for
`canPerformTransitionWithContext:`.
- `MDMTransitionDirection` has been renamed to `TransitionDirection` in Swift.

## New features

`MDMTransitionWithFeasibility` allows a transition to indicate whether it is capable of performing
the transition with a given context.

The new `composeWithTransition:` API on `MDMTransitionContext` makes it possible to build modular
transition objects that delegate responsibility out to other transition objects. View the
`PhotoAlbumTransition` example transition to see the following code in action:

```swift
context.compose(with: FadeTransition(target: .foreView, style: .fadeIn))
context.compose(with: SpringFrameTransition(target: .target(snapshotContextView),
                                            size: fitSize))

if let toolbar = foreDelegate.toolbar(for: self) {
  context.compose(with: SlideUpTransition(target: .target(toolbar)))
}
```

## Source changes

* [Add nullability annotations to MDMTransitionNavigationControllerDelegate. (#46)](https://github.com/material-motion/motion-transitioning-objc/commit/302d3c4ec526ffa942d23937fdfe8ef5163d473d) (featherless)
* [Update Xcode build settings to Xcode 9 warnings and resolve build error.](https://github.com/material-motion/transitioning-objc/commit/5ed85cdc795ae6660901c5e2ae237732f04649e1) (Jeff Verkoeyen)
* [Rework multi-transition support using composition. (#43)](https://github.com/material-motion/transitioning-objc/commit/0b57361557476c7d3ecb8f4c9878da21a2e735ab) (featherless)
* [Fix the Swift symbol name for MDMTransitionDirection. (#44)](https://github.com/material-motion/transitioning-objc/commit/4cdcf4ca0324a1f83d572440887fe5a5d18ee00b) (featherless)
* [Fix bug where transitions would not complete if the presentation controller didn't implement the startWithContext method. (#45)](https://github.com/material-motion/transitioning-objc/commit/784328dae8509df0a2beb3a5afa9701f1e275950) (featherless)
* [Fix broken unit tests.](https://github.com/material-motion/transitioning-objc/commit/46c92ebcab642969ba70ea43aa512cac1cc3cad4) (Jeff Verkoeyen)
* [Add multi-transition support. (#40)](https://github.com/material-motion/transitioning-objc/commit/8653958a5a9419891861fb6fd7648791ca3c744c) (featherless)
* [Remove unused protocol forward declaration.](https://github.com/material-motion/transitioning-objc/commit/74c1655fc3614e5e9788db8b53e8bff83691137a) (Jeff Verkoeyen)

## API changes

### MDMTransitionWithCustomDuration

*changed* protocol `MDMTransitionWithCustomDuration` now conforms to `MDMTransition`.

### MDMTransitionWithFallback

*changed* protocol `MDMTransitionWithFallback` now conforms to `MDMTransition`.

### MDMTransitionWithFeasibility

*new* protocol `MDMTransitionWithFeasibility`.

### MDMTransitionContext

*new* method `composeWithTransition:`

## Non-source changes

* [Add platform to the Podfile per pod install recommendation.](https://github.com/material-motion/transitioning-objc/commit/7384187b2ddd6a2760f5279cabb5032ea3b1e24e) (Jeff Verkoeyen)

# 3.3.0

This minor release deprecates some behavior and replaces it with a new API.

## New deprecations

- `MDMTransitionWithFallback` nil behavior is now deprecated. In order to fall back to system
transitions you must now conform to `MDMTransitionWithFeasibility` and return NO.

## Source changes

* [Backport MDMTransitionWithFeasibility from the v4.0.0 release for v3.1 clients.](https://github.com/material-motion/transitioning-objc/commit/1f994d03c7971001cc8faafe61b3ed2f55bca118) (Jeff Verkoeyen)

## API changes

### MDMTransitionWithFeasibility

*new* protocol `MDMTransitionWithFeasibility`.

# 3.2.1

This patch release resolves Xcode 9 compiler warnings.

## Source changes

* [Explicitly include void for block parameters. (#41)](https://github.com/material-motion/transitioning-objc/commit/eabe53db2a113e548c876247e2c2ff3e04afc58f) (ianegordon)

# 3.2.0

This minor release introduces new features for presentation, view snapshotting, and defered transition work. There is also a new photo album example demonstrating how to build a contextual transition in which the context may change.

## New features

Transition context now has a `deferToCompletion:` API for deferring work to the completion of the transition.

```swift
// Example (Swift):
foreImageView.isHidden = true
context.defer {
  foreImageView.isHidden = false
}
```

`MDMTransitionPresentationController` is a presentation controller that supports presenting view controllers at custom frames and showing an overlay scrim view.

The new `MDMTransitionViewSnapshotter` class can be used to create and manage snapshot views during a transition.

```swift
let snapshotter = TransitionViewSnapshotter(containerView: context.containerView)
context.defer {
  snapshotter.removeAllSnapshots()
}

let snapshotView = snapshotter.snapshot(of: view, isAppearing: context.direction == .forward)
```

## Source changes

* [Add a snapshotting API and contextual transition example (#37)](https://github.com/material-motion/transitioning-objc/commit/a6ae314ddd5ff4e6f0ca9a8711348f8682d95e66) (featherless)
* [Store the presentation controller as a weak reference. (#34)](https://github.com/material-motion/transitioning-objc/commit/9f73e70e382ef8291f3ad85f7ccac25994f06e43) (featherless)
* [Add a stock presentation controller implementation. (#35)](https://github.com/material-motion/transitioning-objc/commit/6c98fa24f7e733262dc802b1e7c6b30134a29936) (featherless)
* [Minor formatting adjustment.](https://github.com/material-motion/transitioning-objc/commit/28f6e2e72534c8e0e77b60a98140be3bc06cd37a) (Jeff Verkoeyen)

## API changes

## MDMTransitionContext

*new* method: `deferToCompletion:`. Defers execution of the provided work until the completion of the transition.

## MDMTransitionPresentationController

*new* class: `MDMTransitionPresentationController`. A transition presentation controller implementation that supports animation delegation, a darkened overlay view, and custom presentation frames.

## MDMTransitionViewSnapshotter

*new* class: `MDMTransitionViewSnapshotter`. A view snapshotter creates visual replicas of views so that they may be animated during a transition without adversely affecting the original view hierarchy.

## Non-source changes

* [Add photo album example. (#38)](https://github.com/material-motion/transitioning-objc/commit/a1d49a6f432b7fddf8d15c90a5ea185fd8e03c5a) (featherless)
* [Add some organization to the transition examples. (#36)](https://github.com/material-motion/transitioning-objc/commit/27756b1e578cb8be3fa6d727a3aefafe9b1aa496) (featherless)

# 3.1.0

This minor release resolves a build warning and introduces the ability to customize navigation
controller transitions.

## New features

- MDMTransitionNavigationControllerDelegate makes it possible to customize transitions in a
  UINavigationController.

## Source changes

* [Add transition navigation controller delegate (#29)](https://github.com/material-motion/transitioning-objc/commit/c1c212030bb8ef8abc3eaaccc315e1880b1b01a1) (featherless)
* [Fix null dereference caught by the static analyzer (#30)](https://github.com/material-motion/transitioning-objc/commit/1aef0121ec4b5313ba3883a3fd3425551c19af14) (ianegordon)

## API changes

## MDMTransitionNavigationControllerDelegate

*new* class: MDMTransitionNavigationControllerDelegate.

# 3.0.1

Fixed the umbrella header name to match the library name.

# 3.0.0 (MotionTransitioning)

The library has been renamed to MotionTransitioning.

---

Prior releases under the library name `MaterialMotionTransitioning`.

# 2.0.0 (MaterialMotionTransitioning)

The library has been renamed to MaterialMotionTransitioning.

## New features

- `TransitionContext` now exposes a `presentationController` property.

## Source changes

* [Rename the library to MaterialMotionTransitioning.](https://github.com/material-motion/material-motion-transitioning-objc/commit/ce3e250b052fc762ed8682cd2efa9ede437707d4) (Jeff Verkoeyen)
* [Expose the presentation controller in TransitionContext (#26)](https://github.com/material-motion/material-motion-transitioning-objc/commit/f643cd58b845e2b428e3ef81020c18ea7fd387f6) (Eric Tang)

## API changes

Auto-generated by running:

    apidiff origin/stable release-candidate objc src/MaterialMotionTransitioning.h

## MDMTransitionContext

*new* property: `presentationController` in `MDMTransitionContext`

## Non-source changes

* [Set version to 1.0.0.](https://github.com/material-motion/material-motion-transitioning-objc/commit/5f2804b0213d7720e43152abf0893d6f5fb50048) (Jeff Verkoeyen)

---

Prior releases under the library name `Transitioning`.

# 1.1.1

This is a patch fix release to address build issues within Google's build environment.

## Source changes

* [Add missing UIKit.h header imports.](https://github.com/material-motion/transitioning-objc/commit/3b653bdd1758a5c47d277af36369e977b3774095) (Jeff Verkoeyen)

## Non-source changes

* [Update Podfile.lock.](https://github.com/material-motion/transitioning-objc/commit/8185ae402e6952e2727af8b7ff0cb4c712d05623) (Jeff Verkoeyen)
* [Add sliding menu as an example (#21)](https://github.com/material-motion/transitioning-objc/commit/4654e4c9c4c4ff49ac007f4b16eaa2458d86f98c) (Eric Tang)

# 1.1.0

This minor release introduces two new features to the Transition protocol family.

## New features

* [Add support for fallback transitioning. (#16)](https://github.com/material-motion/transitioning-objc/commit/e139cc2c5bb7234df6b40cc82bfb81ded57ccbf8) (featherless)
* [Add support for customizing transition durations (#11)](https://github.com/material-motion/transitioning-objc/commit/cf1e7961f51f9f07a252343bf618a45b2a00d707) (Eric Tang)

## API changes

### MDMTransitionWithFallback

*new* protocol: `MDMTransitionWithFallback`

*new* method: `-fallbackTransitionWithContext:` in `MDMTransitionWithFallback`

### MDMTransitionWithCustomDuration

*new* protocol: `MDMTransitionWithCustomDuration`

*new* method: `-transitionDurationWithContext:` in `MDMTransitionWithCustomDuration`

### MDMTransitionController

*new* property: `activeTransition` in `MDMTransitionController`

# 1.0.0

Initial release.

Includes support for building simple view controller transitions and transitions that support custom presentation.

## Source changes

* [Clarify the docs for default modal presentation styles. (#4)](https://github.com/material-motion/transitioning-objc/commit/84c23e5f7c490e2a7d299cca6c4046ac4f368551) (featherless)
* [Initial implementation. (#1)](https://github.com/material-motion/transitioning-objc/commit/c1b760455779226ebc9749e06e528d25a6b444bc) (featherless)

## Non-source changes

* [Simplify the frame calculation APIs in the example. (#5)](https://github.com/material-motion/transitioning-objc/commit/8688b045594ee38204744c7c644d4cce58165ec6) (featherless)

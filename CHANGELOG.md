# #develop#

 TODO: Enumerate changes.


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

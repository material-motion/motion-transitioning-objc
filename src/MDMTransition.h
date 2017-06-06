/*
 Copyright 2017-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <UIKit/UIKit.h>

@protocol MDMTransitionContext;

/**
 A transition coordinates the animated presentation or dismissal of a view controller.

 By default a transition is only expected to implement startWithContext: and to eventually call the
 context's `transitionDidEnd` method once the transition completes.

 A transition can opt in to extra behavior by conforming to other TransitionWith* protocols.
 */
NS_SWIFT_NAME(Transition)
@protocol MDMTransition <NSObject>

/**
 Invoked on initiation of a view controller transition.
 */
- (void)startWithContext:(nonnull id<MDMTransitionContext>)context;

@end

/**
 A transition with custom duration is able to override the default transition duration.
 */
NS_SWIFT_NAME(TransitionWithCustomDuration)
@protocol MDMTransitionWithCustomDuration
/**
 The desired duration of this transition in seconds.
 */
- (NSTimeInterval)transitionDurationWithContext:(nonnull id<MDMTransitionContext>)context;
@end

/**
 A transition can return an alternative fallback transition instance.
 */
NS_SWIFT_NAME(TransitionWithFallback)
@protocol MDMTransitionWithFallback

/**
 Asks the receiver to return a transition instance that should be used to drive this transition.

 If nil is returned, then the system transition will be used.
 If self is returned, then the receiver will be used.
 If a new instance is returned and the returned instance also conforms to this protocol, the
 returned instance will be queried for a fallback.

 Will be queried twice. The first time this method is invoked it's possible to return nil. Doing so
 will result in UIKit taking over the transition and a system transition being used. The second time
 this method is invoked, the custom transition will already be underway from UIKit's point of view
 and a nil return value will be treated equivalent to returning self.
 */
- (nullable id<MDMTransition>)fallbackTransitionWithContext:(nonnull id<MDMTransitionContext>)context;

@end

/**
 A transition with presentation is able to customize the overall presentation of the transition,
 including adding temporary views and changing the destination frame of the presented view
 controller.
 */
NS_SWIFT_NAME(TransitionWithPresentation)
@protocol MDMTransitionWithPresentation <MDMTransition>

/**
 The modal presentation style this transition expects to use.

 This method is queried when the transition is assigned to a view controller's
 `transitionController` transition property. The result, if any, is assigned to the view
 controller's `modalPresentationStyle` property.

 Note: In order for a presentation controller to be used the view controller's
 `modalPresentationStyle` must be `.custom`.

 If you do not wish to use a presentation controller, return anything other than
 `UIModalPresentationStyleCustom`.
 */
- (UIModalPresentationStyle)defaultModalPresentationStyle;

/**
 Queried when the presented view controller is first presented.

 The returned object is cached for the lifetime of the presented view controller.

 If the returned object conforms to MDMTransition then its `startWithContext:` implementation will
 be invoked before the transition's `startWithContext:`.

 If nil is returned then no presentation controller will be used.
 */
// clang-format off
- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(nonnull UIViewController *)presented
                                                               presentingViewController:(nonnull UIViewController *)presenting
                                                                   sourceViewController:(nullable UIViewController *)source
NS_SWIFT_NAME(presentationController(forPresented:presenting:source:));
// clang-format on

@end

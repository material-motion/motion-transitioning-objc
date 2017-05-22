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

#import "MDMViewControllerTransitionContext.h"

#import "MDMTransition.h"

@implementation MDMViewControllerTransitionContext {
  id<MDMTransition> _transition;
  id<UIViewControllerContextTransitioning> _transitionContext;
  UIPresentationController * _presentationController;
}

@synthesize direction = _direction;
@synthesize sourceViewController = _sourceViewController;
@synthesize backViewController = _backViewController;
@synthesize foreViewController = _foreViewController;

- (nonnull instancetype)initWithTransition:(nonnull id<MDMTransition>)transition
                                 direction:(MDMTransitionDirection)direction
                      sourceViewController:(nullable UIViewController *)sourceViewController
                        backViewController:(nonnull UIViewController *)backViewController
                        foreViewController:(nonnull UIViewController *)foreViewController
                    presentationController:(nullable UIPresentationController *)presentationController {
  self = [super init];
  if (self) {
    _transition = transition;
    _direction = direction;
    _sourceViewController = sourceViewController;
    _backViewController = backViewController;
    _foreViewController = foreViewController;
    _presentationController = presentationController;
  }
  return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  // TODO(featherless): Expose a TransitionWithTiming protocol that allows the transition to
  // customize this value.
  return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  _transitionContext = transitionContext;

  [self initiateTransition];
}

// TODO(featherless): Implement interactive transitioning. Need to implement
// UIViewControllerInteractiveTransitioning here and isInteractive and interactionController* in
// MDMPresentationTransitionController.

#pragma mark - MDMTransitionContext

- (NSTimeInterval)duration {
  return [self transitionDuration:_transitionContext];
}

- (UIView *)containerView {
  return _transitionContext.containerView;
}

- (void)transitionDidEnd {
  [_transitionContext completeTransition:true];

  _transition = nil;

  [_delegate transitionDidCompleteWithContext:self];
}

#pragma mark - Private

- (void)initiateTransition {
  UIViewController *from = [_transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  if (from) {
    CGRect finalFrame = [_transitionContext finalFrameForViewController:from];
    if (!CGRectIsEmpty(finalFrame)) {
      from.view.frame = finalFrame;
    }
  }

  UIViewController *to = [_transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  if (to) {
    CGRect finalFrame = [_transitionContext finalFrameForViewController:to];
    if (!CGRectIsEmpty(finalFrame)) {
      to.view.frame = finalFrame;
    }

    switch (_direction) {
      case MDMTransitionDirectionForward:
        [_transitionContext.containerView addSubview:to.view];
        break;

      case MDMTransitionDirectionBackward:
        if (!to.view.superview) {
          [_transitionContext.containerView insertSubview:to.view atIndex:0];
        }
        break;
    }

    [to.view layoutIfNeeded];
  }

  [self anticipateOnlyExplicitAnimations];

  [CATransaction begin];
  [CATransaction setAnimationDuration:[self transitionDuration:_transitionContext]];

  if ([_presentationController respondsToSelector:@selector(startWithContext:)]) {
    id<MDMTransition> asTransition = (id<MDMTransition>)_presentationController;
    [asTransition startWithContext:self];
  }

  [_transition startWithContext:self];

  [CATransaction commit];
}

// UIKit transitions will not animate any of the system animations (status bar changes, notably)
// unless we have at least one implicit UIView animation. Material Motion doesn't use implicit
// animations out of the box, so to ensure that system animations still occur we create an
// invisible throwaway view and apply an animation to it.
- (void)anticipateOnlyExplicitAnimations {
  UIView *throwawayView = [[UIView alloc] init];
  [self.containerView addSubview:throwawayView];

  [UIView animateWithDuration:[self transitionDuration:_transitionContext] animations:^{
    throwawayView.frame = CGRectOffset(throwawayView.frame, 1, 0);

  } completion:^(BOOL finished) {
    [throwawayView removeFromSuperview];
  }];
}

@end

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

#import "MDMViewControllerTransitionCoordinator.h"

#import "MDMTransition.h"

@interface MDMViewControllerTransitionContext : NSObject <MDMTransitionContext>
@property(nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property(nonatomic, strong) id<MDMTransition> transition;
@end

@protocol MDMViewControllerTransitionContextDelegate <NSObject>
- (void)transitionContextDidEnd:(MDMViewControllerTransitionContext *)context;
@end

@implementation MDMViewControllerTransitionContext {
  NSInteger _numberOfActiveTransitions;
  NSMutableArray *_sharedCompletionBlocks;
  __weak id<MDMViewControllerTransitionContextDelegate> _delegate;
}

@synthesize duration = _duration;
@synthesize direction = _direction;
@synthesize sourceViewController = _sourceViewController;
@synthesize backViewController = _backViewController;
@synthesize foreViewController = _foreViewController;
@synthesize presentationController = _presentationController;

- (instancetype)initWithTransition:(id<MDMTransition>)transition
                         direction:(MDMTransitionDirection)direction
              sourceViewController:(UIViewController *)sourceViewController
                backViewController:(UIViewController *)backViewController
                foreViewController:(UIViewController *)foreViewController
            presentationController:(UIPresentationController *)presentationController
            sharedCompletionBlocks:(NSMutableArray *)sharedCompletionBlocks
                          delegate:(id<MDMViewControllerTransitionContextDelegate>)delegate {
  self = [super init];
  if (self) {
    _transition = transition;
    _direction = direction;
    _sourceViewController = sourceViewController;
    _backViewController = backViewController;
    _foreViewController = foreViewController;
    _presentationController = presentationController;
    _sharedCompletionBlocks = sharedCompletionBlocks;
    _delegate = delegate;
    _numberOfActiveTransitions = 1;
  }
  return self;
}

- (void)composeWithTransition:(id<MDMTransition>)transition {
  _numberOfActiveTransitions++;
  [transition startWithContext:self];
}

- (UIView *)containerView {
  return _transitionContext.containerView;
}

- (void)deferToCompletion:(void (^)(void))work {
  [_sharedCompletionBlocks addObject:[work copy]];
}

- (void)transitionDidEnd {
  if (_numberOfActiveTransitions > 0) {
    _numberOfActiveTransitions--;
  }
  if (_numberOfActiveTransitions == 0) {
    [_delegate transitionContextDidEnd:self];
  }
}

@end

@interface MDMViewControllerTransitionCoordinator() <MDMViewControllerTransitionContextDelegate>
@end

@implementation MDMViewControllerTransitionCoordinator {
  MDMTransitionDirection _direction;
  UIPresentationController *_presentationController;

  NSMutableOrderedSet *_contexts;
  NSMutableArray *_completionBlocks;
  MDMViewControllerTransitionContext *_presentationContext;

  id<UIViewControllerContextTransitioning> _transitionContext;
}

- (instancetype)initWithTransitions:(NSArray<NSObject<MDMTransition> *> *)originalTransitions
                          direction:(MDMTransitionDirection)direction
               sourceViewController:(UIViewController *)sourceViewController
                 backViewController:(UIViewController *)backViewController
                 foreViewController:(UIViewController *)foreViewController
             presentationController:(UIPresentationController *)presentationController {
  self = [super init];
  if (self) {
    _direction = direction;
    _presentationController = presentationController;

    _completionBlocks = [NSMutableArray array];

    if (_presentationController) {
      _presentationContext =
          [[MDMViewControllerTransitionContext alloc] initWithTransition:nil
                                                               direction:direction
                                                    sourceViewController:sourceViewController
                                                      backViewController:backViewController
                                                      foreViewController:foreViewController
                                                  presentationController:presentationController
                                                  sharedCompletionBlocks:_completionBlocks
                                                                delegate:self];
    }

    // Build our contexts:

    _contexts = [NSMutableOrderedSet orderedSetWithCapacity:[originalTransitions count]];
    NSMutableArray *transitions = [NSMutableArray arrayWithCapacity:[originalTransitions count]];
    for (id<MDMTransition> transition in originalTransitions) {
      MDMViewControllerTransitionContext *context =
          [[MDMViewControllerTransitionContext alloc] initWithTransition:transition
                                                               direction:direction
                                                    sourceViewController:sourceViewController
                                                      backViewController:backViewController
                                                      foreViewController:foreViewController
                                                  presentationController:presentationController
                                                  sharedCompletionBlocks:_completionBlocks
                                                                delegate:self];
      if ([transition respondsToSelector:@selector(canPerformTransitionWithContext:)]) {
        id<MDMTransitionWithFeasibility> withFeasibility = (id<MDMTransitionWithFeasibility>)transition;
        if (![withFeasibility canPerformTransitionWithContext:context]) {
          continue;
        }
      }

      [transitions addObject:transition];
      [_contexts addObject:context];
    }

    if ([_contexts count] == 0) {
      self = nil;
      return nil; // No active transitions means no need for a coordinator.
    }
  }
  return self;
}

#pragma mark - MDMViewControllerTransitionContextDelegate

- (void)transitionContextDidEnd:(MDMViewControllerTransitionContext *)context {
  if (context != nil && _presentationContext == context) {
    _presentationContext = nil;
  } else if ([_contexts containsObject:context]) {
    [_contexts removeObject:context];
  }

  if (_contexts != nil && [_contexts count] == 0 && _presentationContext == nil) {
    _contexts = nil;

    for (void (^work)() in _completionBlocks) {
      work();
    }
    [_completionBlocks removeAllObjects];

    [_transitionContext completeTransition:true];

    [_delegate transitionDidCompleteWithCoordinator:self];
  }
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  NSTimeInterval maxDuration = 0;
  for (MDMViewControllerTransitionContext *context in _contexts) {
    if ([context.transition respondsToSelector:@selector(transitionDurationWithContext:)]) {
      id<MDMTransitionWithCustomDuration> withCustomDuration = (id<MDMTransitionWithCustomDuration>)context.transition;
      maxDuration = MAX(maxDuration, [withCustomDuration transitionDurationWithContext:context]);
    }
  }

  return (maxDuration > 0) ? maxDuration : 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  _transitionContext = transitionContext;

  [self initiateTransition];
}

// TODO(featherless): Implement interactive transitioning. Need to implement
// UIViewControllerInteractiveTransitioning here and isInteractive and interactionController* in
// MDMViewControllerTransitionController.

- (NSArray<NSObject<MDMTransition> *> *)activeTransitions {
  NSMutableArray *transitions = [NSMutableArray array];
  for (MDMViewControllerTransitionContext *context in _contexts) {
    [transitions addObject:context.transition];
  }
  return transitions;
}

#pragma mark - Private

- (void)initiateTransition {
  for (MDMViewControllerTransitionContext *context in _contexts) {
    context.transitionContext = _transitionContext;
  }

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

  [self mapTransitions];
  [self anticipateOnlyExplicitAnimations];

  [CATransaction begin];
  [CATransaction setAnimationDuration:[self transitionDuration:_transitionContext]];

  if ([_presentationController respondsToSelector:@selector(startWithContext:)]) {
    id<MDMTransition> asTransition = (id<MDMTransition>)_presentationController;
    [asTransition startWithContext:_presentationContext];
  }

  for (MDMViewControllerTransitionContext *context in _contexts) {
    [context.transition startWithContext:context];
  }

  [CATransaction commit];
}

// UIKit transitions will not animate any of the system animations (status bar changes, notably)
// unless we have at least one implicit UIView animation. Material Motion doesn't use implicit
// animations out of the box, so to ensure that system animations still occur we create an
// invisible throwaway view and apply an animation to it.
- (void)anticipateOnlyExplicitAnimations {
  UIView *throwawayView = [[UIView alloc] init];
  [_transitionContext.containerView addSubview:throwawayView];

  [UIView animateWithDuration:[self transitionDuration:_transitionContext]
                   animations:^{
                     throwawayView.frame = CGRectOffset(throwawayView.frame, 1, 0);

                   }
                   completion:^(BOOL finished) {
                     [throwawayView removeFromSuperview];
                   }];
}

#pragma mark - Private

- (void)mapTransitions {
  for (MDMViewControllerTransitionContext *context in _contexts) {
    id<MDMTransition> transition = context.transition;
    while ([transition respondsToSelector:@selector(fallbackTransitionWithContext:)]) {
      id<MDMTransitionWithFallback> withFallback = (id<MDMTransitionWithFallback>)transition;

      id<MDMTransition> fallback = [withFallback fallbackTransitionWithContext:context];
      if (fallback == transition) {
        break;
      }
      transition = fallback;
    }
    context.transition = transition;
  }
}

@end

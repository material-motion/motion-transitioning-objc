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

@class MDMViewControllerTransitionContextNode;

@protocol MDMViewControllerTransitionContextNodeParent <NSObject>
- (void)childNode:(MDMViewControllerTransitionContextNode *)childNode setCanceled:(BOOL)canceled;
- (void)childNode:(MDMViewControllerTransitionContextNode *)childNode setProgress:(CGFloat)progress;
- (void)childNodeInteractionStateDidChange:(MDMViewControllerTransitionContextNode *)childNode;
- (void)childNodeTransitionDidEnd:(MDMViewControllerTransitionContextNode *)childNode;
@end

@interface MDMViewControllerTransitionContextNode : NSObject <
  MDMTransitionContext,
  MDMTransitionInteractiveContext,
  MDMViewControllerTransitionContextNodeParent
>
@property(nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property(nonatomic, strong, readonly) id<MDMTransition> transition;
@property(nonatomic, copy, readonly) NSMutableArray<MDMViewControllerTransitionContextNode *> *children;
@end

@interface MDMViewControllerTransitionState : NSObject
@property(nonatomic) MDMTransitionDirection direction;
@property(nonatomic) BOOL canceled;
@property(nonatomic) CGFloat progress;
@property(nonatomic, strong, readonly) NSMutableArray *completionBlocks;
@property(nonatomic, strong, readonly) NSMutableArray *interactionDidBeginBlocks;
@property(nonatomic, strong, readonly) NSMutableArray *interactionDidEndBlocks;
@property(nonatomic, strong, readonly) NSMutableArray *interactionProgressDidChangeBlocks;
@end

@implementation MDMViewControllerTransitionState

- (instancetype)init {
  self = [super init];
  if (self) {
    _completionBlocks = [NSMutableArray array];
    _interactionDidBeginBlocks = [NSMutableArray array];
    _interactionDidEndBlocks = [NSMutableArray array];
    _interactionProgressDidChangeBlocks = [NSMutableArray array];
  }
  return self;
}

- (void)removeAllObjects {
  [_completionBlocks removeAllObjects];
  [_interactionDidBeginBlocks removeAllObjects];
  [_interactionDidEndBlocks removeAllObjects];
  [_interactionProgressDidChangeBlocks removeAllObjects];
}

@end

@implementation MDMViewControllerTransitionContextNode {
  MDMViewControllerTransitionState *_sharedState;

  BOOL _hasStarted;
  BOOL _didEnd;
  __weak id<MDMViewControllerTransitionContextNodeParent> _parent;
}

@synthesize duration = _duration;
@synthesize sourceViewController = _sourceViewController;
@synthesize backViewController = _backViewController;
@synthesize foreViewController = _foreViewController;
@synthesize presentationController = _presentationController;

- (instancetype)initWithTransition:(id<MDMTransition>)transition
              sourceViewController:(UIViewController *)sourceViewController
                backViewController:(UIViewController *)backViewController
                foreViewController:(UIViewController *)foreViewController
            presentationController:(UIPresentationController *)presentationController
                        sharedWork:(MDMViewControllerTransitionState *)sharedWork
                            parent:(id<MDMViewControllerTransitionContextNodeParent>)parent {
  self = [super init];
  if (self) {
    _children = [NSMutableArray array];
    _transition = transition;
    _sourceViewController = sourceViewController;
    _backViewController = backViewController;
    _foreViewController = foreViewController;
    _presentationController = presentationController;
    _sharedState = sharedWork;
    _parent = parent;

    if ([_transition respondsToSelector:@selector(setInteractiveContext:)]) {
      id<MDMTransitionWithInteraction> withInteraction = (id<MDMTransitionWithInteraction>)_transition;
      withInteraction.interactiveContext = self;
    }
  }
  return self;
}

#pragma mark - Private

- (MDMViewControllerTransitionContextNode *)spawnChildWithTransition:(id<MDMTransition>)transition {
  MDMViewControllerTransitionContextNode *node =
    [[MDMViewControllerTransitionContextNode alloc] initWithTransition:transition
                                                  sourceViewController:_sourceViewController
                                                    backViewController:_backViewController
                                                    foreViewController:_foreViewController
                                                presentationController:_presentationController
                                                            sharedWork:_sharedState
                                                                parent:self];
  node.transitionContext = _transitionContext;
  return node;
}

- (void)checkAndNotifyOfCompletion {
  BOOL anyChildActive = NO;
  for (MDMViewControllerTransitionContextNode *child in _children) {
    if (!child->_didEnd) {
      anyChildActive = YES;
      break;
    }
  }

  if (!anyChildActive && _didEnd) { // Inform our parent of completion.
    [_parent childNodeTransitionDidEnd:self];
  }
}

- (void)tearDown {
  if ([_transition respondsToSelector:@selector(setInteractiveContext:)]) {
    id<MDMTransitionWithInteraction> withInteraction = (id<MDMTransitionWithInteraction>)_transition;
    withInteraction.interactiveContext = nil;
  }

  for (MDMViewControllerTransitionContextNode *child in _children) {
    [child tearDown];
  }
}

#pragma mark - Public

- (void)start {
  if (_hasStarted) {
    return;
  }

  _hasStarted = YES;

  for (MDMViewControllerTransitionContextNode *child in _children) {
    [child attemptFallback];

    [child start];
  }

  if ([_transition respondsToSelector:@selector(startWithContext:)]) {
    [_transition startWithContext:self];
  } else {
    _didEnd = YES;

    [self checkAndNotifyOfCompletion];
  }
}

- (BOOL)isInteractive {
  if ([_transition respondsToSelector:@selector(isInteractive)]) {
    id<MDMTransitionWithInteraction> withInteraction = (id<MDMTransitionWithInteraction>)_transition;
    if ([withInteraction isInteractive]) {
      return YES;
    }
  }

  for (MDMViewControllerTransitionContextNode *child in _children) {
    if ([child isInteractive]) {
      return YES;
    }
  }

  return NO;
}

- (NSArray *)activeTransitions {
  NSMutableArray *activeTransitions = [NSMutableArray array];
  if (!_didEnd) {
    [activeTransitions addObject:self];
  }
  for (MDMViewControllerTransitionContextNode *child in _children) {
    [activeTransitions addObjectsFromArray:[child activeTransitions]];
  }
  return activeTransitions;
}

- (void)setTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
  _transitionContext = transitionContext;

  for (MDMViewControllerTransitionContextNode *child in _children) {
    child.transitionContext = transitionContext;
  }
}

- (void)setDuration:(NSTimeInterval)duration {
  _duration = duration;

  for (MDMViewControllerTransitionContextNode *child in _children) {
    child.duration = duration;
  }
}

- (void)attemptFallback {
  id<MDMTransition> transition = _transition;
  while ([transition respondsToSelector:@selector(fallbackTransitionWithContext:)]) {
    id<MDMTransitionWithFallback> withFallback = (id<MDMTransitionWithFallback>)transition;

    id<MDMTransition> fallback = [withFallback fallbackTransitionWithContext:self];
    if (fallback == transition) {
      break;
    }
    transition = fallback;
  }
  _transition = transition;
}

#pragma mark - MDMTransitionInteractiveContext

- (BOOL)canceled {
  return _sharedState.canceled;
}

- (void)setCanceled:(BOOL)canceled {
  [_parent childNode:self setCanceled:canceled];
}

- (CGFloat)progress {
  return _sharedState.progress;
}

- (void)setProgress:(CGFloat)progress {
  [_parent childNode:self setProgress:progress];
}

- (void)interactiveStateDidChange {
  [_parent childNodeInteractionStateDidChange:self];
}

#pragma mark - MDMViewControllerTransitionContextNodeDelegate

- (void)childNode:(MDMViewControllerTransitionContextNode *)childNode setCanceled:(BOOL)canceled {
  [_parent childNode:self setCanceled:canceled];
}

- (void)childNode:(MDMViewControllerTransitionContextNode *)childNode setProgress:(CGFloat)progress {
  [_parent childNode:self setProgress:progress];
}

- (void)childNodeTransitionDidEnd:(MDMViewControllerTransitionContextNode *)contextNode {
  [self checkAndNotifyOfCompletion];
}

- (void)childNodeInteractionStateDidChange:(MDMViewControllerTransitionContextNode *)childNode {
  [_parent childNodeInteractionStateDidChange:self];
}

#pragma mark - MDMTransitionContext

- (MDMTransitionDirection)direction {
  return _sharedState.direction;
}

- (void)composeWithTransition:(id<MDMTransition>)transition {
  MDMViewControllerTransitionContextNode *child = [self spawnChildWithTransition:transition];

  [_children addObject:child];

  if (_hasStarted) {
    [child start];
  }
}

- (UIView *)containerView {
  return _transitionContext.containerView;
}

- (void)deferToCompletion:(void (^)(void))work {
  [_sharedState.completionBlocks addObject:[work copy]];
}

- (void)transitionDidEnd {
  if (_didEnd) {
    return; // No use in re-notifying.
  }
  _didEnd = YES;

  [self checkAndNotifyOfCompletion];
}

- (void)interactionDidBegin:(void (^)(void))work {
  [_sharedState.interactionDidBeginBlocks addObject:[work copy]];
}

- (void)interactionDidEnd:(void (^)(BOOL, CGFloat))work {
  [_sharedState.interactionDidEndBlocks addObject:[work copy]];
}

- (void)interactionProgressDidChange:(void (^)(CGFloat))work {
  [_sharedState.interactionProgressDidChangeBlocks addObject:[work copy]];
}

@end

@interface MDMViewControllerTransitionCoordinator() <MDMViewControllerTransitionContextNodeParent>
@end

@implementation MDMViewControllerTransitionCoordinator {
  MDMTransitionDirection _initialDirection;
  UIPresentationController *_presentationController;

  MDMViewControllerTransitionContextNode *_root;
  MDMViewControllerTransitionState *_sharedState;
  BOOL _lastPropagatedInteractiveState;

  id<UIViewControllerContextTransitioning> _transitionContext;
}

- (instancetype)initWithTransition:(NSObject<MDMTransition> *)transition
                         direction:(MDMTransitionDirection)direction
              sourceViewController:(UIViewController *)sourceViewController
                backViewController:(UIViewController *)backViewController
                foreViewController:(UIViewController *)foreViewController
            presentationController:(UIPresentationController *)presentationController {
  self = [super init];
  if (self) {
    _initialDirection = direction;
    _presentationController = presentationController;
    _sharedState = [[MDMViewControllerTransitionState alloc] init];
    _sharedState.direction = direction;

    _root = [[MDMViewControllerTransitionContextNode alloc] initWithTransition:transition
                                                          sourceViewController:sourceViewController
                                                            backViewController:backViewController
                                                            foreViewController:foreViewController
                                                        presentationController:presentationController
                                                                    sharedWork:_sharedState
                                                                        parent:self];

    if (_presentationController
        && [_presentationController respondsToSelector:@selector(startWithContext:)]) {
      MDMViewControllerTransitionContextNode *presentationNode =
        [[MDMViewControllerTransitionContextNode alloc] initWithTransition:(id<MDMTransition>)_presentationController
                                                      sourceViewController:sourceViewController
                                                        backViewController:backViewController
                                                        foreViewController:foreViewController
                                                    presentationController:presentationController
                                                                sharedWork:_sharedState
                                                                    parent:_root];
      [_root.children addObject:presentationNode];
    }

    if ([transition respondsToSelector:@selector(canPerformTransitionWithContext:)]) {
      id<MDMTransitionWithFeasibility> withFeasibility = (id<MDMTransitionWithFeasibility>)transition;
      if (![withFeasibility canPerformTransitionWithContext:_root]) {
        self = nil;
        return nil; // No active transitions means no need for a coordinator.
      }
    }
  }
  return self;
}

#pragma mark - MDMViewControllerTransitionContextNodeDelegate

- (void)childNode:(MDMViewControllerTransitionContextNode *)node setCanceled:(BOOL)canceled {
  if (_root == nil || _root != node) {
    return;
  }

  _sharedState.canceled = canceled;

  if (_sharedState.canceled) {
    NSLog(@"Transition is canceled");

    _sharedState.direction = ((_initialDirection == MDMTransitionDirectionForward)
                  ? MDMTransitionDirectionBackward
                  : MDMTransitionDirectionForward);
  } else {
    NSLog(@"Transition is not canceled");
    _sharedState.direction = _initialDirection;
  }
}

- (void)childNode:(MDMViewControllerTransitionContextNode *)node setProgress:(CGFloat)progress {
  if (_root == nil || _root != node) {
    return;
  }

  _sharedState.progress = progress;

  NSLog(@"Interactive progress changed to %@", @(progress));

  [self updateInteractiveTransition:progress];

  for (void (^work)(CGFloat) in _sharedState.interactionProgressDidChangeBlocks) {
    work(progress);
  }
}

- (void)childNodeTransitionDidEnd:(MDMViewControllerTransitionContextNode *)node {
  if (_root == nil || _root != node) {
    return;
  }

  NSLog(@"Transition did end");

  // Unset any known strong references between the transition and our contexts.
  [_root tearDown];

  _root = nil;

  for (void (^work)(void) in _sharedState.completionBlocks) {
    work();
  }
  [_sharedState removeAllObjects];

  [_transitionContext completeTransition:_initialDirection == _sharedState.direction];
  _transitionContext = nil;

  [_delegate transitionDidCompleteWithCoordinator:self];
}

- (void)childNodeInteractionStateDidChange:(MDMViewControllerTransitionContextNode *)node {
  if (_root == nil || _root != node) {
    return;
  }

  BOOL isInteractive = [_root isInteractive];
  if (_lastPropagatedInteractiveState == isInteractive) {
    return;
  }

  if (isInteractive) {
    NSLog(@"Transition did become interactive");
  } else {
    NSLog(@"Transition stopped being interactive");
  }
  [self propagateInteractiveState];
}

- (void)propagateInteractiveState {
  _lastPropagatedInteractiveState = [_root isInteractive];
  if (_lastPropagatedInteractiveState) {
    for (void (^work)(void) in _sharedState.interactionDidBeginBlocks) {
      work();
    }

    if (@available(iOS 10.0, *)) {
      if (!_transitionContext.isInteractive) {
        [self pauseInteractiveTransition];
      }
    }

  } else {
    if (_sharedState.canceled) {
      [self cancelInteractiveTransition];

    } else {
      [self finishInteractiveTransition];
    }

    for (void (^work)(BOOL, CGFloat) in _sharedState.interactionDidEndBlocks) {
      work(_sharedState.canceled, _sharedState.progress);
    }
  }
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  NSTimeInterval duration = 0.35;
  if ([_root.transition respondsToSelector:@selector(transitionDurationWithContext:)]) {
    id<MDMTransitionWithCustomDuration> withCustomDuration = (id<MDMTransitionWithCustomDuration>)_root.transition;
    duration = [withCustomDuration transitionDurationWithContext:_root];
  }
  _root.duration = duration;
  return duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  _transitionContext = transitionContext;

  NSLog(@"Transition is animating");

  [self initiateTransition];
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
  // super calls animateTransition: for us.
  [super startInteractiveTransition:transitionContext];

  NSLog(@"Transition is starting in interactive mode");

  [self propagateInteractiveState];
}

#pragma mark - Public

- (NSArray<NSObject<MDMTransition> *> *)activeTransitions {
  return [_root activeTransitions];
}

- (BOOL)isInteractive {
  return [_root isInteractive];
}

#pragma mark - Private

- (void)initiateTransition {
  _root.transitionContext = _transitionContext;

  UIViewController *from = [_transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIView *fromView = [_transitionContext viewForKey:UITransitionContextFromViewKey];
  if (fromView == nil) {
    fromView = from.view;
  }
  if (fromView != nil && fromView == from.view) {
    CGRect finalFrame = [_transitionContext finalFrameForViewController:from];
    if (!CGRectIsEmpty(finalFrame)) {
      fromView.frame = finalFrame;
    }
  }

  UIViewController *to = [_transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView *toView = [_transitionContext viewForKey:UITransitionContextToViewKey];
  if (toView == nil) {
    toView = to.view;
  }
  if (toView != nil && toView == to.view) {
    CGRect finalFrame = [_transitionContext finalFrameForViewController:to];
    if (!CGRectIsEmpty(finalFrame)) {
      toView.frame = finalFrame;
    }

    if (toView.superview == nil) {
      switch (_sharedState.direction) {
        case MDMTransitionDirectionForward:
          [_transitionContext.containerView addSubview:toView];
          break;

        case MDMTransitionDirectionBackward:
          [_transitionContext.containerView insertSubview:toView atIndex:0];
          break;
      }
    }
  }

  [toView layoutIfNeeded];

  [_root attemptFallback];
  [self anticipateOnlyExplicitAnimations];

  [CATransaction begin];
  [CATransaction setAnimationDuration:[self transitionDuration:_transitionContext]];

  [_root start];

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

@end

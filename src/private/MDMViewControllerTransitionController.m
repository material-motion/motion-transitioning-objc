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

#import "MDMViewControllerTransitionController.h"

#import "MDMTransition.h"
#import "MDMViewControllerTransitionContext.h"

@interface MDMViewControllerTransitionController () <UIViewControllerTransitioningDelegate, MDMViewControllerTransitionContextDelegate>
@end

@implementation MDMViewControllerTransitionController {
  // We expect the view controller to hold a strong reference to its transition controller, so keep
  // a weak reference to the view controller here.
  __weak UIViewController *_associatedViewController;

  __weak UIPresentationController *_presentationController;

  MDMViewControllerTransitionContext *_context;
  __weak UIViewController *_source;
}

@synthesize transition = _transition;

- (nonnull instancetype)initWithViewController:(nonnull UIViewController *)viewController {
  self = [super init];
  if (self) {
    _associatedViewController = viewController;
  }
  return self;
}

#pragma mark - Public

- (void)setTransition:(id<MDMTransition>)transition {
  _transition = transition;

  // Set the default modal presentation style.
  if ([_transition respondsToSelector:@selector(defaultModalPresentationStyle)]) {
    id<MDMTransitionWithPresentation> withPresentation = (id<MDMTransitionWithPresentation>)_transition;
    UIModalPresentationStyle style = [withPresentation defaultModalPresentationStyle];
    _associatedViewController.modalPresentationStyle = style;
  }
}

- (id<MDMTransition>)activeTransition {
  return _context.transition;
}

#pragma mark - UIViewControllerTransitioningDelegate

// Animated transitions

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
  _source = source;

  [self prepareForTransitionWithSourceViewController:source
                                  backViewController:presenting
                                  foreViewController:presented
                                           direction:MDMTransitionDirectionForward];
  return _context;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
  [self prepareForTransitionWithSourceViewController:_source
                                  backViewController:dismissed.presentingViewController
                                  foreViewController:dismissed
                                           direction:MDMTransitionDirectionBackward];
  return _context;
}

// Presentation

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
  if (![_transition respondsToSelector:@selector(presentationControllerForPresentedViewController:presentingViewController:sourceViewController:)]) {
    return nil;
  }
  id<MDMTransitionWithPresentation> withPresentation = (id<MDMTransitionWithPresentation>)_transition;
  UIPresentationController *presentationController =
      [withPresentation presentationControllerForPresentedViewController:presented
                                                presentingViewController:presenting
                                                    sourceViewController:source];
  // _presentationController is weakly-held, so we have to do this local var dance to keep it
  // from being nil'd on assignment.
  _presentationController = presentationController;
  return presentationController;
}

#pragma mark - MDMViewControllerTransitionContextDelegate

- (void)transitionDidCompleteWithContext:(MDMViewControllerTransitionContext *)context {
  if (_context == context) {
    _context = nil;
  }
}

#pragma mark - Private

- (void)prepareForTransitionWithSourceViewController:(nullable UIViewController *)source
                                  backViewController:(nonnull UIViewController *)back
                                  foreViewController:(nonnull UIViewController *)fore
                                           direction:(MDMTransitionDirection)direction {
  if (direction == MDMTransitionDirectionBackward) {
    _context = nil;
  }
  NSAssert(!_context, @"A transition is already active.");

  if (_transition) {
    _context = [[MDMViewControllerTransitionContext alloc] initWithTransition:_transition
                                                                    direction:direction
                                                         sourceViewController:source
                                                           backViewController:back
                                                           foreViewController:fore
                                                       presentationController:_presentationController];
    _context.delegate = self;
  }
}

@end

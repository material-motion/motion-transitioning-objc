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

#import "MDMTransitionContext.h"

API_DEPRECATED_BEGIN("Use standard UIViewController transitioning APIs instead.",
                     ios(12, API_TO_BE_DEPRECATED))

@protocol MDMTransition;
@protocol MDMViewControllerTransitionCoordinatorDelegate;

@interface MDMViewControllerTransitionCoordinator : NSObject <UIViewControllerAnimatedTransitioning>

- (nonnull instancetype)initWithTransition:(nonnull NSObject<MDMTransition> *)transition
                                 direction:(MDMTransitionDirection)direction
                      sourceViewController:(nullable UIViewController *)sourceViewController
                        backViewController:(nonnull UIViewController *)backViewController
                        foreViewController:(nonnull UIViewController *)foreViewController
                    presentationController:(nullable UIPresentationController *)presentationController;
- (nonnull instancetype)init NS_UNAVAILABLE;

- (nonnull NSArray<NSObject<MDMTransition> *> *)activeTransitions;

@property(nonatomic, weak, nullable) id<MDMViewControllerTransitionCoordinatorDelegate> delegate;

@end

@protocol MDMViewControllerTransitionCoordinatorDelegate

- (void)transitionDidCompleteWithCoordinator:(nonnull MDMViewControllerTransitionCoordinator *)coordinator;

@end

API_DEPRECATED_END

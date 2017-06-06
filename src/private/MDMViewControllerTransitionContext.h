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

#import <Foundation/Foundation.h>

#import "MDMTransitionContext.h"

@protocol MDMTransition;
@protocol MDMViewControllerTransitionContextDelegate;

@interface MDMViewControllerTransitionContext : NSObject <MDMTransitionContext, UIViewControllerAnimatedTransitioning>

- (nonnull instancetype)initWithTransition:(nonnull id<MDMTransition>)transition
                                 direction:(MDMTransitionDirection)direction
                      sourceViewController:(nullable UIViewController *)sourceViewController
                        backViewController:(nonnull UIViewController *)backViewController
                        foreViewController:(nonnull UIViewController *)foreViewController
                    presentationController:(nullable UIPresentationController *)presentationController
    NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)init NS_UNAVAILABLE;

@property(nonatomic, strong, nullable) id<MDMTransition> transition;

@property(nonatomic, weak, nullable) id<MDMViewControllerTransitionContextDelegate> delegate;

@end

@protocol MDMViewControllerTransitionContextDelegate

- (void)transitionDidCompleteWithContext:(nonnull MDMViewControllerTransitionContext *)context;

@end

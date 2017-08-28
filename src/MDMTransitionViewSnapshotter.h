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
#import <UIKit/UIKit.h>

/**
 A view snapshotter creates visual replicas of views so that they may be animated during a
 transition without adversely affecting the original view hierarchy.
 */
NS_SWIFT_NAME(TransitionViewSnapshotter)
@interface MDMTransitionViewSnapshotter : NSObject

- (nonnull instancetype)initWithContainerView:(nonnull UIView *)containerView NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)init NS_UNAVAILABLE;

/**
 Returns a snapshot view of the provided view.

 @param view The view to be snapshotted.
 @param isAppearing If the view is appearing for the first time, a slower form of snapshotting may
 be used. Otherwise, fast snapshotting may be used.
 @return A new UIView instance that can be used as a visual replica of the provided view.
 */
- (nonnull UIView *)snapshotOfView:(nonnull UIView *)view isAppearing:(BOOL)isAppearing;

- (void)transitionDidEnd;

@end

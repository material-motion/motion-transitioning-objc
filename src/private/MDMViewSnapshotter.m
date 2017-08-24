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

#import "MDMViewSnapshotter.h"

static UIView *FastSnapshotOfView(UIView *view) {
  return [view snapshotViewAfterScreenUpdates:NO];
}

static UIView *SlowSnapshotOfView(UIView *view) {
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
  UIView *copiedView = [[UIImageView alloc] initWithImage:copied];
  UIGraphicsEndImageContext();
  return copiedView;
}

@implementation MDMViewSnapshotter {
  UIView *_containerView;
  NSMutableArray *_snapshotViews;
  NSMutableArray *_hiddenViews;
}

- (void)dealloc {
  for (UIView *view in _snapshotViews) {
    [view removeFromSuperview];
  }
  for (UIView *view in _hiddenViews) {
    view.hidden = NO;
  }
}

- (instancetype)initWithContainerView:(UIView *)containerView {
  self = [super init];
  if (self) {
    _containerView = containerView;

    _snapshotViews = [NSMutableArray array];
    _hiddenViews = [NSMutableArray array];
  }
  return self;
}

- (UIView *)snapshotOfView:(UIView *)view isAppearing:(BOOL)isAppearing {
  UIView *snapshotView = isAppearing ? SlowSnapshotOfView(view) : FastSnapshotOfView(view);

  snapshotView.frame = [_containerView convertRect:view.bounds fromView:view];
  [_containerView addSubview:snapshotView];
  [_snapshotViews addObject:snapshotView];

  [_hiddenViews addObject:view];
  view.hidden = YES;

  return snapshotView;
}

@end

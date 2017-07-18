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

#import "FadeExample.h"

#import "TransitionsCatalog-Swift.h"

// This example demonstrates the minimal path to building a custom transition using the Material
// Motion Transitioning APIs in Objective-C. Please see the companion Swift implementation for
// detailed comments.

@interface FadeTransition : NSObject <MDMTransition>
@end

@implementation FadeExampleObjcViewController

- (void)didTap {
  ModalViewController *viewController = [[ModalViewController alloc] init];

  viewController.mdm_transitionController.transition = [[FadeTransition alloc] init];

  [self presentViewController:viewController animated:true completion:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor backgroundColor];

  UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
  label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  label.textColor = [UIColor whiteColor];
  label.textAlignment = NSTextAlignmentCenter;
  label.text = @"Tap to start the transition";
  [self.view addSubview:label];

  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(didTap)];
  [self.view addGestureRecognizer:tap];
}

+ (NSArray<NSString *> *)catalogBreadcrumbs {
  return @[ @"Fade transition (objc)" ];
}

@end

@implementation FadeTransition

- (NSTimeInterval)transitionDurationWithContext:(nonnull id<MDMTransitionContext>)context {
  return 0.3;
}

- (void)startWithContext:(id<MDMTransitionContext>)context {
  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    [context transitionDidEnd];
  }];

  CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];

  fade.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

  fade.fromValue = @0;
  fade.toValue = @1;

  if (context.direction == MDMTransitionDirectionBackward) {
    id swap = fade.fromValue;
    fade.fromValue = fade.toValue;
    fade.toValue = swap;
  }

  [context.foreViewController.view.layer addAnimation:fade forKey:fade.keyPath];
  [context.foreViewController.view.layer setValue:fade.toValue forKey:fade.keyPath];

  [CATransaction commit];
}

@end

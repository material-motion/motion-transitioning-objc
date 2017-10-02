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

import UIKit
import MotionTransitioning

// Transitions must be NSObject types that conform to the Transition protocol.
final class FadeTransition: NSObject, Transition {

  // The sole method we're expected to implement, start is invoked each time the view controller is
  // presented or dismissed.
  func start(with context: TransitionContext) {
    CATransaction.begin()

    CATransaction.setCompletionBlock {
      // Let UIKit know that the transition has come to an end.
      context.transitionDidEnd()
    }

    let fade = CABasicAnimation(keyPath: "opacity")

    fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

    // Define our animation assuming that we're going forward (presenting)...
    fade.fromValue = 0
    fade.toValue = 1

    // ...and reverse it if we're going backwards (dismissing).
    if context.direction == .backward {
      let swap = fade.fromValue
      fade.fromValue = fade.toValue
      fade.toValue = swap
    }

    // Add the animation...
    context.foreViewController.view.layer.add(fade, forKey: fade.keyPath)

    // ...and ensure that our model layer reflects the final value.
    context.foreViewController.view.layer.setValue(fade.toValue, forKeyPath: fade.keyPath!)

    CATransaction.commit()
  }
}

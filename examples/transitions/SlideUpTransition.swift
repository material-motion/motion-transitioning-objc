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

// Animates the target view from off the bottom of the screen to its initial position.
final class SlideUpTransition: NSObject, Transition {

  let target: TransitionTarget
  init(target: TransitionTarget) {
    self.target = target

    super.init()
  }

  func start(with context: TransitionContext) {
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      context.transitionDidEnd()
    }

    let shift = CASpringAnimation(keyPath: "position.y")

    // These values are extracted from UIKit's default modal presentation animation.
    shift.damping = 500
    shift.stiffness = 1000
    shift.mass = 3
    shift.duration = 0.5

    let snapshotter = TransitionViewSnapshotter(containerView: context.containerView)
    context.defer {
      snapshotter.removeAllSnapshots()
    }

    let snapshotTarget = snapshotter.snapshot(of: target.resolve(with: context),
                                              isAppearing: context.direction == .forward)

    // Start off-screen...
    shift.fromValue = context.containerView.bounds.height + snapshotTarget.layer.bounds.height / 2
    // ...and shift on-screen.
    shift.toValue = snapshotTarget.layer.position.y

    if context.direction == .backward {
      let swap = shift.fromValue
      shift.fromValue = shift.toValue
      shift.toValue = swap
    }
    snapshotTarget.layer.add(shift, forKey: shift.keyPath)
    snapshotTarget.layer.setValue(shift.toValue, forKeyPath: shift.keyPath!)

    CATransaction.commit()
  }
}

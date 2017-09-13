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

// A small helper function for creating bi-directional animations.
// See https://github.com/material-motion/motion-animator-objc for a more versatile
// bidirectional Core Animation implementation.
func addAnimationToLayer(animation: CABasicAnimation, layer: CALayer, direction: TransitionDirection) {
  if direction == .backward {
    let swap = animation.fromValue
    animation.fromValue = animation.toValue
    animation.toValue = swap
  }
  layer.add(animation, forKey: animation.keyPath)
  layer.setValue(animation.toValue, forKeyPath: animation.keyPath!)
}

final class SpringFrameTransition: NSObject, Transition {

  let target: TransitionTarget
  let size: CGSize
  init(target: TransitionTarget, size: CGSize) {
    self.target = target
    self.size = size

    super.init()
  }

  func start(with context: TransitionContext) {
    let contextView = target.resolve(with: context)

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      context.transitionDidEnd()
    }

    let shift = CASpringAnimation(keyPath: "position")
    shift.damping = 500
    shift.stiffness = 1000
    shift.mass = 3
    shift.duration = 0.5
    shift.fromValue = contextView.layer.position
    shift.toValue = CGPoint(x: context.foreViewController.view.bounds.midX,
                            y: context.foreViewController.view.bounds.midY)
    addAnimationToLayer(animation: shift, layer: contextView.layer, direction: context.direction)

    let expansion = CASpringAnimation(keyPath: "bounds.size")
    expansion.damping = 500
    expansion.stiffness = 1000
    expansion.mass = 3
    expansion.duration = 0.5
    expansion.fromValue = contextView.layer.bounds.size
    expansion.toValue = size
    addAnimationToLayer(animation: expansion, layer: contextView.layer, direction: context.direction)

    CATransaction.commit()
  }
}

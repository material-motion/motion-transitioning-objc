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

protocol ContextualImageTransitionForeDelegate {
  func foreContextView(for transition: ContextualImageTransition) -> UIImageView?
}

protocol ContextualImageTransitionBackDelegate {
  func backContextView(for transition: ContextualImageTransition,
                       with foreViewController: UIViewController) -> UIImageView?
}

final class ContextualImageTransition: NSObject, Transition, TransitionWithFeasibility {

  let backDelegate: ContextualImageTransitionBackDelegate
  let foreDelegate: ContextualImageTransitionForeDelegate
  init(backDelegate: ContextualImageTransitionBackDelegate,
       foreDelegate: ContextualImageTransitionForeDelegate) {
    self.backDelegate = backDelegate
    self.foreDelegate = foreDelegate
  }

  func canPerformTransition(with context: TransitionContext) -> Bool {
    return backDelegate.backContextView(for: self, with: context.foreViewController) != nil
  }

  func start(with context: TransitionContext) {
    guard let contextView = backDelegate.backContextView(for: self,
                                                         with: context.foreViewController) else {
      return
    }
    guard let foreImageView = foreDelegate.foreContextView(for: self) else {
      return
    }

    // A small helper function for creating bi-directional animations.
    // See https://github.com/material-motion/motion-animator-objc for a more versatile
    // bidirectional Core Animation implementation.
    let addAnimationToLayer: (CABasicAnimation, CALayer) -> Void = { animation, layer in
      if context.direction == .backward {
        let swap = animation.fromValue
        animation.fromValue = animation.toValue
        animation.toValue = swap
      }
      layer.add(animation, forKey: animation.keyPath)
      layer.setValue(animation.toValue, forKeyPath: animation.keyPath!)
    }

    let snapshotter = TransitionViewSnapshotter(containerView: context.containerView)
    context.defer {
      snapshotter.removeAllSnapshots()
    }

    let imageSize = foreImageView.image!.size

    let fitScale = min(foreImageView.bounds.width / imageSize.width,
                       foreImageView.bounds.height / imageSize.height)
    let fitSize = CGSize(width: fitScale * imageSize.width, height: fitScale * imageSize.height)

    foreImageView.isHidden = true
    context.defer {
      foreImageView.isHidden = false
    }

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      context.transitionDidEnd()
    }

    let fadeIn = CABasicAnimation(keyPath: "opacity")
    fadeIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    fadeIn.fromValue = 0
    fadeIn.toValue = 1
    addAnimationToLayer(fadeIn, context.foreViewController.view.layer)

    let snapshotContextView = snapshotter.snapshot(of: contextView,
                                                   isAppearing: context.direction == .backward)

    let shift = CASpringAnimation(keyPath: "position")
    shift.damping = 500
    shift.stiffness = 1000
    shift.mass = 3
    shift.duration = 0.5
    shift.fromValue = snapshotContextView.layer.position
    shift.toValue = CGPoint(x: context.foreViewController.view.bounds.midX,
                            y: context.foreViewController.view.bounds.midY)
    addAnimationToLayer(shift, snapshotContextView.layer)

    let expansion = CASpringAnimation(keyPath: "bounds.size")
    expansion.damping = 500
    expansion.stiffness = 1000
    expansion.mass = 3
    expansion.duration = 0.5
    expansion.fromValue = snapshotContextView.layer.bounds.size
    expansion.toValue = fitSize
    addAnimationToLayer(expansion, snapshotContextView.layer)
    
    CATransaction.commit()
  }
}

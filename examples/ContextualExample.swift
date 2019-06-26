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

// This example demonstrates how to build a contextual transition.

class ContextualExampleViewController: ExampleViewController {

  @objc func didTap(_ tapGesture: UITapGestureRecognizer) {
    let controller = DestinationViewController()

    // A contextual transition is provided with information relevant to the transition, such as the
    // view that is being expanded/collapsed. This information can be provided at initialization
    // time if it is unlikely to ever change (e.g. a static view on the screen as in this example).
    //
    // If it's possible for the context to change, then a delegate pattern is a preferred solution
    // because it will allow the delegate to request the new context each time the transition
    // begins. This can be helpful in building photo album transitions, for example.
    //
    // Note that in this example we're populating the contextual transition with the tapped view.
    // Our rudimentary transition will animate the context view to the center of the screen from its
    // current location.
    controller.mdm_transitionController.transition = CompositeTransition(transitions: [
      FadeTransition(target: .foreView),
      ContextualTransition(contextView: tapGesture.view!)
    ])

    present(controller, animated: true)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let square = UIView(frame: .init(x: 16, y: 200, width: 128, height: 128))
    square.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin,
                               .flexibleRightMargin, .flexibleBottomMargin]
    square.backgroundColor = .blue
    view.addSubview(square)

    let circle = UIView(frame: .init(x: 64, y: 400, width: 128, height: 128))
    circle.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin,
                               .flexibleRightMargin, .flexibleBottomMargin]
    circle.backgroundColor = .red
    view.addSubview(circle)

    square.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
    circle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap to present a modal transition.")
  }
}

private class ContextualTransition: NSObject, Transition {

  // Store the context for the lifetime of the transition.
  let contextView: UIView
  init(contextView: UIView) {
    self.contextView = contextView
  }

  func start(with context: TransitionContext) {
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

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      context.transitionDidEnd()
    }

    // We use a snapshot view to accomplish two things:
    // 1) To not affect the context view's state.
    // 2) To allow our context view to appear in front of the fore view controller's view.
    //
    // The provided view snapshotter will automatically hide the snapshotted view and remove the
    // snapshot view upon completion of the transition.
    let snapshotContextView = snapshotter.snapshot(of: contextView,
                                                   isAppearing: context.direction == .backward)

    let expand = CABasicAnimation(keyPath: "transform.scale.xy")
    expand.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    expand.fromValue = 1
    expand.toValue = 2
    addAnimationToLayer(expand, snapshotContextView.layer)

    let shift = CASpringAnimation(keyPath: "position")
    shift.damping = 500
    shift.stiffness = 1000
    shift.mass = 3
    shift.duration = 0.5
    shift.fromValue = snapshotContextView.layer.position
    shift.toValue = CGPoint(x: context.foreViewController.view.bounds.midX,
                            y: context.foreViewController.view.bounds.midY)
    addAnimationToLayer(shift, snapshotContextView.layer)

    context.compose(with: FadeTransition(target: .target(snapshotContextView),
                                         style: .fadeOut))

    CATransaction.commit()
  }
}

private class DestinationViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .primaryColor

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
  }

  @objc func didTap() {
    dismiss(animated: true)
  }
}

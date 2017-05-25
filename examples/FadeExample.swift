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
import Transitioning

// This example demonstrates the minimal path to building a custom transition using the Material
// Motion Transitioning APIs in Swift. The essential steps have been documented below.

class FadeExampleViewController: ExampleViewController {

  func didTap() {
    let modalViewController = ModalViewController()

    // The transition controller is an associated object on all UIViewController instances that
    // allows you to customize the way the view controller is presented. The primary API on the
    // controller that you'll make use of is the `transition` property. Setting this property will
    // dictate how the view controller is presented. For this example we've built a custom
    // FadeTransition, so we'll make use of that now:
    modalViewController.transitionController.transition = FadeTransition()

    // Note that once we assign the transition object to the view controller, the transition will
    // govern all subsequent presentations and dismissals of that view controller instance. If we
    // want to use a different transition (e.g. to use an edge-swipe-to-dismiss transition) then we
    // can simply change the transition object before initiating the transition.

    present(modalViewController, animated: true)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let label = UILabel(frame: view.bounds)
    label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    label.textColor = .white
    label.textAlignment = .center
    label.text = "Tap to start the transition"
    view.addSubview(label)

    let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
    view.addGestureRecognizer(tap)
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap to present a modal transition.")
  }
}

// Transitions must be NSObject types that conform to the Transition protocol.
private final class FadeTransition: NSObject, Transition {

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

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

// This example demonstrates how to build a custom UINavigationController transition using the
// Motion Transitioning APIs in Swift. The essential steps have been documented below.

class NavControllerFadeExampleViewController: ExampleViewController {

  @objc func didTap() {
    let modalViewController = ModalViewController()
    modalViewController.title = "Example view controller"

    // The transition controller is an associated object on all UIViewController instances that
    // allows you to customize the way the view controller is presented. The primary API on the
    // controller that you'll make use of is the `transition` property. Setting this property will
    // dictate how the view controller is presented. For this example we've built a custom
    // FadeTransition, so we'll make use of that now:
    modalViewController.mdm_transitionController.transition = FadeTransition(target: .foreView)

    cachedNavDelegate = navigationController?.delegate

    // In order to customize navigation controller transitions you must implement the necessary
    // delegate methods. By setting the shared transition navigation controller delegate instance
    // we're able to customize push/pop transitions using our transitionController.

    navigationController?.delegate = TransitionNavigationControllerDelegate.sharedDelegate()

    navigationController?.pushViewController(modalViewController, animated: true)
  }
  private var cachedNavDelegate: UINavigationControllerDelegate?

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    if parent == nil { // Popped off
      // Restore the previous delegate, if any.
      navigationController?.delegate = cachedNavDelegate

      cachedNavDelegate = nil
    }
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

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

class MenuExampleViewController: ExampleViewController {

  @objc func didTap() {
    let modalViewController = ModalViewController()
    modalViewController.mdm_transitionController.transition = MenuTransition()
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

private final class MenuTransition: NSObject, TransitionWithPresentation {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController?) -> UIPresentationController? {
    return nil
  }

  func defaultModalPresentationStyle() -> UIModalPresentationStyle {
    return .overCurrentContext
  }
  
  func start(with context: TransitionContext) {
    let foreView = context.foreViewController.view!
    if(context.direction == .forward) {
      foreView.frame.origin.x = -1 * foreView.frame.width
      UIView.animate(
        withDuration: context.duration,
        animations: {
          foreView.frame.origin.x = -1 * (foreView.frame.width / 2)
        },
        completion: { _ in
          context.transitionDidEnd()
        }
      )
    } else {
      UIView.animate(
        withDuration: context.duration,
        animations: {
          foreView.frame.origin.x = -1 * foreView.frame.width
        },
        completion: { _ in
          context.transitionDidEnd()
        }
      )
    }
  }
}

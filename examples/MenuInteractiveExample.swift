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

class MenuGestureViewController: ExampleViewController {
  var call: (() -> Void)! = nil

  public func setCall(call: @escaping ()->Void) {
    self.call = call
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let tap = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanGesture))
    tap.edges = .left
    view.addGestureRecognizer(tap)

    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }

  var percentage = CGFloat(0.01)
  func edgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
    let translation = sender.location(in: sender.view?.superview)
    switch sender.state {
    case .began:
      call()
    case .changed:
      percentage = translation.x / ((sender.view!.frame.width)/2)
      percentage = min(percentage, 0.99)
      interactiveTransitionContext?.updatePercent(percentage)
    case .ended:
      if percentage > 0.8 {
        interactiveTransitionContext?.finishInteractiveTransition()
      } else {
        interactiveTransitionContext?.cancelInteractiveTransition()
      }
      interactiveTransitionContext = nil
      percentage = CGFloat(0.01)
    default:
      break
    }
  }
}

// This example demonstrates the minimal path to building a custom transition using the Material
// Motion Transitioning APIs in Swift. The essential steps have been documented below.

class MenuInteractiveExampleViewController: MenuGestureViewController {

  func didTap() {
    let modalViewController = ModalInteractiveViewController()

    // The transition controller is an associated object on all UIViewController instances that
    // allows you to customize the way the view controller is presented. The primary API on the
    // controller that you'll make use of is the `transition` property. Setting this property will
    // dictate how the view controller is presented. For this example we've built a custom
    // FadeTransition, so we'll make use of that now:
    modalViewController.transitionController.transition = MenuTransition()

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
    label.text = "Swipe from left edge to start the transition"
    view.addSubview(label)

    setCall(call: didTap)
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap to present a modal transition.")
  }
}

// Transitions must be NSObject types that conform to the Transition protocol.
private final class MenuTransition: NSObject, Transition, InteractiveTransition {

  // The sole method we're expected to implement, start is invoked each time the view controller is
  // presented or dismissed.
  func start(with context: TransitionContext) {
    let fromVC = context.backViewController
    let toVC = context.foreViewController
    let containerView = context.containerView

    if(context.direction == .forward) {
      containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
      toVC.view.frame.origin.x = -1 * toVC.view.frame.width
      UIView.animate(
        withDuration: context.duration,
        delay: 0,
        options: .curveLinear,
        animations: {
          toVC.view.frame.origin.x = -1 * (toVC.view.frame.width / 2)
        },
        completion: { _ in
          let deadlineTime = DispatchTime.now() + .milliseconds(10)
          DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            context.transitionDidEnd()
          }
        }
      )
      if let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) {
        snapshot.isUserInteractionEnabled = false
        containerView.insertSubview(snapshot, belowSubview: toVC.view)
        snapshot.tag = 2000
      }
    } else {
      UIView.animate(
        withDuration: context.duration,
        delay: 0,
        options: .curveLinear,
        animations: {
          toVC.view.frame.origin.x = -1 * toVC.view.frame.width
        },
        completion: { _ in

          let deadlineTime = DispatchTime.now() + .milliseconds(10)
          DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            context.transitionDidEnd()
          }

          if(context.wasCancelled == false) {
            containerView.viewWithTag(2000)?.removeFromSuperview()
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
          }
        }
      )
    }
  }

  func isInteractive(_ context: TransitionContext) -> Bool {
    return true
  }

  func start(withInteractiveContext context: InteractiveTransitionContext) {
    context.sourceViewController!.interactiveTransitionContext = context
    context.foreViewController.interactiveTransitionContext = context
  }
}

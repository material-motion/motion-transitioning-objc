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
import MaterialMotionTransitioning

// This example demonstrates how to make use of presentation controllers to build a flexible modal
// transition that supports presenting view controllers at aribtrary frames on the screen.

class CustomPresentationExampleViewController: ExampleTableViewController {

  override init(style: UITableViewStyle) {
    super.init(style: style)

    // Aside: we're using a simple model pattern here to define the data for the different
    // transitions up separate from their presentation. Check out the `didSelectRowAt`
    // implementation to see how we're ultimately presenting the modal view controller.

    // By default, the vertical sheet transition will behave like a full screen transition...
    transitions.append(.init(name: "Vertical sheet", transition: VerticalSheetTransition()))

    // ...but we can also customize the frame of the presented view controller by providing a frame
    // calculation block.
    let modalDialog = VerticalSheetTransition()
    modalDialog.calculateFrameOfPresentedViewInContainerView = { info in
      guard let containerView = info.containerView else {
        assertionFailure("Missing container view during frame query.")
        return .zero
      }
      // Note: this block is retained for the lifetime of the view controller, so be careful not to
      // create a memory loop by referencing self or the presented view controller directly - use
      // the provided info structure to access these values instead.

      // Center the dialog in the container view.
      let size = CGSize(width: 200, height: 200)
      return CGRect(x: (containerView.bounds.width - size.width) / 2,
                    y: (containerView.bounds.height - size.height) / 2,
                    width: size.width,
                    height: size.height)
    }
    transitions.append(.init(name: "Modal dialog", transition: modalDialog))
  }

  override func exampleInformation() -> ExampleInfo {
    return .init(title: type(of: self).catalogBreadcrumbs().last!,
                 instructions: "Tap to present a modal transition.")
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class VerticalSheetTransition: NSObject, Transition {

  // When provided, the transition will use a presentation controller to customize the presentation
  // of the transition.
  var calculateFrameOfPresentedViewInContainerView: CalculateFrame?

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

    // Start off-screen...
    shift.fromValue = context.containerView.bounds.height + context.foreViewController.view.layer.bounds.height / 2
    // ...and shift on-screen.
    shift.toValue = context.foreViewController.view.layer.position.y

    if context.direction == .backward {
      let swap = shift.fromValue
      shift.fromValue = shift.toValue
      shift.toValue = swap
    }
    context.foreViewController.view.layer.add(shift, forKey: shift.keyPath)
    context.foreViewController.view.layer.setValue(shift.toValue, forKeyPath: shift.keyPath!)

    CATransaction.commit()
  }
}

extension VerticalSheetTransition: TransitionWithPresentation, TransitionWithFallback {

  // We customize the transition going forward but fall back to UIKit for dismissal. Our
  // presentation controller will govern both of these transitions.
  func fallbackTransition(with context: TransitionContext) -> Transition? {
    return context.direction == .forward ? self : nil
  }

  // This method is invoked when we assign the transition to the transition controller. The result
  // is assigned to the view controller's modalPresentationStyle property.
  func defaultModalPresentationStyle() -> UIModalPresentationStyle {
    if calculateFrameOfPresentedViewInContainerView != nil {
      return .custom
    }
    return .fullScreen
  }

  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController,
                              source: UIViewController?) -> UIPresentationController? {
    if let calculateFrameOfPresentedViewInContainerView = calculateFrameOfPresentedViewInContainerView {
      return DimmingPresentationController(presentedViewController: presented,
                                           presenting: presenting,
                                           calculateFrameOfPresentedViewInContainerView: calculateFrameOfPresentedViewInContainerView)
    }
    return nil
  }
}

// What follows is a fairly typical presentation controller implementation that adds a dimming view
// and fades the dimming view in/out during the transition.
//
// Note that we've conformed to the Transition type: this allows the presentation controller to
// add any custom animations during the transition. The presentation controller's `start` method
// will be invoked before the Transition object's `start` method.

final class DimmingPresentationController: UIPresentationController {

  init(presentedViewController: UIViewController,
              presenting presentingViewController: UIViewController,
              calculateFrameOfPresentedViewInContainerView: @escaping CalculateFrame) {
    let dimmingView = UIView()
    dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.3)
    dimmingView.alpha = 0
    dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.dimmingView = dimmingView

    self.calculateFrameOfPresentedViewInContainerView = calculateFrameOfPresentedViewInContainerView

    super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
  }

  override var frameOfPresentedViewInContainerView: CGRect {
    // We delegate out our frame calculation here:
    return calculateFrameOfPresentedViewInContainerView(self)
  }

  override func presentationTransitionWillBegin() {
    guard let containerView = containerView else { return }

    dimmingView.frame = containerView.bounds
    containerView.insertSubview(dimmingView, at: 0)

    // This autoresizing mask assumes that the calculated frame is centered in the screen. This
    // assumption won't hold true if the frame is aligned to a particular edge. We could improve
    // this implementation by allowing the creator of the transition to customize the
    // autoresizingMask in some manner.
    presentedViewController.view.autoresizingMask = [.flexibleLeftMargin,
                                                     .flexibleTopMargin,
                                                     .flexibleRightMargin,
                                                     .flexibleBottomMargin]
  }

  override func presentationTransitionDidEnd(_ completed: Bool) {
    if !completed {
      dimmingView.removeFromSuperview()
    }
  }

  override func dismissalTransitionWillBegin() {
    // We fall back to an alongside fade out when there is no active transition instance because
    // our start implementation won't be invoked in this case.
    if presentedViewController.transitionController.activeTransition == nil {
      presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
        self.dimmingView.alpha = 0
      })
    }
  }

  override func dismissalTransitionDidEnd(_ completed: Bool) {
    if completed {
      dimmingView.removeFromSuperview()
    } else {
      dimmingView.alpha = 1
    }
  }

  private let calculateFrameOfPresentedViewInContainerView: CalculateFrame
  fileprivate let dimmingView: UIView
}

extension DimmingPresentationController: Transition {
  func start(with context: TransitionContext) {
    let fade = CABasicAnimation(keyPath: "opacity")
    fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    fade.fromValue = 0
    fade.toValue = 1
    if context.direction == .backward {
      let swap = fade.fromValue
      fade.fromValue = fade.toValue
      fade.toValue = swap
    }
    dimmingView.layer.add(fade, forKey: fade.keyPath)
    dimmingView.layer.setValue(fade.toValue, forKeyPath: fade.keyPath!)
  }
}

typealias CalculateFrame = (UIPresentationController) -> CGRect

// MARK: Supplemental code

extension CustomPresentationExampleViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
  }
}

struct TransitionInfo {
  let name: String
  let transition: Transition
}
var transitions: [TransitionInfo] = []

extension CustomPresentationExampleViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return transitions.count
  }
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = transitions[indexPath.row].name
    return cell
  }
}

extension CustomPresentationExampleViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let modal = ModalViewController()
    modal.transitionController.transition = transitions[indexPath.row].transition
    showDetailViewController(modal, sender: self)
  }
}

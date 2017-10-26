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

// This example demonstrates how to make use of presentation controllers to build a flexible modal
// transition that supports presenting view controllers at aribtrary frames on the screen.

class CustomPresentationExampleViewController: ExampleTableViewController {

  override init(style: UITableViewStyle) {
    super.init(style: style)

    transitions = []

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

final class DragToDismissTransition: NSObject, Transition {
  fileprivate let dismissGesture: UIPanGestureRecognizer
  fileprivate let transition: Transition
  init(transition: Transition, dismissGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()) {
    self.transition = transition
    self.dismissGesture = dismissGesture

    super.init()

    dismissGesture.addTarget(self, action: #selector(didPanToDismiss))
  }

  var dismiss: (() -> Void)?
  var interactiveContext: TransitionInteractiveContext?
  func didPanToDismiss(gestureRecognizer: UIPanGestureRecognizer) {
    if gestureRecognizer.state == .began {
      guard let dismiss = dismiss else {
        return
      }
      dismiss()

    } else if gestureRecognizer.state == .changed {
      guard let interactiveContext = interactiveContext else {
        return
      }

      interactiveContext.progress =
          gestureRecognizer.translation(in: gestureRecognizer.view).y
          / (interactiveContext.foreViewController.view.bounds.height)

    } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
      guard let interactiveContext = interactiveContext else {
        return
      }

      interactiveContext.canceled = gestureRecognizer.velocity(in: gestureRecognizer.view).y < 0

      interactiveContext.interactiveStateDidChange()
    }
  }

  func start(with context: TransitionContext) {
    if dismissGesture.view == nil {
      context.foreViewController.view.addGestureRecognizer(dismissGesture)
    }

    context.compose(with: transition)

    context.transitionDidEnd()
  }
}

extension DragToDismissTransition: TransitionWithInteraction {

  func isInteractive() -> Bool {
    return dismissGesture.state == .began || dismissGesture.state == .changed
  }
}

extension DragToDismissTransition: TransitionWithPresentation {

  // This method is invoked when we assign the transition to the transition controller. The result
  // is assigned to the view controller's modalPresentationStyle property.
  func defaultModalPresentationStyle() -> UIModalPresentationStyle {
    guard let transitionWithPresentation = transition as? TransitionWithPresentation else {
      return .fullScreen
    }
    return transitionWithPresentation.defaultModalPresentationStyle()
  }

  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController,
                              source: UIViewController?) -> UIPresentationController? {
    guard let transitionWithPresentation = transition as? TransitionWithPresentation else {
      return nil
    }
    return transitionWithPresentation.presentationController(forPresented:presented,
                                                             presenting:presenting,
                                                             source:source)
  }
}

final class VerticalSheetTransition: NSObject, Transition {

  // When provided, the transition will use a presentation controller to customize the presentation
  // of the transition.
  var calculateFrameOfPresentedViewInContainerView: TransitionFrameCalculation?

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
    shift.beginTime = context.foreViewController.view.layer.convertTime(CACurrentMediaTime(), from: nil)
    context.foreViewController.view.layer.add(shift, forKey: shift.keyPath)
    context.foreViewController.view.layer.setValue(shift.toValue, forKeyPath: shift.keyPath!)

    let layer = context.foreViewController.view.layer

    context.interactionDidBegin {
      animator.pauseAnimation()

      shift.speed = 0
      layer.add(shift, forKey: shift.keyPath)
    }
    context.interactionProgressDidChange { progress in
      animator.factionComplete = progress

      shift.timeOffset = TimeInterval(progress) * shift.duration
      layer.add(shift, forKey: shift.keyPath)
    }
    context.interactionDidEnd { isReversed in
      animator.isReversed = isReversed
      animator.startAnimation()

      if (isReversed) {
        shift.toValue = shift.fromValue
        shift.fromValue = layer.presentation()!.value(forKeyPath: shift.keyPath!)
        shift.duration = shift.duration - shift.timeOffset
      }

      // Reconnect our layer with the render server's clock.
      let pausedTime = shift.timeOffset
      shift.speed = 1
      shift.timeOffset = 0
      shift.beginTime = 0
      let timeSincePause = context.foreViewController.view.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
      shift.beginTime = timeSincePause

      layer.add(shift, forKey: shift.keyPath)
    }

    CATransaction.commit()

    //
    //    // Start off-screen...
    //    var fromValue = context.containerView.bounds.height + context.foreViewController.view.layer.bounds.height / 2
    //    // ...and shift on-screen.
    //    var toValue = context.foreViewController.view.layer.position.y
    //
    //    if context.direction == .backward {
    //      let swap = fromValue
    //      fromValue = toValue
    //      toValue = swap
    //    }
    //
    //    if #available(iOS 10.0, *) {
    //      context.foreViewController.view.center.y = fromValue
    //      let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1.0) {
    //        context.foreViewController.view.center.y = toValue
    //      }
    //      animator.addCompletion { _ in
    //        context.transitionDidEnd()
    //      }
    //      animator.startAnimation()
    //
    //      context.interactionDidBegin {
    //        animator.pauseAnimation()
    //      }
    //      context.interactionProgressDidChange { progress in
    //        animator.fractionComplete = progress
    //      }
    //      context.interactionDidEnd { isReversed in
    //        animator.isReversed = isReversed
    //        animator.startAnimation()
    //      }
    //
    //    } else {
    //      context.transitionDidEnd()
    //    }
  }
}

extension VerticalSheetTransition: TransitionWithPresentation, TransitionWithFeasibility {

  // We customize the transition going forward but fall back to UIKit for dismissal. Our
  // presentation controller will govern both of these transitions.
  func canPerformTransition(with context: TransitionContext) -> Bool {
    return context.direction == .forward
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
      return TransitionPresentationController(presentedViewController: presented,
                                              presenting: presenting,
                                              calculateFrameOfPresentedView: calculateFrameOfPresentedViewInContainerView)
    }
    return nil
  }
}

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
    let transition = DragToDismissTransition(transition: transitions[indexPath.row].transition)
    weak var weakModal = modal
    transition.dismiss = {
      guard let strongModal = weakModal else {
        return
      }
      guard !strongModal.isBeingDismissed else {
        return
      }
      strongModal.dismiss(animated: true)
    }
    modal.mdm_transitionController.transition = transition
    showDetailViewController(modal, sender: self)
  }
}

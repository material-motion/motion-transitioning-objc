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

import XCTest
import MotionTransitioning

class TransitionWithPresentationTests: XCTestCase {

  private var window: UIWindow!
  override func setUp() {
    window = UIWindow()
    window.rootViewController = UIViewController()
    window.makeKeyAndVisible()
  }

  override func tearDown() {
    window = nil
  }

  func testPresentationControllerIsQueriedAndCompletesWithoutAnimation() {
    let presentedViewController = UIViewController()
    presentedViewController.mdm_transitionController.transition = TestingPresentationTransition()

    let didComplete = expectation(description: "Did complete")
    window.rootViewController!.present(presentedViewController, animated: false) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.5)

    XCTAssert(presentedViewController.presentationController is TestingPresentationController)
  }

  func testPresentationControllerIsQueriedAndCompletesWithAnimation() {
    let presentedViewController = UIViewController()
    presentedViewController.mdm_transitionController.transition = TestingPresentationTransition()

    let didComplete = expectation(description: "Did complete")
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.5)

    XCTAssert(presentedViewController.presentationController is TestingPresentationController)
  }

  func testPresentedFrameMatchesWindowFrame() {
    let presentedViewController = UIViewController()
    let transition = InstantCompletionTransition()
    presentedViewController.transitionController.transition = transition

    let didComplete = expectation(description: "Did complete")
    window.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.1)

    XCTAssertEqual(window.rootViewController!.presentedViewController, presentedViewController)
    XCTAssertEqual(window.rootViewController!.presentedViewController?.view.bounds,
                   window.rootViewController!.view.bounds)
  }

  func testPresentedFrameMatchesPresentationFrame() {
    let presentedViewController = UIViewController()
    let transition = TestingPresentationTransition()
    transition.presentationFrame = CGRect(x: 100, y: 30, width: 50, height: 70)
    presentedViewController.transitionController.transition = transition

    let didComplete = expectation(description: "Did complete")
    window.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.1)

    XCTAssertEqual(window.rootViewController!.presentedViewController, presentedViewController)
    XCTAssertEqual(window.rootViewController!.presentedViewController?.view.frame,
                   transition.presentationFrame)
  }

  func testNoFramesModifiedWhenThereIsAPresentationView() {
    let presentedViewController = UIViewController()
    let transition = TestingPresentationTransition()
    let presentationFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let presentationView = UIView(frame: presentationFrame)
    transition.presentationView = presentationView
    presentedViewController.transitionController.transition = transition

    let didComplete = expectation(description: "Did complete")
    window.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.1)

    XCTAssertEqual(window.rootViewController!.presentedViewController, presentedViewController)
    XCTAssertEqual(presentationView.frame, presentationFrame)
    XCTAssertEqual(presentedViewController.view.frame, UIScreen.main.bounds)
  }
}

final class TestingPresentationController: UIPresentationController {
  var presentationFrame: CGRect?
  var presentationView: UIView?
  override var frameOfPresentedViewInContainerView: CGRect {
    if let presentationFrame = presentationFrame {
      return presentationFrame
    }
    return super.frameOfPresentedViewInContainerView
  }

  override var presentedView: UIView? {
    return presentationView
  }

  override func presentationTransitionWillBegin() {
    super.presentationTransitionWillBegin()

    if let presentationView = presentationView {
      containerView?.addSubview(presentationView)
    }
  }
}

final class TestingPresentationTransition: NSObject, TransitionWithPresentation {
  var presentationFrame: CGRect?
  var presentationView: UIView?

  func defaultModalPresentationStyle() -> UIModalPresentationStyle {
    return .custom
  }

  func presentationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController?) -> UIPresentationController? {
    let presentationController =
      TestingPresentationController(presentedViewController: presented, presenting: presenting)
    presentationController.presentationFrame = presentationFrame
    presentationController.presentationView = presentationView
    return presentationController
  }

  func start(with context: TransitionContext) {
    context.transitionDidEnd()
  }
}

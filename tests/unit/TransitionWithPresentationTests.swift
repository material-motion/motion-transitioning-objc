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
    presentedViewController.mdm_transitionController.transition =
      PresentationTransition(presentationControllerType: TestingPresentationController.self)

    let didComplete = expectation(description: "Did complete")
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.5)

    XCTAssert(presentedViewController.presentationController is TestingPresentationController)
  }

  func testPresentationControllerIsQueriedAndCompletesWithAnimation() {
    let presentedViewController = UIViewController()
    presentedViewController.mdm_transitionController.transition =
      PresentationTransition(presentationControllerType: TransitionPresentationController.self)

    let didComplete = expectation(description: "Did complete")
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.5)

    XCTAssert(presentedViewController.presentationController is TransitionPresentationController)
  }
}

final class TestingPresentationController: UIPresentationController {
}

final class PresentationTransition: NSObject, TransitionWithPresentation {
  let presentationControllerType: UIPresentationController.Type
  init(presentationControllerType: UIPresentationController.Type) {
    self.presentationControllerType = presentationControllerType

    super.init()
  }

  func defaultModalPresentationStyle() -> UIModalPresentationStyle {
    return .custom
  }

  func presentationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController?) -> UIPresentationController? {
    return presentationControllerType.init(presentedViewController: presented, presenting: presenting)
  }

  func start(with context: TransitionContext) {
    context.transitionDidEnd()
  }
}

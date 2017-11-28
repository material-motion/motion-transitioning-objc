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

class TransitionTests: XCTestCase {

  private var window: UIWindow!
  override func setUp() {
    window = UIWindow()
    window.rootViewController = UIViewController()
    window.makeKeyAndVisible()
  }

  override func tearDown() {
    window = nil
  }

  func testTransitionDidEndDoesComplete() {
    let presentedViewController = UIViewController()
    presentedViewController.mdm_transitionController.transition = InstantCompletionTransition()

    let didComplete = expectation(description: "Did complete")
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.1)

    XCTAssertEqual(window.rootViewController!.presentedViewController, presentedViewController)
  }

  func testTransitionCompositionDoesComplete() {
    let presentedViewController = UIViewController()
    presentedViewController.mdm_transitionController.transition = CompositeTransition(transitions: [
      InstantCompletionTransition(),
      InstantCompletionTransition()
    ])

    let didComplete = expectation(description: "Did complete")
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.1)

    XCTAssertEqual(window.rootViewController!.presentedViewController, presentedViewController)
  }

  func testTransitionFallbackToOtherTransitionDoesComplete() {
    let presentedViewController = UIViewController()
    let transition = FallbackTransition(to: InstantCompletionTransition())
    presentedViewController.mdm_transitionController.transition = transition

    let didComplete = expectation(description: "Did complete")
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.1)

    XCTAssertFalse(transition.startWasInvoked)
    XCTAssertEqual(window.rootViewController!.presentedViewController, presentedViewController)
  }

  func testTransitionFallbackToSelfDoesComplete() {
    let presentedViewController = UIViewController()
    let transition = FallbackTransition()
    presentedViewController.mdm_transitionController.transition = transition

    let didComplete = expectation(description: "Did complete")
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.1)

    XCTAssertTrue(transition.startWasInvoked)
    XCTAssertEqual(window.rootViewController!.presentedViewController, presentedViewController)
  }
}


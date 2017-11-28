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

final class DurationMemoryTransition: NSObject, Transition {
  var recordedDuration: TimeInterval?
  func start(with context: TransitionContext) {
    recordedDuration = context.duration

    context.transitionDidEnd()
  }
}

final class CustomDurationMemoryTransition: NSObject, TransitionWithCustomDuration {
  let duration: TimeInterval
  init(with duration: TimeInterval) {
    self.duration = duration
  }

  func transitionDuration(with context: TransitionContext) -> TimeInterval {
    return duration
  }

  var recordedDuration: TimeInterval?
  func start(with context: TransitionContext) {
    recordedDuration = context.duration

    context.transitionDidEnd()
  }
}

class TransitionWithCustomDurationTests: XCTestCase {

  private var window: UIWindow!
  override func setUp() {
    window = UIWindow()
    window.rootViewController = UIViewController()
    window.makeKeyAndVisible()
  }

  override func tearDown() {
    window = nil
  }

  func testDefaultDurationIsProvidedViaContext() {
    let presentedViewController = UIViewController()
    let transition = DurationMemoryTransition()
    presentedViewController.mdm_transitionController.transition = transition

    let didComplete = expectation(description: "Did complete")
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.1)

    // TODO: This should be an extern const in the library.
    XCTAssertEqual(transition.recordedDuration, 0.35)

    XCTAssertEqual(window.rootViewController!.presentedViewController, presentedViewController)
  }

  func testCustomDurationIsProvidedViaContext() {
    let presentedViewController = UIViewController()
    let customDuration: TimeInterval = 0.1
    let transition = CustomDurationMemoryTransition(with: customDuration)
    presentedViewController.mdm_transitionController.transition = transition

    let didComplete = expectation(description: "Did complete")
    window.rootViewController!.present(presentedViewController, animated: true) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 0.1)

    XCTAssertEqual(transition.recordedDuration, customDuration)

    XCTAssertEqual(window.rootViewController!.presentedViewController, presentedViewController)
  }
}


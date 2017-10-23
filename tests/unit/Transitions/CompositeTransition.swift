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

final class CompositeTransition: NSObject, Transition, TransitionWithCustomDuration {

  let transitions: [Transition]
  init(transitions: [Transition]) {
    self.transitions = transitions

    super.init()
  }

  // The sole method we're expected to implement, start is invoked each time the view controller is
  // presented or dismissed.
  func start(with context: TransitionContext) {
    transitions.forEach { context.compose(with: $0) }

    context.transitionDidEnd()
  }

  // MARK: TransitionWithCustomDuration

  func transitionDuration(with context: TransitionContext) -> TimeInterval {
    let duration = transitions.flatMap { $0 as? TransitionWithCustomDuration }.map { $0.transitionDuration(with: context) }.max { $0 < $1 }
    if let duration = duration {
      return duration
    }
    return 0.35
  }
}


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

import MotionTransitioning

final class FallbackTransition: NSObject, Transition, TransitionWithFallback {

  let fallbackTo: Transition?

  init(to: Transition) {
    self.fallbackTo = to
  }

  override init() {
    self.fallbackTo = nil
  }

  func fallbackTransition(with context: TransitionContext) -> Transition {
    if let fallbackTo = fallbackTo {
      return fallbackTo
    }
    return self
  }

  var startWasInvoked = false
  func start(with context: TransitionContext) {
    startWasInvoked = true
    context.transitionDidEnd()
  }
}


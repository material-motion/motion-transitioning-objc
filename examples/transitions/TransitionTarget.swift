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

// A potential target for a transition's motion.
enum TransitionTarget {
  case backView
  case foreView
  case target(UIView)

  func resolve(with context: TransitionContext) -> UIView {
    switch self {
    case .backView:
      return context.backViewController.view
    case .foreView:
      return context.foreViewController.view
    case .target(let view):
      return view
    }
  }
}

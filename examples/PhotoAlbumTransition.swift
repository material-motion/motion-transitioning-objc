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

import Foundation
import UIKit
import MotionTransitioning

protocol PhotoAlbumTransitionForeDelegate: class {
  func foreContextView(for transition: PhotoAlbumTransition) -> UIImageView?
  func toolbar(for transition: PhotoAlbumTransition) -> UIToolbar?
}

protocol PhotoAlbumTransitionBackDelegate: class {
  func backContextView(for transition: PhotoAlbumTransition,
                       with foreViewController: UIViewController) -> UIImageView?
}

final class PhotoAlbumTransition: NSObject, Transition, TransitionWithFeasibility {
  weak var backDelegate: PhotoAlbumTransitionBackDelegate?
  weak var foreDelegate: PhotoAlbumTransitionForeDelegate?
  init(backDelegate: PhotoAlbumTransitionBackDelegate,
       foreDelegate: PhotoAlbumTransitionForeDelegate) {
    self.backDelegate = backDelegate
    self.foreDelegate = foreDelegate
  }

  func canPerformTransition(with context: TransitionContext) -> Bool {
    guard let backDelegate = backDelegate else {
      return false
    }
    return backDelegate.backContextView(for: self, with: context.foreViewController) != nil
  }

  func start(with context: TransitionContext) {
    guard let backDelegate = backDelegate, let foreDelegate = foreDelegate else {
      return
    }
    guard let contextView = backDelegate.backContextView(for: self,
                                                         with: context.foreViewController) else {
                                                          return
    }
    guard let foreImageView = foreDelegate.foreContextView(for: self) else {
      return
    }

    let snapshotter = TransitionViewSnapshotter(containerView: context.containerView)
    context.defer {
      snapshotter.removeAllSnapshots()
    }

    foreImageView.isHidden = true
    context.defer {
      foreImageView.isHidden = false
    }

    let imageSize = foreImageView.image!.size

    let fitScale = min(foreImageView.bounds.width / imageSize.width,
                       foreImageView.bounds.height / imageSize.height)
    let fitSize = CGSize(width: fitScale * imageSize.width, height: fitScale * imageSize.height)

    let snapshotContextView = snapshotter.snapshot(of: contextView,
                                                   isAppearing: context.direction == .backward)

    context.compose(with: FadeTransition(target: .foreView, style: .fadeIn))
    context.compose(with: SpringFrameTransition(target: .target(snapshotContextView),
                                                size: fitSize))

    if let toolbar = foreDelegate.toolbar(for: self) {
      context.compose(with: SlideUpTransition(target: .target(toolbar)))
    }

    // This transition doesn't directly produce any animations, so we inform the context that it is
    // complete here, otherwise the transition would never complete:
    context.transitionDidEnd()
  }
}

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

class PhotoCollectionViewCell: UICollectionViewCell {
  let imageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)

    imageView.contentMode = .scaleAspectFill
    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    imageView.frame = bounds
    imageView.clipsToBounds = true

    contentView.addSubview(imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

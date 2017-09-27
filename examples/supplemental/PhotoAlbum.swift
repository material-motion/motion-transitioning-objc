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

let numberOfImageAssets = 10
let numberOfPhotosInAlbum = 30

class PhotoAlbum {
  let photos: [Photo]
  let identifierToIndex: [String: Int]

  init() {
    var photos: [Photo] = []
    var identifierToIndex: [String: Int] = [:]
    for index in 0..<numberOfPhotosInAlbum {
      let photo = Photo(name: "image\(index % numberOfImageAssets)")
      photos.append(photo)
      identifierToIndex[photo.uuid] = index
    }
    self.photos = photos
    self.identifierToIndex = identifierToIndex
  }
}

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

// MARK: Catalog by convention

extension ContextualExampleViewController {
  @objc class func catalogBreadcrumbs() -> [String] { return ["Contextual transition"] }
}

extension FadeExampleViewController {
  @objc class func catalogBreadcrumbs() -> [String] { return ["Fade transition"] }
}

extension NavControllerFadeExampleViewController {
  @objc class func catalogBreadcrumbs() -> [String] { return ["Fade transition (nav controller)"] }
}

extension MenuExampleViewController {
  @objc class func catalogBreadcrumbs() -> [String] { return ["Menu transition"] }
}

extension PhotoAlbumExampleViewController {
  @objc class func catalogBreadcrumbs() -> [String] { return ["Photo album transition"] }
}

extension CustomPresentationExampleViewController {
  @objc class func catalogBreadcrumbs() -> [String] { return ["Custom presentation transitions"] }
}

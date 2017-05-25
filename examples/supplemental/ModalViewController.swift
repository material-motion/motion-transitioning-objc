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

class ModalViewController: ExampleViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .primaryColor

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))

    let label = UILabel(frame: view.bounds)
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In aliquam dolor eget orci condimentum, eu blandit metus dictum. Suspendisse vitae metus pellentesque, sagittis massa vel, sodales velit. Aliquam placerat nibh et posuere interdum. Etiam fermentum purus vel turpis lobortis auctor. Curabitur auctor maximus purus, ac iaculis mi. In ac hendrerit sapien, eget porttitor risus. Integer placerat cursus viverra. Proin mollis nulla vitae nisi posuere, eu rutrum mauris condimentum. Nullam in faucibus nulla, non tincidunt lectus. Maecenas mollis massa purus, in viverra elit molestie eu. Nunc volutpat magna eget mi vestibulum pharetra. Suspendisse nulla ligula, laoreet non ante quis, vehicula facilisis libero. Morbi faucibus, sapien a convallis sodales, leo quam scelerisque leo, ut tincidunt diam velit laoreet nulla. Proin at quam vel nibh varius ultrices porta id diam. Pellentesque pretium consequat neque volutpat tristique. Sed placerat a purus ut molestie. Nullam laoreet venenatis urna non pulvinar. Proin a vestibulum nulla, eu placerat est. Morbi molestie aliquam justo, ut aliquet neque tristique consectetur. In hac habitasse platea dictumst. Fusce vehicula justo in euismod elementum. Ut vel malesuada est. Aliquam mattis, ex vel viverra eleifend, mauris nibh faucibus nibh, in fringilla sem purus vitae elit. Donec sed dapibus orci, ut vulputate sapien. Integer eu magna efficitur est pellentesque tempor. Sed ac imperdiet ex. Maecenas congue quis lacus vel dictum. Phasellus dictum mi at sollicitudin euismod. Mauris laoreet, eros vitae euismod commodo, libero ligula pretium massa, in scelerisque eros dui eu metus. Fusce elementum mauris velit, eu tempor nulla congue ut. In at tellus id quam feugiat semper eget ut felis. Nulla quis varius quam. Nullam tincidunt laoreet risus, ut aliquet nisl gravida id. Nulla iaculis mauris velit, vitae feugiat nunc scelerisque ac. Vivamus eget ligula porta, pulvinar ex vitae, sollicitudin erat. Maecenas semper ornare suscipit. Ut et neque condimentum lectus pulvinar maximus in sit amet odio. Aliquam congue purus erat, eu rutrum risus placerat a."
    label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(label)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  func didTap() {
    dismiss(animated: true)
  }
}

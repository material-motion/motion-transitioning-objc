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

// This example demonstrates how to build a photo album contextual transition.

let numberOfImageAssets = 10
let numberOfPhotosInAlbum = 30

struct Photo {
  let name: String
  let image: UIImage
  let uuid: String

  fileprivate init(name: String) {
    self.uuid = NSUUID().uuidString
    self.name = name

    // NOTE: In a real app you should never load images from disk on the UI thread like this.
    // Instead, you should find some way to cache the thumbnails in memory and then asynchronously
    // load the full-size photos from disk/network when needed. The photo library APIs provide
    // exactly this sort of behavior (square thumbnails are accessible immediately on the UI thread
    // while the full-sized photos need to be loaded asynchronously).
    self.image = UIImage(named: "\(self.name).jpg")!
  }
}

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

private let photoCellIdentifier = "photoCell"

private class PhotoCollectionViewCell: UICollectionViewCell {
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

public class PhotoAlbumExampleViewController: UICollectionViewController, ContextualImageTransitionBackDelegate {

  let album = PhotoAlbum()

  init() {
    super.init(collectionViewLayout: UICollectionViewFlowLayout())
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    collectionView!.backgroundColor = .white
    collectionView!.register(PhotoCollectionViewCell.self,
                             forCellWithReuseIdentifier: photoCellIdentifier)
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    updateLayout()
  }

  func updateLayout() {
    let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
    layout.sectionInset = .init(top: 4, left: 4, bottom: 4, right: 4)
    layout.minimumInteritemSpacing = 4
    layout.minimumLineSpacing = 4

    let numberOfColumns: CGFloat = 3
    let squareDimension = (view.bounds.width - layout.sectionInset.left - layout.sectionInset.right - (numberOfColumns - 1) * layout.minimumInteritemSpacing) / numberOfColumns
    layout.itemSize = CGSize(width: squareDimension, height: squareDimension)
  }

  public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return album.photos.count
  }

  public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier,
                                                  for: indexPath) as! PhotoCollectionViewCell
    let photo = album.photos[indexPath.row]
    cell.imageView.image = photo.image
    return cell
  }

  public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let viewController = PhotoAlbumViewController(album: album)
    viewController.currentPhoto = album.photos[indexPath.row]
    viewController.transitionController.transitions = [
      PhotoAlbumTransition(backDelegate: self, foreDelegate: viewController),
    ]
    present(viewController, animated: true)
  }

  func backContextView(for transition: PhotoAlbumTransition,
                       with foreViewController: UIViewController) -> UIImageView? {
    let currentPhoto = (foreViewController as! PhotoAlbumViewController).currentPhoto
    guard let photoIndex = album.identifierToIndex[currentPhoto.uuid] else {
      return nil
    }
    let photoIndexPath = IndexPath(item: photoIndex, section: 0)
    if collectionView?.cellForItem(at: photoIndexPath) == nil {
      collectionView?.scrollToItem(at: photoIndexPath, at: .top, animated: false)
      collectionView?.reloadItems(at: [photoIndexPath])
    }
    guard let cell = collectionView?.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell else {
      return nil
    }
    return cell.imageView
  }
}

protocol ContextualImageTransitionForeDelegate {
  func foreContextView(for transition: PhotoAlbumTransition) -> UIImageView?
}

protocol ContextualImageTransitionBackDelegate {
  func backContextView(for transition: PhotoAlbumTransition,
                       with foreViewController: UIViewController) -> UIImageView?
}

final class PhotoAlbumTransition: NSObject, Transition, TransitionWithFeasibility {
  let backDelegate: ContextualImageTransitionBackDelegate
  let foreDelegate: ContextualImageTransitionForeDelegate
  init(backDelegate: ContextualImageTransitionBackDelegate,
       foreDelegate: ContextualImageTransitionForeDelegate) {
    self.backDelegate = backDelegate
    self.foreDelegate = foreDelegate
  }

  func canPerformTransition(with context: TransitionContext) -> Bool {
    return backDelegate.backContextView(for: self, with: context.foreViewController) != nil
  }

  func start(with context: TransitionContext) {
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

    if let photoAlbumViewController = context.foreViewController as? PhotoAlbumViewController {
      context.compose(with: SlideUpTransition(target: .target(photoAlbumViewController.toolbar)))
    }

    // This transition doesn't directly produce any animations, so we inform the context that it is
    // complete here, otherwise the transition would never complete:
    context.transitionDidEnd()
  }
}

private class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ContextualImageTransitionForeDelegate {

  var collectionView: UICollectionView!
  let toolbar = UIToolbar()
  var currentPhoto: Photo

  let album: PhotoAlbum
  init(album: PhotoAlbum) {
    self.album = album
    self.currentPhoto = self.album.photos.first!

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    automaticallyAdjustsScrollViewInsets = false

    let layout = UICollectionViewFlowLayout()
    layout.itemSize = view.bounds.size
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 8
    layout.footerReferenceSize = CGSize(width: layout.minimumLineSpacing / 2,
                                        height: view.bounds.size.height)
    layout.headerReferenceSize = layout.footerReferenceSize
    layout.scrollDirection = .horizontal

    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
    collectionView.isPagingEnabled = true
    collectionView.backgroundColor = .backgroundColor
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.dataSource = self
    collectionView.delegate = self

    collectionView.register(PhotoCollectionViewCell.self,
                            forCellWithReuseIdentifier: photoCellIdentifier)

    var extendedBounds = view.bounds
    extendedBounds.size.width = extendedBounds.width + layout.minimumLineSpacing
    collectionView.bounds = extendedBounds

    view.addSubview(collectionView)

    let toolbarSize = toolbar.sizeThatFits(view.bounds.size)
    toolbar.frame = .init(x: 0, y: view.bounds.height - toolbarSize.height,
                          width: toolbarSize.width, height: toolbarSize.height)
    view.addSubview(toolbar)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    collectionView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigationController?.setNavigationBarHidden(true, animated: animated)

    let photoIndex = album.photos.index { $0.image == currentPhoto.image }!
    let indexPath = IndexPath(item: photoIndex, section: 0)
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: ContextualImageTransitionForeDelegate

  func foreContextView(for transition: PhotoAlbumTransition) -> UIImageView? {
    return (collectionView.cellForItem(at: indexPathForCurrentPhoto()) as! PhotoCollectionViewCell).imageView
  }

  // MARK: UICollectionViewDataSource

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return album.photos.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier,
                                                  for: indexPath) as! PhotoCollectionViewCell
    let photo = album.photos[indexPath.row]
    cell.imageView.image = photo.image
    cell.imageView.contentMode = .scaleAspectFit
    return cell
  }

  // MARK: UICollectionViewDelegate

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    dismiss(animated: true)
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    currentPhoto = album.photos[indexPathForCurrentPhoto().item]
  }

  // MARK: Private

  private func indexPathForCurrentPhoto() -> IndexPath {
    return collectionView.indexPathsForVisibleItems.first!
  }
}

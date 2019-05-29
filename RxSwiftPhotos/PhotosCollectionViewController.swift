//
//  PhotosCollectionViewController.swift
//  RxSwiftPhotos
//
//  Created by Federico Nieto on 29/05/2019.
//  Copyright © 2019 Fede. All rights reserved.
//

import UIKit
import Photos
import RxSwift

class PhotosCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var images = [PHAsset]()
    
    var selectedSubject = PublishSubject<UIImage>()
    var selectedPhoto: Observable<UIImage> {
        return selectedSubject.asObservable()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        populatePhotos()
    }
    
    private func populatePhotos() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                let assets = PHAsset.fetchAssets(with: .image, options: nil)
                assets.enumerateObjects({ (object, count, stop) in
                    self.images.append(object)
                })
                self.images.reverse()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }

}

extension PhotosCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotosCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let asset = images[indexPath.row]
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil) { (image, _) in
            DispatchQueue.main.async {
                cell.image.image = image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = self.images[indexPath.row]
        PHImageManager.default().requestImage(for: selectedImage, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: nil) { (image, info) in
            guard let info = info else { return }
            let isDegraded = info["PHImageResultIsDegradedKey"] as! Bool
            if !isDegraded {
                if let image = image {
                    self.selectedSubject.onNext(image)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
}

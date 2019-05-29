//
//  ViewController.swift
//  RxSwiftPhotos
//
//  Created by Federico Nieto on 29/05/2019.
//  Copyright © 2019 Fede. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var applyFilterBtn: UIButton!
    @IBOutlet weak var image: UIImageView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navVC = segue.destination as? UINavigationController,
              let vc = navVC.children.first as? PhotosCollectionViewController else {
              fatalError("Error")
        }
        vc.selectedPhoto.subscribe(onNext: { image in
            DispatchQueue.main.async {
                self.updateUI(image: image)
            }
        }).disposed(by: disposeBag)
    }
    
    func updateUI(image: UIImage) {
        self.image.image = image
        self.applyFilterBtn.isHidden = false
    }

    @IBAction func didTapApplyFilter(_ sender: Any) {
        if let image = self.image.image {
            FiltersService.init().applyFilter(to: image).subscribe(onNext: { image in
                self.image.image = image
            }).disposed(by: disposeBag)
        }
    }
}


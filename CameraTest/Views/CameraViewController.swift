//
//  ViewController.swift
//  CameraTest
//
//  Created by 高松　幸平 on 2017/01/26.
//  Copyright © 2017年 高松　幸平. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift

class CameraViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shutterOutlet: UIButton!
    var viewModel: CameraViewModel!
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = CameraViewModel(shutterTaps: shutterOutlet.rx.tap.asDriver())
        self.viewModel.videoLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.viewModel.videoLayer)
        self.view.bringSubview(toFront: self.shutterOutlet)
        viewModel.takenPhoto.drive(imageView.rx.image).addDisposableTo(disposeBag)
        viewModel.photoDidBeTaken.drive(onNext: {
            self.viewModel.videoLayer.removeFromSuperlayer()
        }).addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


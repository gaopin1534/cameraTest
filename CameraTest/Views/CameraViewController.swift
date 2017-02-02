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

    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shutterOutlet: UIButton!
    var viewModel: CameraViewModel!
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        let removeTaps = removeButton.rx.tap.asDriver().map {
            self.removeButton.isHidden = true
            return Void()
        }.startWith(Void())
        
        viewModel = CameraViewModel(input: (shutterTaps: shutterOutlet.rx.tap.asDriver(), removeTaps: removeTaps), bounds: view.bounds)
        
        viewModel.isCameraReady.drive(onNext: {
            self.shutterOutlet.isHidden = false
            self.imageView.isHidden = true
            self.view.layer.addSublayer(self.viewModel.videoLayer)
            self.view.bringSubview(toFront: self.shutterOutlet)
        }).addDisposableTo(disposeBag)
        
        viewModel.takenPhoto.skip(1).map(){ imageData in
            self.removeButton.isHidden = false
            self.view.bringSubview(toFront: self.removeButton)
            self.shutterOutlet.isHidden = true
            self.imageView.isHidden = false
            return UIImage(data: imageData)!
        }
        .drive(imageView.rx.image).addDisposableTo(disposeBag)
        
        viewModel.photoDidBeTaken.drive(onNext: {
            self.viewModel.videoLayer.removeFromSuperlayer()
        }).addDisposableTo(disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.rotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rotate() {
        UIView.animate(withDuration: 0.7, animations: {
            self.shutterOutlet.transform = CGAffineTransform(rotationAngle: self.angle())
        })
    }
    
    private func angle() -> CGFloat {
        switch(UIDevice.current.orientation) {
        case .portrait:
            return 0
        case .landscapeLeft:
            return CGFloat(90*M_PI/180)
        case .landscapeRight:
            return CGFloat(-90*M_PI/180)
        case .portraitUpsideDown:
            return CGFloat(M_PI)
        default:
            return 0
        }
    }
    
}


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

    @IBOutlet weak var switchCamButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shutterOutlet: UIButton!
    
    var viewModel: CameraViewModel!
    let disposeBag = DisposeBag()
    var deviceOrientation: Variable<UIDeviceOrientation>!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.contentMode = .scaleAspectFit
        
        let removeTaps = removeButton.rx.tap.asDriver().map {
            self.removeButton.isHidden = true
            return Void()
        }.startWith(Void())
        
        viewModel = CameraViewModel(input: (shutterTaps: shutterOutlet.rx.tap.asDriver(), removeTaps: removeTaps, switchCamTaps: switchCamButton.rx.tap.asDriver()), bounds: view.bounds)
        
        viewModel.isCameraReady.drive(onNext: {
            self.shutterOutlet.isHidden = false
            self.switchCamButton.isHidden = false
            self.imageView.isHidden = true
            self.view.layer.addSublayer(self.viewModel.videoLayer)
            self.view.bringSubview(toFront: self.shutterOutlet)
            self.view.bringSubview(toFront: self.switchCamButton)
        }).addDisposableTo(disposeBag)
        
        viewModel.takenPhoto.skip(1).map(){ imageData in
            self.removeButton.isHidden = false
            self.view.bringSubview(toFront: self.removeButton)
            self.shutterOutlet.isHidden = true
            self.switchCamButton.isHidden = true
            self.imageView.isHidden = false
            
            return UIImage(cgImage: UIImage(data: imageData)!.cgImage!, scale: 1.0, orientation: self.imageOrientation(from: UIDevice.current.orientation))
        }
        .drive(imageView.rx.image).addDisposableTo(disposeBag)
        
        viewModel.photoDidBeTaken.drive(onNext: {
            self.viewModel.videoLayer.removeFromSuperlayer()
        }).addDisposableTo(disposeBag)
        
        deviceOrientation = Variable(UIDevice.current.orientation)
        deviceOrientation.asDriver().filter { orientation in
            UIDeviceOrientationIsValidInterfaceOrientation(UIDevice.current.orientation)
            }.drive(onNext: { orientation in
                self.rotate(with: orientation)
            }).addDisposableTo(disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.setDeviceOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    func setDeviceOrientation() {
        deviceOrientation.value = UIDevice.current.orientation
    }
    
    func rotate(with orientation: UIDeviceOrientation) {
        UIView.animate(withDuration: 0.7, animations: {
            self.shutterOutlet.transform = CGAffineTransform(rotationAngle: self.angle(for: orientation))
        })
    }

    
    private func imageOrientation(from deviceOrientation: UIDeviceOrientation) -> UIImageOrientation {
        if viewModel.isBack {
            switch(deviceOrientation) {
            case .portrait:
                return .right
            case .landscapeRight:
                return .down
            case .landscapeLeft:
                return .up
            case .portraitUpsideDown:
                return .left
            default:
                return .right
            }
        } else {
            switch(deviceOrientation) {
            case .portrait:
                return .right
            case .landscapeRight:
                return .up
            case .landscapeLeft:
                return .down
            case .portraitUpsideDown:
                return .left
            default:
                return .right
            }
        }
    }

    private func angle(for orientation: UIDeviceOrientation) -> CGFloat {
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


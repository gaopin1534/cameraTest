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
    var deviceOrientation: Variable<UIDeviceOrientation>!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set ContentMode for result imageView
        imageView.contentMode = .scaleAspectFit
        
        // Driver which sends remove button tap
        // starts with void not display result when the app just begins
        let removeTaps = removeButton.rx.tap.asDriver().map {
            self.removeButton.isHidden = true
            return Void()
        }.startWith(Void())
        
        viewModel = CameraViewModel(input: (shutterTaps: shutterOutlet.rx.tap.asDriver(), removeTaps: removeTaps, switchCamTaps: switchCamButton.rx.tap.asDriver()), bounds: view.bounds)
        
        // subscribes when camera session is ready
        viewModel.isCameraReady.drive(onNext: {
            self.shutterOutlet.isHidden = false
            self.switchCamButton.isHidden = false
            self.imageView.isHidden = true
            self.view.layer.addSublayer(self.viewModel.videoLayer)
            self.view.bringSubview(toFront: self.shutterOutlet)
            self.view.bringSubview(toFront: self.switchCamButton)
        }).addDisposableTo(disposeBag)
        
        // subscribes taken photo and skips once to avoid running when the app just begins
        viewModel.takenPhoto.skip(1).map(){ imageData in
            self.removeButton.isHidden = false
            self.view.bringSubview(toFront: self.removeButton)
            self.shutterOutlet.isHidden = true
            self.switchCamButton.isHidden = true
            self.imageView.isHidden = false
            self.viewModel.videoLayer.removeFromSuperlayer()
            let image = UIImage(cgImage: UIImage(data: imageData)!.cgImage!, scale: 1.0, orientation: self.imageOrientation(from: UIDevice.current.orientation))
            // save image
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            return image
        }
        .drive(imageView.rx.image).addDisposableTo(disposeBag)
        
        // subscribes when the photo's taken
        viewModel.photoDidBeTaken.drive(onNext: {
            self.viewModel.videoLayer.removeFromSuperlayer()
        }).addDisposableTo(disposeBag)
        
        deviceOrientation = Variable(UIDevice.current.orientation)
        deviceOrientation.asDriver().filter { orientation in
            UIDeviceOrientationIsValidInterfaceOrientation(UIDevice.current.orientation)
            }.drive(onNext: { orientation in
                self.rotate(with: orientation)
            }).addDisposableTo(disposeBag)
        
        // observes when the device's rotated
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.setDeviceOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    // set device orientation when the device's rotated
    func setDeviceOrientation() {
        deviceOrientation.value = UIDevice.current.orientation
    }
    
    // rotate the items when the device's rotated
    func rotate(with orientation: UIDeviceOrientation) {
        UIView.animate(withDuration: 0.7, animations: {
            self.shutterOutlet.transform = CGAffineTransform(rotationAngle: self.angle(for: orientation))
            self.switchCamButton.transform = CGAffineTransform(rotationAngle: self.angle(for: orientation))
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


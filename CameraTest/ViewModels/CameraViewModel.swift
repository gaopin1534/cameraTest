//
//  CameraViewModel.swift
//  CameraTest
//
//  Created by 高松　幸平 on 2017/01/26.
//  Copyright © 2017年 高松　幸平. All rights reserved.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

class CameraViewModel: NSObject {
    
    var backCamera: AVCaptureDevice!
    var output: AVCapturePhotoOutput!
    var videoLayer: AVCaptureVideoPreviewLayer!
    var takenPhoto: Driver<Data>!
    var photoDidBeTaken: Driver<Void>!
    var isCameraReady: Driver<Void>!
    var imageData: Variable<Data>!
    let disposeBag = DisposeBag()
    var cameraService: CameraService!
    
    init(input: (shutterTaps: Driver<Void>, removeTaps: Driver<Void>), bounds: CGRect) {
        super.init()
        self.cameraService = CameraService(with: bounds)
        isCameraReady = input.removeTaps.map {
            self.videoLayer = self.cameraService.previewLayer
        }
        imageData = Variable(Data())
        takenPhoto = imageData.asDriver()
        
        photoDidBeTaken = input.shutterTaps.map {
            self.cameraService.shutterDidTaped(with: self)
        }.asDriver()
        
//        input.viewDidRotate.drive(onNext: { (bounds) in
//            self.videoLayer.frame = bounds
//            if self.videoLayer.connection.isVideoOrientationSupported {
//                self.videoLayer.connection.videoOrientation = self.interfaceOrientationToVideoOrientation(orientation: UIApplication.shared.statusBarOrientation)
//            }
//        }).addDisposableTo(disposeBag)
    }
    
    private func interfaceOrientationToVideoOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch(orientation) {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard let photoSampleBuffer = photoSampleBuffer else {
            return
        }
        guard let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        imageData.value = photoData
    }
}


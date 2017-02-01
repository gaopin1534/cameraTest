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
    var takenPhoto: Driver<UIImage>!
    var photoDidBeTaken: Driver<Void>!
    var isCameraReady: Driver<Void>!
    var image: Variable<UIImage>!
    let disposeBag = DisposeBag()
    var cameraService: CameraService!
    
    init(input: (shutterTaps: Driver<Void>, removeTaps: Driver<CGRect>)) {
        super.init()
        self.cameraService = CameraService()
        isCameraReady = input.removeTaps.map { bounds in
            self.cameraService.previewLayer.frame = bounds
            self.videoLayer = self.cameraService.previewLayer
        }
        image = Variable(UIImage())
        takenPhoto = image.asDriver()
        
        photoDidBeTaken = input.shutterTaps.map {
            self.cameraService.shutterDidTaped(with: self)
        }.asDriver()
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
        guard let takenImage = UIImage(data: photoData) else {
            return
        }
        image.value = takenImage
        videoLayer.removeFromSuperlayer()
    }
}


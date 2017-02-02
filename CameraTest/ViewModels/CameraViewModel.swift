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
    
    var output: AVCapturePhotoOutput!
    var videoLayer: AVCaptureVideoPreviewLayer!
    var takenPhoto: Driver<Data>!
    var photoDidBeTaken: Driver<Void>!
    var isCameraReady: Driver<Void>!
    var imageData: Variable<Data>!
    let disposeBag = DisposeBag()
    var cameraService: CameraService!
    var isBack = true
        
    init(input: (shutterTaps: Driver<Void>, removeTaps: Driver<Void>, switchCamTaps: Driver<Void>), bounds: CGRect) {
        super.init()
        self.cameraService = CameraService(with: bounds)
        
        // switch the front cam and back cam when the switch button's tapped
        let camDidSwitched = input.switchCamTaps.map {
            self.cameraService.switchCam(with: bounds)
        }.asDriver()
        
        // notify when the camera is ready
        isCameraReady = Observable.of(camDidSwitched,input.removeTaps).merge().asDriver(onErrorJustReturn: ()).startWith(Void()).map {_ in
            self.isBack = self.cameraService.camPosition.isBack()
            self.videoLayer = self.cameraService.previewLayer
        }
        
        // make imageData driver
        imageData = Variable(Data())
        takenPhoto = imageData.asDriver()

        // take a photo when the shutter button's tapped
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
        imageData.value = photoData
    }
}


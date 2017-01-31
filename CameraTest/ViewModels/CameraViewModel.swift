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
    var image: Variable<UIImage>!
    let disposeBag = DisposeBag()
    
    init(shutterTaps: Driver<Void>) {
        super.init()
        let captureSession = AVCaptureSession()
        guard let captureDevice = getBackCamera() else {
            fatalError()
        }
        backCamera = captureDevice
        let input = try! AVCaptureDeviceInput(device: backCamera)

        captureSession.addInput(input)
        output = AVCapturePhotoOutput()
        captureSession.addOutput(output)
        
        videoLayer = videoLayerSetUp(with: captureSession)

        captureSession.startRunning()
        image = Variable(UIImage())
        takenPhoto = image.asDriver()
        
        photoDidBeTaken = shutterTaps.map {
            self.shutterDidTap()
        }.asDriver()
    
    }
    
    private func videoLayerSetUp(with session: AVCaptureSession) -> AVCaptureVideoPreviewLayer? {
        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        return videoLayer
    }
    
    private func getBackCamera() -> AVCaptureDevice? {
        guard let avCaptureDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back) else {
            return nil
        }
        for device in avCaptureDeviceDiscoverySession.devices {
            if device.position == .back {
                return device
            }
        }
        return nil
    }
    
    private func shutterDidTap() {
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        // シャッターを切る
        output.capturePhoto(with: settingsForMonitoring, delegate: self)
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


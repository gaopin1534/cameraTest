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

class CameraViewModel {
    
    var backCamera: AVCaptureDevice!
    
    var videoLayer: AVCaptureVideoPreviewLayer!
    
    init(shutterTaps: Observable<Void>) {
        let captureSession = AVCaptureSession()
        guard let captureDevice = getBackCamera() else {
            fatalError()
        }
        backCamera = captureDevice
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
        } catch {
            fatalError("\(error)")
        }
        let output = AVCaptureStillImageOutput()
        
        captureSession.addOutput(output)
        
        videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        captureSession.startRunning()
        
        
    }
    
    private func getBackCamera() -> AVCaptureDevice? {
        guard let avCaptureDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .front) else {
            return nil
        }
        for device in avCaptureDeviceDiscoverySession.devices {
            if device.position == .back {
                return device
            }
        }
        return nil
    }
}

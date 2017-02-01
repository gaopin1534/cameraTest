//
//  CameraService.swift
//  CameraTest
//
//  Created by 高松　幸平 on 2017/02/01.
//  Copyright © 2017年 高松　幸平. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation
class CameraService {
    
    var output: AVCapturePhotoOutput!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    init(with bounds: CGRect) {
        captureSession = setUpCameraSession()
        previewLayer = videoLayerSetUp(with: captureSession)
        previewLayer.frame = bounds
    }
    
    private func setUpCameraSession() -> AVCaptureSession {
        let captureSession = AVCaptureSession()
        guard let captureDevice = getBackCamera() else {
            fatalError()
        }
        let backCamera = captureDevice
        let input = try! AVCaptureDeviceInput(device: backCamera)
        
        captureSession.addInput(input)
        output = AVCapturePhotoOutput()
        captureSession.addOutput(output)
        captureSession.startRunning()
        return captureSession
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
    
    func shutterDidTaped(with object: AVCapturePhotoCaptureDelegate) {
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        // シャッターを切る
        output.capturePhoto(with: settingsForMonitoring, delegate: object)
    }

}

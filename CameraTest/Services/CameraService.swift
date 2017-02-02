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

enum CamPosition {
    case front
    case back
    
    mutating func switchPosition() {
        if self == .front {
            self = .back
        } else {
            self = .front
        }
    }
    
    func toAVCapturePosition() -> AVCaptureDevicePosition {
        switch(self) {
        case .front:
            return .front
        case .back:
            return .back
        }
    }
    
    func isBack() -> Bool {
        return self == .back
    }
}

class CameraService {
    var output: AVCapturePhotoOutput!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var camPosition = CamPosition.back
    
    init(with bounds: CGRect) {
        setUpCam(with: bounds, position: camPosition)
    }
    
    // switch front and back cams
    func switchCam(with bounds: CGRect) {
        camPosition.switchPosition()
        captureSession.beginConfiguration()
        captureSession.removeInput(captureSession.inputs.first! as! AVCaptureInput)
        captureSession.addInput(try! AVCaptureDeviceInput(device: getCamera(with: camPosition.toAVCapturePosition())))
        captureSession.commitConfiguration()
    }
    
    // initialize the camera as the app starts
    private func setUpCam(with bounds: CGRect, position: CamPosition) {
        captureSession = setUpCameraSession(with: position)
        previewLayer = videoLayerSetUp(with: captureSession)
        previewLayer.frame = bounds
        previewLayer.videoGravity = AVLayerVideoGravityResize
    }
    
    // set up a camera session
    private func setUpCameraSession(with position: CamPosition) -> AVCaptureSession {
        let session = AVCaptureSession()
        guard let captureDevice = getCamera(with: position.toAVCapturePosition()) else {
            fatalError()
        }
        
        let input = try! AVCaptureDeviceInput(device: captureDevice)
        session.addInput(input)
        
        output = AVCapturePhotoOutput()
        session.addOutput(output)
        
        session.startRunning()
        return session
    }
    
    // set up a video layer
    private func videoLayerSetUp(with session: AVCaptureSession) -> AVCaptureVideoPreviewLayer? {
        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        return videoLayer
    }
    
    // get a camera object with a position
    private func getCamera(with position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        guard let avCaptureDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: position) else {
            return nil
        }
        for device in avCaptureDeviceDiscoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    // processes run when shutter button is tapped
    func shutterDidTaped(with object: AVCapturePhotoCaptureDelegate) {
        let settingsForMonitoring = AVCapturePhotoSettings()
        if camPosition == .back {
            settingsForMonitoring.flashMode = .auto
        } else {
            settingsForMonitoring.flashMode = .off
        }
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        // シャッターを切る
        output.capturePhoto(with: settingsForMonitoring, delegate: object)
    }
}

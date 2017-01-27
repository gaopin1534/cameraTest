//
//  ViewController.swift
//  CameraTest
//
//  Created by 高松　幸平 on 2017/01/26.
//  Copyright © 2017年 高松　幸平. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    @IBOutlet weak var shutterOutlet: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = CameraViewModel(shutterTaps: shutterOutlet.rx.tap.asObservable())
        viewModel.videoLayer.frame = view.bounds
        
        view.layer.addSublayer(viewModel.videoLayer)
        view.bringSubview(toFront: shutterOutlet)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


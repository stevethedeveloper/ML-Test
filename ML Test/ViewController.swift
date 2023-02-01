//
//  ViewController.swift
//  ML Test
//
//  Created by Stephen Walton on 1/31/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a new capture session using the AVCaptureSession constructor
        let captureSession = AVCaptureSession()
        
        // Create a capture device using AVCaptureDevice
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        // Create an input for the capture device
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        // Set the input to the capture session
        captureSession.addInput(input)
        
        // Start the capture session
        captureSession.startRunning()
    }


}


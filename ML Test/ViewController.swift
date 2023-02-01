//
//  ViewController.swift
//  ML Test
//
//  Created by Stephen Walton on 1/31/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

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
        
        // create a preview layer for the captureSession
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        // add the previewLayer as a sublayer on our main view
        view.layer.addSublayer(previewLayer)
        
        // link view's frame with previewLayer's frame
        previewLayer.frame = view.frame
        
        // create the outputData
        let outputData = AVCaptureVideoDataOutput()
        
        // Sets the sample buffer delegate and the queue for invoking callbacks
        // first param is an object conforming to the AVCaptureVideoDataOutputSampleBufferDelegate protocol that will receive sample buffers after they are captured.
        // We must use a serial dispatch queue to guarantee that the video frames will be delivered in order
        outputData.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoFrames.queue"))
        captureSession.addOutput(outputData)
    }


}


//
//  ViewController.swift
//  ML Test
//
//  Created by Stephen Walton on 1/31/23.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let resultLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate func positionResultLabel() {
        view.addSubview(resultLabel)
        resultLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        resultLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        resultLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        resultLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
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
        
        positionResultLabel()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Use the model
        guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: MLModelConfiguration()).model) else {return}

        // Create model request, pass model and print finalisedReq
        let modelRequest = VNCoreMLRequest(model: model) { (finalisedReq, err) in
            
            // results will be an array of VNClassificationObservation
            guard let results = finalisedReq.results as?  [VNClassificationObservation] else { return }
            
            // Let's get the top VNClassficationObservation
            guard let topResult = results.first else { return }
            
            // And finally print the identifier and confidence of the top result
            let confidence = Int(floor(topResult.confidence * 100))
            if confidence > 50 {
                let resultText = "\(topResult.identifier): \(confidence)%"
                
                DispatchQueue.main.async {
                    self.resultLabel.text = resultText
                }
            }
//            print(topResult.identifier, topResult.confidence)
        }

        // Cast cvPixelBuffer as CVPixelBuffer
        // get the image buffer using CMSampleBufferGetImageBuffer
        guard let cvPixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}

        // Handler for all image requests
        // handles all frames from cvPixelBuffer and performs the model request on each
        try? VNImageRequestHandler(cvPixelBuffer: cvPixelBuffer, options: [ : ]).perform([modelRequest])
        
    }

}


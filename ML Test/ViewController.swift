//
//  ViewController.swift
//  ML Test
//
//  Created by Stephen Walton on 1/31/23.
//

// Needs camera permissions

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // result label
    let resultLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Constraints for the result label
    fileprivate func setResultLabelConstraints() {
        view.addSubview(resultLabel)
        NSLayoutConstraint.activate([
            resultLabel.heightAnchor.constraint(equalToConstant: 50),
            resultLabel.rightAnchor.constraint(equalTo: view.rightAnchor),
            resultLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            resultLabel.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // New session
        let session = AVCaptureSession()
        
        // Use video
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}
        
        // Create an input for the device
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        
        // Add input to session
        session.addInput(input)
        
        // Start session on background thread
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
        
        // layer to view session
        let preview = AVCaptureVideoPreviewLayer(session: session)
        view.layer.addSublayer(preview)
        preview.frame = view.frame
        
        // create the outputData
        let outputData = AVCaptureVideoDataOutput()
        
        // Set delegate and queue
        outputData.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoFrames.queue"))
        session.addOutput(outputData)
        
        setResultLabelConstraints()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let model = try? VNCoreMLModel(for: MobileNetV2(configuration: MLModelConfiguration()).model) else {return}

        // Create model request, pass model and print finalisedReq
        let modelRequest = VNCoreMLRequest(model: model) { (finalRequest, err) in
            
            // Set results array of type VNClassificationObservation
            guard let results = finalRequest.results as? [VNClassificationObservation] else { return }
            
            // Get the first one
            guard let topResult = results.first else { return }
            
            let confidence = Int(floor(topResult.confidence * 100))
            // Change this if you want a different level of confidence
            if confidence > 25 {
                let result = "\(topResult.identifier): \(confidence)%"
                
                // Write to the main queue
                DispatchQueue.main.async {
                    self.resultLabel.text = result
                }
            } else {
                // Remove text on the main queue
                DispatchQueue.main.async {
                    self.resultLabel.text = ""
                }
            }
        }

        // get the image buffer
        guard let cvPixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}

        // Run model request on each
        try? VNImageRequestHandler(cvPixelBuffer: cvPixelBuffer, options: [:]).perform([modelRequest])
        
    }

}


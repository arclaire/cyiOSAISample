//
//  LiveFeedViewController.swift
//  cyiOSAISample
//
//  Created by Lucy on 20/08/23.
//

import UIKit
import AVFoundation
import Vision
import CoreML

class LiveFeedViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var labelTitlenav: UIImageView!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewNav: UIView!
    @IBOutlet weak var viewVideo: UIView!

    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
      
    }
    
    private func setupCamera() {
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        self.cameraOutput = AVCapturePhotoOutput()
        
        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            if let input = try? AVCaptureDeviceInput(device: device) {
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                    
                    if self.captureSession.canAddOutput(self.cameraOutput) {
                        self.captureSession.addOutput(self.cameraOutput)
                    }
                }
            }
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            self.previewLayer.frame = self.view.bounds
            self.previewLayer.frame.size.width = self.view.bounds.size.width + 25
            self.viewVideo.layer.addSublayer(self.previewLayer)
            
            DispatchQueue.global(qos: .background).async {
                // do your job here
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.launchAI()
                }
            }

           
        }
        
       
        
    }

    @objc private func launchAI() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 200,
            kCVPixelBufferHeightKey as String: 200
        ]
        
        settings.previewPhotoFormat = previewFormat as [String : Any]
        self.cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imagedata = photo.fileDataRepresentation(), let image = UIImage(data: imagedata) {
            self.predict(image: image)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
            // dispose system shutter sound
            AudioServicesDisposeSystemSoundID(1108)
    }
    
    private func predict(image:UIImage) {
        let config = MLModelConfiguration()
        guard let modelCat = try? YOLOv3(configuration: config) else {
            return
        }
        guard let vnModel = try? VNCoreMLModel(for: modelCat.model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: vnModel, completionHandler: { result, error in
            
            guard let results = result.results else {
                return
            }
            
            var strPrediction: String = ""
            var bestConfidence: VNConfidence = 0.4
        
            for observation in results where observation is VNRecognizedObjectObservation {
                guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                    continue
                }
                // Select only the label with the highest confidence.
                    let alllabels = objectObservation.labels
                
                for label in alllabels {
                    print("Labels", label.identifier, label.confidence)
                    if label.confidence > bestConfidence {
                        strPrediction = strPrediction + " \(label.identifier)"
                    }
                }
                    
                
               
               
                
                print("RAW", observation)
            }
            if strPrediction.count > 0 {
                self.labelInfo.text = strPrediction
            } else {
                self.labelInfo.text = "Not Classified"
            }
            
            /*
            for classifications in results {
                
                print("RAW RESULT", classifications.description)
                if classifications.confidence > bestConfidence {
                    bestConfidence = classifications.confidence
                     let subs = classifications.description.components(separatedBy: "labels")
                    if let index = subs.last?.firstIndex(of: "[") {
                        strPrediction = String(subs.last?[index...] ?? "")
                    }
                    
                    self.labelInfo.text = strPrediction
                }
            }*/
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.launchAI), userInfo: nil, repeats: false)
        })
        
        if let imageCG = image.cgImage {
          
            let handler = VNImageRequestHandler(cgImage: imageCG)
            do {
                try  handler.perform([request])
            } catch {
                
            }
           
           
        }
    
    }
    
    @IBAction func buttonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.captureSession.stopRunning()
    }
}

//
//  CoreMLViewController.swift
//  cyiOSAISample
//
//  Created by Lucy on 19/08/23.
//

import UIKit
import CoreML

import Vision

class CoreMLViewController: UIViewController {

    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var labelTitlenav: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonPlaces: UIButton!
    @IBOutlet weak var buttonCat: UIButton!
    
   
    @IBOutlet weak var imageInput: UIImageView!
    var imagePassed: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelTitlenav.text = "CoreML Observation"
        if let img = self.imagePassed {
            self.imageInput.image = img
        }
        // Do any additional setup after loading the view.
    }

    private func checkImageWithModelGoogleNetPlaces() {
        let config = MLModelConfiguration()
        guard let modelGoogle = try? GoogLeNetPlaces(configuration: config) else {
            return
        }
        guard let vnModel = try? VNCoreMLModel(for: modelGoogle.model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: vnModel, completionHandler: { result, error in
            
            guard let results = result.results else {
                return
            }
            
            var strPrediction: String = "Not Classified"
            var bestConfidence: VNConfidence = 0.0
        
            for classifications in results {
                if classifications.confidence > bestConfidence {
                    bestConfidence = classifications.confidence
                    if let index = classifications.description.firstIndex(of: "\"") {
                        print("RAW RESULT", classifications.description)
                        strPrediction = String(classifications.description[index...])
                    }
                    
                    self.labelResult.text = strPrediction
                }
            }
        })
        
        if let imageCG = self.imagePassed?.cgImage {
            self.imageInput.image = self.imagePassed
            let handler = VNImageRequestHandler(cgImage: imageCG)
            do {
                try  handler.perform([request])
            } catch {
                
            }
           
           
        }
        
    }
 
    @IBAction func doBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func doCheckPlaces(_ sender: Any) {
        self.checkImageWithModelGoogleNetPlaces()
    }
    
    @IBAction func doCheckCat(_ sender: Any) {
        let config = MLModelConfiguration()
        guard let modelCat = try? cyCatModelTraining_(configuration: config) else {
            return
        }
        guard let vnModel = try? VNCoreMLModel(for: modelCat.model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: vnModel, completionHandler: { result, error in
            
            guard let results = result.results else {
                return
            }
            
            var strPrediction: String = "Not Classified"
            var bestConfidence: VNConfidence = 0.0
        
            for classifications in results {
                if classifications.confidence > bestConfidence {
                    bestConfidence = classifications.confidence
                    if let index = classifications.description.firstIndex(of: "\"") {
                        print("RAW RESULT", classifications.description)
                        strPrediction = String(classifications.description[index...])
                    }
                    
                    self.labelResult.text = strPrediction
                }
            }
        })
        
        if let imageCG = self.imagePassed?.cgImage {
            self.imageInput.image = self.imagePassed
            let handler = VNImageRequestHandler(cgImage: imageCG)
            do {
                try  handler.perform([request])
            } catch {
                
            }
           
           
        }
    }
    
    @IBAction func checkFaces(_ sender: Any) {
        self.doCheckFace()
    }
    
    private func doCheckFace() {
        if let imgSource = self.imagePassed {
            DispatchQueue.global().async {
                FaceDetector().findLandmarks(for: imgSource, completion: { image, faces in
                    DispatchQueue.main.async {
                        self.imageInput.image = image
                        if faces > 0 {
                            self.labelResult.text = "Total face \(faces)"
                        } else {
                            self.labelResult.text = "No Face Detected"
                        }
                        
                        if FaceDetector().isSmiline {
                            self.labelResult.text = self.labelResult.text ?? "" + " have a smile"
                        } else {
                            self.labelResult.text = self.labelResult.text ?? "" + " no smile"
                        }
                    }
                    
                })
            }
        }
        
    }
}

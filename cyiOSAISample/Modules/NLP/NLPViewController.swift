//
//  NLPViewController.swift
//  cyiOSAISample
//
//  Created by Lucy on 20/08/23.
//

import UIKit
import NaturalLanguage
import CoreML

class NLPViewController: UIViewController {

    @IBOutlet weak var labelPrediction: UILabel!
    @IBOutlet weak var imagePrediction: UIImageView!
    @IBOutlet weak var buttonResult: UIButton!
    @IBOutlet weak var textViewReview: UITextView!
    
    private lazy var sentimentClassifier: NLModel? = {
        let config = MLModelConfiguration()
        let modelML = try? MovieReviewsClassifier(configuration: config)
        let nlmodel = try? NLModel(mlModel: modelML!.model)
        return nlmodel
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonResult.isUserInteractionEnabled = false
        self.buttonResult.alpha = 0.5
        self.textViewReview.layer.borderColor = UIColor.lightGray.cgColor
        self.textViewReview.layer.borderWidth = 1.0
        self.textViewReview.layer.cornerRadius = 10
        self.textViewReview.textColor = UIColor.black
        self.textViewReview.delegate = self
        self.textViewReview.text = ""
        self.labelPrediction.text = ""
        self.textViewReview.becomeFirstResponder()
    }

    @IBAction func showResult(_ sender: UIButton) {
        if let label = sentimentClassifier?.predictedLabel(for: self.textViewReview.text) {
            switch label {
            case "pos":
                self.imagePrediction.image = UIImage(named: "positive")
                self.labelPrediction.text = "Positive"
            case "neg":
                self.imagePrediction.image = UIImage(named: "negative")
                self.labelPrediction.text = "Negative"
            default:
                self.imagePrediction.image = UIImage(named: "neutral")
                self.labelPrediction.text = "Neutral"
            }
        }
    }
    
    @IBAction func doback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func clearAction(_ sender: UIButton) {
        self.imagePrediction.image = UIImage(named: "")
        self.labelPrediction.text = ""
        self.textViewReview.text = ""
        self.buttonResult.isUserInteractionEnabled = false
        self.buttonResult.alpha = 0.5
    }
    
    
    
}

extension NLPViewController:UITextViewDelegate
{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.isEmpty == false {
            self.buttonResult.isUserInteractionEnabled = true
            self.buttonResult.alpha = 1.0
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        self.buttonResult.isUserInteractionEnabled = true
        self.buttonResult.alpha = 1.0
    }
}

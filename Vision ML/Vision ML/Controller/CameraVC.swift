//
//  ViewController.swift
//  Vision ML
//
//  Created by Kafkas Baranseli on 16/05/2019.
//  Copyright © 2019 Baranseli. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision


enum FlashStatus {
    case off
    case on
}

class CameraVC: UIViewController {

    
    var captureSession : AVCaptureSession!
    var cameraOutput : AVCapturePhotoOutput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var photoData : Data?
    var flashControlState : FlashStatus = .off
    
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureImageView: RoundedShadowImage!
    @IBOutlet weak var flashbtn: RoundedShadowBtn!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var roundedLblView: RoundedShadowView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
        speechSynthesizer.delegate = self
        spinner.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CameraVC.didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            cameraOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(cameraOutput) == true {
                captureSession.addOutput(cameraOutput!)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer!)
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
                
            }
        } catch {
            debugPrint(error)
        }
    }
    
    
 @objc  func didTapCameraView() {
    self.cameraView.isUserInteractionEnabled = false
    self.spinner.isHidden = false
    self.spinner.startAnimating()
    
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
    
    
    if flashControlState == .off {
        settings.flashMode = .off
    } else {
        settings.flashMode = .on
    }
    
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func resultsMethod(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else { return }
        
        for classification in results {
            if classification.confidence < 0.5 {
                let unknownObjectMessage = "I could not determine what the object is. Please try again with more light."
                self.identificationLbl.text = unknownObjectMessage
                synthesizeSpeech(fromString: unknownObjectMessage)
                self.confidenceLbl.text = ""
                break
            } else {
                let identification = classification.identifier
                let confidence = Int(classification.confidence * 100)
                self.identificationLbl.text = identification
                self.confidenceLbl.text = "CONFIDENCE: \(confidence)%"
                let completeSentence = "This looks like a \(identification) and I am \(confidence) percent sure."
                synthesizeSpeech(fromString: completeSentence)
                break
            }
        }
    }

    
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSynthesizer.speak(speechUtterance)
    }
    
    
    
    
    @IBAction func flashBtnPressed(_ sender: Any) {
        
        switch flashControlState {
        case .off:
            flashbtn.setTitle("FLASH ON", for: .normal)
            flashControlState = .on
        case .on:
            flashbtn.setTitle("FLASH OFF", for: .normal)
            flashControlState = .off
        }
        
    }
    
    
    
}




extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error)
        } else {
            photoData = photo.fileDataRepresentation()
            
            
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model)
                let request = VNCoreMLRequest(model: model, completionHandler: resultsMethod)
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
            
            
            let image = UIImage(data: photoData!)
            self.captureImageView.image = image
        }
    }
}




extension CameraVC: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.cameraView.isUserInteractionEnabled = true
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
    }
}

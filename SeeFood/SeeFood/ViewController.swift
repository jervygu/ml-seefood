//
//  ViewController.swift
//  SeeFood
//
//  Created by Jervy Umandap on 9/30/24.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerSetup()
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerSetup() {
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func detect(image: CIImage) {
        guard let mlModel = try? Inceptionv3(configuration: .init()).model,
              let model = try? VNCoreMLModel(for: mlModel) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            print(results)
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("detect image: \(error)")
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.originalImage] as? UIImage else {
            return
        }
        imageView.image = userPickedImage
        guard let ciImage = CIImage(image: userPickedImage) else {
            fatalError("Could not convert UIImage to CIImage.")
        }
        detect(image: ciImage)
        imagePicker.dismiss(animated: true)
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}

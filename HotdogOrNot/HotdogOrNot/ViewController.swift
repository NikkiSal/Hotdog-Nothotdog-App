//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
   
    //MARK: - detect function
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) {(request, error) in
            guard let results = request.results as? [VNClassificationObservation],
                //take the first result because that one has the highest accuracy
                let topResult = results.first else {
                fatalError("Model failed to process image")
            }
            // Thisi s if you want the exact name and probability
//            let probability = Int(topResult.confidence*100)
//            DispatchQueue.main.async {
//                self.navigationItem.title =  String(probability) + "%" + String(topResult.identifier)
//                self.navigationController?.navigationBar.barTintColor = UIColor.green
//                self.navigationController?.navigationBar.isTranslucent = false
//            }
                if topResult.identifier.contains ("hotdog") {
                    DispatchQueue.main.async {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = false
                    }
                } else {
                    DispatchQueue.main.async {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.navigationController?.navigationBar.isTranslucent = false
                }
            }
            
        }
        let handler = VNImageRequestHandler(ciImage: image) // little confusing
        do {
            try handler.perform([request])
        } catch {
            print ("Error performing request \(error)")
        }
        
    }
    //MARK: -   imagePickerController function
       
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
           if let userPickedImage = info[.originalImage] as? UIImage {
               imageView.image = userPickedImage
               guard let ciimage = CIImage(image: userPickedImage) else { fatalError("Could not convert to CIImage")
               }
                detect(image: ciimage)
           }
           imagePicker.dismiss(animated: true, completion: nil)
       }
       
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = false // but true is better, because the user can crop the image
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}


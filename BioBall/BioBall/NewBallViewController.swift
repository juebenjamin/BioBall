//
//  NewBallViewController.swift
//  BioBall
//
//  Created by Jeremiah Benjamin on 6/6/20.
//  Copyright © 2020 Jeremiah Benjamin. All rights reserved.
//
import UIKit
import CoreData
class NewBallViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    @IBAction func saveButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "saveBall", sender: self)
    }
    @IBOutlet var titleField: UITextField!
    @IBOutlet var descriptionField: UITextView!
    @IBOutlet var titleFieldLine: UIView!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var descriptionFieldLine: UIView!
    @IBOutlet var titleFieldLabel: UILabel!
    @IBOutlet var descriptionFieldLabel: UILabel!
    let customPurple = UIColor(red: 197/255, green: 0/255, blue: 197/255, alpha: 1)
    let imagePicker = UIImagePickerController()
    func invalidAlert(){
        let alert = UIAlertController(title: "Invalid Input", message: "Please make sure you have entered an image, title and description.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func upLoadImageBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Choose an option", message: nil, preferredStyle: .actionSheet)
        let pickPhotoAction = UIAlertAction(title: "Chose from Library", style: .default) { (_) in
               // Show the image picker with the photo library as the source
               self.imagePicker.sourceType = .photoLibrary
               self.present(self.imagePicker, animated: true, completion: nil)
           }
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { (_) in
               // Show the image picker with the camera as the source
               self.imagePicker.sourceType = .camera
               self.present(self.imagePicker, animated: true, completion: nil)
           }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           
        alert.addAction(pickPhotoAction)
        alert.addAction(takePhotoAction)
        alert.addAction(cancelAction)
           
        present(alert, animated: true, completion: nil)
    }
    var imageData: Data?
    var managedObject: NSManagedObject!
    let placeholder = "                                                                                                                                                                                                                                                                                                                                                    Insert your  description here..."
    var isNewBall = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        titleField.delegate = self
        titleField.attributedPlaceholder = NSAttributedString(
              string: "Insert Title",
              attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
          )
        descriptionField.delegate = self
        descriptionField.textColor = .black
        imagePicker.delegate = self
        uploadButton.layer.borderWidth = 2
        uploadButton.layer.cornerRadius = uploadButton.frame.height/2
        uploadButton.clipsToBounds = true
        uploadButton.layer.borderColor = UIColor.black.cgColor
        let dynamicBundle = Bundle(for: type(of: self))
        let baseimage = UIImage(named: "CameraIcon", in: dynamicBundle, compatibleWith: nil)
        if managedObject != nil {
            let uploadedTitle = managedObject.value(forKey: "titles") as? String
            titleField.text = uploadedTitle
            let uploadedDescription = managedObject.value(forKey: "balldescriptions") as? String
            descriptionField.text = uploadedDescription
            let uploadedImage = managedObject.value(forKey: "images") as? Data
            let image = UIImage(data: uploadedImage!)
            uploadButton.setImage(image, for: .normal)
        }
        else {
            isNewBall = true
            descriptionField.font = .systemFont(ofSize: 19)
            descriptionField.text = placeholder
            descriptionField.textColor = UIColor.lightGray
            uploadButton.setImage(baseimage, for: .normal)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                imageData = pickedImage.jpegData(compressionQuality: 1.0)
                uploadButton.setImage(pickedImage, for: .normal)
            }
            
            dismiss(animated: true, completion: nil)
        }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveBall" {
            if !isNewBall {
                let titleInput = titleField.text
                let descriptionInput = descriptionField.text
                if titleInput!.trimmingCharacters(in: .whitespacesAndNewlines) != "" && (descriptionInput != placeholder && descriptionInput!.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                    managedObject.setValue(titleInput, forKey: "titles")
                    managedObject.setValue(descriptionInput, forKey: "balldescriptions")
                }
                else {
                    invalidAlert()
                }
                if imageData != nil {
                    managedObject.setValue(imageData, forKey: "images")
                }
                do {
                    let managedObjectContext = managedObject.managedObjectContext
                    try managedObjectContext?.save()
                } catch {
                    print("Error saving")
                }
            }
            if isNewBall {
                let titleInput = titleField.text
                let descriptionInput = descriptionField.text
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "Balls", in: context)
                if titleInput!.trimmingCharacters(in: .whitespacesAndNewlines) != "" && (descriptionInput != placeholder && descriptionInput!.trimmingCharacters(in: .whitespacesAndNewlines) != "") && imageData != nil {
                    let newBall = NSManagedObject(entity: entity!, insertInto: context)
                    newBall.setValue(imageData, forKey: "images")
                    newBall.setValue(titleInput, forKey: "titles")
                    newBall.setValue(descriptionInput, forKey: "balldescriptions")
                }
                else {
                    invalidAlert()
                }
                do {
                  try context.save()
                } catch {
                    print("Error saving")
                }
            }
        }
        
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleFieldLine.backgroundColor = .darkGray
        titleFieldLabel.textColor = .darkGray
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        titleFieldLine.backgroundColor = customPurple
        titleFieldLabel.textColor = customPurple
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        descriptionFieldLine.backgroundColor = .darkGray
        descriptionFieldLabel.textColor = .darkGray
        if descriptionField.textColor == UIColor.lightGray {
            descriptionField.font = .systemFont(ofSize: 14)
            descriptionField.text = ""
            descriptionField.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        descriptionFieldLine.backgroundColor = customPurple
        descriptionFieldLabel.textColor = customPurple
        if descriptionField.text == "" {
            descriptionField.font = .systemFont(ofSize: 19)
            descriptionField.text = placeholder
            descriptionField.textColor = UIColor.lightGray
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = titleField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 30
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return updatedText.count <= 144
    }
}
extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}


//
//  AddCollectionTableViewController.swift
//  collector
//
//  Created by Ivan Pryhara on 14.12.21.
//

import UIKit
import PhotosUI

class AddCollectionTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameItemTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var addNewImageButton: UIButton!
    
    
    //Image's interaction outlets
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var changeButton: UIButton!
    //...
    
    var item: Item?
    
    
    init?(coder: NSCoder, item: Item?) {
        super.init(coder: coder)
        self.item = item
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameItemTextField.delegate = self

        //For dismissing keyboard by gentle swipe.
        tableView.keyboardDismissMode = .interactive
        
        //Make a tap gesture recognizer, that user can tap anywhere in the table view for dismissing keyboard.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        tableView.addGestureRecognizer(tapGesture)
        
        if let item = item {
            guard let imageDataDirectory = item.imageDataDirectory,
                  let data = Item.retrieveData(forDirectory: imageDataDirectory) else {return}
            
            imageView.image = UIImage(data: data)
            updateImageViewAvailability()
            nameItemTextField.text = item.name
            descriptionTextView.text = item.itemDescription
            notesTextView.text = item.noteText
        }
        updateSaveButtonState()
        updateImageInteractionsState()
    }
    
    //MARK: Helper methods
    
    func updateImageViewAvailability() {
        if imageView.image != nil {
            imageView.isHidden = false
            addNewImageButton.isHidden = true
        } else {
            imageView.isHidden = true
            addNewImageButton.isHidden = false
        }
    }
    
    func updateImageInteractionsState() {
        if imageView.image != nil {
            shareButton.isEnabled = true
            changeButton.isEnabled = true
            deleteButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
            changeButton.isEnabled = false
            deleteButton.isEnabled = false
        }
    }

   @objc func hideKeyboard() {
        tableView.endEditing(true)
    }
    
    //MARK: - IBActions
    
    @IBAction func addNewImageButtonTapped(_ sender: UIButton) {
        //Define PHPicker confing and selection limit.
        var PHPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        PHPickerConfig.selectionLimit = 1
        PHPickerConfig.filter = PHPickerFilter.images
        //Define PHPicker with configuration.
        let PHPicker = PHPickerViewController(configuration: PHPickerConfig)
        PHPicker.delegate = self
        //Image picker for handling camera support.
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //Define alert controller.
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        //Create and add a cancel action.
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true)
            }
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { action in
            self.present(PHPicker, animated: true)
        }
        alertController.addAction(photoLibraryAction)
        

        //This line for iPad only.
        //Shows the pop over from sender.
        alertController.popoverPresentationController?.sourceView = sender

        present(alertController, animated: true)
    }
    
    
    @IBAction func nameTextFieldEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
        guard let image = imageView.image else {return}
        let activities = [image]
        let activityController = UIActivityViewController(activityItems: activities, applicationActivities: nil)
        //This line for iPad only.
        //Shows the pop over from sender.
        activityController.popoverPresentationController?.sourceView = sender
        present(activityController, animated: true)
    }
    
    @IBAction func changeButtonTapped(_ sender: UIButton) {
        //Here I just copied content that has been defined above
        
        //Define PHPicker confing and selection limit.
        var PHPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        PHPickerConfig.selectionLimit = 1
        PHPickerConfig.filter = PHPickerFilter.images
        //Define PHPicker with configuration.
        let PHPicker = PHPickerViewController(configuration: PHPickerConfig)
        PHPicker.delegate = self
        //Image picker for handling camera support.
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //Define alert controller.
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        //Create and add a cancel action.
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { action in
            self.present(PHPicker, animated: true)
        }
        alertController.addAction(photoLibraryAction)
        

        //This line for iPad only.
        //Shows the pop over from sender.
        alertController.popoverPresentationController?.sourceView = sender

        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        self.imageView.image = nil
        guard item?.imageDataDirectory != nil else {
            updateSaveButtonState()
            updateImageViewAvailability()
            updateImageInteractionsState()
            return
        }
        updateSaveButtonState()
        updateImageViewAvailability()
        updateImageInteractionsState()
    }
    
    //MARK: - Segue actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "saveUnwind" else {return}
        
        //Save id for item that has been sent in this class.
        let id = self.item?._id
        //Force unwrapping textField.text is safe;
        //'cause save button can't be avilable for touching without name and image values.
        let name = nameItemTextField.text!
        let description = descriptionTextView.text
        let notes = notesTextView.text
        //Same as for name
        let image = imageView.image!
        let date = item?.dateOfCreation ?? Date()
        let directory = Item.saveImageData(Data.encode(image:image), toDirectory: item?.imageDataDirectory)
        item = Item(name: name, dateOfCreation: date, imageDataDirectory: directory, itemDescription: description, noteText: notes)
        //Workaround solution, 'cause in the line above new instance was created with new _id;
        //So I need to the item instance has the same id as those who was sent by the segue.
        if let id = id {
            item?._id = id
        }
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Deselct row that was tapped, because there's no view that move to another controller.
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Simple function

    func updateSaveButtonState() {
        //Ensure that image and name is not empty.
        let image = imageView.image ?? nil
        let name = nameItemTextField.text ?? ""
        
        saveButton.isEnabled = image != nil && !name.isEmpty
    }
}

//MARK: Extension
extension AddCollectionTableViewController {
    
    //MARK: Conform to the PHPickerDelagate protocol
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
            results.forEach { result in
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                    guard let image = reading as? UIImage, error == nil else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.imageView.image = image
                        self.updateSaveButtonState()
                        self.updateImageViewAvailability()
                        self.updateImageInteractionsState()
                    }
                }
            }
    }
    
    //MARK: Text Field Delegate functions
    
    //Dismiss keyboard from the screen by tapping 'return', while editing text.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {return}
        
        self.imageView.image = image
        self.updateSaveButtonState()
        self.updateImageViewAvailability()
        self.updateImageInteractionsState()
        dismiss(animated: true)
    }
}

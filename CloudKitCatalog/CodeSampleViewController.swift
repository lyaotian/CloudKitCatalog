/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This view controller displays some descriptive text for a code sample, the input form for configuring the sample, and the button for running it. It also has all relevant event handlers.
*/

import UIKit
import CoreLocation

class CodeSampleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // Mark: - Properties
    
    var locationManager: CLLocationManager = CLLocationManager()
    var imagePickerController: UIImagePickerController = UIImagePickerController()
    
    @IBOutlet weak var pickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var className: UILabel!
    @IBOutlet weak var methodName: UILabel!
    @IBOutlet weak var runButton: UIBarButtonItem!
    @IBOutlet weak var codeSampleDescription: UILabel!
    
    var selectedCodeSample: CodeSample?
    var groupTitle: String?
    
    var selectedLocationCellIndex: Int?
    var selectedImageCellIndex: Int?
    var selectedSelectionCellIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let codeSample = selectedCodeSample {
            className.text = "Class: " + codeSample.className
            methodName.text = codeSample.methodName
            codeSampleDescription.text = codeSample.description
        }
        
        if let groupTitle = groupTitle {
            navigationItem.title = groupTitle
        }
        navigationItem.hidesBackButton = (navigationController!.viewControllers.first?.navigationItem.hidesBackButton)!
        
        let border = CALayer()
        border.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1).cgColor
        border.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1.0)
        tableView.layer.addSublayer(border)
        
        locationManager.delegate = self
        
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        validateInputs()

    }
    
    func validateInputs() {
        var runButtonIsEnabled = true
        if let codeSample = selectedCodeSample {
            for input in codeSample.inputs {
                if !input.isValid {
                    runButtonIsEnabled = false
                    break
                }
            }
        }
        runButton.isEnabled = runButtonIsEnabled
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let codeSample = selectedCodeSample {
            return codeSample.inputs.filter({ !$0.isHidden }).count
        }
        return 0
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let codeSample = selectedCodeSample {
            let inputs = codeSample.inputs.filter { !$0.isHidden }
            let input = inputs[indexPath.row]
            if let input = input as? TextInput, let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as? TextFieldTableViewCell {
                cell.textInput = input
                cell.fieldLabel.text = input.label
                cell.textField.text = input.value
                if input.type == .Email {
                    cell.textField.keyboardType = .emailAddress
                }
                cell.textField.delegate = self
                if indexPath.row == 0 {
                    cell.textField.becomeFirstResponder()
                }
                return cell
            } else if let input = input as? LocationInput, let cell = tableView.dequeueReusableCell(withIdentifier: "LocationFieldCell", for: indexPath) as? LocationFieldTableViewCell {
                cell.locationInput = input
                cell.fieldLabel.text = input.label
                cell.longitudeField.delegate = self
                cell.latitudeField.delegate = self
                if indexPath.row == 0 {
                    cell.latitudeField.becomeFirstResponder()
                }
                
                cell.lookUpButton.isEnabled = CLLocationManager.authorizationStatus() != .denied
                
                return cell
            } else if let input = input as? ImageInput, let cell = tableView.dequeueReusableCell(withIdentifier: "ImageFieldCell", for: indexPath) as? ImageFieldTableViewCell {
                cell.fieldLabel.text = input.label
                cell.imageInput = input
                return cell
            } else if let input = input as? BooleanInput, let cell = tableView.dequeueReusableCell(withIdentifier: "BooleanFieldCell", for: indexPath) as? BooleanFieldTableViewCell {
                cell.fieldLabel.text = input.label
                cell.booleanField.isOn = input.value
                cell.booleanInput = input
                return cell
            } else if let input = input as? SelectionInput, let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionFieldCell", for: indexPath) as? SelectionFieldTableViewCell {
                cell.fieldLabel.text = input.label
                cell.selectedItemLabel.text = input.items.count > 0 ? (input.value != nil ? input.items[input.value!].label : input.items[0].label ) : ""
                cell.selectionInput = input
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormFieldCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let codeSample = selectedCodeSample, let _ = codeSample.inputs[indexPath.row] as? ImageInput {
            return 236.0
        }
        return tableView.rowHeight
    }
    
    // Mark: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let contentView = textField.superview {
            
            if let cell = contentView.superview as? TextFieldTableViewCell {
                cell.textInput.value = textField.text ?? ""
            } else if let stackView = contentView.superview, let cell = stackView.superview as? LocationFieldTableViewCell, let text = textField.text, let value = Int(text) {
                if textField.tag == 0 {
                    cell.locationInput.latitude = value
                } else if textField.tag == 1 {
                    cell.locationInput.longitude = value
                }
            }
            
            validateInputs()
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let contentView = textField.superview, let stackView = contentView.superview, let cell = stackView.superview as? LocationFieldTableViewCell, let errorLabel = cell.errorLabel {
            errorLabel.isHidden = true
            errorLabel.layoutIfNeeded()
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let selectedSelectionCellIndex = selectedSelectionCellIndex {
            let indexPath = IndexPath(row: selectedSelectionCellIndex, section: 0)
            if let cell = tableView.cellForRow(at:indexPath) as? SelectionFieldTableViewCell {
                return cell.selectionInput.items.count
            }
        }
        return 0
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let selectedSelectionCellIndex = selectedSelectionCellIndex {
            let indexPath = IndexPath(row: selectedSelectionCellIndex, section: 0)
            if let cell = tableView.cellForRow(at:indexPath) as? SelectionFieldTableViewCell {
                return cell.selectionInput.items[row].label
            }
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let selectedSelectionCellIndex = selectedSelectionCellIndex {
            let indexPath = IndexPath(row: selectedSelectionCellIndex, section: 0)
            if let cell = tableView.cellForRow(at:indexPath) as? SelectionFieldTableViewCell {
                cell.selectedItemLabel.text = cell.selectionInput.items[row].label
                UIView.animate(withDuration: 0.4, animations: {
                    self.pickerHeightConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }) { completed in
                    if completed {
                        if let oldValue = cell.selectionInput.value {
                            for index in cell.selectionInput.items[oldValue].toggleIndexes {
                                self.selectedCodeSample!.inputs[index].isHidden = true
                            }
                        }
                        for index in cell.selectionInput.items[row].toggleIndexes {
                            self.selectedCodeSample!.inputs[index].isHidden = false
                        }
                        cell.selectionInput.value = row
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // Mark: - CLLocationManagerDelegate
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if let index = selectedLocationCellIndex {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! LocationFieldTableViewCell
            cell.lookUpButton.isEnabled = status != .denied
            if status == .authorizedWhenInUse {
                requestLocationForCell(cell)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let index = selectedLocationCellIndex {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at:indexPath) as! LocationFieldTableViewCell
            endLocationLookupForCell(cell)
            cell.errorLabel.isHidden = false
            cell.errorLabel.layoutIfNeeded()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let index = selectedLocationCellIndex {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at:indexPath) as! LocationFieldTableViewCell
            endLocationLookupForCell(cell)
            if let location = locations.last {
                cell.setCoordinate(coordinate: location.coordinate)
                validateInputs()
            }
        }
    }
    
    func endLocationLookupForCell(_ cell: LocationFieldTableViewCell) {
        cell.latitudeField.isEnabled = true
        cell.longitudeField.isEnabled = true
        cell.lookUpButton.isEnabled = true
        cell.spinner.stopAnimating()
    }
    
    func requestLocationForCell(_ cell: LocationFieldTableViewCell) {
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestLocation()
        cell.latitudeField.isEnabled = false
        cell.longitudeField.isEnabled = false
        cell.spinner.startAnimating()
        cell.spinner.layoutIfNeeded()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let index = selectedImageCellIndex, let imageURL = getImageURL() {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at:indexPath) as! ImageFieldTableViewCell
            let imageData = UIImageJPEGRepresentation(selectedImage, 0.8)
            try? imageData?.write(to: imageURL, options: .atomic)
            cell.assetView.image = selectedImage
            cell.imageInput.value = imageURL
            
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func getImageURL() -> URL? {
        if let index = selectedImageCellIndex {
            let manager = FileManager.default
            do {
                let directoyURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let tempImageName = "ck_catalog_tmp_image_\(index)"
                return directoyURL.appendingPathComponent(tempImageName)
            } catch {
                return nil
            }
            
        }
        return nil
    }
    
    // MARK: - Actions
    
    @IBAction func pickImage(sender: UIButton) {
        if let contentView = sender.superview, let cell = contentView.superview as? ImageFieldTableViewCell {
            selectedImageCellIndex = tableView.indexPath(for: cell)?.row
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func runCode(sender: UIBarButtonItem) {
        if let codeSample = selectedCodeSample {
            
            if let error = codeSample.error {
                let alertController = UIAlertController(title: "Invalid Parameter", message: error, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.navigationController!.performSegue(withIdentifier: "ShowLoadingView", sender: codeSample)
            }
            
        }
    }

    @IBAction func lookUpLocation(sender: UIButton) {
        if let stackView = sender.superview, let contentView = stackView.superview, let cell = contentView.superview as? LocationFieldTableViewCell {
            cell.errorLabel.isHidden = true
            cell.lookUpButton.isEnabled = false
            selectedLocationCellIndex = tableView.indexPath(for: cell)?.row
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            } else {
                requestLocationForCell(cell)
            }
        }
    }
    
    
    @IBAction func selectOption(sender: UITapGestureRecognizer) {
        let location = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: location) {
            selectedSelectionCellIndex = indexPath.row
            pickerView.reloadComponent(0)
            UIView.animate(withDuration: 0.4, animations: {
                self.pickerHeightConstraint.constant = 200
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    

}

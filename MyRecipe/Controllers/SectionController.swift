//
//  SectionController.swift
//  MyRecipe
//
//  Created by Steven Manus on 10/03/21.
//

import UIKit

class SectionController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var sectionName: UITextField!
    @IBOutlet weak var sectionType: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var viewTitle: UILabel!
    
    let recipeBrain = RecipeBrain.singleton
    var sections = [Section]()
    var pickerList = [""]
    var addMode = 0 // 0 for adding, 1 for editing
    var listIndex = 0 // 0 for section type, 1 for section
        
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionName.delegate = self
        sectionType.delegate = self
        picker.delegate = self
        picker.dataSource = self
        sections = recipeBrain.getSectionList()
        setMode()
    }

    // configure controller and interface for whether in add or edit mode
    func setMode() {
        if addMode == 0 {
            viewTitle.text = "Create a New Section"
            makePickerList(list: 0)
        } else if addMode == 1 {
            viewTitle.text = "Edit a Section"
            makePickerList(list: 1)
        }
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        if (sectionName.text ?? "").isEmpty  {
            alertMessage(title: "Section", message: "Please enter a section name.")
            return
        }
        if (sectionType.text ?? "").isEmpty {
            alertMessage(title: "Section Type", message: "Please select a section type")
            return
        }
        let addResult = recipeBrain.addEditSection(section: sections.count, sectionName: sectionName.text!, sectionType: sectionType.text!)
        if addResult == 1 {
            print("Section index is out of bounds")
        }
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    
    // MARK: - Pickerview Delegate Methods
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
   }

   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return pickerList.count
   }

   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerList[row]
   }

   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       if listIndex == 0 {
           sectionType.text = pickerList[row]
       } else if listIndex == 1 {
           sectionName.text = pickerList[row]
       }
   }

    func makePickerList(list: Int) {
        switch list {
        case 1: do {
            self.pickerList = [""]
            for section in sections {
                self.pickerList.append(section.name)
            }
        }
        case 0: do {
            self.pickerList = [""]
            for type in SectionType.allCases {
                self.pickerList.append(type.rawValue)
            }
        }
        default: pickerList = [""]
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == sectionType {
            return false; //do not show keyboard nor cursor
        }
        return true
    }

}

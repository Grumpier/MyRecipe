//
//  EggController.swift
//  MyRecipe
//
//  Created by Steven Manus on 02/04/21.
//

import UIKit

class EggController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var eggType: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    
    var completionHandler: ((EggType) -> Void)?
    
    var pickerList: [String] {
        let eggs = EggType.allCases
        var eggList = [""]
        for egg in eggs {
            eggList.append(egg.rawValue)
        }
        return eggList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eggType.delegate = self
        picker.delegate = self
        picker.dataSource = self
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        if let thisEgg = EggType(rawValue: eggType.text!) {
            view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
            completionHandler?(thisEgg)
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
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
        eggType.text = pickerList[row]
   }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}


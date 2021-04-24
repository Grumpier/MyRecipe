//
//  DairyController.swift
//  MyRecipe
//
//  Created by Steven Manus on 08/04/21.
//

import UIKit

class DairyController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var dairyType: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var proteinQty: UITextField!
    @IBOutlet weak var proteinStepperValue: UIStepper!
    @IBOutlet weak var fatQty: UITextField!
    @IBOutlet weak var fatStepperValue: UIStepper!
    @IBOutlet weak var carbsQty: UITextField!
    @IBOutlet weak var carbsStepperValue: UIStepper!
    @IBOutlet weak var ashQty: UITextField!
    @IBOutlet weak var ashStepperValue: UIStepper!
    @IBOutlet weak var saltQty: UITextField!
    @IBOutlet weak var saltStepperValue: UIStepper!
    @IBOutlet weak var hydrationQty: UITextField!
    
    var completionHandler: ((DairyItem) -> Void)?
    var thisDairyItem = DairyType.whole.defaults()
    
    var pickerList: [String] {
        let dairyItems = DairyType.allCases
        var dairyList = [""]
        for dairy in dairyItems {
            dairyList.append(dairy.rawValue)
        }
        return dairyList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        dairyType.text = thisDairyItem.name
        setDefaultValue(item: dairyType.text ?? "", inComponent: 0)
        getValues()
    }

    func setDefaultValue(item: String, inComponent: Int) {
        if let indexPosition = pickerList.firstIndex(of: item) {
            picker.selectRow(indexPosition, inComponent: inComponent, animated: true)
        }
    }
    
    func getValues() {
        /// Updates fields with new DairyItem values
        proteinQty.text = thisDairyItem.protein.description
        proteinStepperValue.value = thisDairyItem.protein * 10
        fatQty.text = thisDairyItem.fat.description
        fatStepperValue.value = thisDairyItem.fat * 10
        carbsQty.text = thisDairyItem.carbs.description
        carbsStepperValue.value = thisDairyItem.carbs * 10
        ashQty.text = thisDairyItem.ash.description
        ashStepperValue.value = thisDairyItem.ash * 10
        saltQty.text = thisDairyItem.salt.description
        saltStepperValue.value = thisDairyItem.salt * 10
        hydrationQty.text = thisDairyItem.hydration.description
    }
    
    func setValues() {
        /// Update DairyItem instance with values from fields
        thisDairyItem.protein = Double(proteinQty.text!) ?? 0.0
        thisDairyItem.fat = Double(fatQty.text!) ?? 0.0
        thisDairyItem.carbs = Double(carbsQty.text!) ?? 0.0
        thisDairyItem.ash = Double(ashQty.text!) ?? 0.0
        thisDairyItem.salt = Double(saltQty.text!) ?? 0.0
        hydrationQty.text = thisDairyItem.hydration.description
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        setValues()
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        completionHandler?(thisDairyItem)
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
        dairyType.text = pickerList[row]
        if let thisType = DairyType(rawValue: dairyType.text!) {
            thisDairyItem = thisType.defaults()
            getValues()
        }
   }

 // MARK: - Stepper functions
    @IBAction func proteinStepper(_ sender: UIStepper) {
        proteinQty.text = Double(sender.value / 10).description
        setValues()
    }
    
    @IBAction func fatStepper(_ sender: UIStepper) {
        fatQty.text = Double(sender.value / 10).description
        setValues()
    }
    
    @IBAction func carbsStepper(_ sender: UIStepper) {
        carbsQty.text = Double(sender.value / 10).description
        setValues()
    }
    
    @IBAction func ashStepper(_ sender: UIStepper) {
        ashQty.text = Double(sender.value / 10).description
        setValues()
    }
    
    @IBAction func saltStepper(_ sender: UIStepper) {
        saltQty.text = Double(sender.value / 10).description
        setValues()
    }
    
}


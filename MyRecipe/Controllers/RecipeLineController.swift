//
//  RecipeLineController.swift
//  MyRecipe
//
//  Created by Steven Manus on 02/03/21.
//

import UIKit

protocol RecipeLineDelegate {
    func returnFromRecipeLine()
    func getAddMode() -> Int
}

// Needs to know whether it is adding or editing an exiting line
// Too tricky to create a custom init() so we are calling the delegate to tell us what we are
class RecipeLineController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var ingredient: UITextField!
    @IBOutlet weak var measure: UITextField!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var viewTitle: UILabel!
    
    
    let recipeBrain = RecipeBrain.singleton
    var ingredients = [Ingredient]()
    var pickerList = [""]
    var listIndex = 0
    var delegate: RecipeLineDelegate?
    var qty = 0.0
    var addMode = 0 // 0 for adding, 1 for editing
        
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredient.delegate = self
        measure.delegate = self
        picker.delegate = self
        picker.dataSource = self
        ingredients = recipeBrain.ingredients
        makePickerList(list: listIndex)
        askDelegateForMode()
    }
    
    // configure controller and interface for whether in add or edit mode
    func askDelegateForMode() {
        addMode = delegate?.getAddMode() ?? 0
        if addMode == 0 {
            viewTitle.text = "Add a New Recipe Line"
            clearLine()
        } else if addMode == 1 {
            viewTitle.text = "Edit Recipe Line"
            getLine()
        }
    }
    
    func clearLine() {
        ingredient.text = ""
        quantity.text = ""
        measure.text = ""
        makePickerList(list: 0)
    }
    
    func getLine() {
        let recipeLine = recipeBrain.getCurrentRecipeLine()
        ingredient.text = recipeLine.ingredient.name
        quantity.text = String(format: "%.3f", recipeLine.measure.value)
        measure.text = recipeLine.measure.unit.symbol
        makePickerList(list: 0)
    }
    
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
            ingredient.text = pickerList[row]
        } else if listIndex == 1 {
            measure.text = pickerList[row]
        }
    }
    
    func makePickerList(list: Int) {
        switch list {
        case 0: do {
            self.pickerList = [""]
            for ingredient in ingredients {
                self.pickerList.append(ingredient.name)
            }
        }
        case 1: do {
            self.pickerList = [""]
            for uom in UOM.allCases {
                self.pickerList.append(uom.rawValue.symbol)
            }
        }
        default: pickerList = [""]
        }
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        var addResult = 0
        if quantity.text == nil  {
            alertMessage(title: "Quantity", message: "Please enter a quantity.")
            return
        }
        if (ingredient.text ?? "").isEmpty  {
            alertMessage(title: "Ingredient", message: "Please select an ingredient")
            return
        }
        if (measure.text ?? "").isEmpty {
            alertMessage(title: "Measure", message: "Please select a unit of measure")
            return
        }
        let thisMeasure = (UOM.allCases.filter({ $0.rawValue.symbol == measure.text }).first)!
        let ingredientName = ingredient.text ?? ""
        let qtyValue = Double(quantity.text ?? "0") ?? 0.0
        if addMode == 0 {
            addResult = recipeBrain.addRecipeLine(ingredientName: ingredientName, quantity: qtyValue, uom: thisMeasure)
        } else if addMode == 1 {
            addResult = recipeBrain.editRecipeLine(ingredientName: ingredientName, quantity: qtyValue, uom: thisMeasure)
        }
        
        if addResult == 1 {
            alertMessage(title: "Ingredient", message: "Select a valid ingredient or Add a new one")
            return
        } else if addResult == 2 {
            alertMessage(title: "Quantity", message: "Please enter a quantity greater than 0.")
            return
        }
        clearLine()
        delegate?.returnFromRecipeLine()
    }

    @IBAction func cancelPressed(_ selector: UIBarButtonItem) {
        clearLine()
        delegate?.returnFromRecipeLine()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField == ingredient {
            listIndex = 0
            makePickerList(list: listIndex)
            pickerList = pickerList.filter {$0.starts(with: textField.text!) }
            picker.reloadAllComponents()
        } else if textField == measure {
            listIndex = 1
            makePickerList(list: listIndex)
            measure.resignFirstResponder()
            picker.reloadAllComponents()
        }
    }
        
    func textFieldDidChangeSelection(_ textField: UITextField){
        if textField == ingredient {
            listIndex = 0
            makePickerList(list: listIndex)
            pickerList = pickerList.filter {$0.starts(with: textField.text!) }
            if pickerList.count == 0 {
                pickerList.append(" ") // to allow user to selecte from picker - IOS doesn't detect keypress on picker without movement
            }
            picker.reloadAllComponents()
        }
    }
    
    func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }    
}

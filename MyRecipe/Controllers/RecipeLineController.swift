//
//  RecipeLineController.swift
//  MyRecipe
//
//  Created by Steven Manus on 02/03/21.
//

import UIKit

protocol RecipeLineDelegate {
    func returnFromRecipeLine()
}

class RecipeLineController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
        
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var ingredient: UITextField!
    @IBOutlet weak var measure: UITextField!
    @IBOutlet weak var quantity: UITextField!
    
    
    let recipeBrain = RecipeBrain.singleton
    var ingredients = [Ingredient]()
    var pickerList = [""]
    var listIndex = 0
    var delegate: RecipeLineDelegate?
    var qty = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredient.delegate = self
        measure.delegate = self
        picker.delegate = self
        picker.dataSource = self
        ingredients = recipeBrain.ingredients
        makePickerList(list: listIndex)
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
        // Check if a valid recipe line was created
        if let qtyText = quantity.text {
            qty = Double(qtyText) ?? 0.0
            if qty <= 0 {
                sendAlert(title: "Quantity", message: "Please enter a value greater than zero")
                return
            }
        } else {
            sendAlert(title: "Quantity", message: "Please enter a value greater than zero")
            return
        }
        if !ingredients.map({ $0.name }).contains(ingredient.text) {
            sendAlert(title: "Ingredient", message: "Select an existing ingredient or press 'Add New Ingredient'")
            return
        }
        if !UOM.allCases.map({ $0.rawValue.symbol }).contains(measure.text) {
            sendAlert(title: "Measure", message: "Select a unit of measure")
            return
        }
        // passed all tests add to recipe - make a recipeline from the data
        let thisIngredient = ingredients.filter({ $0.name == ingredient.text }).first!
        let thisMeasure = (UOM.allCases.filter({ $0.rawValue.symbol == measure.text }).first?.rawValue)!
        let thisRecipeLine = RecipeLine(ingredient: thisIngredient, measure: Measurement<Unit>(value: qty, unit: thisMeasure))
        recipeBrain.addRecipeLine(thisRecipeLine)
        ingredient.text = ""
        quantity.text = ""
        measure.text = ""
        delegate?.returnFromRecipeLine()
    }

    @IBAction func cancelPressed(_ selector: UIBarButtonItem) {
        ingredient.text = ""
        quantity.text = ""
        measure.text = ""
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
    
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

}

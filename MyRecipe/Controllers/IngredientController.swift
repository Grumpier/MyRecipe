//
//  IngredientController.swift
//  MyRecipe
//
//  Created by Steven Manus on 06/03/21.
//

import UIKit

class IngredientController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var ingredient: UITextField!
    @IBOutlet weak var type: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var viewTitle: UILabel!
    @IBOutlet weak var delete: UIBarButtonItem!
    
    let recipeBrain = RecipeBrain.singleton
    var ingredients = [Ingredient]()
    var pickerList = [String]()
    var indexedList = [Int]()  // used to map sorted ingredient array indices to original ingredient array indices
    var editRow = 0  // the pickerList row selected by the user
    var addMode = 0 // 0 for adding, 1 for editing
    var ingredientName = ""  // used to pass value from recipe line
    var listIndex = 0 // 0 for ingredient type, 1 for ingredient
        
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredient.delegate = self
        ingredient.text = ingredientName
        type.delegate = self
        picker.delegate = self
        picker.dataSource = self
        ingredients = recipeBrain.ingredients
        setMode()
    }

    // configure controller and interface for whether in add or edit mode
    func setMode() {
        if addMode == 0 {
            viewTitle.text = "Create a New Ingredient"
            delete.isEnabled = false
            makePickerList(list: 0)
        } else if addMode == 1 {
            viewTitle.text = "Edit an Ingredient"
            delete.isEnabled = true
            makePickerList(list: 1)
        }
    }

    @IBAction func save(_ sender: UIBarButtonItem) {
        if (ingredient.text ?? "").isEmpty  {
            alertMessage(title: "Ingredient", message: "Please enter an ingredient name.")
            return
        }
        if (type.text ?? "").isEmpty {
            alertMessage(title: "Ingredient Type", message: "Please select an ingredient type")
            return
        }
        if addMode == 0 {
            recipeBrain.addIngredient(name: ingredient.text!.capitalized, type: type.text!)
        } else {
            recipeBrain.editIngredient(index: indexedList[editRow], name: ingredient.text!.capitalized, type: type.text!)
        }
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        recipeBrain.deleteIngredient(index: indexedList[editRow])
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
      editRow = row
      if listIndex == 0 {
           type.text = pickerList[row]
        if ingredient.text == "" || ingredient.text == nil {
               ingredient.text = pickerList[row]
           }
       } else if listIndex == 1 {
           ingredient.text = pickerList[row]
       }
   }

    func makePickerList(list: Int) {
        switch list {
        case 1: do {
            let enumeratedList = ingredients.enumerated().sorted(by: {$0.element.name < $1.element.name} )
            pickerList = enumeratedList.map( {$0.element.name} )
            indexedList = enumeratedList.map( {$0.offset} )
        }
        case 0: do {
            pickerList = IngredientType.allCases.map( {$0.rawValue} ).sorted(by: {$0 < $1} )
            self.pickerList = [""]
            for type in IngredientType.allCases {
                self.pickerList.append(type.rawValue)
                pickerList.sort()
            }
        }
        default: pickerList = [""]
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == type {
            ingredient.resignFirstResponder()
            return false
        }
        return true
    }
}

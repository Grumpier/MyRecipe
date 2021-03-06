//
//  NewIngredientController.swift
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
    
    let recipeBrain = RecipeBrain.singleton
    var ingredients = [Ingredient]()
    var pickerList = [""]
    var addMode = 0 // 0 for adding, 1 for editing
    var listIndex = 0 // 0 for ingredient type, 1 for ingredient
        
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredient.delegate = self
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
            makePickerList(list: 0)
        } else if addMode == 1 {
            viewTitle.text = "Edit an Ingredient"
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
        recipeBrain.addIngredient(name: ingredient.text!, type: type.text!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
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
           type.text = pickerList[row]
       } else if listIndex == 1 {
           ingredient.text = pickerList[row]
       }
   }

    func makePickerList(list: Int) {
        switch list {
        case 1: do {
            self.pickerList = [""]
            for ingredient in ingredients {
                self.pickerList.append(ingredient.name)
            }
        }
        case 0: do {
            self.pickerList = [""]
            for type in IngredientType.allCases {
                self.pickerList.append(type.rawValue)
            }
        }
        default: pickerList = [""]
        }
    }


}

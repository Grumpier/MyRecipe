//
//  RecipeLineController.swift
//  MyRecipe
//
//  Created by Steven Manus on 02/03/21.
//

import UIKit

// Needs to know whether it is adding or editing an exiting line
// Too tricky to create a custom init() so we are calling the delegate to tell us what we are
class RecipeLineController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, GetRecipeUpdates, GetEggType {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var ingredient: UITextField!
    @IBOutlet weak var measure: UITextField!
    @IBOutlet weak var quantity: UITextField!
    @IBOutlet weak var viewTitle: UILabel!
    
    let recipeBrain = RecipeBrain.singleton
    var ingredients = [Ingredient]()
    var pickerList = [""]
    var listIndex = 0
    var qty = 0.0
    var addMode = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredient.delegate = self
        measure.delegate = self
        picker.delegate = self
        picker.dataSource = self
        recipeBrain.addDelegate(self)
        ingredients = recipeBrain.ingredients
        makePickerList(list: listIndex)
        adjustForMode()
    }
    
    // configure controller and interface for whether in add or edit mode
    func setAddMode(_ mode: Int) {
        addMode = mode
    }
    
    func adjustForMode() {
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
        ingredient.text = recipeLine!.ingredient.name
        quantity.text = String(format: "%.3f", recipeLine!.measure.value)
        measure.text = recipeLine!.measure.unit.symbol
        makePickerList(list: 0)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        /// Checks if all fields are entered. Checks if ingredient type requires an associated value. If so, calls a UIAlert with a closure that handles the captured variable from a textfield inside the alert and calls the saveLine function that completes the save. If not, the saveLine is just called.
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
        if let thisType = recipeBrain.getIngredientType(name: ingredientName) {
            switch thisType {
            case .Starter:
                getHydration {(hydration) in
                    if let hydrationValue = Int(hydration!) {
                        if self.recipeBrain.validHydration(hydrationValue) {
                            let newType = IngredientType.Starter(hydration: hydrationValue)
                            self.saveLine(thisMeasure: thisMeasure, ingredientName: ingredientName, qtyValue: qtyValue, thisType: newType)
                        }
                    } else {
                    // THIS MESSAGE SHOULD COME FROM RECIPEBRAIN!!!!
                    self.alertMessage(title: "Hydration", message: "Please enter a number between 1 and 100 with no other characters.")
                    }
                }
            case .Egg:
                performSegue(withIdentifier: "EggSegue", sender: self)
            default:
                saveLine(thisMeasure: thisMeasure, ingredientName: ingredientName, qtyValue: qtyValue, thisType: thisType)
            }
        } else {
            print("Bad Ingredient")
        }
    }

    @IBAction func cancelPressed(_ selector: UIBarButtonItem) {
        clearLine()
        view.endEditing(true)
        ingredient.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveLine(thisMeasure: UOM, ingredientName: String, qtyValue: Double, thisType: IngredientType){
        var addResult = 0
        if addMode == 0 {
            addResult = recipeBrain.addRecipeLine(section: recipeBrain.getCurrentSection(), ingredientName: ingredientName, quantity: qtyValue, uom: thisMeasure, thisType: thisType)
        } else if addMode == 1 {
            addResult = recipeBrain.editRecipeLine(ingredientName: ingredientName, quantity: qtyValue, uom: thisMeasure, thisType: thisType)
        }

        if addResult == 1 {
            alertMessage(title: "Ingredient", message: "Select a valid ingredient or Add a new one")
            return
        } else if addResult == 2 {
            alertMessage(title: "Quantity", message: "Please enter a quantity greater than 0.")
            return
        }
        clearLine()
        view.endEditing(true)
        ingredient.resignFirstResponder()
        self.dismiss(animated: true, completion: { self.view.endEditing(true)}  )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "IngredientController":
            let ingredientController = segue.destination as! IngredientController
            ingredientController.addMode = 0
        case "EggSegue":
            let eggController = segue.destination as! EggController
            eggController.delegate = self
        default:
            break
        }
    }
    
    func getEggType(_ type: EggType) {
        let thisMeasure = (UOM.allCases.filter({ $0.rawValue.symbol == measure.text }).first)!
        let ingredientName = ingredient.text ?? ""
        let qtyValue = Double(quantity.text ?? "0") ?? 0.0
        saveLine(thisMeasure: thisMeasure, ingredientName: ingredientName, qtyValue: qtyValue, thisType: IngredientType.Egg(type: type))
    }
            
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == ingredient {
            listIndex = 0
            makePickerList(list: listIndex)
            pickerList = pickerList.filter {$0.starts(with: textField.text!) }
            picker.reloadAllComponents()
            return true
        } else if textField == measure {
            textField.text = UnitMass.grams.symbol
            listIndex = 1
            makePickerList(list: listIndex)
            picker.reloadAllComponents()
            return false
        }
        return true
    }
        
    func textFieldDidChangeSelection(_ textField: UITextField){
        if textField == ingredient {
            listIndex = 0
            makePickerList(list: listIndex)
            pickerList = pickerList.filter {$0.starts(with: textField.text!.capitalized) }
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
        switch listIndex {
        case 0:
            ingredient.text = pickerList[row]
        case 1:
            measure.text = pickerList[row]
        default:
            break
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
    
    func didChangeIngredients(_ ingredients: [Ingredient]) {
        self.ingredients = ingredients
        makePickerList(list: 0)
        picker.reloadComponent(0)
    }

    // MARK: - Alert box for Hydration input
    func getHydration(completion: @escaping (String?) -> Void) {
        ///A completion handler is passed to this alert function which takes a string as input and runs through the save process.
        var textField = UITextField()
        let alert = UIAlertController(title: "Specify hydration", message: "Enter a number between 0 and 100 to indicate the ratio of fluid/flour in this ingredient. For example, if there is an equal amount of fluid to flour, then enter '100'", preferredStyle: .alert)

        let action = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            completion(textField.text)
        })

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "0..100"
            textField = alertTextField
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

}

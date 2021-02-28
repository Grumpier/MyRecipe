//
//  AddIngredientController.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import Foundation

//STUFF FROM ORIGINAL DESIGN

//var ingredientPicker = UIPickerView(frame: CGRect(x: 250, y: 400, width: 300, height: 300))
//var recipePicker = UIPickerView(frame: CGRect(x: 250, y: 400, width: 300, height: 300))
//
//let addBut: UIButton = UIButton()
//let selectBut: UIButton = UIButton()
//
//var ingredientPickerDelegate: PickerDelegate = PickerDelegate(strings: [""])
//var recipePickerDelegate: PickerDelegate = PickerDelegate(strings: [""])
//
//// Add button for ingredient list
//addBut.setImage(UIImage(systemName: "plus"), for: .normal)
//addBut.tintColor = .black
//addBut.frame.size = CGSize(width: 25, height: 25)
//addBut.addTarget(self, action: #selector(addIngredient), for: .touchUpInside)
//addBut.isEnabled = true
//addBut.showsTouchWhenHighlighted = true
//
//// Tableview header to display add button
//tableView.tableHeaderView = UIView()
//tableView.tableHeaderView?.frame.size.height = 30
//tableView.tableHeaderView?.backgroundColor = .lightGray
//tableView.tableHeaderView?.addSubview(addBut)
//
//// ingredient picker
//ingredientPicker.backgroundColor = .lightGray
//ingredientPicker.dataSource = ingredientPickerDelegate
//ingredientPicker.delegate = ingredientPickerDelegate
//self.view.addSubview(ingredientPicker)
//ingredientPicker.isHidden = true
//
//// select button for picker
//selectBut.setImage(UIImage(systemName: "plus"), for: .normal)
//selectBut.tintColor = .black
//selectBut.frame.size = CGSize(width: 25, height: 25)
//selectBut.addTarget(self, action: #selector(ingredientSelected), for: .touchUpInside)
//ingredientPicker.addSubview(selectBut)
//
//// add an dummy ingredient to ingredient list to choose to create a new ingredient
//ingredients = [Ingredient(name: "+", type: .None)]
//// add some test data
//ingredients.append(Ingredient(name: "White Flour", type: .Flour))
//ingredients.append(Ingredient(name: "Water", type: .Fluid))
//ingredients.append(Ingredient(name: "Rye Flour", type: .Flour))
//ingredients.append(Ingredient(name: "Whole Wheat Flour", type: .Flour))


//// MARK: - Pickerview Data Source Protocol
//extension ViewController: UIPickerViewDataSource {
//   func numberOfComponents(in pickerView: UIPickerView) -> Int {
//       return 1
//   }
//   
//   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//       return ingredients.count
//   }
//}
//
//// MARK: - Pickerview Delegate Protocol
//extension ViewController: UIPickerViewDelegate {
//   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//       return ingredients[row].name
//   }
//   
//   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//       if row > 0 {
//           recipe.ingredientList.append(RecipeLine(ingredient: ingredients[row], measure: Measurement<Unit>(value: 0, unit: UnitMass.grams)))
//       } else {
//           print("Need to add a new ingredient - go to New Ingredient Detail View")
//       }
//       ingredientPicker.isHidden = true
//       tableView.reloadData()
//
//   }
//   
//   
//}
//
//// A generalized class to handle view pickers - just need to pass strings to each instance
//class PickerDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
//   var strings: [String]
//
//   init(strings: [String]) {
//       self.strings = strings
//       super.init()
//   }
//
//   func numberOfComponents(in pickerView: UIPickerView) -> Int {
//       return 1
//   }
//
//   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//       return strings.count
//   }
//
//   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//       return strings[row]
//   }
//   
////    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
////        print(row)
////    }
//
//}

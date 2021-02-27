//
//  ViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import UIKit


class recipeCell: UITableViewCell {
    @IBOutlet weak var ingredient: UILabel!
    @IBOutlet weak var measure: UILabel!
    
}




class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recipeName: UITextField!
    var ingredientPicker = UIPickerView(frame: CGRect(x: 250, y: 400, width: 300, height: 300))
    var recipePicker = UIPickerView(frame: CGRect(x: 250, y: 400, width: 300, height: 300))

    let addBut: UIButton = UIButton()

    var recipes: [Recipe] = []
    var ingredients: [Ingredient] = []
    
    // Test Data
    var recipe = Recipe(name: "Sylvie's Super Duper White Bread", measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams), ingredientList: [RecipeLine(ingredient: Ingredient(name: "White Flour", type: .Flour), measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams)), RecipeLine(ingredient: Ingredient(name: "Water", type: .Fluid), measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams))])
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the tableview properties
        tableView.dataSource = self
        tableView.delegate = self

        // Add button for ingredient list
        addBut.setImage(UIImage(systemName: "plus"), for: .normal)
        addBut.tintColor = .black
        addBut.frame.size = CGSize(width: 25, height: 25)
        addBut.addTarget(self, action: #selector(addIngredient), for: .touchUpInside)
        addBut.isEnabled = true
        addBut.showsTouchWhenHighlighted = true

        // Tableview header to display add button
        tableView.tableHeaderView = UIView()
        tableView.tableHeaderView?.frame.size.height = 30
        tableView.tableHeaderView?.backgroundColor = .lightGray
        tableView.tableHeaderView?.addSubview(addBut)

        // ingredient picker
        ingredientPicker.backgroundColor = .lightGray
        ingredientPicker.dataSource = self
        ingredientPicker.delegate = self
        self.view.addSubview(ingredientPicker)
        ingredientPicker.isHidden = true
        
        // Place recipe name into label
        recipeName.text = recipe.name
        
        // add an dummy ingredient to ingredient list to choose to create a new ingredient
        ingredients = [Ingredient(name: "+", type: .None)]
        // add some test data
        ingredients.append(Ingredient(name: "White Flour", type: .Flour))
        ingredients.append(Ingredient(name: "Water", type: .Fluid))
        ingredients.append(Ingredient(name: "Rye Flour", type: .Flour))
        ingredients.append(Ingredient(name: "Whole Wheat Flour", type: .Flour))
    }

    // Search for a Recipe
    @IBAction func searchRecipe(_ sender: UIBarButtonItem) {



    }
    
    @IBAction func addRecipe(_ sender: UIBarButtonItem) {
        // clear the table view and recipe label
        recipeName.text = ""
        recipeName.isUserInteractionEnabled = true
        recipe.ingredientList = []
        tableView.reloadData()
        
    }
    
    @objc func addIngredient() {
        // display a list of ingredients to choose from - if "+"
        ingredientPicker.isHidden = false
    }
}

// MARK: - Table View Data Source
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe.ingredientList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeItem", for: indexPath) as! recipeCell
        cell.ingredient.text = recipe.ingredientList[indexPath.row].ingredient.name
        cell.measure.text = String(format: "%.1f", recipe.ingredientList[indexPath.row].measure.value) +   "  \(recipe.ingredientList[indexPath.row].measure.unit.symbol)"
        return cell
    }
}

 // MARK: - Table View Delegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }


}

 // MARK: - Text Input Delegate



 // MARK: - Pickerview Data Source Protocol
extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ingredients.count
    }
}

 // MARK: - Pickerview Delegate Protocol
extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ingredients[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            recipe.ingredientList.append(RecipeLine(ingredient: ingredients[row], measure: Measurement<Unit>(value: 0, unit: UnitMass.grams)))
        } else {
            print("Need to add a new ingredient - go to New Ingredient Detail View")
        }
        ingredientPicker.isHidden = true
        tableView.reloadData()

    }
    
    
}




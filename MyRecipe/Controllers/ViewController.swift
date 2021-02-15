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
    
    var recipe: Recipe = Recipe(name: "White Bread", ingredientList: [(Ingredient(name: "White Flour", type: IngredientType.Flour), Measurement(value: 1000, unit: UnitMass.grams)), (Ingredient(name: "Water", type: IngredientType.Fluid), Measurement(value: 500, unit: UnitVolume.milliliters))])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
    }


}

// MARK: - Table View Data Source
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe.ingredientList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeItem", for: indexPath) as! recipeCell
        cell.ingredient.text = recipe.ingredientList[indexPath.row].0.name
        cell.measure.text = String(format: "%.1f", recipe.ingredientList[indexPath.row].1.value) +   "  \(recipe.ingredientList[indexPath.row].1.unit.symbol)"
        
        return cell
    }
}


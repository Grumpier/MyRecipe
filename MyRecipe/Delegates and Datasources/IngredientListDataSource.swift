//
//  IngredientDataSource.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import UIKit

class IngredientListDataSource: NSObject, RecipeUpdateDelegate {

    private let tableView: UITableView

    var recipe = Recipe(name: "", measure: Measurement<Unit>(value: 0, unit: UnitMass.grams), ingredientList: [])

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.reloadData()
    }

//    func ingredientAtIndexPath(_ indexPath: IndexPath) -> Ingredient? {
//        return indexPath.row < locations.count ? locations[indexPath.row] : nil
//    }

    // called as a delegate from the RecipeUpdateDelegate protocol
    func didChangeRecipe(_ recipe: Recipe) {
        self.recipe = recipe
        print(recipe.ingredientList)
        tableView.reloadData()
    }
}

extension IngredientListDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipe.ingredientList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let line = recipe.ingredientList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientListCell", for: indexPath) as! IngredientListTableViewCell
        cell.ingredient.text = line.ingredient.name
        cell.measure.text = String(format: "%.1f", line.measure.value) + "\(line.measure.unit.symbol)"
        return cell
    }

//    private func configure(cell: UITableViewCell, indexPath: IndexPath) {
//        if let cell = cell as? IngredientListTableViewCell {
//            let object = recipe.ingredientList[indexPath.row]
//            cell.configure(object: object)
//        }
//    }
}


//
//  IngredientDataSource.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import UIKit



class IngredientListDataSource: NSObject, RecipeUpdateDelegate {

    private let tableView: UITableView

    var recipe = Recipe(name: "Test", measure: Measurement<Unit>(value: 0, unit: UnitMass.grams), ingredientList: [RecipeLine(ingredient: Ingredient(name: "Test", type: .Flour), measure: Measurement<Unit>(value: 0, unit: UnitMass.grams))])
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCell.reuseIdentifier, for: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }

    private func configure(cell: UITableViewCell, indexPath: IndexPath) {
        if let cell = cell as? RecipeCell {
            let object = recipe.ingredientList[indexPath.row]
            cell.configure(object: object)
        }
    }
}


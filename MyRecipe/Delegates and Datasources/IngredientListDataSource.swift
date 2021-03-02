//
//  IngredientDataSource.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import UIKit


class IngredientListDataSource: NSObject, GetRecipeUpdates {

    private let tableView: UITableView

    let recipeBrain = RecipeBrain.singleton
    var recipe = Recipe(name: "", measure: Measurement<Unit>(value: 0, unit: UnitMass.grams), ingredientList: [])

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        recipeBrain.addDelegate(self)
        recipe = recipeBrain.recipe
        tableView.dataSource = self
        tableView.reloadData()
    }

    // returns the recipe line at the specified index path
    func recipeLineAtIndexPath(_ indexPath: IndexPath) -> RecipeLine? {
        return indexPath.row < recipe.ingredientList.count ? recipe.ingredientList[indexPath.row] : nil
    }

    // called as a delegate from the RecipeUpdateDelegate protocol
    func didChangeRecipe(_ recipe: Recipe) {
        self.recipe = recipe
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


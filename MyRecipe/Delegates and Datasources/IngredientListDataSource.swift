//
//  IngredientDataSource.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import UIKit

class IngredientListDataSource: NSObject {

    private let tableView: UITableView

    let recipeBrain = RecipeBrain.singleton

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.reloadData()
    }

}

extension IngredientListDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return recipeBrain.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeBrain.getNumberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCell.reuseIdentifier, for: indexPath)
        configure(cell: cell, indexPath: indexPath)
        return cell
    }

    private func configure(cell: UITableViewCell, indexPath: IndexPath) {
        if let cell = cell as? RecipeCell {
            if let object1 = recipeBrain.getRecipeLine(indexPath: indexPath){
                let object2 = recipeBrain.recipe
                cell.configure(object1: object1, object2: object2)
            }
        }
    }
}


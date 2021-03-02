//
//  RecipeCell.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import UIKit

class RecipeCell: UITableViewCell, ReusableIdentifier {
    @IBOutlet weak var ingredient: UILabel!
    @IBOutlet weak var measure: UILabel!
}

extension RecipeCell: ConfigurableCell {
    func configure(object: RecipeLine) {
        ingredient.text = object.ingredient.name
        measure.text = String(format: "%.1f", object.measure.value) + "\(object.measure.unit.symbol)"
    }
}

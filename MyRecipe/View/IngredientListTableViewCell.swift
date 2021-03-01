//
//  IngredientListCellTableViewCell.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import UIKit

class IngredientListTableViewCell: UITableViewCell {
        @IBOutlet weak var ingredient: UILabel!
        @IBOutlet weak var measure: UILabel!
}

//extension IngredientListTableViewCell: ConfigurableCell {
//    func configure(object: RecipeLine) {
//        ingredient.text = object.ingredient.name
//        measure.text = String(format: "%.1f", object.measure.value) + "\(object.measure.unit.symbol)"
//    }
//}

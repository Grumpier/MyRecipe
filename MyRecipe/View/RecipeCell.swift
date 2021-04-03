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
    func configure(object1: RecipeLine, object2: Recipe) {
        var caption = ""
        if object2.totalFlour > 0 {
            let percentOfFlour = Int(round(100 * (object1.measure.converted(to: .grams).value / object2.totalFlour)))
            caption = String(" (\(percentOfFlour)%)")
        }
        switch object1.ingredient.type {
        case .Starter(let hydration):
            caption = String(" (\(hydration)% hydration)") + caption
        case .Egg(let type):
            caption = String(" (\(type.name))") + caption
        default:
            break
        }
        ingredient.text = object1.ingredient.name + caption
        measure.text = String(format: "%.1f", object1.measure.value) + "\(object1.measure.unit.symbol)"
    }
}

//
//  HeaderTableViewCell.swift
//  MyRecipe
//
//  Created by Steven Manus on 09/03/21.
//

import UIKit

class HeaderTableViewCell: UITableViewCell, ReusableIdentifier {
    var newLine: ((UITableViewCell) -> Void)?
    var editHeader: ((UITableViewCell) -> Void)?
    
    @IBOutlet weak var sectionName: UILabel!
    @IBAction func addIngredientPressed(_ sender: UIButton) {
        newLine?(self)
    }
    
    @IBAction func editTouched(_ sender: UIButton) {
        editHeader?(self)
    }
    
    
}

extension HeaderTableViewCell: ConfigurableCell {
    func configure(object1: Section, object2: Any?) {
        sectionName.text = object1.name
    }
}


//
//  Ingredients.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import Foundation

struct Ingredient: Codable  {
    let name: String
    var type: IngredientType
    
    init(name: String, type: IngredientType) {
        self.name = name
        self.type = type
    }
        
}


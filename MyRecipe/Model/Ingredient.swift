//
//  Ingredients.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import Foundation

struct Ingredient: Codable  {
    var name: String
    var type: IngredientType
    
    init(name: String, type: IngredientType) {
        self.name = name
        self.type = type
    }
}

struct DairyItem: Codable {
    let name: String
    var protein: Double
    var fat: Double
    var carbs: Double
    var ash: Double
    var salt: Double
    var hydration: Double {
        return 100.0 - (protein + fat + carbs + ash + salt)
    }
}


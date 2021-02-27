//
//  Recipes.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import Foundation

struct Recipe: Codable {
    var name: String
    var measure: Measurement<Unit>
    var ingredientList: [RecipeLine]
    
    init(name: String, measure: Measurement<Unit>, ingredientList: [RecipeLine]) {
        self.name = name
        self.measure = measure
        self.ingredientList = ingredientList
    }
    
}

struct RecipeLine: Codable {
    var ingredient: Ingredient
    var measure: Measurement<Unit>
    
    init(ingredient: Ingredient, measure: Measurement<Unit>) {
        self.ingredient = ingredient
        self.measure = measure
    }
    
}


    
    

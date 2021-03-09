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
    var ingredientList: [[RecipeLine]]
    var sectionList: [Section]
    
    init(name: String, measure: Measurement<Unit>, ingredientList: [[RecipeLine]], sectionList: [Section]) {
        self.name = name
        self.measure = measure
        self.ingredientList = ingredientList
        self.sectionList = sectionList
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

struct Section: Codable {
    var name: String
    var type: SectionType
}

    
    

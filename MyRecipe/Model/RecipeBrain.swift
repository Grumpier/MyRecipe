//
//  RecipeBrain.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import Foundation   

class RecipeBrain {
    // Directories for storing data objects
    static let recipePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Recipes.plist")
    static let ingredientPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Ingredients.plist")


    
    
    static func writeRecipes() {
        
        
    }
    
    
    static func readRecipes(){
        
        
    }
    
    
}

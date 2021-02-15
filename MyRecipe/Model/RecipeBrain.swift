//
//  RecipeBrain.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import Foundation

struct RecipeBrain {
    static let recipeURL = URL(fileURLWithPath: "Recipes", relativeTo: FileManager.documentDirectoryURL)
    static let ingredientURL = URL(fileURLWithPath: "Ingredients", relativeTo: FileManager.documentDirectoryURL)
    var ingredients: [Ingredient]
    var recipeList: [Recipe]
    
    init() {
        do {
            let ingredientData = try Data(contentsOf: RecipeBrain.ingredientURL)
            self.ingredients = Array(ingredientData)
        } catch {
            print("Some kind of error retrieving ingredients")
        }

        let savedFavoriteBytes = Array(savedFavoriteBytesData)

        
    }
    
    
    static func setIngredient(ingredient: Ingredient) {
        
        
    }
    
    func writeRecipes {
        
        
    }
    
    
    func readRecipes
    
    
}

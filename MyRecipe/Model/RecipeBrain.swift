//
//  RecipeBrain.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import Foundation   

protocol GetRecipeUpdates: AnyObject {
    func didChangeRecipe(_ recipe: Recipe)
}


// Singleton to control all data updates and refreshes
class RecipeBrain {
    static let singleton = RecipeBrain()
    
    var recipes: [Recipe] = []
    var ingredients: [Ingredient] = []
    var delegates = [GetRecipeUpdates]()
    
    // Test Data
    var recipe = Recipe(name: "Sylvie's Super Duper White Bread", measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams), ingredientList: [RecipeLine(ingredient: Ingredient(name: "White Flour", type: .Flour), measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams)), RecipeLine(ingredient: Ingredient(name: "Water", type: .Fluid), measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams)), RecipeLine(ingredient: Ingredient(name: "Yeast", type: .Yeast), measure: Measurement<Unit>(value: 50, unit: UnitMass.grams))])

    private init() {
        // TEMPORARILY USING LOCAL PLISTS
        let urlIngredients = Bundle.main.url(forResource: "Ingredients", withExtension: "plist")!
        loadIngredients(url: urlIngredients)
        let urlRecipes = Bundle.main.url(forResource: "Recipes", withExtension: "plist")!
        loadRecipes(url: urlRecipes)
    }
    
    // Directories for storing data objects
    let recipePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Recipes.plist")
    let ingredientPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Ingredients.plist")

    func addDelegate(_ delegate: GetRecipeUpdates){
        delegates.append(delegate)
    }
    
    func broadcastRecipe() {
        for delegate in delegates {
            delegate.didChangeRecipe(recipe)
        }
    }
    
    func getRecipeName() -> String {
        return recipe.name
    }
    
    
    func writeRecipes() {
        
        
    }
    
    
    static func readRecipes(){
        
        
    }
    
    func loadIngredients(url: URL) {
        if let data = try? Data(contentsOf: url) {
            let decoder = PropertyListDecoder()
            do {
                ingredients = try decoder.decode([Ingredient].self, from: data)
                print(ingredients)
            } catch {
                print("Error decoding item array \(error)")
            }
        }
        
    }

    // NOT WORKING - NEED TO REVIEW OBJECT AND PLIST STRUCTURES
    func loadRecipes(url: URL) {
        if let data = try? Data(contentsOf: url) {
            let decoder = PropertyListDecoder()
            do {
                recipes = try decoder.decode([Recipe].self, from: data)
                print(recipes)
            } catch {
                print("Error decoding item array \(error)")
            }
        }
        
    }
    

}

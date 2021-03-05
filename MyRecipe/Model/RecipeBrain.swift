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
    var currentRecipeLine: RecipeLine?
    var currentRecipeLineIndex = 0
    var currentRecipeIndex = 0
    
    // Test Data
    var recipe = Recipe(name: "Sylvie's Super Duper White Bread", measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams), ingredientList: [RecipeLine(ingredient: Ingredient(name: "White Flour", type: .Flour), measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams)), RecipeLine(ingredient: Ingredient(name: "Water", type: .Fluid), measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams)), RecipeLine(ingredient: Ingredient(name: "Yeast", type: .Yeast), measure: Measurement<Unit>(value: 50, unit: UnitMass.grams))])

    // TEMPORARILY USING LOCAL PLISTS
    let urlIngredients = Bundle.main.url(forResource: "Ingredients", withExtension: "plist")!
    let urlRecipes = Bundle.main.url(forResource: "Recipes", withExtension: "plist")!
    
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
    
    func setRecipeName(_ name: String) {
        /// Changes recipe name with passed string. Saves changed recipe.
        recipe.name = name
        saveRecipe()
    }
    
    func getRecipeLine(indexPath: IndexPath) -> RecipeLine {
        return recipe.ingredientList[indexPath.row]
    }

    func getCurrentRecipeLine() -> RecipeLine {
        ///Returns curently active recipe line from ingredient list
        return currentRecipeLine ?? recipe.ingredientList[0]
    }
    
    func setCurrentRecipeLine(indexPath: IndexPath) {
        ///Sets current recipe line to the ingredient list entry at the passed index path row.
        currentRecipeLineIndex = indexPath.row
        currentRecipeLine = recipe.ingredientList[indexPath.row]
    }
    
    func addRecipeLine(ingredientName: String, quantity: Double, uom: UOM) -> Int {
        ///Receives receipe line components and validates before appending to ingredient list. Saves modified recipe and broadcasts. Return 0 for okay, 1 for bad ingredient, 2 for bad quantity.
        if quantity <= 0 {return 2}
        if !ingredients.map({ $0.name }).contains(ingredientName) {return 1}

        // passed all tests add to recipe - make a recipeline from the data
        let thisIngredient = ingredients.filter({ $0.name == ingredientName }).first!
        let thisRecipeLine = RecipeLine(ingredient: thisIngredient, measure: Measurement<Unit>(value: quantity, unit: uom.rawValue))
        recipe.ingredientList.append(thisRecipeLine)
        saveRecipe()
        broadcastRecipe()
        return 0
    }
    
    func editRecipeLine(ingredientName: String, quantity: Double, uom: UOM) -> Int {
        ///Receives recipe line components and validates before replacing the current recipe line. Saves modified recipe and broadcasts. Return 0 for okay, 1 for bad ingredient, 2 for bad quantity.
        if quantity <= 0 {return 2}
        if !ingredients.map({ $0.name }).contains(ingredientName) {return 1}

        // passed all tests - edit current recipe line
        let thisIngredient = ingredients.filter({ $0.name == ingredientName }).first!
        let thisRecipeLine = RecipeLine(ingredient: thisIngredient, measure: Measurement<Unit>(value: quantity, unit: uom.rawValue))
        recipe.ingredientList[currentRecipeLineIndex] = thisRecipeLine
        saveRecipe()
        broadcastRecipe()
        return 0
    }

    func deleteRecipeLine(_ index: Int) {
        ///Deletes the entry in the ingredient list at the specified index. Save the modified recipe and broadcast to delegates.
        recipe.ingredientList.remove(at: index)
        saveRecipe()
        broadcastRecipe()
    }
    
    func getRecipe(indexPath: IndexPath) -> Recipe {
        return recipes[indexPath.row]
    }
    
    func saveRecipe() {
        ///Saves the current recipe in the recipes array at the currentrecipeindex.
        recipes[currentRecipeIndex] = recipe
    }
        
    func newRecipe() {
        /// Creates and broadcasts to delegates an empty recipe object. Appends to recipes array and updates currentRecipeIndex. If add aborted, deleteRecipe at this index needs to be called.
        recipe = Recipe(name: "", measure: Measurement<Unit>(value: 0, unit: UOM.grams.rawValue), ingredientList: [])
        recipes.append(recipe)
        currentRecipeIndex = recipes.count - 1
        broadcastRecipe()
    }
    
    func writeRecipes() {
        
        
    }
    
    
    static func readRecipes(){
        
        
    }
    
    func loadIngredients() {
        if let data = try? Data(contentsOf: urlIngredients) {
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
        if let data = try? Data(contentsOf: urlRecipes) {
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

//
//  RecipeBrain.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import Foundation   

protocol GetRecipeUpdates: AnyObject {
    func didChangeRecipe(_ recipe: Recipe)
    func didChangeIngredients(_ ingredients: [Ingredient])
    func didChangeRecipes(_ recipes: [Recipe])
}

// make all the protocol methods optional
extension GetRecipeUpdates {
    func didChangeRecipe(_ recipe: Recipe) {}
    func didChangeIngredients(_ ingredients: [Ingredient]) {}
    func didChangeRecipes(_ recipes: [Recipe]) {}
}


// Singleton to control all data updates and refreshes
class RecipeBrain {
    static let singleton = RecipeBrain()
    
    var recipes: [Recipe] = []
    var ingredients: [Ingredient] = []
    var delegates = [GetRecipeUpdates]()
    var currentRecipeLine: RecipeLine?
    var currentRecipeLineIndex = 0
    var currentRecipeIndex = -1
    var recipe = Recipe(name: "", measure: Measurement<Unit>(value: 0, unit: UOM.grams.rawValue), ingredientList: [])
    
    
    // Directories for storing data objects
    let urlRecipes = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Recipes.plist")

    let urlIngredients = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Ingredients.plist")
    
    let urlRecipe = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Recipe.plist")

    let defaults = UserDefaults.standard
    
    // Delegate stuff for broadcasting to controllers
    func addDelegate(_ delegate: GetRecipeUpdates){
        ///Registers a delegate of GetRecipeUpdates delegate protocol
        delegates.append(delegate)
    }
    
    func broadcastRecipe() {
        ///Broadcasts current recipe to all delegates of GetRecipeUpdates protocol
        for delegate in delegates {
            delegate.didChangeRecipe(recipe)
        }
    }
    
    func broadcastIngredients() {
        ///Broadcasts ingredient array
        for delegate in delegates {
            delegate.didChangeIngredients(ingredients)
        }
    }
    
    func broadcastRecipes() {
        ///Broadcasts ingredient array
        for delegate in delegates {
            delegate.didChangeRecipes(recipes)
        }
    }
    
    func getRecipeAt(_ row: Int) {
        recipe = recipes[row]
        currentRecipeIndex = row
        broadcastRecipe()
    }

    func getRecipeName() -> String {
        return recipe.name
    }
    
    func setRecipeName(_ name: String) {
        /// Changes recipe name with passed string. Saves changed recipe.
        recipe.name = name
        saveRecipe()
    }
    
    func addIngredient(name: String, type: IngredientType.RawValue) {
        /// Create a new ingredient and append to ingredients array. Broadcasts new array.
        let ingredient = Ingredient(name: name, type: IngredientType(rawValue: type)!)
        ingredients.append(ingredient)
        broadcastIngredients()
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
        ///Saves the current recipe in the recipes array at the currentrecipeindex. If index is -1 appends unless recipe.name is empty. Broadcasts new array.
        if currentRecipeIndex == -1 {
            if !recipe.name.isEmpty {
                recipes.append(recipe)
                currentRecipeIndex = recipes.count - 1
            }
        } else {
            recipes[currentRecipeIndex] = recipe
        }
        broadcastRecipes()
    }
        
    func newRecipe() {
        /// Creates and broadcasts to delegates an empty recipe object. Sets currentRecipeIndex to -1 to indicate current recipe is not in recipes array.
        recipe = Recipe(name: "", measure: Measurement<Unit>(value: 0, unit: UOM.grams.rawValue), ingredientList: [])
        currentRecipeIndex = -1
        broadcastRecipe()
    }
    
    func writeIngredients() {
        ///Write ingredients array to disk
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(ingredients)
            try data.write(to: urlIngredients!)
        } catch {
            print("Error encoding ingredients array, \(error)")
        }
    }
    
    func writeRecipe() {
        ///Write recipe object to disk
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(recipe)
            try data.write(to: urlRecipe!)
        } catch {
            print("Error encoding current recipe, \(error)")
        }
    }
    
    func writeRecipes() {
        ///Write recipes array to disk
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(recipes)
            try data.write(to: urlRecipes!)
        } catch {
            print("Error encoding ingredients array, \(error)")
        }
    }
    
    func writeCurrentRecipeIndex() {
        defaults.setValue(currentRecipeIndex, forKey: "CurrentRecipeIndex")
    }
    
    func loadIngredients() {
        ///Reads ingredients array from disk
        if let data = try? Data(contentsOf: urlIngredients!) {
            let decoder = PropertyListDecoder()
            do {
                ingredients = try decoder.decode([Ingredient].self, from: data)
            } catch {
                print("Error decoding ingredients array \(error)")
            }
        }
    }
    
    func loadRecipe() {
        ///Reads current recipe from disk
        if let data = try? Data(contentsOf: urlRecipe!) {
            let decoder = PropertyListDecoder()
            do {
                recipe = try decoder.decode(Recipe.self, from: data)
            } catch {
                print("Error decoding current recipe \(error)")
            }
        }
    }

    func loadRecipes() {
        ///Reads recipes array from disk
        if let data = try? Data(contentsOf: urlRecipes!) {
            let decoder = PropertyListDecoder()
            do {
                recipes = try decoder.decode([Recipe].self, from: data)
                if recipes.count == 0 {
                    currentRecipeIndex = -1
                } else {
                    // load currentRecipeIndex
                    if let data = defaults.integer(forKey: "CurrentRecipeIndex") as Int? {
                        currentRecipeIndex = data
                    } else {
                        currentRecipeIndex = -1
                    }
                }
            } catch {
                print("Error decoding current recipe \(error)")
            }
        }
    }

}

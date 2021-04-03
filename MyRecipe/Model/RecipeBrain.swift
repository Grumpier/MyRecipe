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
    ///Master class for handling all data entry and retrieval
    static let singleton = RecipeBrain()
    
    var recipes: [Recipe] = []
    var ingredients: [Ingredient] = []
    var delegates = [GetRecipeUpdates]()
    var currentRecipeLine: RecipeLine?
    var currentRecipeLineIndex = 0
    // Note that sections are just integers - let TableView handling headings for each section group
    var currentRecipeSection = 0
    var currentRecipeIndex = -1
    var recipe = Recipe(name: "", qty: 1, notes: "", ingredientList: [[]], sectionList: [Section(name: "Dough", type: SectionType(rawValue: "Dough")!)])
    
    
 // MARK: - Directories for storing data objects
    let urlRecipes = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Recipes.plist")

    let urlIngredients = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Ingredients.plist")
    
    let urlRecipe = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Recipe.plist")

    let defaults = UserDefaults.standard
    
 // MARK: - Delegate stuff for broadcasting data updates to controllers
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
    
 // MARK: - Recipe set/get methods
    func getRecipeAt(_ row: Int) {
        recipe = recipes[row]
        currentRecipeIndex = row
        writeRecipe()
        broadcastRecipe()
    }
    
    func getNumberOfSections() -> Int {
        ///Returns the number of sections of the current recipe
        return recipe.ingredientList.count
    }
    
    func getNumberOfRowsInSection(section: Int) -> Int {
        ///Section is an index.
        if recipe.ingredientList.count > section {
            return recipe.ingredientList[section].count
        } else {
            return 0
        }
    }
    
    func getSectionName(section: Int) -> String {
        ///Section is an index
        if recipe.sectionList.count > section {
            return recipe.sectionList[section].name
        } else {
            return ""
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
    
    func getQty() -> Double {
        return recipe.qty
    }
    
    func setQty(_ qty: Double) {
        recipe.qty = qty
        saveRecipe()
    }
    
    func getNotes() -> String {
        return recipe.notes
    }
    
    func setNotes(_ notes: String) {
        recipe.notes = notes
        saveRecipe()
    }
    
    func getRecipeLine(indexPath: IndexPath) -> RecipeLine? {
        if recipe.ingredientList.count > indexPath.section {
            return recipe.ingredientList[indexPath.section][indexPath.row]
        } else {
            return nil
        }
    }

    func getCurrentRecipeLine() -> RecipeLine? {
        ///Returns curently active recipe line from ingredient list
        return currentRecipeLine
    }
    
    func setCurrentRecipeLine(indexPath: IndexPath) {
        ///Sets current recipe line to the ingredient list entry at the passed index path section and row.
        if recipe.sectionList.count > indexPath.section {
            if recipe.ingredientList[indexPath.section].count > indexPath.row {
                currentRecipeLineIndex = indexPath.row
                currentRecipeSection = indexPath.section
                currentRecipeLine = recipe.ingredientList[currentRecipeSection][currentRecipeLineIndex]
            }
        }
    }
    
    func setCurrentSection(_ section: Int) {
        currentRecipeSection = section
        print(currentRecipeSection)
    }
    
    func getCurrentSection() -> Int {
        return currentRecipeSection
    }
    
    func getSectionList() -> [Section] {
        return recipe.sectionList
    }
    
    func addEditSection(section: Int, sectionName: String, sectionType: SectionType.RawValue) -> Int {
        /// Adds a new section or replaces section name and type if already exists. If section index is out of order, returns error code 1.
        if recipe.sectionList.count < section {
            return 1
        } else if recipe.sectionList.count == section {
            recipe.sectionList.append(Section(name: sectionName, type: SectionType(rawValue: sectionType)!))
            recipe.ingredientList.append([])
        } else {
            recipe.sectionList[section].name = sectionName
            recipe.sectionList[section].type = SectionType(rawValue: sectionType)!
        }
        broadcastRecipe()
        return 0
    }
    
    func addRecipeLine(section: Int, ingredientName: String, quantity: Double, uom: UOM, thisType: IngredientType) -> Int {
        ///Receives receipe line components and validates before appending to ingredient list. Saves modified recipe and broadcasts. Return 0 for okay, 1 for bad ingredient, 2 for bad quantity, 3 for bad section.
        if quantity <= 0 {return 2}
        if !ingredients.map({ $0.name }).contains(ingredientName) {return 1}
        if recipe.sectionList.count <= section {return 3}
        
        // passed all tests add to recipe - make a recipeline from the data
        var thisIngredient = ingredients.filter({ $0.name == ingredientName }).first!
        thisIngredient.type = thisType
        let thisRecipeLine = RecipeLine(ingredient: thisIngredient, measure: Measurement<UnitMass>(value: quantity, unit: uom.rawValue as! UnitMass))
        recipe.ingredientList[section].append(thisRecipeLine)
        saveRecipe()
        broadcastRecipe()
        return 0
    }
    
    func editRecipeLine(ingredientName: String, quantity: Double, uom: UOM, thisType: IngredientType) -> Int {
        ///Receives recipe line components and validates before replacing the current recipe line. Saves modified recipe and broadcasts. Return 0 for okay, 1 for bad ingredient, 2 for bad quantity.
        if quantity <= 0 {return 2}
        if !ingredients.map({ $0.name }).contains(ingredientName) {return 1}

        // passed all tests - edit current recipe line
        var thisIngredient = ingredients.filter({ $0.name == ingredientName }).first!
        thisIngredient.type = thisType
        let thisRecipeLine = RecipeLine(ingredient: thisIngredient, measure: Measurement<UnitMass>(value: quantity, unit: uom.rawValue as! UnitMass))
        recipe.ingredientList[currentRecipeSection][currentRecipeLineIndex] = thisRecipeLine
        currentRecipeLine = thisRecipeLine
        saveRecipe()
        broadcastRecipe()
        return 0
    }

    func deleteRecipeLine(indexPath: IndexPath) {
        ///Deletes the entry in the ingredient list at the specified index. Save the modified recipe and broadcast to delegates.
        if recipe.sectionList.count > indexPath.section {
            if recipe.ingredientList[indexPath.section].count > indexPath.row {
                recipe.ingredientList[indexPath.section].remove(at: indexPath.row)
                saveRecipe()
                broadcastRecipe()
            }
        }
    }
    
    func getRecipe(indexPath: IndexPath) -> Recipe {
        return recipes[indexPath.row]
    }
    
    func scaleRecipe(_ percent: Double) {
        ///Takes a percent and changes measures for every ingredient line based on percent.
        if percent > 0 {
            for sectionIndex in 0..<getNumberOfSections() {
                for lineIndex in 0..<getNumberOfRowsInSection(section: sectionIndex) {
                    recipe.ingredientList[sectionIndex][lineIndex].measure.value *= percent
                }
            }
            saveRecipe()
        }
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
        writeRecipe()
        writeRecipes()
        broadcastRecipes()
    }
        
    func newRecipe() {
        /// Creates and broadcasts to delegates an empty recipe object. Sets currentRecipeIndex to -1 to indicate current recipe is not in recipes array.
        recipe = Recipe(name: "", qty: 1, notes: "", ingredientList: [[]], sectionList: [Section(name: "Dough", type: SectionType(rawValue: "Dough")!)])
        writeRecipe()
        currentRecipeIndex = -1
        broadcastRecipe()
    }
    
    func deleteRecipe() {
        /// Deletes the current recipe from the recipes array and retrieves the last recipe or if none, a new empty recipe
        if !recipes.isEmpty {
            recipes.remove(at: currentRecipeIndex)
            writeRecipes()
            if recipes.isEmpty {
                newRecipe()
            } else {
                getRecipeAt(recipes.count - 1)
            }
        }
    }
    
    
 // MARK: - Hydration methods
    func validHydration(_ hydration: Int) -> Bool {
        return hydration >= 1 && hydration <= 100
    }

    
 // MARK: - Ingredient set/get methods
    func addIngredient(name: String, type: IngredientType.RawValue) {
        /// Create a new ingredient and append to ingredients array. Broadcasts new array.
        let ingredient = Ingredient(name: name, type: IngredientType(rawValue: type)!)
        ingredients.append(ingredient)
        writeIngredients()
        broadcastIngredients()
    }
    
    func getIngredientType(name: String) -> IngredientType? {
        /// Returns an optional ingredient type from a passed ingredient name
        if let thisIngredient = ingredients.first(where: {$0.name == name}) {
            return thisIngredient.type
        } else {
            return nil
        }
    }
    
 // MARK: - Data storage methods

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
        print(urlRecipe)
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

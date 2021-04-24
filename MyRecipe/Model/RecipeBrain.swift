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
    var ingredients: [Ingredient] = [] {
        didSet {
            writeIngredients()
            broadcastIngredients()
        }
    }
    var delegates = [GetRecipeUpdates]()
    var currentRecipeLine: RecipeLine?
    var currentRecipeLineIndex = 0
    // Note that sections are just integers - let TableView handling headings for each section group
    var currentRecipeSection = 0
    var currentRecipeIndex = -1
    var recipe = Recipe(name: "", qty: 1, notes: "", constraints: [:], ingredientList: [[]], sectionList: [Section(name: "Dough", type: SectionType(rawValue: "Dough")!)]) {
        didSet {
            // Enforce constraints against changes to the recipe
            // Ensure that these adjustments don't break other constraints
            if !recipe.saltOk {
                if recipe.totalSalt == 0 {
                    // salt has been removed - disable the constraint
                    recipe.constraints["salt"] = nil
                } else {
                    // adjust salt to restore constraint
                    let percent = (recipe.totalFlour * recipe.constraints["salt"]! / 100) / recipe.totalSalt
                    for sectionIndex in 0..<getNumberOfSections() {
                        for lineIndex in 0..<getNumberOfRowsInSection(section: sectionIndex) {
                            if recipe.ingredientList[sectionIndex][lineIndex].ingredient.type.salt() > 0 {
                                recipe.ingredientList[sectionIndex][lineIndex].measure.value *= percent
                            }
                        }
                    }
                }
            }
            if !recipe.hydrationOk {
                if recipe.totalFluid == 0 {
                    // fluids have been removed from the recipe - disable the constraint
                    recipe.constraints["hydration"] = nil
                } else {
                    // adjust fluids to restore hydration
                    let newFluid = recipe.constraints["hydration"]! / 100 * recipe.flourWeight - recipe.totalStarterFluid
                    let percent = newFluid / recipe.totalFluid
                    if percent > 0 {
                        for sectionIndex in 0..<getNumberOfSections() {
                            if recipe.sectionList[sectionIndex].type != .Soaker {
                                for lineIndex in 0..<getNumberOfRowsInSection(section: sectionIndex) {
                                    if recipe.ingredientList[sectionIndex][lineIndex].ingredient.type.fluid() > 0 {
                                        recipe.ingredientList[sectionIndex][lineIndex].measure.value *= percent
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if !recipe.innoculationOk {
                let percent = recipe.constraints["innoculation"]! / recipe.totalInnoculation
                func adjustStarter() {
                    for sectionIndex in 0..<getNumberOfSections() {
                        for lineIndex in 0..<getNumberOfRowsInSection(section: sectionIndex) {
                            if recipe.ingredientList[sectionIndex][lineIndex].ingredient.type.rawValue == "Starter" {
                                recipe.ingredientList[sectionIndex][lineIndex].measure.value *= percent
                                return
                            }
                        }
                    }
                    return
                }
                adjustStarter()
            }

            // ensure changes are saved to disk and broadcast to delegates
            saveRecipe()
            writeRecipes()
            broadcastRecipes()
        }
    }
    
    var sampleIngredents = [Ingredient(name: "White Flour", type: .Flour), Ingredient(name: "Water", type: .Fluid), Ingredient(name: "Starter", type: .Starter(hydration: 100))]
    
    
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
        ///Broadcasts ingredient array and current recipe
        broadcastRecipe()
        for delegate in delegates {
            delegate.didChangeRecipes(recipes)
        }
    }
    
 // MARK: - Recipe set/get methods
    func getRecipe(indexPath: IndexPath) -> Recipe {
        return recipes[indexPath.row]
    }
    
    func getRecipeAt(_ row: Int) {
        if row >= 0 {
            currentRecipeIndex = row
            recipe = recipes[row]
            print("get recipe at: \(currentRecipeIndex)")
        }
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
    
    func getSectionType(section: Int) -> SectionType? {
        ///Section is an index
        if recipe.sectionList.count > section {
            return recipe.sectionList[section].type
        } else {
            return nil
        }
    }
    
    func getRecipeName() -> String {
        return recipe.name
    }
    
    func setRecipeName(_ name: String) {
        /// Changes recipe name with passed string. Saves changed recipe.
        recipe.name = name
//        saveRecipe()
    }
    
    func getQty() -> Double {
        return recipe.qty
    }
    
    func setQty(_ qty: Double) {
        recipe.qty = qty
//        saveRecipe()
    }
    
    func getNotes() -> String {
        return recipe.notes
    }
    
    func setNotes(_ notes: String) {
        recipe.notes = notes
//        saveRecipe()
    }
    
    func getTotalWeight() -> Double {
        return recipe.totalDough
    }
    
    func getTotalFlour() -> Double {
        return recipe.totalFlour
    }
    
    func getTotalFluid() -> Double {
        return recipe.totalFluid
    }
    
    func getTotalYeast() -> Double {
        return recipe.totalYeast
    }
    
    func getTotalStarterFluid() -> Double {
        return recipe.totalStarterFluid
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
    }
    
    func getCurrentSection() -> Int {
        return currentRecipeSection
    }
    
    func getSectionList() -> [Section] {
        return recipe.sectionList
    }
    
    func addSection(sectionName: String, sectionType: SectionType.RawValue) {
        /// Adds a new section
        recipe.sectionList.append(Section(name: sectionName, type: SectionType(rawValue: sectionType)!))
        recipe.ingredientList.append([])
//        saveRecipe()
//        broadcastRecipe()
    }
    
    func editSection(section: Int, sectionName: String, sectionType: SectionType.RawValue) -> Int {
        /// Replaces section name and type if already exists. If section index is out of order, returns error code 1.
        if recipe.sectionList.count <= section {
            return 1
        } else {
            recipe.sectionList[section].name = sectionName
            recipe.sectionList[section].type = SectionType(rawValue: sectionType)!
        }
//        saveRecipe()
//        broadcastRecipe()
        return 0
    }
    
    func deleteSection(_ section: Int){
        if recipe.sectionList.count > section {
            recipe.sectionList.remove(at: section)
            recipe.ingredientList.remove(at: section)
//            saveRecipe()
//            broadcastRecipe()
        }
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
//        saveRecipe()
//        broadcastRecipe()
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
//        saveRecipe()
//        broadcastRecipe()
        return 0
    }
    
    func moveRecipeLine(from: IndexPath, to: IndexPath) {
        ///Responds to a drag by user to change order of rows in an ingredient list
        let mover = recipe.ingredientList[from.section].remove(at: from.row)
        recipe.ingredientList[to.section].insert(mover, at: to.row)
//        saveRecipe()
//        broadcastRecipe()
    }

    func deleteRecipeLine(indexPath: IndexPath) {
        ///Deletes the entry in the ingredient list at the specified index. Save the modified recipe and broadcast to delegates.
        if recipe.sectionList.count > indexPath.section {
            if recipe.ingredientList[indexPath.section].count > indexPath.row {
                recipe.ingredientList[indexPath.section].remove(at: indexPath.row)
//                saveRecipe()
//                broadcastRecipe()
            }
        }
    }
    
    func activateConstraint(constraint: String, value: Double) {
        if recipe.totalFlour > 0 {
            switch constraint {
            case "hydration":
                // add water if there are no fluids
                if recipe.totalFluid == 0 {
                    if !ingredients.contains(where: {$0.name == "Water" && $0.type.rawValue == "Fluid"}) {
                        addIngredient(name: "Water", type: "Fluid")
                    }
                    addRecipeLine(section: 0, ingredientName: "Water", quantity: recipe.totalFlour * value / 100, uom: .grams, thisType: .Fluid)
                } else {
                    scaleRecipeHydration(value)
//                    saveRecipe()
                }
            case "innoculation":
                if recipe.totalInnoculation == 0 {
                    addSourdough(percent: value)
                } else {
                    scaleInnoculation(oldInnoculation: recipe.totalInnoculation, newInnoculation: value)
                }
//                saveRecipe()
            case "salt":
                if recipe.totalSalt == 0 {
                    if !ingredients.contains(where: {$0.name == "Salt" && $0.type.rawValue == "Salt"}) {
                        addIngredient(name: "Salt", type: "Salt")
                    }
                    addRecipeLine(section: 0, ingredientName: "Salt", quantity: recipe.totalFlour * value / 100, uom: .grams, thisType: .Salt)
                } else {
                    let percent = (recipe.totalFlour * value / 100) / recipe.totalSalt
                    for sectionIndex in 0..<getNumberOfSections() {
                        for lineIndex in 0..<getNumberOfRowsInSection(section: sectionIndex) {
                            if recipe.ingredientList[sectionIndex][lineIndex].ingredient.type.salt() > 0 {
                                recipe.ingredientList[sectionIndex][lineIndex].measure.value *= percent
                            }
                        }
                    }
//                    saveRecipe()
                }
            default:
                break
            }
        }
        recipe.constraints[constraint] = value
    }

    func deactivateConstraint(_ constraint: String) {
        recipe.constraints[constraint] = nil
//        saveRecipe()
    }
    
    
    func scaleRecipe(_ percent: Double) {
        ///Takes a percent and changes measures for every ingredient line based on percent.
        if percent > 0 {
            for sectionIndex in 0..<getNumberOfSections() {
                for lineIndex in 0..<getNumberOfRowsInSection(section: sectionIndex) {
                    recipe.ingredientList[sectionIndex][lineIndex].measure.value *= percent
                }
            }
//            saveRecipe()
        }
    }
    
    func scaleRecipeHydration(_ newHydration: Double) {
        ///Adjust all fluid ingredients (except starter) to result in new hydration percentage.
        if recipe.constraints["hydration"] ?? 0 > 0 {
            recipe.constraints["hydration"] = newHydration
        }
        
        let newFluid = newHydration / 100 * recipe.flourWeight - recipe.totalStarterFluid
        let percent = newFluid / recipe.totalFluid
        if percent > 0 {
            for sectionIndex in 0..<getNumberOfSections() {
                if recipe.sectionList[sectionIndex].type != .Soaker {
                    for lineIndex in 0..<getNumberOfRowsInSection(section: sectionIndex) {
                        if recipe.ingredientList[sectionIndex][lineIndex].ingredient.type.fluid() > 0 {
                            recipe.ingredientList[sectionIndex][lineIndex].measure.value *= percent
                        }
                    }
                }
            }
        }
    }
    
    func scaleInnoculation(oldInnoculation: Double, newInnoculation: Double) {
        ///Adjusts recipe to desired innoculation % with the constraints that total dough weight and hydration % are unchanged
        if recipe.constraints["innoculation"] ?? 0 > 0 {
            recipe.constraints["innoculation"] = newInnoculation
        }

        //0. Save constraints
        let total = recipe.totalDough
        let hydration = recipe.hydrationPercent
        //1. Adjust starter to new innoculation %
        let percent = newInnoculation / oldInnoculation
        func adjustStarter() {
            for sectionIndex in 0..<getNumberOfSections() {
                for lineIndex in 0..<getNumberOfRowsInSection(section: sectionIndex) {
                    if recipe.ingredientList[sectionIndex][lineIndex].ingredient.type.rawValue == "Starter" {
                        recipe.ingredientList[sectionIndex][lineIndex].measure.value *= percent
                        return
                    }
                }
            }
            return
        }
        adjustStarter()
        //2. Scale back the hydration to constraint value
        scaleRecipeHydration(hydration)
        //3. Scale back the recipe weight to constraint value
        scaleRecipe(total / recipe.totalDough)
    }
    
    func addSourdough(percent: Double){
        ///Adds a new ingredient called "sourdough starter" at 100% hydration with a target innoculation of the parameter and constraints of total weight and hydration %
        //0. Save constraints
        let total = recipe.totalDough
        let hydration = recipe.hydrationPercent
        //1. Add ingredient "Sourdough Starter" if doesn't yet exist
        if !ingredients.contains(where: {$0.name == "Sourdough Starter" && $0.type.rawValue == "Starter"}) {
            addIngredient(name: "Sourdough Starter", type: "Starter")
        }
        //2. Add sourdough starter to the recipe at the passed percentage
        addRecipeLine(section: 0, ingredientName: "Sourdough Starter", quantity: percent / 100 * recipe.totalFlour, uom: .grams, thisType: .Starter(hydration: 100))
        //3. Scale back the hydration to constraint value
        scaleRecipeHydration(hydration)
        //4. Scale back the recipe weight to constraint value
        scaleRecipe(total / recipe.totalDough)
    }
    
    func addTangzhong(percent: Double) {
        ///Adds new ingredients "Tangzhong Flour" and "Tangzhong Water" with a total weight equal to passed percentage of existing total dough weight. Total weight and hydration constraints are maintained. Ratio of flour to water is always 1/5.
        //0. Save constraints and initial values
        let total = recipe.totalDough
        let totalFlour = recipe.totalFlour
        let totalStarterFlour = recipe.totalStarterFlour
        let totalFluid = recipe.totalFluid
        let totalStarterFluid = recipe.totalStarterFluid
        let totalOther = total - totalFlour - totalFluid - totalStarterFlour - totalStarterFluid
        let hydration = recipe.hydrationPercent / 100
        //1. Add ingredients if doesn't yet exist
        if !ingredients.contains(where: {$0.name == "Tangzhong Flour" && $0.type.rawValue == "Flour"}) {
            addIngredient(name: "Tangzhong Flour", type: "Flour")
        }
        if !ingredients.contains(where: {$0.name == "Tangzhong Water" && $0.type.rawValue == "Fluid"}) {
            addIngredient(name: "Tangzhong Water", type: "Fluid")
        }
        //2. Calc Tangzhong ingredients to the recipe at the passed percentage - ratio of fluid to flour is 5 to 1
        let tFlour = percent / 100 * recipe.totalDough / 6
        let tFluid = percent / 100 * recipe.totalDough / 1.2
        //3. Solve two simultaneous equations for p1 and p2 -
        let constant1 = total - tFlour - tFluid - totalStarterFlour - totalStarterFluid
        let constant2 = totalFlour + totalOther
        // p2 = constant1/constant2 - (totalFluid/constant2) * p1
        // Equation 2: (p1 * totalFluid + tFluid + starterFluid) / (p2 * totalFlour + tFlour + starterFlour) = totalFluid / totalFlour
        // substitue result from equation 1 for p2
        let constant3 = (hydration * totalFlour * constant1) / constant2
        let constant4 = hydration * tFlour + hydration * totalStarterFlour - tFluid - totalStarterFluid
        let constant5 = (totalFluid + (hydration * totalFlour * totalFluid) / constant2)
        
        let p1 = (constant3 + constant4) / constant5
        let p2 = constant1 / constant2 - (totalFluid / constant2) * p1
        //4. multiply all fluids by p1 and everything else (except Starter) by p2
        for sectionIndex in 0..<getNumberOfSections() {
            for lineIndex in 0..<getNumberOfRowsInSection(section: sectionIndex) {
                if recipe.ingredientList[sectionIndex][lineIndex].ingredient.type.rawValue != "Starter" {
                    if recipe.ingredientList[sectionIndex][lineIndex].ingredient.type.fluid() > 0  {
                        recipe.ingredientList[sectionIndex][lineIndex].measure.value *= p1
                    } else {
                        recipe.ingredientList[sectionIndex][lineIndex].measure.value *= p2
                    }
                }
            }
        }
        //5. add the Tangzhong ingredients to the recipe
        addRecipeLine(section: 0, ingredientName: "Tangzhong Flour", quantity: tFlour, uom: .grams, thisType: .Flour)
        addRecipeLine(section: 0, ingredientName: "Tangzhong Water", quantity: tFluid, uom: .grams, thisType: .Fluid)
    }

    func saveRecipe() {
        ///Saves the current recipe in the recipes array at the currentrecipeindex. If index is -1 appends unless recipe.name is empty. Broadcasts new array.
        print("Save recipe at: \(currentRecipeIndex)")
        if currentRecipeIndex == -1 {
            if !recipe.name.isEmpty {
                recipes.append(recipe)
                currentRecipeIndex = recipes.count - 1
            }
        } else {
            recipes[currentRecipeIndex] = recipe
        }
//        writeRecipe()
        writeRecipes()
        broadcastRecipes()
    }
        
    func newRecipe() {
        /// Creates an empty recipe object. Sets currentRecipeIndex to -1 to indicate current recipe is not in recipes array.
        currentRecipeIndex = -1
        recipe = Recipe(name: "", qty: 1, notes: "", constraints: [:], ingredientList: [[]], sectionList: [Section(name: "Dough", type: SectionType(rawValue: "Dough")!)])
        broadcastRecipe()
    }
    
    func deleteRecipe() {
        /// Deletes the current recipe from the recipes array and retrieves the last recipe or if none, a new empty recipe
        if !recipes.isEmpty {
            print("Delete recipe at: \(currentRecipeIndex)")
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
//        writeIngredients()
//        broadcastIngredients()
    }
    
    func editIngredient(index: Int, name: String, type: IngredientType.RawValue) {
        if index < ingredients.count {
            ingredients[index].name = name
            ingredients[index].type = IngredientType(rawValue: type)!
//            writeIngredients()
//            broadcastIngredients()
        }
    }
    
    func deleteIngredient(index: Int) {
        if index < ingredients.count {
            ingredients.remove(at: index)
//            writeIngredients()
//            broadcastIngredients()
        }
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
    
//    func writeRecipe() {
//        ///Write recipe object to disk
//        let encoder = PropertyListEncoder()
//        do {
//            let data = try encoder.encode(recipe)
//            try data.write(to: urlRecipe!)
//        } catch {
//            print("Error encoding current recipe, \(error)")
//        }
//    }
    
    func writeRecipes() {
        ///Write recipes array to disk
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(recipes)
            try data.write(to: urlRecipes!)
        } catch {
            print("Error encoding ingredients array, \(error)")
        }
        writeCurrentRecipeIndex()
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
//                if ingredients.count == 0 {
//                    ingredients = sampleIngredents
//                }
            } catch {
                print("Error decoding ingredients array \(error)")
            }
        }
    }
    
//    func loadRecipe() {
//        ///Reads current recipe from disk
//        if let data = try? Data(contentsOf: urlRecipe!) {
//            let decoder = PropertyListDecoder()
//            do {
//                recipe = try decoder.decode(Recipe.self, from: data)
//            } catch {
//                print("Error decoding current recipe \(error)")
//            }
//        }
//    }

    func loadRecipes() {
        ///Reads recipes array from disk
        print(urlRecipe)
        if let data = try? Data(contentsOf: urlRecipes!) {
            let decoder = PropertyListDecoder()
            do {
                recipes = try decoder.decode([Recipe].self, from: data)
                if recipes.count == 0 {
                    currentRecipeIndex = -1
                } else {
                    // load currentRecipeIndex
                    if let data = defaults.integer(forKey: "CurrentRecipeIndex") as Int? {
                        if data < recipes.count {
                            currentRecipeIndex = data
                        } else {
                            currentRecipeIndex = recipes.count - 1
                        }
                    } else {
                        currentRecipeIndex = -1
                    }
                }
            } catch {
                print("Error decoding current recipe \(error)")
            }
            getRecipeAt(currentRecipeIndex)
        }
    }
    
}

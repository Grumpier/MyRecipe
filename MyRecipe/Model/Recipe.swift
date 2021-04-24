//
//  Recipes.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import Foundation

//protocol recipeDelegate {
//    func didChangeRecipe()
//}

struct Recipe: Codable {
//    var delegate: recipeDelegate?
    var name: String
    var qty: Double
    var notes: String
    var constraints: [String: Double]
    var ingredientList: [[RecipeLine]] 
    var sectionList: [Section]
    
    var totalDough: Double {
        let ingredients = ingredientList.flatMap{$0}
        let values = ingredients.map{$0.measure.converted(to: .grams).value}
        return values.reduce(0, +)
    }
    
    // NOT NECESSARY TO TRAP FOR STARTER SINCE HYDRATION IS A METHOD OF ALL CASES!
    var totalStarterFlour: Double {
        /// Flour weight of the starter is total weight / (1 + hydration)
        let ingredients = ingredientList.flatMap{$0}
        let starter = ingredients.filter{$0.ingredient.type.rawValue == "Starter"}
        let flour = starter.map{$0.measure.converted(to: .grams).value / (1 + Double($0.ingredient.type.hydration()) / 100)}
        return flour.reduce(0, +)
    }
    
    var totalStarterFluid: Double {
        /// Fluid weight of the starter is total weight / (1 + 1 / hydration)
        let ingredients = ingredientList.flatMap{$0}
        let starter = ingredients.filter{$0.ingredient.type.rawValue == "Starter"}
        let fluid = starter.map{$0.measure.converted(to: .grams).value / (1 + 1 / (Double($0.ingredient.type.hydration()) / 100))}
        return fluid.reduce(0, +)
    }
    

    var totalFlour: Double {
        let ingredients = ingredientList.flatMap{$0}
        let flour = ingredients.filter{$0.ingredient.type == .Flour}
        let values = flour.map{$0.measure.converted(to: .grams).value}
        return values.reduce(0, +)
    }
    
    var flourWeight: Double {
        return totalFlour + totalStarterFlour
    }
        
    var totalFluid: Double {
        ///Does not include fluid from starter. Also exclude fluids in a Soaker section
        // 1. Get indexes of all sections that are not soakers
        let notSoakers = sectionList.indices.filter({ sectionList[$0].type != SectionType.Soaker })
        // 2. Create new flattened array of nonsoaker sections
        let ingredients = ingredientList.enumerated().filter( {notSoakers.contains($0.offset)} ).map( {$0.element} ).flatMap{$0}
        let values = ingredients.map{$0.measure.converted(to: .grams).value * $0.ingredient.type.fluid()}
        return values.reduce(0, +)
    }

    var starterPercent: Double {
        return Double(flourWeight > 0 ? Int(round(100 * (totalStarterFlour / flourWeight))) : 0)
    }

    var hydrationPercent: Double {
        return Double(flourWeight > 0 ? Int(round(100 * ((totalFluid + totalStarterFluid) / flourWeight))) : 0)
    }
    
    var totalInnoculation: Double {
        return Double(totalFlour > 0 ? Int(round(100 * (totalStarterFlour + totalStarterFluid) / totalFlour)) : 0)
    }
    
    var totalSalt: Double {
        let ingredients = ingredientList.flatMap{$0}
        let values = ingredients.map{$0.measure.converted(to: .grams).value * $0.ingredient.type.salt()}
        return values.reduce(0, +)
    }

    var totalYeast: Double {
        let ingredients = ingredientList.flatMap{$0}
        let yeast = ingredients.filter{$0.ingredient.type == .Yeast}
        let values = yeast.map{$0.measure.converted(to: .grams).value}
        return values.reduce(0, +)
    }

    var totalFat: Double {
        let ingredients = ingredientList.flatMap{$0}
        let values = ingredients.map{$0.measure.converted(to: .grams).value * $0.ingredient.type.fat()}
        return values.reduce(0, +)
    }

    var totalSugar: Double {
        let ingredients = ingredientList.flatMap{$0}
        let sugar = ingredients.filter{$0.ingredient.type == .Sugar}
        let values = sugar.map{$0.measure.converted(to: .grams).value}
        return values.reduce(0, +)
    }
    
    var hydrationOk: Bool {
        if constraints["hydration"] != nil {
            return hydrationPercent == constraints["hydration"]
        } else {
            return true
        }
    }

    var innoculationOk: Bool {
        if constraints["innoculation"] != nil {
            return totalInnoculation == constraints["innoculation"]
        } else {
            return true
        }
    }

    var saltOk: Bool {
        if constraints["salt"] != nil {
            return totalSalt / totalFlour == constraints["salt"]
        } else {
            return true
        }
    }

    init(name: String, qty: Double, notes: String, constraints: [String: Double], ingredientList: [[RecipeLine]], sectionList: [Section]) {
        self.name = name
        self.qty = qty
        self.notes = notes
        self.constraints = constraints
        self.ingredientList = ingredientList
        self.sectionList = sectionList
    }
}

struct RecipeLine: Codable {
    var ingredient: Ingredient
    var measure: Measurement<UnitMass>
    
    init(ingredient: Ingredient, measure: Measurement<UnitMass>) {
        self.ingredient = ingredient
        self.measure = measure
    }
    
}

struct Section: Codable {
    var name: String
    var type: SectionType
}

    
    

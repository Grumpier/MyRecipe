//
//  Recipes.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import Foundation

struct Recipe: Codable {
    var name: String
    var qty: Double
    var notes: String
    var ingredientList: [[RecipeLine]]
    var sectionList: [Section]
    
    var totalDough: Double {
        let ingredients = ingredientList.flatMap{$0}
        let values = ingredients.map{$0.measure.converted(to: .grams).value}
        return values.reduce(0, +)
    }
    
    var totalStarterFlour: Double {
        /// Flour weight of the starter is total weight / (1 + hydration)
        let ingredients = ingredientList.flatMap{$0}
        let starter = ingredients.filter{$0.ingredient.type.rawValue == "Starter"}
        let flour = starter.map{$0.measure.converted(to: .grams).value / (1 + Double($0.ingredient.type.hydration()!) / 100)}
        return flour.reduce(0, +)
    }
    
    var totalStarterFluid: Double {
        /// Fluid weight of the starter is total weight / (1 + 1 / hydration)
        let ingredients = ingredientList.flatMap{$0}
        let starter = ingredients.filter{$0.ingredient.type.rawValue == "Starter"}
        let fluid = starter.map{$0.measure.converted(to: .grams).value / (1 + 1 / (Double($0.ingredient.type.hydration()!) / 100))}
        return fluid.reduce(0, +)
    }

    var totalFlour: Double {
        let ingredients = ingredientList.flatMap{$0}
        let flour = ingredients.filter{$0.ingredient.type == .Flour}
        let values = flour.map{$0.measure.converted(to: .grams).value}
        return values.reduce(0, +)
    }
        
    var totalFluid: Double {
        let ingredients = ingredientList.flatMap{$0}
        let fluid = ingredients.filter{$0.ingredient.type == .Fluid}
        let values = fluid.map{$0.measure.converted(to: .grams).value}
        return values.reduce(0, +)
    }
    
    var totalSalt: Double {
        let ingredients = ingredientList.flatMap{$0}
        let salt = ingredients.filter{$0.ingredient.type == .Salt}
        let values = salt.map{$0.measure.converted(to: .grams).value}
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
        let fat = ingredients.filter{$0.ingredient.type == .Fat}
        let values = fat.map{$0.measure.converted(to: .grams).value}
        return values.reduce(0, +)
    }

    var totalSugar: Double {
        let ingredients = ingredientList.flatMap{$0}
        let sugar = ingredients.filter{$0.ingredient.type == .Sugar}
        let values = sugar.map{$0.measure.converted(to: .grams).value}
        return values.reduce(0, +)
    }

    init(name: String, qty: Double, notes: String, ingredientList: [[RecipeLine]], sectionList: [Section]) {
        self.name = name
        self.qty = qty
        self.notes = notes
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

    
    

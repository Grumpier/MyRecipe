//
//  Enumerators.swift
//  MyRecipe
//
//  Created by Steven Manus on 03/03/21.
//

import Foundation

enum UOM: String, CaseIterable {
    case kilograms
    case grams
    case pounds
    case ounces
}

extension UOM: RawRepresentable {
    typealias RawValue = Dimension

    init?(rawValue: RawValue) {
        switch rawValue {
        case UnitMass.kilograms: self = .kilograms
        case UnitMass.grams: self = .grams
        case UnitMass.pounds: self = .pounds
        case UnitMass.ounces: self = .ounces
        default: return nil
        }
    }

    var rawValue: RawValue {
        switch self {
        case .kilograms: return UnitMass.kilograms
        case .grams: return UnitMass.grams
        case .pounds: return UnitMass.pounds
        case .ounces: return UnitMass.ounces
        }
    }
}


// use associated values to control how this ingredient type affects various totals
enum IngredientType {
    case Flour
    case Fluid
    case Starter(hydration: Int)
    case Salt
    case Yeast
    case Fat
    case Sugar
    case Dairy(type: DairyItem = DairyType.whole.defaults())
    case Egg(type: EggType)
    case Miscellaneous
    case OtherExtras
    
    func hydration() -> Int {
      switch self {
      case .Starter(let value):
        return value
      default:
        return 0
      }
    }

    func fluid() -> Double {
        switch self {
        case .Fluid:
            return 1.0
        case .Egg(let value):
            return value.fluid
        case .Dairy(let value):
            return value.hydration / 100
        default:
            return 0.0
        }
    }
    
    func fat() -> Double {
      switch self {
      case .Fat:
        return 1.0
      case .Egg(let value):
        return value.fat
      case .Dairy(let value):
        return value.fat / 100
      default:
        return 0.0
      }
    }
    
    func salt() -> Double {
        switch self {
        case .Salt:
            return 1.0
        case .Dairy(let value):
            return value.salt / 100
        default:
            return 0.0
        }
    }

}

extension IngredientType: Codable {

    private enum CodingKeys: String, CodingKey {
        case Flour
        case Fluid
        case Starter
        case Salt
        case Yeast
        case Fat
        case Sugar
        case Dairy
        case Egg
        case Miscellaneous
        case OtherExtras
    }

    enum IngredientTypeCodingError: Error {
        case decoding(String)
    }

    // THERE MUST BE A WAY TO GLOBALLY CATCH ALL OTHER VALUES BUT I CAN'T FIND IT
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(Int.self, forKey: .Starter) {
            self = .Starter(hydration: value)
            return
        }
        if (try? values.decode(String.self, forKey: .Flour)) != nil {
            self = .Flour
            return
        }
        if (try? values.decode(String.self, forKey: .Fluid)) != nil {
            self = .Fluid
            return
        }
        if (try? values.decode(String.self, forKey: .Salt)) != nil {
            self = .Salt
            return
        }
        if (try? values.decode(String.self, forKey: .Yeast)) != nil {
            self = .Yeast
            return
        }
        if (try? values.decode(String.self, forKey: .Fat)) != nil {
            self = .Fat
            return
        }
        if (try? values.decode(String.self, forKey: .Sugar)) != nil {
            self = .Sugar
            return
        }
        if let value = try? values.decode(DairyItem.self, forKey: .Dairy) {
            self = .Dairy(type: value)
            return
        }
        if let value = try? values.decode(EggType.self, forKey: .Egg) {
            self = .Egg(type: value)
            return
        }
        if (try? values.decode(String.self, forKey: .Miscellaneous)) != nil {
            self = .Miscellaneous
            return
        }
        if (try? values.decode(String.self, forKey: .OtherExtras)) != nil {
            self = .OtherExtras
            return
        }

        throw IngredientTypeCodingError.decoding("Whoops! \(dump(values))")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .Starter(let hydration):
            try container.encode(hydration, forKey: .Starter)
        case .Egg(let type):
            try container.encode(type, forKey: .Egg)
        case .Dairy(let type):
            try container.encode(type, forKey: .Dairy)
        default:
            try container.encode("", forKey: IngredientType.CodingKeys(rawValue: self.rawValue)!)
        }
    }
}

extension IngredientType: RawRepresentable {
    init?(rawValue: String) {
        switch rawValue {
        case "Flour": self = .Flour
        case "Fluid": self = .Fluid
        case "Starter": self = .Starter(hydration: 100)
        case "Salt": self = .Salt
        case "Yeast": self = .Yeast
        case "Fat": self = .Fat
        case "Sugar": self = .Sugar
        case "Dairy": self = .Dairy(type: DairyType.whole.defaults())
        case "Egg": self = .Egg(type: .whole)
        case "Miscellaneous": self = .Miscellaneous
        case "OtherExtras": self = .OtherExtras
        default: self = .Miscellaneous
        }
    }
        
    var rawValue: String {
        switch self {
        case .Flour: return "Flour"
        case .Fluid: return "Fluid"
        case .Starter: return "Starter"
        case .Salt: return "Salt"
        case .Yeast: return "Yeast"
        case .Fat: return "Fat"
        case .Sugar: return "Sugar"
        case .Dairy: return "Dairy"
        case .Egg: return "Egg"
        case .Miscellaneous: return "Miscellaneous"
        case .OtherExtras: return "OtherExtras"
        }
    }
}

extension IngredientType: CaseIterable {
    static var allCases: [IngredientType] = [Flour, Fluid, Starter(hydration: 100), Salt, Yeast, Fat, Sugar, Dairy(type: DairyType.whole.defaults()), Egg(type: .whole), Miscellaneous, OtherExtras]
}


enum EggType: String, CaseIterable, Codable {
    case whole
    case yolk
    case white

    var fat: Double {
        switch self {
        case .whole: return 0.11
        case .yolk: return 0.33
        case .white: return 0.0
        }
    }
    
    var fluid: Double {
        switch self {
        case .whole: return 0.75
        case .yolk: return 0.49
        case .white: return 0.89
        }
    }
}

enum DairyType: String, CaseIterable {
    case skim01 = "Skim milk (0.1%)"
    case skim03 = "Skim milk (0.3%)"
    case skim05 = "Skim milk (0.5%)"
    case low = "Low fat milk (1.0%)"
    case reduced = "Reduced fat milk (2.0%)"
    case whole = "Whole milk (3.5%)"
    case cream09 = "Cream (9%)"
    case cream12 = "Cream (12%)"
    case cream20 = "Cream (20%)"
    case cream33 = "Cream (33%)"
    case cream38 = "Cream (38%)"
    case cream50 = "Cream (50%)"
    case yogurt36 = "Yoghurt (3.6%)"
    case yoghurt = "Yoghurt (0.1%)"
    case butterSalt = "Butter, salted"
    case butter = "Butter, unsalted"
    case undefined = "undefined"

    
    func defaults() -> DairyItem {
        switch self {
        case .skim01:
            return DairyItem(name: self.rawValue, protein: 3.5, fat: 0.1, carbs: 4.7, ash: 0.7, salt: 0.0)
        case .skim03:
            return DairyItem(name: self.rawValue, protein: 3.5, fat: 0.3, carbs: 4.7, ash: 0.7, salt: 0.0)
        case .skim05:
            return DairyItem(name: self.rawValue, protein: 3.5, fat: 0.5, carbs: 4.7, ash: 0.7, salt: 0.0)
        case .low:
            return DairyItem(name: self.rawValue, protein: 3.5, fat: 1.0, carbs: 4.9, ash: 0.7, salt: 0.0)
        case .reduced:
            return DairyItem(name: self.rawValue, protein: 3.5, fat: 2.0, carbs: 4.9, ash: 0.7, salt: 0.0)
        case .whole:
            return DairyItem(name: self.rawValue, protein: 3.5, fat: 3.5, carbs: 4.8, ash: 0.7, salt: 0.0)
        case .cream09:
            return DairyItem(name: self.rawValue, protein: 2.1, fat: 9.0, carbs: 3.2, ash: 0.5, salt: 0.0)
        case .cream12:
            return DairyItem(name: self.rawValue, protein: 2.1, fat: 12.0, carbs: 3.2, ash: 0.5, salt: 0.0)
        case .cream20:
            return DairyItem(name: self.rawValue, protein: 2.1, fat: 20.0, carbs: 3.2, ash: 0.5, salt: 0.0)
        case .cream33:
            return DairyItem(name: self.rawValue, protein: 2.1, fat: 33.0, carbs: 3.2, ash: 0.5, salt: 0.0)
        case .cream38:
            return DairyItem(name: self.rawValue, protein: 2.1, fat: 38.0, carbs: 3.2, ash: 0.5, salt: 0.0)
        case .cream50:
            return DairyItem(name: self.rawValue, protein: 2.1, fat: 50.0, carbs: 3.2, ash: 0.5, salt: 0.0)
        case .yogurt36:
            return DairyItem(name: self.rawValue, protein: 3.8, fat: 3.6, carbs: 3.8, ash: 0.8, salt: 0.0)
        case .yoghurt:
            return DairyItem(name: self.rawValue, protein: 3.8, fat: 0.1, carbs: 3.8, ash: 0.8, salt: 0.0)
        case .butterSalt:
            return DairyItem(name: self.rawValue, protein: 0.5, fat: 81.4, carbs: 0.6, ash: 1.0, salt: 1.2)
        case .butter:
            return DairyItem(name: self.rawValue, protein: 0.5, fat: 81.4, carbs: 0.6, ash: 1.0, salt: 0.0)
        case .undefined:
            return DairyItem(name: "undefined", protein: 0.0, fat: 0.0, carbs: 0.0, ash: 0.0, salt: 0.0)
        }
    }
}


enum SectionType: String, Codable, CaseIterable {
    case Dough
    case PreFerment
    case Soaker
    case Miscellaneous
}

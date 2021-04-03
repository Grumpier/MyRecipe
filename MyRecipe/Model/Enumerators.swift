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
    case Dairy
    case Egg(type: EggType)
    case Miscellaneous
    case Other_extras
    
    func hydration() -> Int? {
      switch self {
      case .Starter(let value):
        return value
      default:
        return nil
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
        case Other_extras
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
        if (try? values.decode(String.self, forKey: .Dairy)) != nil {
            self = .Dairy
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
        if (try? values.decode(String.self, forKey: .Other_extras)) != nil {
            self = .Other_extras
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
        case "Dairy": self = .Dairy
        case "Egg": self = .Egg(type: .whole)
        case "Miscellaneous": self = .Miscellaneous
        case "Other extras" : self = .Other_extras
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
        case .Other_extras: return "Other extras"
        }
    }
}

extension IngredientType: CaseIterable {
    static var allCases: [IngredientType] = [Flour, Fluid, Starter(hydration: 100), Salt, Yeast, Fat, Sugar, Dairy, Egg(type: .whole), Miscellaneous, Other_extras]
}


enum EggType: Int, CaseIterable, Codable {
    /// Maps type of egg to the fat content as a percent
    case whole = 2
    case yolk = 3
    case white = 1
    
    var name: String {
        switch self {
        case .whole: return "whole"
        case .yolk: return "yolk"
        case .white: return "white"
        }
    }
        
}

enum SectionType: String, Codable, CaseIterable {
    case Dough
    case PreFerment
    case Soaker
    case Miscellaneous
}

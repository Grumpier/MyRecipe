//
//  UOM.swift
//  MyRecipe
//
//  Created by Steven Manus on 03/03/21.
//

import Foundation

enum UOM: String, CaseIterable {
    case kilograms
    case grams
    case liters
    case milliliters
    case quarts
    case cups
    case pounds
}

extension UOM: RawRepresentable {
    typealias RawValue = Dimension

    init?(rawValue: RawValue) {
        switch rawValue {
        case UnitMass.kilograms: self = .kilograms
        case UnitMass.grams: self = .grams
        case UnitVolume.liters: self = .liters
        case UnitVolume.milliliters: self = .milliliters
        case UnitVolume.quarts: self = .quarts
        case UnitVolume.cups: self = .cups
        case UnitMass.pounds: self = .pounds
        default: return nil
        }
    }

    var rawValue: RawValue {
        switch self {
        case .kilograms: return UnitMass.kilograms
        case .grams: return UnitMass.grams
        case .liters: return UnitVolume.liters
        case .milliliters: return UnitVolume.milliliters
        case .quarts: return UnitVolume.quarts
        case .cups: return UnitVolume.cups
        case .pounds: return UnitMass.pounds
        }
    }
}

//
//  ReusableIdentifier.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import Foundation

protocol ReusableIdentifier: class {
    static var reuseIdentifier: String { get }
}

extension ReusableIdentifier {
    static var reuseIdentifier: String {
        return "\(self)"
    }
}

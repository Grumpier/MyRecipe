//
//  ConfigurableCell.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import Foundation

protocol ConfigurableCell {
    associatedtype Object1
    associatedtype Object2
    func configure(object1: Object1, object2: Object2)
}

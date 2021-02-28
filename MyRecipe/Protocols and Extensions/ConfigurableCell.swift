//
//  ConfigurableCell.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import Foundation

protocol ConfigurableCell {
    associatedtype Object
    func configure(object: Object)
}

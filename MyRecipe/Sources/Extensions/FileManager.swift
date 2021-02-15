//
//  FileManager.swift
//  MyRecipe
//
//  Created by Steven Manus on 04/02/21.
//

import Foundation

// directory to hold our files
public extension FileManager {
    static var documentDirectoryURL: URL {self.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

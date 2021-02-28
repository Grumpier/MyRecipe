//
//  IngredientListTableViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import UIKit

protocol IngredientProviderDelegate: AnyObject {
    func didSelectLocation(_ ingredient: Ingredient)
}

class IngredientListTableViewController: UITableViewController, RecipeUpdateDelegate {
    
    weak var delegate: IngredientProviderDelegate?
    private var ingredientListDataSource: IngredientListDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.delegate = self

        // this instantiates the data source object for this tableview and provides the data source with the path to find the data
        ingredientListDataSource = IngredientListDataSource(tableView: tableView)
    }

    func didChangeRecipe(_ recipe: Recipe) {
        // pass it on....
        ingredientListDataSource?.didChangeRecipe(recipe)
    }

    
}

    


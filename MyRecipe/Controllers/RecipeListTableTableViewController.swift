//
//  RecipeListTableTableViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 07/03/21.
//

import UIKit

class RecipeListTableTableViewController: UITableViewController, GetRecipeUpdates {

    let recipeBrain = RecipeBrain.singleton
    var recipes: [Recipe] = []
    var selectedRow = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipes = recipeBrain.recipes
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()

    }
    
    // MARK: - GetRecipeUpdates
    func didChangeRecipes(_ recipes: [Recipe]) {
        self.recipes = recipes
    }

    // MARK: - Table view data source and delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipesCell", for: indexPath)
        cell.textLabel?.text = recipes[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        recipeBrain.getRecipeAt(selectedRow)
        self.dismiss(animated: true, completion: nil)
    }

}

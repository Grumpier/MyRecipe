//
//  IngredientListTableViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import UIKit

protocol IngredientProviderDelegate: AnyObject {
    func didSelectRecipeLine(_ recipeLine: RecipeLine)
    func wantsToAddRecipeLine()
}

class IngredientListTableViewController: UITableViewController {
    
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
    
    // checks the location of the selected row and sends it to any of its delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let recipeLine = ingredientListDataSource?.recipeLineAtIndexPath(indexPath) {
            delegate?.didSelectRecipeLine(recipeLine)
        }
    }

    
    @IBAction func addIngredientPressed(_ sender: UIButton) {
        print("button pressed")
        delegate?.wantsToAddRecipeLine()
    }

    @IBAction func addSectionPressed(_ sender: UIButton) {
    }
}

    


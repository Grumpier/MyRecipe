//
//  IngredientListTableViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 28/02/21.
//

import UIKit

protocol IngredientProviderDelegate: AnyObject {
    func wantsToAddRecipeLine()
    func wantsToEditRecipeLine()
}

class IngredientListTableViewController: UITableViewController {
    
    weak var delegate: IngredientProviderDelegate?
    private var ingredientListDataSource: IngredientListDataSource?
    var recipeBrain = RecipeBrain.singleton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.delegate = self

        // this instantiates the data source object for this tableview and provides the data source with the path to find the data
        ingredientListDataSource = IngredientListDataSource(tableView: tableView)
    }
    
//    @IBAction func addIngredientPressed(_ sender: UIButton) {
//        delegate?.wantsToAddRecipeLine()
//    }

    @IBAction func addSectionPressed(_ sender: UIButton) {
    }
    
    func performDelete(_ indexPath: IndexPath) {
        let thisRecipeLine = recipeBrain.getRecipeLine(indexPath: indexPath)
        let thisIngredient = thisRecipeLine.ingredient.name
        let thisQuantity = String(format: "%.3f", thisRecipeLine.measure.value)
        let thisUOM = thisRecipeLine.measure.unit.symbol
        alertOkCancel(title: "Delete this recipe line?", message: thisIngredient + " - " + thisQuantity + thisUOM, indexPath: indexPath)
    }

    func performEdit(_ indexPath: IndexPath) {
        recipeBrain.setCurrentRecipeLine(indexPath: indexPath)
        print("edit button pressed")
        delegate?.wantsToEditRecipeLine()
    }
    
    // confirm delete line
    func alertOkCancel(title: String, message: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.recipeBrain.deleteRecipeLine(indexPath.row)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        present(alert, animated: true, completion: nil)
    }


 // MARK: - Tableview Delegate methods
    override func tableView(_ tableView: UITableView,
                            contextMenuConfigurationForRowAt indexPath: IndexPath,
                            point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: {
                                           suggestedActions in
            let deleteAction = UIAction(title: NSLocalizedString("Delete this line", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { action in self.performDelete(indexPath)}
            let editAction = UIAction(title: NSLocalizedString("Edit this line", comment: ""), image: UIImage(systemName: "pencil"), attributes: .destructive) {action in
                self.performEdit(indexPath)}
            return UIMenu(title: "", children: [deleteAction, editAction])
        })
    }

}

    


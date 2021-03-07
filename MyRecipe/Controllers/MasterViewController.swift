//
//  ViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import UIKit


class MasterViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate {

    @IBOutlet weak var fullScreenStack: UIStackView!
    @IBOutlet weak var rightScreenStack: UIStackView!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // ADD A PREPARE FOR SEGUE FOR SEGUE BASED ON EDIT
    var recipeLineAddMode = 0 // used to track whether recipe line controller is adding or editing lines
    private var ingredientListDataSource: IngredientListDataSource?

    let recipeBrain = RecipeBrain.singleton

    override func viewDidLoad() {
        super.viewDidLoad()
        // instantiate RecipeBrain and force broadcast
        recipeBrain.loadRecipe()
        recipeBrain.loadIngredients()
        recipeBrain.loadRecipes()
        recipeBrain.broadcastRecipe()
        
        // Delegates
//        tableView.delegate = self
        recipeName.delegate = self
        
        // this instantiates the data source object for this tableview and provides the data source with the path to find the data
        ingredientListDataSource = IngredientListDataSource(tableView: tableView)

        // Place recipe name into label
        recipeName.text = recipeBrain.getRecipeName()
    }

    
    private func addContentController(_ child: UIViewController, to stackView: UIStackView) {
        addChild(child) // adds the specified view controller to the current view
        stackView.addArrangedSubview(child.view) // adds the container to the stack
        child.didMove(toParent: self) // required after adding the child to the parent
    }

    private func removeContentController(_ child: UIViewController, from stackView: UIStackView) {
        if self.children.contains(child) {
            child.willMove(toParent: nil)
            stackView.removeArrangedSubview(child.view)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }


//    private func axisForSize(_ size: CGSize) -> NSLayoutConstraint.Axis {
//        return size.width > size.height ? .horizontal : .vertical
//    }
    
    private func buildFromStoryboard<T>(_ name: String) -> T {
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let identifier = String(describing: T.self)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError("Missing \(identifier) in Storyboard")
        }
        return viewController
    }
    
    
    @IBAction func addRecipe(_ sender: UIBarButtonItem) {
//        // clear the recipe label and have RecipeBrain broadcast an empty recipe to child controllers
        recipeName.text = ""
        recipeName.isSelected = true
        recipeBrain.newRecipe()
    }
    
     // MARK: - RecipeNameTextField functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let alert = UIAlertController(title: "Save recipe name?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.recipeBrain.setRecipeName(textField.text ?? self.recipeBrain.getRecipeName())
            print(self.recipeBrain.recipe.name)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            textField.text = self.recipeBrain.getRecipeName()
            print(self.recipeBrain.recipe.name)
        }))
        present(alert, animated: true, completion: nil)
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let alert = UIAlertController(title: "Save recipe name?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.recipeBrain.setRecipeName(textField.text ?? self.recipeBrain.getRecipeName())
            print(self.recipeBrain.recipe.name)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            textField.text = self.recipeBrain.getRecipeName()
            print(self.recipeBrain.recipe.name)
        }))
        present(alert, animated: true, completion: nil)
        return true
    }
    
     // MARK: - IngredientListTableView Functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row \(indexPath.row) selected")
    }
    
    
    func tableView(_ tableView: UITableView,
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
//        delegate?.wantsToEditRecipeLine()
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

}

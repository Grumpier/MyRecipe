//
//  ViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import UIKit


class MasterViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, GetRecipeUpdates {

    @IBOutlet weak var fullScreenStack: UIStackView!
    @IBOutlet weak var rightScreenStack: UIStackView!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var recipeLineAddMode = 0 // used to track whether recipe line controller is adding or editing lines
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
        tableView.delegate = self
        recipeName.delegate = self
        recipeBrain.addDelegate(self)
        
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

//    private func removeContentController(_ child: UIViewController, from stackView: UIStackView) {
//        if self.children.contains(child) {
//            child.willMove(toParent: nil)
//            stackView.removeArrangedSubview(child.view)
//            child.view.removeFromSuperview()
//            child.removeFromParent()
//        }
//    }
//
//    private func buildFromStoryboard<T>(_ name: String) -> T {
//        let storyboard = UIStoryboard(name: name, bundle: nil)
//        let identifier = String(describing: T.self)
//        guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
//            fatalError("Missing \(identifier) in Storyboard")
//        }
//        return viewController
//    }
//
//
//    @IBAction func addRecipe(_ sender: UIBarButtonItem) {
////        // clear the recipe label and have RecipeBrain broadcast an empty recipe to child controllers
//        recipeName.text = ""
//        recipeName.isSelected = true
//        recipeBrain.newRecipe()
//    }
    
     // MARK: - RecipeNameTextField functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                self.recipeBrain.setRecipeName(textField.text ?? self.recipeBrain.getRecipeName())
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
                self.recipeBrain.setRecipeName(textField.text ?? self.recipeBrain.getRecipeName())
        return true
    }
    
     // MARK: - IngredientListTableView Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell")
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                            contextMenuConfigurationForRowAt indexPath: IndexPath,
                            point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: {
            suggestedActions in
            let deleteAction = UIAction(title: NSLocalizedString("Delete this line", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { action in self.performDelete(indexPath: indexPath)}
            let editAction = UIAction(title: NSLocalizedString("Edit this line", comment: ""), image: UIImage(systemName: "pencil"), attributes: .destructive) {action in
                self.performEdit(indexPath)}
            return UIMenu(title: "", children: [deleteAction, editAction])
        })
    }
    
    func performDelete(indexPath: IndexPath) {
        let thisRecipeLine = recipeBrain.getRecipeLine(indexPath: indexPath)
        let thisIngredient = thisRecipeLine!.ingredient.name
        let thisQuantity = String(format: "%.3f", thisRecipeLine!.measure.value)
        let thisUOM = thisRecipeLine!.measure.unit.symbol
        alertOkCancel(title: "Delete this recipe line?", message: thisIngredient + " - " + thisQuantity + thisUOM, indexPath: indexPath)
    }

    func performEdit(_ indexPath: IndexPath) {
        recipeBrain.setCurrentRecipeLine(indexPath: indexPath)
        performSegue(withIdentifier: "RecipeLineSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecipeLineSegue" {
            recipeName.resignFirstResponder()
            let destinationVC = segue.destination as! RecipeLineController
            if sender as! NSObject == self {
                destinationVC.setAddMode(1)
            } else {
                destinationVC.setAddMode(0)
            }
        }
    }
            
    // confirm delete line
    func alertOkCancel(title: String, message: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.recipeBrain.deleteRecipeLine(indexPath: indexPath)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        present(alert, animated: true, completion: nil)
    }
    
     // MARK: - GetRecipeUpdates Delegate
    func didChangeRecipe(_ recipe: Recipe) {
        tableView.reloadData()
    }
}

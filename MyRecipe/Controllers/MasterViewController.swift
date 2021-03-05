//
//  ViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import UIKit


class MasterViewController: UIViewController {

    @IBOutlet weak var fullScreenStack: UIStackView!
    @IBOutlet weak var leftScreenStack: UIStackView!
    @IBOutlet weak var rightScreenStack: UIStackView!
    
    // MODIFY THIS SO THAT IT HAS CORRECT CONSTRAINTS???
    var leftStackOverlay = UIStackView(frame: CGRect(x: 100, y: 230, width: 400, height: 400))
    var recipeLineAddMode = 0 // used to track whether recipe line controller is adding or editing lines
    
    lazy var ingredientListTableViewController: IngredientListTableViewController = self.buildFromStoryboard("Main")
    lazy var addRecipeLineController: RecipeLineController = self.buildFromStoryboard("Main")
    lazy var editRecipeLineController: RecipeLineController = self.buildFromStoryboard("Main")

    @IBOutlet weak var recipeName: UITextField!
    let recipeBrain = RecipeBrain.singleton

    override func viewDidLoad() {
        super.viewDidLoad()
        addContentController(ingredientListTableViewController, to: leftScreenStack)

        // instantiate RecipeBrain and force broadcast
        recipeBrain.broadcastRecipe()

        // assign the current controller as the delegate of all child views
        ingredientListTableViewController.delegate = self
        addRecipeLineController.delegate = self
        editRecipeLineController.delegate = self
        recipeName.delegate = self

        // Place recipe name into label
        recipeName.text = recipeBrain.getRecipeName()
        recipeName.isEnabled = true
        
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
    
    
    
    // Search for a Recipe
    @IBAction func searchRecipe(_ sender: UIBarButtonItem) {



    }
    
    @IBAction func addRecipe(_ sender: UIBarButtonItem) {
//        // clear the recipe label and have RecipeBrain broadcast an empty recipe to child controllers
        recipeName.text = ""
        recipeName.isSelected = true
        recipeBrain.newRecipe()
    }
}


 // MARK: - Ingredient Provider Delegate
extension MasterViewController: IngredientProviderDelegate {
    // coming from the IngredientListTableViewController
    func wantsToAddRecipeLine() {
        // call Recipe Line Controller
        recipeLineAddMode = 0
        addContentController(addRecipeLineController, to: leftStackOverlay)
        self.view.insertSubview(leftStackOverlay, aboveSubview: leftScreenStack)
        leftStackOverlay.isHidden = false
    }

    func wantsToEditRecipeLine() {
        // call Recipe Line Controller
        recipeLineAddMode = 1
        addContentController(editRecipeLineController, to: leftStackOverlay)
        self.view.insertSubview(leftStackOverlay, aboveSubview: leftScreenStack)
        leftStackOverlay.isHidden = false
    }

}

 // MARK: - RecipeLineDelegate
extension MasterViewController: RecipeLineDelegate {
    func returnFromRecipeLine () {
        removeContentController(addRecipeLineController, from: leftStackOverlay)
        removeContentController(editRecipeLineController, from: leftStackOverlay)
        leftStackOverlay.isHidden = true
    }
    
    func getAddMode() -> Int {
        return recipeLineAddMode
    }
}

 // MARK: - Text Field Delegate - change of recipe name
extension MasterViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == recipeName {
            let alert = UIAlertController(title: "Save recipe name?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    self.recipeBrain.setRecipeName(textField.text ?? self.recipeBrain.getRecipeName())
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                textField.text = self.recipeBrain.getRecipeName()
            }))
            present(alert, animated: true, completion: nil)
        }
    }

}
    

//
//  ViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import UIKit

protocol RecipeUpdateDelegate: AnyObject {
    func didChangeRecipe(_ recipe: Recipe)
}


class MasterViewController: UIViewController {

    @IBOutlet weak var fullScreenStack: UIStackView!
    @IBOutlet weak var leftScreenStack: UIStackView!
    @IBOutlet weak var rightScreenStack: UIStackView!

    lazy var ingredientListTableViewController: IngredientListTableViewController = self.buildFromStoryboard("Main")

    @IBOutlet weak var recipeName: UITextField!
    weak var delegate: RecipeUpdateDelegate?

    var recipes: [Recipe] = []
    var ingredients: [Ingredient] = []
    
    // Test Data
    @Published var recipe = Recipe(name: "Sylvie's Super Duper White Bread", measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams), ingredientList: [RecipeLine(ingredient: Ingredient(name: "White Flour", type: .Flour), measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams)), RecipeLine(ingredient: Ingredient(name: "Water", type: .Fluid), measure: Measurement<Unit>(value: 1000, unit: UnitMass.grams))])
        
    override func viewDidLoad() {
        super.viewDidLoad()
        addContentController(ingredientListTableViewController, to: leftScreenStack)
        // temp solution to push recipe to ingredientlistdatasource
        ingredientListTableViewController.didChangeRecipe(recipe)
        

        // assign the current controller as the delegate of the ingredient list child controller - needed to get the ingredient selections from that tableview
//        ingredientListTableViewController.delegate = self

        // Place recipe name into label
        recipeName.text = recipe.name
        
        // update the delegates with the current recipe selected
//        delegate?.didChangeRecipe(recipe)
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        topStackView.axis = axisForSize(view.bounds.size)
//    }

    private func addContentController(_ child: UIViewController, to stackView: UIStackView) {
        addChild(child) // adds the specified view controller to the current view
        stackView.addArrangedSubview(child.view) // adds the container to the stack
        child.didMove(toParent: self) // required after adding the child to the parent
    }

    private func removeContentController(_ child: UIViewController, from stackView: UIStackView) {
        child.willMove(toParent: nil)
        stackView.removeArrangedSubview(child.view)
        child.view.removeFromSuperview()
        child.removeFromParent()
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
    
//    @IBAction func addRecipe(_ sender: UIBarButtonItem) {
//        // clear the table view and recipe label
//        recipeName.text = ""
//        recipeName.isUserInteractionEnabled = true
//        recipe.ingredientList = []
//        tableView.reloadData()
//
//    }
    
//    @objc func addIngredient() {
//        // display a list of ingredients to choose from - if "+"
//        ingredientPickerDelegate.strings = ingredients.map{ $0.name }
//        DispatchQueue.main.async{self.ingredientPicker.reloadAllComponents()}
//        ingredientPicker.isHidden = false
//    }
//
//    @objc func ingredientSelected() {
//        let ingredientRow = ingredientPicker.selectedRow(inComponent: 0)
//
//        print("\(ingredientRow)")
//    }
}


 // MARK: - Ingredient Provider Delegate
extension MasterViewController: IngredientProviderDelegate {
    func didSelectLocation(_ ingredient: Ingredient) {
        // do something
    }
}

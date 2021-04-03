//
//  ViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import UIKit


class MasterViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, GetRecipeUpdates, UITextViewDelegate {

    @IBOutlet weak var fullScreenStack: UIStackView!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var qty: UITextField!
    @IBOutlet weak var notes: UITextView!
    
    @IBOutlet weak var tableView: UITableView!
 
    // Totals outlets
    @IBOutlet weak var totalDoughWeight: UILabel!
    @IBOutlet weak var totalPreFermentedFlour: UILabel!
    @IBOutlet weak var totalFlour: UILabel!
    @IBOutlet weak var totalFluid: UILabel!
    @IBOutlet weak var totalYeast: UILabel!
    @IBOutlet weak var totalYeastHeight: NSLayoutConstraint!
    @IBOutlet weak var totalInnoculation: UILabel!
    @IBOutlet weak var totalInnoculationHeight: NSLayoutConstraint!
    @IBOutlet weak var totalSalt: UILabel!
    @IBOutlet weak var totalDoughHydration: UILabel!
    @IBOutlet weak var totalFat: UILabel!
    @IBOutlet weak var totalFatHeight: NSLayoutConstraint!
    @IBOutlet weak var totalSugar: UILabel!
    @IBOutlet weak var totalSugarHeight: NSLayoutConstraint!
    
    private var recipeLineAddMode = 0 // used to track whether recipe line controller is adding or editing lines
    private var ingredientListDataSource: IngredientListDataSource?
    
    let recipeBrain = RecipeBrain.singleton

    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        tableView.delegate = self
        recipeName.delegate = self
        qty.delegate = self
        notes.delegate = self
        recipeBrain.addDelegate(self)
        
        // instantiate RecipeBrain and force broadcast
        recipeBrain.loadRecipe()
        recipeBrain.loadIngredients()
        recipeBrain.loadRecipes()
        recipeBrain.broadcastRecipe()
        
        // this instantiates the data source object for this tableview and provides the data source with the path to find the data
        ingredientListDataSource = IngredientListDataSource(tableView: tableView)

        // Call keyboard disabler
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func qtyStepper(_ sender: UIStepper) {
        self.qty.text = Double(sender.value / 10).description
        let qtyNum = Double(self.qty.text!)
        self.recipeBrain.setQty(qtyNum!)
    }
    
    @IBAction func addRecipe(_ sender: UIBarButtonItem) {
    /// Have RecipeBrain broadcast an empty recipe to child controllers
        recipeName.isSelected = true
        recipeBrain.newRecipe()
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        alertOkCancel(title: "Delete this Recipe?", message: "Are you sure you want to delete this recipe?", indexPath: IndexPath(row: 0, section: 0), sender: "recipeDelete")
    }
    
    
     // MARK: - TextField functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.recipeBrain.setRecipeName(textField.text ?? self.recipeBrain.getRecipeName())
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.recipeBrain.setRecipeName(textField.text ?? self.recipeBrain.getRecipeName())
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == qty {
            return false
        }
        return true
    }
    
 // MARK: - TextView functions
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.recipeBrain.setNotes(textView.text ?? self.recipeBrain.getNotes())
        return true
    }
    
    
     // MARK: - IngredientListTableView Methods
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderTableViewCell
        cell.sectionName.text = recipeBrain.getSectionName(section: section)
        cell.tapAction = { action in self.performAdd(section) }
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
            let scaleAction = UIAction(title: NSLocalizedString("Scale recipe from this line", comment: ""), image: UIImage(systemName: "scalemass"), attributes: .destructive) {action in self.performScale(indexPath)
            }
            return UIMenu(title: "", children: [deleteAction, editAction, scaleAction])
        })
    }
    
    func performDelete(indexPath: IndexPath) {
        let thisRecipeLine = recipeBrain.getRecipeLine(indexPath: indexPath)
        let thisIngredient = thisRecipeLine!.ingredient.name
        let thisQuantity = String(format: "%.3f", thisRecipeLine!.measure.value)
        let thisUOM = thisRecipeLine!.measure.unit.symbol
        alertOkCancel(title: "Delete this recipe line?", message: thisIngredient + " - " + thisQuantity + thisUOM, indexPath: indexPath, sender: "lineDelete")
    }
    
    func performAdd(_ section: Int){
        recipeBrain.setCurrentSection(section)
        performSegue(withIdentifier: "RecipeLineSegue", sender: "Add")
    }
    

    func performEdit(_ indexPath: IndexPath) {
        recipeBrain.setCurrentRecipeLine(indexPath: indexPath)
        performSegue(withIdentifier: "RecipeLineSegue", sender: "Edit")
    }

    func performScale(_ indexPath: IndexPath) {
        var textField = UITextField()
        let measure = recipeBrain.getRecipeLine(indexPath: indexPath)?.measure.converted(to: .grams).value
        
        let alert = UIAlertController(title: "Scale recipe", message: "The entire recipe will be scaled based on the new weight you enter here.", preferredStyle: .alert)

            let scaleIt = UIAlertAction(title: "Scale", style: .default, handler: { (action) -> Void in
                if let newMeasure = Double(textField.text ?? "0") {
                    if newMeasure > 0 {
                        let percent = newMeasure / measure!
                        self.recipeBrain.scaleRecipe(percent)
                        self.recipeBrain.broadcastRecipe()
                    }
                }
            })

            alert.addTextField { (alertTextField) in
                alertTextField.text = String(measure!)
                textField = alertTextField
            }

            alert.addAction(scaleIt)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))

            present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecipeLineSegue" {
            recipeName.resignFirstResponder()
            let destinationVC = segue.destination as! RecipeLineController
            if sender as! String == "Edit" {
                destinationVC.setAddMode(1)
            } else {
                destinationVC.setAddMode(0)
            }
        }
    }
            
    // confirm delete
    func alertOkCancel(title: String, message: String, indexPath: IndexPath, sender: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            switch sender {
            case "lineDelete":
                self.recipeBrain.deleteRecipeLine(indexPath: indexPath)
            case "recipeDelete":
                self.recipeBrain.deleteRecipe()
            default:
                break
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        present(alert, animated: true, completion: nil)
    }
    
     // MARK: - GetRecipeUpdates Delegate
    func didChangeRecipe(_ recipe: Recipe) {
        recipeName.text = recipe.name
        qty.text = String(format: "%.1f", recipe.qty)
        notes.text = recipe.notes
        
        // Update Totals Section
        totalDoughWeight.text = String("\(Int(recipe.totalDough))g ")
        let flourWeight = recipe.totalFlour + recipe.totalStarterFlour
        let starterPercent = flourWeight > 0 ? Int(round(100 * (recipe.totalStarterFlour / flourWeight))) : 0
        let hydrationPercent = flourWeight > 0 ? Int(round(100 * ((recipe.totalFluid + recipe.totalStarterFluid) / flourWeight))) : 0
        totalPreFermentedFlour.text = String("\(Int(recipe.totalStarterFlour))g (\(starterPercent)%) ")
        totalFlour.text = String("\(Int(recipe.totalFlour + recipe.totalStarterFlour))g ") + String(recipe.totalStarterFlour > 0 ? "(\(Int(recipe.totalStarterFlour))g from starter) ": "")
        totalFluid.text = String("\(Int(recipe.totalFluid + recipe.totalStarterFluid))g ") + String(recipe.totalStarterFluid > 0 ? "(\(Int(recipe.totalStarterFluid))g from starter) ": "")
        if recipe.totalYeast > 0 {
            totalYeast.text = String("\(recipe.totalYeast)g ")
            totalYeastHeight.constant = 30
        } else {
            totalYeastHeight.constant = 0
        }
        if recipe.totalStarterFlour + recipe.totalStarterFluid > 0 && recipe.totalFlour > 0 {
            totalInnoculation.text = String("\(Int(round(100 * (recipe.totalStarterFlour + recipe.totalStarterFluid) / recipe.totalFlour)))% ")
            totalInnoculationHeight.constant = 30
        } else {
            totalInnoculationHeight.constant = 0
        }
        totalSalt.text = String("\(recipe.totalSalt)g (") + String(flourWeight > 0 ? Int(round(100 * recipe.totalSalt / flourWeight)) : 100) + "%) "
        totalDoughHydration.text = String("\(hydrationPercent)% ")
        if recipe.totalFat > 0 && flourWeight > 0 {
            totalFat.text = String("\(Int(round(100 * recipe.totalFat / flourWeight)))% ")
            totalFatHeight.constant = 30
        } else {
            totalFatHeight.constant = 0
        }
        if recipe.totalSugar > 0 && flourWeight > 0 {
            totalSugar.text = String("\(Int(round(100 * recipe.totalSugar / flourWeight)))% ")
            totalSugarHeight.constant = 30
        } else {
            totalSugarHeight.constant = 0
        }

        
        
        // Update ingredient list section
        tableView.reloadData()
        
    }
}

 // MARK: - Disable keyboard
extension MasterViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

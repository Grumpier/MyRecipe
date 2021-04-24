//
//  ViewController.swift
//  MyRecipe
//
//  Created by Steven Manus on 24/01/21.
//

import UIKit

class NavigationController: UINavigationController {
    override var disablesAutomaticKeyboardDismissal: Bool {
        get { return false }
        set { }
    }
}


class MasterViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, GetRecipeUpdates, UITextViewDelegate, UITableViewDragDelegate {

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
    
    // Constraints outlets
    @IBOutlet weak var innoculationConstraintValue: UITextField!
    @IBOutlet weak var hydrationConstraintValue: UITextField!
    @IBOutlet weak var saltConstraintValue: UITextField!
    @IBOutlet weak var innoculationConstraintSwitch: UISwitch!
    @IBOutlet weak var hydrationConstraintSwitch: UISwitch!
    @IBOutlet weak var saltConstraintSwitch: UISwitch!
    
    
    // Bottom Toolbar Buttons as Outlets
    @IBOutlet weak var totalButton: UIBarButtonItem!
    @IBOutlet weak var flourButton: UIBarButtonItem!
    @IBOutlet weak var hydrationButton: UIBarButtonItem!
    @IBOutlet weak var fromYeastButton: UIBarButtonItem!
    @IBOutlet weak var tangzhongButton: UIBarButtonItem!
    @IBOutlet weak var innoculationButton: UIBarButtonItem!
    
    private var recipeLineAddMode = 0 // used to track whether recipe line controller is adding or editing lines
    private var ingredientListDataSource: IngredientListDataSource?
    
    let recipeBrain = RecipeBrain.singleton

    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        tableView.delegate = self
        tableView.dragDelegate = self
        recipeName.delegate = self
        qty.delegate = self
        innoculationConstraintValue.delegate = self
        hydrationConstraintValue.delegate = self
        saltConstraintValue.delegate = self
        notes.delegate = self
        recipeBrain.addDelegate(self)
        
        // instantiate RecipeBrain and force broadcast
//        recipeBrain.loadRecipe()
        recipeBrain.loadIngredients()
        recipeBrain.loadRecipes()
        recipeBrain.broadcastRecipe()
        
        // this instantiates the data source object for this tableview and provides the data source with the path to find the data
        ingredientListDataSource = IngredientListDataSource(tableView: tableView)

        // Call keyboard disabler
        hideKeyboardWhenTappedAround()
        
        // set keyboard types for input fields
        recipeName.keyboardType = .default
        innoculationConstraintValue.keyboardType = .numberPad
        hydrationConstraintValue.keyboardType = .numberPad
        saltConstraintValue.keyboardType = .numberPad

        // Allow dragging to move recipe list ingredients
        tableView.allowsSelection = true
        tableView.dragInteractionEnabled = true
    }
    
    @IBAction func qtyStepper(_ sender: UIStepper) {
        self.qty.text = Double(sender.value / 10).description
        let qtyNum = Double(self.qty.text!)
        self.recipeBrain.setQty(qtyNum!)
    }
    
    @IBAction func scaleQtyPressed(_ sender: UIButton) {
        performScale(message: "The recipe will be scaled based on the new number of units you enter here. For example, if this is a recipe to produce 1 loaf, enter 2 to increase the recipe to make 2 loaves.", value: recipeBrain.getQty(), type: "units")
    }
    
    @IBAction func addRecipe(_ sender: UIBarButtonItem) {
    /// Have RecipeBrain broadcast an empty recipe to child controllers
        recipeName.isSelected = true
        recipeBrain.newRecipe()
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        alertOkCancel(title: "Delete this Recipe?", message: "Are you sure you want to delete this recipe?", indexPath: IndexPath(row: 0, section: 0), sender: "recipeDelete")
    }
    
    // MARK: - Constraints Buttons
    //
    
    @IBAction func innoculationConstraintPressed(_ sender: UISwitch) {
        innoculationConstraintValue.resignFirstResponder()
        if innoculationConstraintSwitch.isOn && Double(innoculationConstraintValue.text ?? "0")! > 0 {
            recipeBrain.activateConstraint(constraint: "innoculation", value: Double(innoculationConstraintValue.text ?? "0")!)
        } else if !innoculationConstraintSwitch.isOn {
            recipeBrain.deactivateConstraint("innoculation")
        }
    }
    
    @IBAction func hydrationConstraintPressed(_ sender: UISwitch) {
        hydrationConstraintValue.resignFirstResponder()
        if hydrationConstraintSwitch.isOn && Double(hydrationConstraintValue.text ?? "0")! > 0 {
            recipeBrain.activateConstraint(constraint: "hydration", value: Double(hydrationConstraintValue.text ?? "0")!)
        } else if !hydrationConstraintSwitch.isOn {
            recipeBrain.deactivateConstraint("hydration")
        }
    }
    @IBAction func saltConstraintPressed(_ sender: UISwitch) {
        saltConstraintValue.resignFirstResponder()
        if saltConstraintSwitch.isOn && Double(saltConstraintValue.text ?? "0")! > 0 {
            recipeBrain.activateConstraint(constraint: "salt", value: Double(saltConstraintValue.text ?? "0")!)
        } else if !saltConstraintSwitch.isOn {
            recipeBrain.deactivateConstraint("salt")
        }
    }
    
     // MARK: - Toolbar buttons
    
    @IBAction func totalPressed(_ sender: UIBarButtonItem) {
        performScale(message: "The recipe will be scaled based on the new total weight", value: recipeBrain.getTotalWeight(), type: "weight")
    }
    
    @IBAction func flourPressed(_ sender: UIBarButtonItem) {
        performScale(message: "The recipe will be scaled based on the new total raw flour weight", value: recipeBrain.getTotalFlour(), type: "weight")
    }
    
    @IBAction func hydrationPressed(_ sender: UIBarButtonItem) {
        performScale(message: "The fluid part of the recipe will be adjusted in order to reach the new hydration percentage you enter. Use a value between 50 and 150.", value: Double(totalDoughHydration.text!.filter("0123456789.".contains))!, type: "hydration")
    }
    
    @IBAction func fromYeastPressed(_ sender: UIBarButtonItem) {
        performScale(message: "A sourdough starter will be added at the entered percentage.", value: 20.0, type: "sourdough")
    }
    
    @IBAction func tangzhongPressed(_ sender: UIBarButtonItem) {
        performScale(message: "Tangzhong flour and water will be added as this percentage of the total dough.", value: 20.0, type: "tangzhong")
    }
    
    @IBAction func innoculationPressed(_ sender: UIBarButtonItem) {
        performScale(message: "Enter the desired innoculation percent and starter will be adjusted along with other ingredients in order to maintain existing dough weight and hydration %", value: Double(totalInnoculation.text!.filter("0123456789.".contains))!, type: "innoculation")
    }
    
    @IBAction func printPressed(_ sender: UIBarButtonItem) {
    }
    
     // MARK: - TextField functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case recipeName:
            self.recipeBrain.setRecipeName(textField.text ?? self.recipeBrain.getRecipeName())
        case innoculationConstraintValue:
            if innoculationConstraintSwitch.isOn && Double(innoculationConstraintValue.text ?? "0")! > 0 {
                recipeBrain.activateConstraint(constraint: "innoculation", value: Double(innoculationConstraintValue.text ?? "0")!)
            }
        case hydrationConstraintValue:
            if hydrationConstraintSwitch.isOn && Double(hydrationConstraintValue.text ?? "0")! > 0 {
                recipeBrain.activateConstraint(constraint: "hydration", value: Double(hydrationConstraintValue.text ?? "0")!)
            }
        case saltConstraintValue:
            if saltConstraintSwitch.isOn && Double(saltConstraintValue.text ?? "0")! > 0 {
                recipeBrain.activateConstraint(constraint: "salt", value: Double(saltConstraintValue.text ?? "0")!)
            }

        default:
            break
        }
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case recipeName:
            self.recipeBrain.setRecipeName(textField.text ?? self.recipeBrain.getRecipeName())
        case innoculationConstraintValue:
            if innoculationConstraintSwitch.isOn && Double(innoculationConstraintValue.text ?? "0")! > 0 {
                recipeBrain.activateConstraint(constraint: "innoculation", value: Double(innoculationConstraintValue.text ?? "0")!)
            }
        case hydrationConstraintValue:
            if hydrationConstraintSwitch.isOn && Double(hydrationConstraintValue.text ?? "0")! > 0 {
                recipeBrain.activateConstraint(constraint: "hydration", value: Double(hydrationConstraintValue.text ?? "0")!)
            }
        case saltConstraintValue:
            if saltConstraintSwitch.isOn && Double(saltConstraintValue.text ?? "0")! > 0 {
                recipeBrain.activateConstraint(constraint: "salt", value: Double(saltConstraintValue.text ?? "0")!)
            }

        default:
            break
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let flour = Double(totalFlour.text!.filter("0123456789.".contains))!
        switch textField {
        case qty:
            return false
        case innoculationConstraintValue:
            return flour > 0
        case hydrationConstraintValue:
            return flour > 0
        case saltConstraintValue:
            return flour > 0
        default:
            break
        }
        return true
    }
    
 // MARK: - TextView functions
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.recipeBrain.setNotes(textView.text ?? self.recipeBrain.getNotes())
        return true
    }
    
    
     // MARK: - IngredientListTableView Methods
    // display section header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderTableViewCell
        cell.sectionName.text = recipeBrain.getSectionName(section: section)
        cell.newLine = { action in self.performAdd(section) }
        cell.editHeader = { action in self.editHeader(section) }
        return cell
    }
    
    // enables drag
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = recipeBrain.getRecipeLine(indexPath: indexPath)
        return [dragItem]
    }
    
    // enables swipes
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete", handler: {(action: UIContextualAction, view: UIView, success: (Bool) -> Void) in self.performDelete(indexPath: indexPath); success(true)})
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: {(action: UIContextualAction, view: UIView, success: (Bool) -> Void) in self.performEdit(indexPath); success(true)})
        editAction.backgroundColor = .blue
        let scaleAction = UIContextualAction(style: .normal, title: "Scale Recipe", handler: {(action: UIContextualAction, view: UIView, success: (Bool) -> Void) in self.performScale(message: "The entire recipe will be scaled based on the new weight you enter here.", value: self.recipeBrain.getRecipeLine(indexPath: indexPath)!.measure.converted(to: .grams).value, type: "weight"); success(true)})
        scaleAction.backgroundColor = .systemTeal

        let configuration = UISwipeActionsConfiguration(actions: [editAction, scaleAction])
        return configuration
    }
    
    // enables context menu - for short press on a line
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // A BIT TRICKY TO IMPLEMENT - ADD LATER?
        print(indexPath.section, indexPath.row)
    }

    // enables context menu - for long presses on a line
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
            let scaleAction = UIAction(title: NSLocalizedString("Scale recipe from this line", comment: ""), image: UIImage(systemName: "scalemass"), attributes: .destructive) {action in self.performScale(message: "The entire recipe will be scaled based on the new weight you enter here.", value: self.recipeBrain.getRecipeLine(indexPath: indexPath)!.measure.converted(to: .grams).value, type: "weight")
            }
            return UIMenu(title: "", children: [deleteAction, editAction, scaleAction])
        })
    }
    
     // MARK: - Table Section Functions
    
    @IBAction func addHeader(_ sender: Any) {
        performSegue(withIdentifier: "SectionSegue", sender: "Add")
    }
    
    func editHeader(_ section: Int){
        recipeBrain.setCurrentSection(section)
        performSegue(withIdentifier: "SectionSegue", sender: "Edit")
    }
    
    
     // MARK: - Recipe Line Functions
    
    func performDelete(indexPath: IndexPath) {
        self.recipeBrain.deleteRecipeLine(indexPath: indexPath)
    }
    
    func performAdd(_ section: Int){
        recipeBrain.setCurrentSection(section)
        performSegue(withIdentifier: "RecipeLineSegue", sender: "Add")
    }
    

    func performEdit(_ indexPath: IndexPath) {
        recipeBrain.setCurrentRecipeLine(indexPath: indexPath)
        performSegue(withIdentifier: "RecipeLineSegue", sender: "Edit")
    }
    
     // MARK: - Scaling Functions
    func performScale(message: String, value: Double = 0.0, type: String) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Scale recipe", message: message, preferredStyle: .alert)
        let scaleIt = UIAlertAction(title: "Scale", style: .default, handler: { (action) -> Void in
            if let newMeasure = Double(textField.text ?? "0") {
                if newMeasure > 0 {
                    switch type {
                    case "weight":
                        let percent = newMeasure / value
                        self.recipeBrain.scaleRecipe(percent)
                        self.recipeBrain.broadcastRecipe()
                    case "units":
                        let percent = newMeasure / value
                        self.recipeBrain.scaleRecipe(percent)
                        self.recipeBrain.broadcastRecipe()
                        self.recipeBrain.setQty(newMeasure)
                        self.qty.text = newMeasure.description
                    case "hydration":
                        if (50...150).contains(newMeasure) {
                            self.recipeBrain.scaleRecipeHydration(newMeasure)
                            self.recipeBrain.broadcastRecipe()
                        }
                    case "innoculation":
                        if newMeasure > 0 {
                            self.recipeBrain.scaleInnoculation(oldInnoculation: value, newInnoculation: newMeasure)
                            self.recipeBrain.broadcastRecipe()
                        }
                    case "sourdough":
                        if newMeasure > 0 {
                            self.recipeBrain.addSourdough(percent: newMeasure)
                            self.recipeBrain.broadcastRecipe()
                        }
                    case "tangzhong":
                        if newMeasure > 0 {
                            self.recipeBrain.addTangzhong(percent: newMeasure)
                            self.recipeBrain.broadcastRecipe()
                        }
                    default:
                        break
                    }
                }
            }
        })

        alert.addTextField { (alertTextField) in
            alertTextField.text = String(value)
            textField = alertTextField
            textField.keyboardType = .numberPad
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
        if segue.identifier == "SectionSegue" {
            let destinationVC = segue.destination as! SectionController
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
        totalPreFermentedFlour.text = String("\(Int(recipe.totalStarterFlour))g (\(recipe.starterPercent)%) ")
        totalFlour.text = String("\(Int(recipe.totalFlour + recipe.totalStarterFlour))g ") + String(recipe.totalStarterFlour > 0 ? "(\(Int(recipe.totalStarterFlour))g from starter) ": "")
        totalFluid.text = String("\(Int(recipe.totalFluid + recipe.totalStarterFluid))g ") + String(recipe.totalStarterFluid > 0 ? "(\(Int(recipe.totalStarterFluid))g from starter) ": "")
        if recipe.totalYeast > 0 {
            totalYeast.text = String("\(recipe.totalYeast)g ")
            totalYeastHeight.constant = 30
        } else {
            totalYeastHeight.constant = 0
        }
        if recipe.totalInnoculation > 0 {
            totalInnoculation.text = String("\(recipe.totalInnoculation)% ")
            totalInnoculationHeight.constant = 30
        } else {
            totalInnoculationHeight.constant = 0
        }
        totalSalt.text = String("\(Int(round(recipe.totalSalt)))g (") + String(recipe.flourWeight > 0 ? Int(round(100 * recipe.totalSalt / recipe.flourWeight)) : 100) + "%) "
        totalDoughHydration.text = String("\(recipe.hydrationPercent)% ")
        if recipe.totalFat > 0 && recipe.flourWeight > 0 {
            totalFat.text = String("\(Int(round(100 * recipe.totalFat / recipe.flourWeight)))% ")
            totalFatHeight.constant = 30
        } else {
            totalFatHeight.constant = 0
        }
        if recipe.totalSugar > 0 && recipe.flourWeight > 0 {
            totalSugar.text = String("\(Int(round(100 * recipe.totalSugar / recipe.flourWeight)))% ")
            totalSugarHeight.constant = 30
        } else {
            totalSugarHeight.constant = 0
        }
        
        // update constraint values and switches
        innoculationConstraintValue.text = String("\(Int(recipe.constraints["innoculation"] ?? 0))")
        hydrationConstraintValue.text = String("\(Int(recipe.constraints["hydration"] ?? 0))")
        saltConstraintValue.text = String("\(Int(recipe.constraints["salt"] ?? 0))")
        innoculationConstraintSwitch.isEnabled = recipe.totalFlour > 0
        hydrationConstraintSwitch.isEnabled = recipe.totalFlour > 0
        saltConstraintSwitch.isEnabled = recipe.totalFlour > 0
        innoculationConstraintSwitch.isOn = recipe.constraints["innoculation"] ?? 0 > 0
        hydrationConstraintSwitch.isOn = recipe.constraints["hydration"] ?? 0 > 0
        saltConstraintSwitch.isOn = recipe.constraints["salt"] ?? 0 > 0

        // Update ingredient list section
        tableView.reloadData()
        
        // Update Bar buttons
        totalButton.isEnabled = recipeBrain.getTotalFluid() > 0 ? true : false
        flourButton.isEnabled = recipeBrain.getTotalFluid() > 0 ? true : false
        hydrationButton.isEnabled = recipeBrain.getTotalFluid() > 0 ? true : false
        fromYeastButton.isEnabled = recipeBrain.getTotalYeast() + recipeBrain.getTotalStarterFluid() + recipeBrain.getTotalFluid() > 0 ? true : false
        tangzhongButton.isEnabled = recipeBrain.getTotalFluid() > 0 ? true : false
        innoculationButton.isEnabled = recipeBrain.getTotalStarterFluid() > 0 ? true : false
    }
}

 // MARK: - Disable keyboard
extension MasterViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }


}

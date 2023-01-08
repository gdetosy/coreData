//
//  CategoryViewController.swift
//  coreDatas
//
//  Created by tosy on 8.01.23.
//

import UIKit
import CoreData
class CategoryViewController: UITableViewController {
    var categories =  [CategoryModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    @IBAction func addNewCategory(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        alert.addTextField { textField in textField.placeholder = "Category"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first,
               let text = textField.text,
               text != "",
               let self = self
            {
                let newCategory = CategoryModel(context: self.context)
                newCategory.name = text
                self.categories.append(newCategory)
                self.saveCategories()
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .automatic)
            }
        }
        alert.addAction(cancel)
        alert.addAction(addAction)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        categories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    
    
    // MARK: - Table view delegate
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
            let name = categories[indexPath.row].name
            {
                let request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()
                request.predicate =  NSPredicate(format: "name==\(name)")
                if let categories = try? context.fetch(request) {
                    for categorie in categories {
                        context.delete(categorie)
                    }
                    self.categories.remove(at: indexPath.row)
                    saveCategories()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                }
            }
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
    }
    
    
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showItemsSegue", sender: nil)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toDoVc = segue.destination as? ToDoViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            toDoVc.selectedCategory = categories[indexPath.row]
        }
    }
    
    //   MARK: - CoreData

    private func saveCategories() {
        do {
            try context.save()
            
        } catch {
            print("\(error)")
        }
    }

    private func loadCategories(with request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()) {
        do {
            categories = try context.fetch(request)
            
        } catch {
            print("error")
        }
        tableView.reloadData()
    }
    
}

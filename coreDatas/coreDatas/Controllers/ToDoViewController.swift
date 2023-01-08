//
//  ToDoViewController.swift
//  coreDatas
//
//  Created by tosy on 8.01.23.
//

import CoreData
import UIKit
class ToDoViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: CategoryModel? {
        didSet {
            self.title = selectedCategory?.name
            getData()
        }
    }
    
    var itemsArray = [ItemModel]()
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        alert.addTextField { textField in textField.placeholder = "your task"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let add = UIAlertAction(title: "Add", style: .default) { [weak self] _
            in
                if let textField = alert.textFields?.first,
                   let text = textField.text,
                   text != "",
                   let self = self
                {
                    let newItem = ItemModel(context: self.context)
                    newItem.title = text
                    newItem.done = false
                    newItem.parentCategory = self.selectedCategory
                
                    self.itemsArray.append(newItem)
                    self.saveItems()
                    self.tableView.insertRows(at: [IndexPath(row: self.itemsArray.count - 1, section: 0)], with: .automatic)
                }
        }
        alert.addAction(cancel)
        alert.addAction(add)
        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = itemsArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = itemsArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if editingStyle == .delete {
                if let categoryName = selectedCategory?.name, let itemName = itemsArray[indexPath.row].title {
                    let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
                    let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
                    let itemPredicate = NSPredicate(format: "title MATCHES %@", itemName)
                    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, itemPredicate])
                    if let results = try? context.fetch(request) {
                        for object in results {
                            context.delete(object)
                        }
                        itemsArray.remove(at: indexPath.row)
                        saveItems()
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
        private func getData() {
            loadItem()
        }
        private func saveItems() {
            do {
                try context.save()
            } catch {
                print("Error save context")
            }
        }
        private func loadItem(with request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest(), predicate: NSPredicate? = nil) {
            guard let name = selectedCategory?.name else { return }
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
            if let predicate = predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, categoryPredicate])
            } else {
                request.predicate = categoryPredicate
            }
            do { itemsArray = try context.fetch(request) }
            catch {
                print("error")
            }
            tableView.reloadData()
        }
    }
    extension ToDoViewController: UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            
            if searchText.isEmpty {
                loadItem()
                searchBar.resignFirstResponder()
            } else {
                let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
                let searchPredicate = NSPredicate(format: "title CONTAINS %@", searchText)
                request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                loadItem(with: request, predicate: searchPredicate)
            }
        }
    }
  

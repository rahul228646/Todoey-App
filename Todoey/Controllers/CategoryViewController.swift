//
//  CategoryViewController.swift
//  Todoey
//
//  Created by rahul kaushik on 05/10/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories : Results<Category>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        loadCategories()
      
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default){ action in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            self.save(category: newCategory)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navBar = navigationController?.navigationBar {
            navBar.backgroundColor = UIColor(hexString: "000000")
            
            searchBar.barTintColor = UIColor(hexString: "000000")
            
            searchBar.tintColor = ContrastColorOf(UIColor(hexString: "000000")!, returnFlat: true)
            
            var textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField

            textFieldInsideSearchBar?.textColor = ContrastColorOf(UIColor(hexString: "000000")!, returnFlat: true)
            view.backgroundColor = UIColor(hexString: "000000")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        if let color = categories![indexPath.row].color {
            cell.backgroundColor = UIColor(hexString : color)
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString : color)!, returnFlat: true)
        }
       
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    
    func save(category : Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        }catch {
            print("error saving \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        self.tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error Deleting \(error)")
            }
        }
    }
    
}

extension CategoryViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategories()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else {
            categories = categories?.filter("name CONTAINS[cd] %@", searchBar.text!)
            self.tableView.reloadData()
        }
    }
}


//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController : SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var toDoItems : Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))


           tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        
        loadItems()
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorhex = selectedCategory?.color {
            title = selectedCategory?.name
            
            if let navBar = navigationController?.navigationBar {
                
                let color = UIColor(hexString: selectedCategory!.color!)!.darken(byPercentage: CGFloat(toDoItems!.count-1)/CGFloat(toDoItems!.count))
                
                navBar.tintColor = ContrastColorOf(UIColor(hexString: colorhex)!, returnFlat: true)
                
                var textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
                
                textFieldInsideSearchBar?.textColor = ContrastColorOf(UIColor(hexString: colorhex)!, returnFlat: true)
                
                
                navBar.backgroundColor = UIColor(hexString: colorhex)
                searchBar.barTintColor = UIColor(hexString: colorhex)
                navBar.barTintColor = UIColor(hexString: colorhex)
                
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(UIColor(hexString: colorhex)!, returnFlat: true)]
                
                searchBar.tintColor = ContrastColorOf(UIColor(hexString: colorhex)!, returnFlat: true)
                view.backgroundColor = UIColor(hexString: colorhex)
                
                
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType  = item.done ? .checkmark : .none
        }
        else {
            cell.textLabel?.text = "No Items Added"
        }
        
        if let color = UIColor(hexString: selectedCategory!.color ?? "000000")?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(toDoItems!.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            cell.tintColor = ContrastColorOf(color, returnFlat: true)
        }
        
        
        cell.selectionStyle = .none
        return cell
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToBeDeleted = self.toDoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemToBeDeleted)
                }
            }catch{
                print("Error Deleting \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
                
            }catch{
                print("error saving \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default){ action in
            
            if let currcategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currcategory.items.append(newItem)
                        self.tableView.reloadData()
                    }
                }catch {
                    print("error saving \(error)")
                }
            }
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
        
        
    }
    
    
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        self.tableView.reloadData()
    }
}


extension TodoListViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else {
            toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            self.tableView.reloadData()
        }
    }
    
}


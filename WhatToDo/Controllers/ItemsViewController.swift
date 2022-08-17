//
//  ToDoListViewController.swift
//  WhatToDo
//
//  Created by Óscar on 1/8/22.
//  Copyright © 2022 Oscar Moreno . All rights reserved.
//

import UIKit
import CoreData

class ItemsViewController: UITableViewController{
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  var items = [Item]()
  var selectedCategory: Category? {
    didSet {
      loadItems()
    }
  }
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
  }
  
  //MARK: - Add Items
  @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
    var newItemTextField = UITextField()
    let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
    let addItemAction = UIAlertAction(title: "Add item", style: .default) { action in
      if newItemTextField.text != "" {
        let newItem = Item(context: self.context)
        newItem.title = newItemTextField.text!
        newItem.done = false
        newItem.parentCategory = self.selectedCategory
        self.items.append(newItem)
        self.saveItems()
      } else {
        print("ERROR: Add empty string as item is not allowed")
        let alertEmptyString = UIAlertController(title: "WARNING", message: "Emtpy item is not allowed", preferredStyle: .alert)
        let actionEmptyString = UIAlertAction(title: "OK", style: .default)
        alertEmptyString.addAction(actionEmptyString)
        self.present(alertEmptyString, animated: true)
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    alert.addTextField { textfield in
      textfield.placeholder = "New item"
      newItemTextField = textfield
    }
    alert.addAction(addItemAction)
    alert.addAction(cancelAction)
    present(alert, animated: true, completion: nil)
  }
  
  //MARK: - Model Manipulation
  func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(),_ predicate: NSPredicate? = nil) {
    let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
    let inputPredicate = predicate
    
    if let argumentPredicate = inputPredicate {
      let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,argumentPredicate])
      request.predicate = compoundPredicate
    } else {
      request.predicate = categoryPredicate
    }
    do {
      items = try context.fetch(request)
    } catch {
      print("ERROR: Error fetching data from database -> \(error.localizedDescription)")
    }
    tableView.reloadData()
  }
  
  func loadSearchedItems() {
    let request:NSFetchRequest<Item> = Item.fetchRequest()
    let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
    request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    loadItems(with: request, predicate)
  }
  
  func saveItems() {
    do {
      try context.save()
    } catch {
      print("ERROR: Error saving data in database-> \(error.localizedDescription)")
    }
    tableView.reloadData()
  }
    
  
  //MARK: - UITableView Datasource
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
    cell.textLabel?.text = items[indexPath.row].title
    cell.accessoryType = items[indexPath.row].done ? .checkmark : .none
    return cell
  }
  
  //MARK: - UITableView Delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    items[indexPath.row].done = !items[indexPath.row].done
    saveItems()
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == .delete) {
      context.delete(items[indexPath.row])
      items.remove(at: indexPath.row)
      saveItems()
    }
  }
  
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
  
}

//MARK: - UISearchBar Delegate

extension ItemsViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text?.count == 0 {
      loadItems()
      DispatchQueue.main.async {
        searchBar.resignFirstResponder()
      }
    } else {
      loadSearchedItems()
    }
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    loadSearchedItems()
  }
}

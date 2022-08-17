//
//  CategoryViewController.swift
//  WhatToDo
//
//  Created by Óscar on 15/8/22.
//  Copyright © 2022 Oscar Moreno . All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UITableViewController {
  
  var categories = [Category]()
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadCategories()
  }
  
  //MARK: - Add Categories
  @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
    var newCategoryTextField = UITextField()
    let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
    let addCategoryAction = UIAlertAction(title: "Add category", style: .default) { action in
      if newCategoryTextField.text != "" {
        let newCategory = Category(context: self.context)
        newCategory.name = newCategoryTextField.text!
        self.categories.append(newCategory)
        self.saveCategories()
      } else {
        print("ERROR: Add empty string as category is not allowed")
        let alertEmptyString = UIAlertController(title: "WARNING", message: "Emtpy category is not allowed", preferredStyle: .alert)
        let actionEmptyString = UIAlertAction(title: "OK", style: .default)
        alertEmptyString.addAction(actionEmptyString)
        self.present(alertEmptyString, animated: true)
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    alert.addTextField { textfield in
      textfield.placeholder = "New category"
      newCategoryTextField = textfield
    }
    alert.addAction(addCategoryAction)
    alert.addAction(cancelAction)
    present(alert, animated: true, completion: nil)
  }
  
  //MARK: - Model Manipulation
  func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
    do {
      categories = try context.fetch(request)
    } catch {
      print("ERROR: Error fetching data from database -> \(error.localizedDescription)")
    }
    tableView.reloadData()
  }
  
  func saveCategories() {
    do {
      try context.save()
    } catch {
      print("ERROR: Error saving data in database-> \(error.localizedDescription)")
    }
    tableView.reloadData()
  }
    
  
  //MARK: - UITableView Datasource
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    categories.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    cell.textLabel?.text = categories[indexPath.row].name
    return cell
  }
  
  //MARK: - UITableView Delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "GoToItems", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! ItemsViewController
    if let indexPath = tableView.indexPathForSelectedRow {
      destinationVC.selectedCategory = categories[indexPath.row]
      destinationVC.title = "\(destinationVC.selectedCategory!.name!)"
    }
    
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == .delete) {
      context.delete(categories[indexPath.row])
      categories.remove(at: indexPath.row)
      saveCategories()
    }
  }
  
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
  
}

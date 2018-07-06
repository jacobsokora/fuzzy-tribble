//
//  CategoriesViewController.swift
//  Documents
//
//  Created by Jacob Sokora on 7/6/18.
//  Copyright © 2018 Jacob Sokora. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UITableViewController {
    
    var categories: [Category] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        request.returnsObjectsAsFaults = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            let results = try context.fetch(request)
            categories = results as! [Category]
        } catch {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        cell.detailTextLabel?.text = "\(category.documents?.count ?? 0) documents"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            let category = self.categories[indexPath.row]
            if category.documents?.count != 0 {
                let alert = UIAlertController(title: "Delete \(category.name ?? "")", message: "This category contains \(category.documents?.count ?? 0) document(s), are you sure you want to delete it?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "No", style: .cancel))
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { action in
                    self.delete(category, at: indexPath.row)
                })
                self.present(alert, animated: true)
                success(true)
            } else {
                success(self.delete(category, at: indexPath.row))
            }
            self.tableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func delete(_ category: Category, at row: Int) -> Bool {
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            context.mergePolicy = NSOverwriteMergePolicy
            context.delete(category)
            try context.save()
            self.categories.remove(at: row)
            self.tableView.reloadData()
        } catch {
            print("Failed to delete document: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            let category = self.categories[indexPath.row]
            let alert = UIAlertController(title: "Edit Category", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textField in
                textField.text = category.name
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Save", style: .default) { action in
                if let name = alert.textFields?.first?.text {
                    category.name = name
                    do {
                        try category.managedObjectContext?.save()
                        self.categories[indexPath.row].name = name
                        self.tableView.reloadData()
                    } catch {
                        print("Failed to save category name: \(error.localizedDescription)")
                    }
                }
            })
            self.present(alert, animated: true)
            success(true)
        }
        return UISwipeActionsConfiguration(actions: [editAction])
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let selected = tableView.indexPathForSelectedRow, let destination = segue.destination as? DocumentsViewController {
            destination.category = categories[selected.row]
        }
    }
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Edit Category", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Category name"
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { action in
            if let name = alert.textFields?.first?.text {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                context.mergePolicy = NSRollbackMergePolicy
                let entity = NSEntityDescription.entity(forEntityName: "Category", in: context)
                let data = Category(entity: entity!, insertInto: context)
                data.name = name
                data.documents = NSSet()
                do {
                    try context.save()
                    self.categories.append(data)
                    self.tableView.reloadData()
                } catch {
                    print("Failed to save document: \(error.localizedDescription)")
                }
            }
        })
        self.present(alert, animated: true)
    }
}

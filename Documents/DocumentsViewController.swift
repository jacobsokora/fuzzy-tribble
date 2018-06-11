//
//  ViewController.swift
//  Documents
//
//  Created by Jacob Sokora on 6/9/18.
//  Copyright © 2018 Jacob Sokora. All rights reserved.
//

import UIKit

class DocumentsViewController: UIViewController {
    
    @IBOutlet weak var documentsTableView: UITableView!
    
    let fileManager = FileManager.default
    var documents: [Document] = []
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        documentsTableView.dataSource = self
        documentsTableView.delegate = self
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].path
        if !fileManager.changeCurrentDirectoryPath(directory) {
            fatalError("Could not open application document directory!")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        documents.removeAll()
        do {
            for fileName in try fileManager.contentsOfDirectory(atPath: ".") {
                let attributes = try fileManager.attributesOfItem(atPath: fileName)
                documents.append(Document(name: fileName, size: attributes[FileAttributeKey.size] as! Int, lastModified: attributes[FileAttributeKey.modificationDate] as! Date))
            }
        } catch {
            print(error.localizedDescription)
        }
        documentsTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selected = documentsTableView.indexPathForSelectedRow, let destination = segue.destination as? EditDocumentViewController {
            let document = documents[selected.row]
            destination.document = document
        }
    }
}

extension DocumentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath) as! DocumentsTableViewCell
        let document = documents[indexPath.row]
        cell.nameLabel.text = document.name
        cell.sizeLabel.text = "\(document.size) bytes"
        cell.timeLabel.text = "Modified: \(dateFormatter.string(from: document.lastModified))"
        return cell
    }
}

extension DocumentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            let document = self.documents[indexPath.row]
            do {
                try self.fileManager.removeItem(atPath: document.name)
                self.documents.remove(at: indexPath.row)
                success(true)
                self.documentsTableView.reloadData()
            } catch {
                print(error.localizedDescription)
                success(false)
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

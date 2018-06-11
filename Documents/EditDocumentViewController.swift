//
//  EditDocumentViewController.swift
//  Documents
//
//  Created by Jacob Sokora on 6/9/18.
//  Copyright © 2018 Jacob Sokora. All rights reserved.
//

import UIKit

class EditDocumentViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var documentArea: UITextView!
    
    var document: Document?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let document = document else {
            return
        }
        
        nameField.text = document.name
        if let dataBuffer = FileManager.default.contents(atPath: document.name) {
            documentArea.text = String(data: dataBuffer, encoding: .utf8) ?? ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveFile(_ sender: Any) {
        guard let fileName = nameField.text, fileName.count > 0, let content = documentArea.text, content.count > 0 else {
            return
        }
        FileManager.default.createFile(atPath: fileName, contents: content.data(using: .utf8), attributes: nil)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nameFieldChanged(_ sender: UITextField) {
         self.title = nameField.text ?? "New Document"
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

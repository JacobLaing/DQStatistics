//
//  managersPopupViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 4/28/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit
import CoreData

class managersPopupViewController: UIViewController {

    @IBOutlet weak var nameInputText: UITextField!
    @IBOutlet weak var addManager: UIButton!
    @IBOutlet weak var cancelAddManager: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(managersPopupViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addManager_TouchUpInside(_ sender: UIButton) {
        let name = nameInputText.text!
        if (!name.isEmpty) {
            let manager = Manager(context: PersistenceService.context)
            manager.name = name.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            PersistenceService.saveContext()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateManagerTable"), object: nil)
            dismiss(animated: true)
        }
        else {
            let alert = UIAlertController(title: "Uh Oh...", message: "It looks like you have the big dumb. Try filling out all of the fields before hitting add next time.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func cancelAddManager_TouchUpInside(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

}

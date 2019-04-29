//
//  LaborPopupViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 4/28/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit
import CoreData

class LaborPopupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var enterNameTextField: UITextField!
    @IBOutlet weak var addLabor: UIButton!
    @IBOutlet weak var cancelAddLabor: UIButton!
    
    var managers = [Manager]()
    
    private var datePicker: UIDatePicker?
    private var managerPicker: UIPickerView?
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterNameTextField.isHidden = true
        let fetchRequest: NSFetchRequest<Manager> = Manager.fetchRequest()
        do {
            let managers = try PersistenceService.context.fetch(fetchRequest)
            let managersSorted = managers.sorted { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
            self.managers = managersSorted
            //self.tableView.reloadData()
        } catch{}
        
        managerPicker = UIPickerView()
        pickerData.append("")
        for manager in managers {
            pickerData.append(manager.name!)
        }
        pickerData.append("Other")
        managerPicker?.delegate = self
        managerPicker?.dataSource = self
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = dateFormatter.string(from: datePicker!.date)
        datePicker?.addTarget(self, action: #selector(LaborPopupViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LaborPopupViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        nameTextField.inputView = managerPicker
        dateTextField.inputView = datePicker
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addLabor_TouchUpInside(_ sender: UIButton) {
        var name: String
        if (nameTextField.text == "Other") {
            name = enterNameTextField.text!
        }
        else {
            name = nameTextField.text!
        }
        let date = dateTextField.text!
        let amount = amountTextField.text!
        if (!name.isEmpty && !date.isEmpty && !amount.isEmpty) {
            let labor = Labor(context: PersistenceService.context)
            labor.name = name.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            labor.date = dateFormatter.date(from: date) as NSDate?
            labor.amount = Double(amount) ?? 0.0
            PersistenceService.saveContext()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateLaborTable"), object: nil)
            dismiss(animated: true)
        }
        else {
            let alert = UIAlertController(title: "Uh Oh...", message: "It looks like you have the big dumb. Try filling out all of the fields before hitting add next time.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func cancelAddLabor_TouchUpInside(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        nameTextField.text = pickerData[row]
        if (nameTextField.text == "Other") {
            enterNameTextField.isHidden = false
            nameTextField.frame.origin.y = 69
            dateTextField.frame.origin.y = 151
        }
        else {
            enterNameTextField.isHidden = true
            nameTextField.frame.origin.y = 78
            dateTextField.frame.origin.y = 135
        }
        view.endEditing(true)
    }
    
    
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }

}

//
//  DrawersPopupViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 5/1/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit
import CoreData

class DrawersPopupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var countedTextField: UITextField!
    @IBOutlet weak var depositedTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var managerTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var managers = [Manager]()
    private var datePicker: UIDatePicker?
    private var managerPicker: UIPickerView?
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest: NSFetchRequest<Manager> = Manager.fetchRequest()
        do {
            let managers = try PersistenceService.context.fetch(fetchRequest)
            let managersSorted = managers.sorted { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
            self.managers = managersSorted
        } catch{}
        managerPicker = UIPickerView()
        pickerData.append("")
        for manager in managers {
            pickerData.append(manager.name!)
        }
        managerPicker?.delegate = self
        managerPicker?.dataSource = self
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        datePicker?.setDate(Date(), animated: true)
        dateTextField.text = dateFormatter.string(from: datePicker!.date)
        datePicker?.addTarget(self, action: #selector(LaborPopupViewController.dateChanged(datePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LaborPopupViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        depositedTextField.delegate = self
        countedTextField.delegate = self
        managerTextField.inputView = managerPicker
        dateTextField.inputView = datePicker
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else {
            return true
        }
        let newText = oldText.replacingCharacters(in: r, with: string)
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        
        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
    }
    
    @IBAction func cancelButton_TouchUpInside(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func addButton_TouchUpInside(_ sender: UIButton) {
        var name: String
        name = managerTextField.text!
        let date = dateTextField.text!
        let deposited = depositedTextField.text!
        let counted = countedTextField.text!
        if (!name.isEmpty && !date.isEmpty && !deposited.isEmpty && !counted.isEmpty) {
            let drawer = Drawer(context: PersistenceService.context)
            drawer.name = name.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            drawer.date = dateFormatter.date(from: date) as NSDate?
            drawer.deposited = Double(deposited) ?? 0.0
            drawer.counted = Double(counted) ?? 0.0
            PersistenceService.saveContext()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateDrawerTable"), object: nil)
            dismiss(animated: true)
        }
        else {
            let alert = UIAlertController(title: "Uh Oh...", message: "It looks like you have the big dumb. Try filling out all of the fields before hitting add next time.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
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
        managerTextField.text = pickerData[row]
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

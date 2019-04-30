//
//  ContestPopupViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 4/29/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit

class ContestPopupViewController: UIViewController {

    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var clearDatesButton: UIButton!
    
    private var startDatePicker: UIDatePicker?
    private var endDatePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDatePicker = UIDatePicker()
        endDatePicker = UIDatePicker()
        startDatePicker?.datePickerMode = .date
        endDatePicker?.datePickerMode = .date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        startDate.text = dateFormatter.string(from: startDatePicker!.date)
        endDate.text = dateFormatter.string(from: endDatePicker!.date)
        startDatePicker?.addTarget(self, action: #selector(ContestPopupViewController.startDateChanged(startDatePicker:)), for: .valueChanged)
        endDatePicker?.addTarget(self, action: #selector(ContestPopupViewController.endDateChanged(endDatePicker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ContestPopupViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        startDate.inputView = startDatePicker
        startDate.addTarget(self, action: #selector(startDateTapped), for: .touchDown)
        endDate.inputView = endDatePicker
        endDate.addTarget(self, action: #selector(endDateTapped), for: .touchDown)
        // Do any additional setup after loading the view.
    }
    
    @objc func startDateTapped(textField: UITextField) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        startDate.text = dateFormatter.string(from: startDatePicker!.date)
        endDate.text = dateFormatter.string(from: endDatePicker!.date)
    }
    @objc func endDateTapped(textField: UITextField) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        startDate.text = dateFormatter.string(from: startDatePicker!.date)
        endDate.text = dateFormatter.string(from: endDatePicker!.date)
    }
    @IBAction func clearDatesPressed_TouchUpInside(_ sender: UIButton) {
        startDate.text = ""
        endDate.text = ""
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func startDateChanged(startDatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        startDate.text = dateFormatter.string(from: startDatePicker.date)
        endDatePicker?.minimumDate = startDatePicker.date
        endDate.text = dateFormatter.string(from: endDatePicker!.date)
    }
    @objc func endDateChanged(endDatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        endDate.text = dateFormatter.string(from: endDatePicker.date)
        startDatePicker?.maximumDate = endDatePicker.date
        startDate.text = dateFormatter.string(from: startDatePicker!.date)
    }
    
    @IBAction func cancelSelectDates_TouchUpInside(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func confirmSelectDates_TouchUpInside(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "datesSelected"), object: nil, userInfo: ["startDate":startDate.text!, "endDate":endDate.text!])
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

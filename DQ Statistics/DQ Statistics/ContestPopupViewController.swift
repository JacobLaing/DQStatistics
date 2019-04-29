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
        endDate.inputView = endDatePicker
        // Do any additional setup after loading the view.
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func startDateChanged(startDatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        startDate.text = dateFormatter.string(from: startDatePicker.date)
        endDatePicker?.minimumDate = startDatePicker.date
    }
    @objc func endDateChanged(endDatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        endDate.text = dateFormatter.string(from: endDatePicker.date)
        startDatePicker?.maximumDate = endDatePicker.date
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

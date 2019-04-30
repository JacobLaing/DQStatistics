//
//  ContestViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 4/26/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit
import CoreData

class ContestViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var firstPlaceNameLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var firstPlaceAvgLaborLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var firstPlaceShiftsLabel: UILabel!
    var labors = [Labor]()
    var managers = [Manager]()
    var managerNames = [String]()
    var managerLabors = [Labor]()
    var avgManagerLabors = [Double]()
    
    var laborsSortedForTable = [Double]()
    var managersSortedForTable = [String]()
    var shiftsSortedForTable = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        customizeNavBar()
        
        let fetchRequest: NSFetchRequest<Manager> = Manager.fetchRequest()
        do {
            let managers = try PersistenceService.context.fetch(fetchRequest)
            let managersSorted = managers.sorted { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
            self.managers = managersSorted
        } catch{}
        let fetchRequest2: NSFetchRequest<Labor> = Labor.fetchRequest()
        do {
            let labors = try PersistenceService.context.fetch(fetchRequest2)
            let sortedLabors = labors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.labors = sortedLabors
        } catch{}
        
        sortByManagerName()
        dateRangeLabel.text = ""
        calculateAverageLabors(laborsToUse: managerLabors)
        NotificationCenter.default.addObserver(self, selector: #selector(datesSelected(_:)), name: Notification.Name(rawValue: "datesSelected"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func datesSelected(_ notification: Notification) {
        guard let startDate = notification.userInfo!["startDate"] as? String else { return }
        guard let endDate = notification.userInfo!["endDate"] as? String else { return }
        if (!startDate.isEmpty && !endDate.isEmpty) {
            dateRangeLabel.text = String(startDate) + " -> " + String(endDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            var laborsByDate = [Labor]()
            for labor in managerLabors {
                if ((dateFormatter.date(from: startDate)! ... dateFormatter.date(from: endDate)!).contains(labor.date! as Date)) {
                    laborsByDate.append(labor)
                }
            }
            calculateAverageLabors(laborsToUse: laborsByDate)
        }
        else {
            dateRangeLabel.text = ""
            calculateAverageLabors(laborsToUse: managerLabors)
        }
    }
    
    func calculateAverageLabors(laborsToUse: [Labor]) {
        if (!laborsToUse.isEmpty) {
            avgManagerLabors = [Double]()
            var managerSpecificLabors = [Labor]()
            var managersToUse = managerNames
            let tempNames = managersToUse
            for manager in tempNames {
                managerSpecificLabors = [Labor]()
                for labor in laborsToUse {
                    if (labor.name! == manager) {
                        managerSpecificLabors.append(labor)
                    }
                }
                if (managerSpecificLabors.count == 0) {
                    if let indexValue = managersToUse.firstIndex(of: manager) {
                        managersToUse.remove(at: indexValue)
                    }
                }
            }
            for manager in managersToUse {
                var totalLabor = 0.0
                managerSpecificLabors = [Labor]()
                for labor in laborsToUse {
                    if (labor.name! == manager) {
                        managerSpecificLabors.append(labor)
                        totalLabor += labor.amount
                    }
                }
                let numShifts = managerSpecificLabors.count
                let avgLabor = totalLabor/Double(numShifts)
                avgManagerLabors.append(avgLabor)
            }
            var avgLaborsSorted = [Double]()
            avgLaborsSorted = avgManagerLabors.sorted()
            var place = 0;
            managersSortedForTable = [String]()
            laborsSortedForTable = [Double]()
            shiftsSortedForTable = [Int]()
            for value in avgLaborsSorted {
                var i = 0;
                for labor in avgManagerLabors {
                    if (labor == value) {
                        let managerName = managersToUse[i]
                        let amount = value
                        managerSpecificLabors = [Labor]()
                        for labor in laborsToUse {
                            if (labor.name == managerName) {
                                managerSpecificLabors.append(labor)
                            }
                        }
                        let shifts = managerSpecificLabors.count
                        if (place == 0) {
                            firstPlaceNameLabel.text = managerName
                            firstPlaceAvgLaborLabel.text = String(format: "%.2f", amount)
                            firstPlaceShiftsLabel.text = String(shifts)
                        }
                        else {
                            managersSortedForTable.append(managersToUse[i])
                            laborsSortedForTable.append(value)
                            shiftsSortedForTable.append(shifts)
                        }
                    }
                    else {
                        i += 1
                    }
                }
                place += 1
            }
        }
        else {
            managersSortedForTable = [String]()
            laborsSortedForTable = [Double]()
            shiftsSortedForTable = [Int]()
            firstPlaceNameLabel.text = "-"
            firstPlaceAvgLaborLabel.text = "-"
            firstPlaceShiftsLabel.text = "-"
        }
        tableView.reloadData()
    }
    
    func sortByManagerName() {
        for manager in self.managers {
            if (manager.name != "Peyton Ahrens" && manager.name != "Peyton" &&
                manager.name != "Koby Donithan" && manager.name != "Koby") {
                managerNames.append(manager.name!)
            }
        }
        for labor in self.labors {
            if (managerNames.contains(labor.name!)) {
                managerLabors.append(labor)
            }
        }
    }
    
    func sideMenus() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 250 //275
            //revealViewController()?.rightViewRevealWidth = 0
            
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }
    
    func customizeNavBar() {
        navigationController?.navigationBar.topItem?.title = "Contest"
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 122/255, blue: 193/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}

extension ContestViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laborsSortedForTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = NumberFormatter.localizedString(from: NSNumber(value: indexPath.row + 2), number: .ordinal) + ":  " + managersSortedForTable[indexPath.row]
        cell.detailTextLabel?.text = "Number of Shifts: " + String(shiftsSortedForTable[indexPath.row])
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
        label.text = String(format: "%.2f", laborsSortedForTable[indexPath.row])
        label.textAlignment = .right
        cell.accessoryView = label
        return cell
    }
}
extension Date {
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}

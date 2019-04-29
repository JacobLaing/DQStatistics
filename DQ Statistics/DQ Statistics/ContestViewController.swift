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
        NotificationCenter.default.addObserver(self, selector: #selector(datesSelected(_:)), name: Notification.Name(rawValue: "datesSelected"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func datesSelected(_ notification: Notification) {
        guard let startDate = notification.userInfo!["startDate"] as? String else { return }
        guard let endDate = notification.userInfo!["endDate"] as? String else { return }
        dateRangeLabel.text = String(startDate) + " -> " + String(endDate)
    }
    
    func sortByManagerName() {
        for manager in self.managers {
            managerNames.append(manager.name!)
        }
        for labor in self.labors {
            if (managerNames.contains(labor.name!)) {
                managerLabors.append(labor)
            }
        }
        self.labors = managerLabors
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
        return 0//labors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        /*
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.textLabel?.text = labors[indexPath.row].name!
        cell.detailTextLabel?.text = dateFormatter.string(from: labors[indexPath.row].date! as Date)
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
        label.text = String(labors[indexPath.row].amount)
        label.textAlignment = .right
        cell.accessoryView = label
 */
        return cell
    }
}

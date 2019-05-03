//
//  DrawersViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 4/26/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit
import CoreData

class DrawersTableViewCell: UITableViewCell {
    @IBOutlet weak var managerTextField: UILabel!
    @IBOutlet weak var dateTextField: UILabel!
    @IBOutlet weak var depositedTextField: UILabel!
    @IBOutlet weak var countedTextField: UILabel!
    @IBOutlet weak var differenceTextField: UILabel!
}

class DrawersViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var drawers = [Drawer]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        customizeNavBar()
        let fetchRequest: NSFetchRequest<Drawer> = Drawer.fetchRequest()
        do {
            let drawers = try PersistenceService.context.fetch(fetchRequest)
            let drawersSorted = drawers.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.drawers = drawersSorted
        } catch{}
        self.tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateDrawerTable(_:)), name: Notification.Name(rawValue: "updateDrawerTable"), object: nil)
    }
    
    @objc func updateDrawerTable(_ notification: Notification) {
        let fetchRequest: NSFetchRequest<Drawer> = Drawer.fetchRequest()
        do {
            let drawers = try PersistenceService.context.fetch(fetchRequest)
            let drawersSorted = drawers.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.drawers = drawersSorted
        } catch{}
        self.tableView.reloadData()
    }
    
    func sideMenus() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 250
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func customizeNavBar() {
        navigationController?.navigationBar.topItem?.title = "Drawers"
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 122/255, blue: 193/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}
extension DrawersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.drawers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "drawerCell", for: indexPath)
            as! DrawersTableViewCell
        let drawer = drawers[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.managerTextField.text = drawer.name
        cell.dateTextField.text = dateFormatter.string(from: drawer.date! as Date)
        cell.depositedTextField.text = "Deposited: $" + String(format: "%.2f", drawer.deposited)
        cell.countedTextField.text = "Counted: $" + String(format: "%.2f", drawer.counted)
        let difference = drawer.deposited - drawer.counted
        //Amount counted is less than deposited (Bad)
        if (difference > 0) {
            cell.differenceTextField.text = "$" + String(format: "%.2f", abs(difference))
            cell.differenceTextField.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
        //Amount counted is less than deposited (Good)
        else if (difference < 0) {
            cell.differenceTextField.text = "-$" + String(format: "%.2f", abs(difference))
            cell.differenceTextField.textColor = UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1)
        }
        //Amount counted is same as deposited (Good)
        else {
            cell.differenceTextField.text = "$" + String(format: "%.2f", abs(difference))
            cell.differenceTextField.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            PersistenceService.context.delete(drawers[indexPath.row])
            PersistenceService.saveContext()
            let fetchRequest: NSFetchRequest<Drawer> = Drawer.fetchRequest()
            do {
                let drawers = try PersistenceService.context.fetch(fetchRequest)
                let drawersSorted = drawers.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
                self.drawers = drawersSorted
            } catch{}
            self.tableView.reloadData()
        }
    }
}


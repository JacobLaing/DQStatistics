//
//  ManagersViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 4/26/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit
import CoreData

class ManagersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var managers = [Manager]()
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        customizeNavBar()
        
        //returns an array of managers
        let fetchRequest: NSFetchRequest<Manager> = Manager.fetchRequest()
        do {
            let managers = try PersistenceService.context.fetch(fetchRequest)
            let managersSorted = managers.sorted { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
            self.managers = managersSorted
            self.tableView.reloadData()
        } catch{}
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateManagerTable(_:)), name: Notification.Name(rawValue: "updateManagerTable"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func updateManagerTable(_ notification: Notification) {
        let fetchRequest: NSFetchRequest<Manager> = Manager.fetchRequest()
        do {
            let managers = try PersistenceService.context.fetch(fetchRequest)
            let managersSorted = managers.sorted { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
            self.managers = managersSorted
            self.tableView.reloadData()
        } catch{}
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
        navigationController?.navigationBar.topItem?.title = "Managers"
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 122/255, blue: 193/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}

extension ManagersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return managers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = managers[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            PersistenceService.context.delete(managers[indexPath.row])
            PersistenceService.saveContext()
            let fetchRequest: NSFetchRequest<Manager> = Manager.fetchRequest()
            do {
                let managers = try PersistenceService.context.fetch(fetchRequest)
                let managersSorted = managers.sorted { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending}
                self.managers = managersSorted
                self.tableView.reloadData()
            } catch{}
        }
    }
}

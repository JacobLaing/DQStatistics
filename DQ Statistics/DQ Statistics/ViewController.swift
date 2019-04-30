//
//  ViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 4/24/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var labors = [Labor]()
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        customizeNavBar()
    
        //returns an array of labors
        let fetchRequest: NSFetchRequest<Labor> = Labor.fetchRequest()
        do {
            let labors = try PersistenceService.context.fetch(fetchRequest)
            let sortedLabors = labors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.labors = sortedLabors
            self.tableView.reloadData()
        } catch{}
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLaborTable(_:)), name: Notification.Name(rawValue: "updateLaborTable"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func updateLaborTable(_ notification: Notification) {
        let fetchRequest: NSFetchRequest<Labor> = Labor.fetchRequest()
        do {
            let labors = try PersistenceService.context.fetch(fetchRequest)
            let sortedLabors = labors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.labors = sortedLabors
            self.tableView.reloadData()
        } catch{}
    }
    
    func sideMenus() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController()?.rearViewRevealWidth = 250 //275
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
    }
    
    func customizeNavBar() {
        navigationController?.navigationBar.topItem?.title = "Labor"
        navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 122/255, blue: 193/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        cell.textLabel?.text = labors[indexPath.row].name!
        cell.detailTextLabel?.text = dateFormatter.string(from: labors[indexPath.row].date! as Date)
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
        label.text = String(labors[indexPath.row].amount)
        label.textAlignment = .right
        cell.accessoryView = label
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            PersistenceService.context.delete(labors[indexPath.row])
            PersistenceService.saveContext()
            let fetchRequest: NSFetchRequest<Labor> = Labor.fetchRequest()
            do {
                let labors = try PersistenceService.context.fetch(fetchRequest)
                let sortedLabors = labors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
                self.labors = sortedLabors
                self.tableView.reloadData()
            } catch{}
        }
    }
}

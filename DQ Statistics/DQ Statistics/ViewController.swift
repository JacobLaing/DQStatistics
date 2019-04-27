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
            self.labors = labors
            self.tableView.reloadData()
        } catch{}
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPlusTapped() {
        let alert = UIAlertController(title: "Add Labor Statistic", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Manager Name"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Date (mm/dd/yyyy)"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Labor Amount"
        }
        let action = UIAlertAction(title: "Add Labor Statistic", style: .default) { (_) in
            let name = alert.textFields!.first!.text!
            let date = alert.textFields![1].text
            let amount = alert.textFields!.last?.text!
            let labor = Labor(context: PersistenceService.context)
            if (!name.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).isEmpty) {
                labor.name = name.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                labor.date = dateFormatter.date(from: date!) as NSDate?
                labor.amount = Double(amount!) ?? 0.0
                PersistenceService.saveContext()
                self.labors.append(labor)
                self.tableView.reloadData()
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
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
}

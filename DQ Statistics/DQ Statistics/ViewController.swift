//
//  ViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 4/24/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit
import CoreData
import Charts

class ViewController: UIViewController {

    @IBOutlet weak var chartSwitch: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var labors = [Labor]()
    var allLaborsSorted = [Labor]()
    var lastTenLabors = [Labor]()
    var index = 10
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
            allLaborsSorted = self.labors
            self.tableView.reloadData()
        } catch{}
        index = 10
        while (index > 0) {
            lastTenLabors.append(allLaborsSorted[index])
            index = index - 1
        }
        barChartUpdate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLaborTable(_:)), name: Notification.Name(rawValue: "updateLaborTable"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func chartFilterChanged(_ sender: UISegmentedControl) {
        barChartUpdate()
    }
    func barChartUpdate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        var monthTotals = [Double]()
        var i = 12
        while (i > 0) {
            monthTotals.append(0.0)
            i -= 1
        }
        if (chartSwitch.selectedSegmentIndex == 0) {
            var janTotal = 0.0
            var febTotal = 0.0
            var marTotal = 0.0
            var aprTotal = 0.0
            var mayTotal = 0.0
            var junTotal = 0.0
            var julTotal = 0.0
            var augTotal = 0.0
            var sepTotal = 0.0
            var octTotal = 0.0
            var novTotal = 0.0
            var decTotal = 0.0
            
            for labor in allLaborsSorted {
                switch Int(dateFormatter.string(from: labor.date! as Date)) {
                case 1:
                    janTotal += 1.0
                    monthTotals[0] += labor.amount
                    break
                case 2:
                    febTotal += 1.0
                    monthTotals[1] += labor.amount
                    break
                case 3:
                    marTotal += 1.0
                    monthTotals[2] += labor.amount
                    break
                case 4:
                    aprTotal += 1.0
                    monthTotals[3] += labor.amount
                    break
                case 5:
                    mayTotal += 1.0
                    monthTotals[4] += labor.amount
                    break
                case 6:
                    junTotal += 1.0
                    monthTotals[5] += labor.amount
                    break
                case 7:
                    julTotal += 1.0
                    monthTotals[6] += labor.amount
                    break
                case 8:
                    augTotal += 1.0
                    monthTotals[7] += labor.amount
                    break
                case 9:
                    sepTotal += 1.0
                    monthTotals[8] += labor.amount
                    break
                case 10:
                    octTotal += 1.0
                    monthTotals[9] += labor.amount
                    break
                case 11:
                    novTotal += 1.0
                    monthTotals[10] += labor.amount
                    break
                case 12:
                    decTotal += 1.0
                    monthTotals[11] += labor.amount
                    break
                default:
                    break
                }
            }
            monthTotals[0] = monthTotals[0]/janTotal
            monthTotals[1] = monthTotals[1]/febTotal
            monthTotals[2] = monthTotals[2]/marTotal
            monthTotals[3] = monthTotals[3]/aprTotal
            monthTotals[4] = monthTotals[4]/mayTotal
            monthTotals[5] = monthTotals[5]/junTotal
            monthTotals[6] = monthTotals[6]/julTotal
            monthTotals[7] = monthTotals[7]/augTotal
            monthTotals[8] = monthTotals[8]/sepTotal
            monthTotals[9] = monthTotals[9]/octTotal
            monthTotals[10] = monthTotals[10]/novTotal
            monthTotals[11] = monthTotals[11]/decTotal
            var entries = [BarChartDataEntry]()
            var index = 1.0
            for value in monthTotals {
                entries.append(BarChartDataEntry(x: index, y: value))
                index += 1.0
            }
            let dataSet = BarChartDataSet(entries: entries, label: "Month")
            let data = BarChartData(dataSets: [dataSet])
            barChart.data = data
            barChart.chartDescription?.text = "Average Labor by Month"
        }
        else {
            
        }
        barChart.notifyDataSetChanged()
    }
    
    @objc func updateLaborTable(_ notification: Notification) {
        let fetchRequest: NSFetchRequest<Labor> = Labor.fetchRequest()
        do {
            let labors = try PersistenceService.context.fetch(fetchRequest)
            let sortedLabors = labors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.labors = sortedLabors
            allLaborsSorted = self.labors
            self.tableView.reloadData()
        } catch{}
        index = 10
        while (index > 0) {
            lastTenLabors.append(allLaborsSorted[index])
            index = index - 1
        }
        barChartUpdate()
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

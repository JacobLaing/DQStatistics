//
//  DrawersViewController.swift
//  DQ Statistics
//
//  Created by Jacob Laing on 4/26/19.
//  Copyright © 2019 Jacob Laing. All rights reserved.
//

import UIKit
import CoreData
import Charts

class DrawersTableViewCell: UITableViewCell {
    @IBOutlet weak var managerTextField: UILabel!
    @IBOutlet weak var dateTextField: UILabel!
    @IBOutlet weak var depositedTextField: UILabel!
    @IBOutlet weak var countedTextField: UILabel!
    @IBOutlet weak var differenceTextField: UILabel!
}

class DrawersViewController: UIViewController {

    
    
    
    @IBOutlet weak var variableDifferenceLabel: UILabel!
    @IBOutlet weak var variableDepositedLabel: UILabel!
    @IBOutlet weak var yearlyDifferenceLabel: UILabel!
    @IBOutlet weak var yearlyDepositedLabel: UILabel!
    @IBOutlet weak var variableNameLabel: UILabel!
    @IBOutlet weak var drawersLineChart: LineChartView!
    @IBOutlet weak var drawersSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    weak var axisFormatDelegate: IAxisValueFormatter?
    var drawers = [Drawer]()
    var yearlyDrawers = [Drawer]() //List of drawers only from this year
    var lastTenDrawers = [Drawer]() //List of the 10 most recent drawers
    
    var yearlyDrawerDepositTotals = [Double]()
    var yearlyDrawerCountedTotals = [Double]()
    var yearlyDrawerDifferenceTotals = [Double]()
    
    var variableDrawerDepositedTotals = [Double]()
    var variableDrawerCountedTotals = [Double]()
    var variableDrawerDifferenceTotals = [Double]()
    
    //x-axis variables
    let months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var lastTenDays = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        customizeNavBar()
        axisFormatDelegate = self
        drawersLineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        updateData()
        drawersLineChart.animate(xAxisDuration: 1.5, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDrawerTable(_:)), name: Notification.Name(rawValue: "updateDrawerTable"), object: nil)
    }
    
    func lineChartUpdate() {
        if (drawersSegmentControl.selectedSegmentIndex == 0) {
            drawersLineChart.xAxis.labelCount = 11
            drawersLineChart.xAxis.drawAxisLineEnabled = false
            drawersLineChart.xAxis.drawGridLinesEnabled = false
            setChart(dataEntryX: months, depositedY: yearlyDrawerDepositTotals, countedY: yearlyDrawerCountedTotals, differenceY: yearlyDrawerDifferenceTotals)
        }
        else {
            drawersLineChart.xAxis.labelCount = 9
            drawersLineChart.xAxis.drawAxisLineEnabled = false
            drawersLineChart.xAxis.drawGridLinesEnabled = false
            lastTenDays = [String]()
            for i in 0..<lastTenDrawers.count{
                lastTenDays.insert(String((lastTenDrawers[lastTenDrawers.count - (i+1)].date! as Date).dayNumberOfWeek()!), at: 0)
            }
            while (lastTenDays.count < 10) {
                lastTenDays.insert("", at: 0)
            }
            for i in 0..<lastTenDays.count{
                switch lastTenDays[i] {
                case "1":
                    lastTenDays[i] = "Sun"
                    break
                case "2":
                    lastTenDays[i] = "Mon"
                    break
                case "3":
                    lastTenDays[i] = "Tue"
                    break
                case "4":
                    lastTenDays[i] = "Wed"
                    break
                case "5":
                    lastTenDays[i] = "Thu"
                    break
                case "6":
                    lastTenDays[i] = "Fri"
                    break
                case "7":
                    lastTenDays[i] = "Sat"
                    break
                default:
                    break
                }
            }
            setChart(dataEntryX: lastTenDays, depositedY: variableDrawerDepositedTotals, countedY: variableDrawerCountedTotals, differenceY: variableDrawerDifferenceTotals)
        }
    }
    
    func setChart(dataEntryX forX:[String], depositedY forDepositY: [Double], countedY forCountedY: [Double], differenceY forDifferenceY: [Double]) {
        var depositEntries:[ChartDataEntry] = []
        for i in 0..<forX.count{
            let depositEntry = ChartDataEntry(x: Double(i), y: Double(forDepositY[i]) , data: months as AnyObject?)
            depositEntries.append(depositEntry)
        }
        var countedEntries:[ChartDataEntry] = []
        for i in 0..<forX.count{
            let countedEntry = ChartDataEntry(x: Double(i), y: Double(forCountedY[i]) , data: months as AnyObject?)
            countedEntries.append(countedEntry)
        }
        var differenceEntries:[ChartDataEntry] = []
        for i in 0..<forX.count{
            let differenceEntry = ChartDataEntry(x: Double(i), y: Double(forDifferenceY[i]) , data: months as AnyObject?)
            differenceEntries.append(differenceEntry)
        }
        let depositLine = LineChartDataSet(entries: depositEntries, label: "Deposited")
        let countedLine = LineChartDataSet(entries: countedEntries, label: "Counted")
        let differenceLine = LineChartDataSet(entries: differenceEntries, label: "Difference")
        
        depositLine.setColor(UIColor(red: 0/255, green: 122/255, blue: 193/255, alpha: 1))
        depositLine.drawCirclesEnabled = false
        depositLine.drawValuesEnabled = false
        countedLine.setColor(UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1))
        countedLine.drawCirclesEnabled = false
        countedLine.drawValuesEnabled = false
        differenceLine.setColor(UIColor(red: 249/255, green: 170/255, blue: 83/255, alpha: 1))
        differenceLine.drawCirclesEnabled = false
        let data = LineChartData()
        data.addDataSet(depositLine)
        data.addDataSet(countedLine)
        data.addDataSet(differenceLine)
        drawersLineChart.data = data
        let xAxisValue = drawersLineChart.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
    }
    
    func updateData() {
        let fetchRequest: NSFetchRequest<Drawer> = Drawer.fetchRequest()
        do {
            let drawers = try PersistenceService.context.fetch(fetchRequest)
            let drawersSorted = drawers.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.drawers = drawersSorted
        } catch{}
        yearlyDrawers = [Drawer]()
        yearlyDrawerDepositTotals = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        yearlyDrawerCountedTotals = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        yearlyDrawerDifferenceTotals = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        let curYear = Calendar.current.component(.year, from: Date())
        for drawer in self.drawers {
            if (dateFormatter.string(from: drawer.date! as Date) == String(curYear)) {
                yearlyDrawers.insert(drawer, at: 0)
                let index = Int(monthFormatter.string(from: drawer.date! as Date))! - 1
                yearlyDrawerDepositTotals[index] += drawer.deposited
                yearlyDrawerCountedTotals[index] += drawer.counted
                yearlyDrawerDifferenceTotals[index] += drawer.deposited - drawer.counted
            }
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        yearlyDepositedLabel.text = "$" + numberFormatter.string(from: NSNumber(value: yearlyDrawerDepositTotals.reduce(0, +)))!
        let difference = yearlyDrawerDifferenceTotals.reduce(0, +)
        if (difference >= 0) {
            yearlyDifferenceLabel.text = "$" + numberFormatter.string(from: NSNumber(value: abs(difference)))!
            yearlyDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
            //Amount counted is less than deposited (Good)
        else {
            yearlyDifferenceLabel.text = "-$" + numberFormatter.string(from: NSNumber(value: abs(difference)))!
            yearlyDifferenceLabel.textColor = UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1)
        }
        lastTenDrawers = [Drawer]()
        variableDrawerDepositedTotals = [Double]()
        variableDrawerCountedTotals = [Double]()
        variableDrawerDifferenceTotals = [Double]()
        for drawer in self.drawers {
            if (lastTenDrawers.count < 10) {
                lastTenDrawers.insert(drawer, at: 0)
                variableDrawerDepositedTotals.insert(drawer.deposited, at: 0)
                variableDrawerCountedTotals.insert(drawer.counted, at: 0)
                variableDrawerDifferenceTotals.insert(drawer.deposited - drawer.counted, at: 0)
            }
            else {
                break
            }
        }
        while (variableDrawerDepositedTotals.count < 10) {
            variableDrawerDepositedTotals.insert(0.0, at: 0)
            variableDrawerCountedTotals.insert(0.0, at: 0)
            variableDrawerDifferenceTotals.insert(0.0, at: 0)
        }
        var diff = 0.0
        if (drawersSegmentControl.selectedSegmentIndex == 0) {
            variableNameLabel.text = "This Month"
            let curMonth = Calendar.current.component(.month, from: Date())
            let index = curMonth - 1
            variableDepositedLabel.text = "$" + numberFormatter.string(from: NSNumber(value: yearlyDrawerDepositTotals[index]))!//String(format: "%.2f", yearlyDrawerDepositTotals[index])
            diff = yearlyDrawerDifferenceTotals[index]
            //Use yearlyDrawers
        }
        else {
            variableNameLabel.text = "Last 10 Days"
            variableDepositedLabel.text = "$" + numberFormatter.string(from: NSNumber(value: variableDrawerDepositedTotals.reduce(0, +)))!//String(format: "%.2f", variableDrawerDepositedTotals.reduce(0, +))
            diff = variableDrawerDifferenceTotals.reduce(0, +)
        }
        if (diff >= 0) {
            variableDifferenceLabel.text = "$" + numberFormatter.string(from: NSNumber(value: abs(diff)))!//String(format: "%.2f", abs(diff))
            variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
            //Amount counted is less than deposited (Good)
        else {
            variableDifferenceLabel.text = "-$" + numberFormatter.string(from: NSNumber(value: abs(diff)))!//String(format: "%.2f", abs(diff))
            variableDifferenceLabel.textColor = UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1)
        }
        self.tableView.reloadData()
        lineChartUpdate()
    }
    
    @IBAction func drawersSegmentChanged(_ sender: UISegmentedControl) {
        updateData()
        drawersLineChart.animate(xAxisDuration: 1.5, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
    }
    
    @objc func updateDrawerTable(_ notification: Notification) {
        updateData()
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
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        cell.managerTextField.text = drawer.name
        cell.dateTextField.text = dateFormatter.string(from: drawer.date! as Date)
        cell.depositedTextField.text = "Deposited: $" + numberFormatter.string(from: NSNumber(value: drawer.deposited))!
        cell.countedTextField.text = "Counted: $" + numberFormatter.string(from: NSNumber(value: drawer.counted))!
        let difference = drawer.deposited - drawer.counted
        //Amount counted is less than deposited (Bad)
        if (difference >= 0) {
            cell.differenceTextField.text = "$" + numberFormatter.string(from: NSNumber(value: abs(difference)))!
            cell.differenceTextField.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
        //Amount counted is less than deposited (Good)
        else {
            cell.differenceTextField.text = "-$" + numberFormatter.string(from: NSNumber(value: abs(difference)))!
            cell.differenceTextField.textColor = UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1)
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
            updateData()
        }
    }
}

extension DrawersViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if (drawersSegmentControl.selectedSegmentIndex == 0) {
            return months[Int(value)]
        }
        else {
            return lastTenDays[Int(value)]
        }
    }
}

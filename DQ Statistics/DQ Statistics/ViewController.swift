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

    @IBOutlet weak var variableDifferenceLabel: UILabel!
    @IBOutlet weak var variableAverageLabel: UILabel!
    @IBOutlet weak var allTimeEntriesLabel: UILabel!
    @IBOutlet weak var allTimeAverageLabel: UILabel!
    @IBOutlet weak var variableLabel: UILabel!
    @IBOutlet weak var chartSwitch: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    weak var axisFormatDelegate: IAxisValueFormatter?
    var labors = [Labor]()
    var allLaborsSorted = [Labor]()
    var lastTenLabors = [Labor]()
    var lastTenLaborsSorted = [Labor]()
    var lastTenLaborAmounts = [Double]()
    var index = 10
    let months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var lastTenDays = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        customizeNavBar()
        axisFormatDelegate = self
        let fetchRequest: NSFetchRequest<Labor> = Labor.fetchRequest()
        do {
            let labors = try PersistenceService.context.fetch(fetchRequest)
            let sortedLabors = labors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.labors = sortedLabors
            allLaborsSorted = self.labors
            self.tableView.reloadData()
        } catch{}
        lastTenLabors = [Labor]()
        lastTenLaborAmounts = [Double]()
        for labor in allLaborsSorted {
            if (lastTenLabors.count < 10) {
                lastTenLabors.insert(labor, at: 0)
                lastTenLaborAmounts.insert(labor.amount, at: 0)
            }
            else {
                break
            }
        }
        while (lastTenLaborAmounts.count < 10) {
            lastTenLaborAmounts.insert(0.0, at: 0)
        }
        var sum = 0.0
        for labor in self.labors {
            sum += labor.amount
        }
        allTimeAverageLabel.text = String(format: "%.2f", sum/Double(self.labors.count))
        allTimeEntriesLabel.text = "Entries: " + String(self.labors.count)
        var difference = 0.0
        if (chartSwitch.selectedSegmentIndex == 0) {
            variableLabel.text = "This Year"
            var yearSum = 0.0
            var yearEntries = 0
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let curYear = Calendar.current.component(.year, from: Date())
            for labor in self.labors {
                if (dateFormatter.string(from: labor.date! as Date) == String(curYear)) {
                    yearSum += labor.amount
                    yearEntries += 1
                }
            }
            variableAverageLabel.text = String(format: "%.2f", yearSum/Double(yearEntries))
        }
        else {
            variableLabel.text = "Last 10 Days"
            var sumTen = 0.0
            for labor in lastTenLabors {
                sumTen += labor.amount
            }
            variableAverageLabel.text = String(format: "%.2f", sumTen/Double(lastTenLabors.count))
        }
        difference = Double(allTimeAverageLabel.text!)! - Double(variableAverageLabel.text!)!
        if (difference > 0) {
            variableDifferenceLabel.text = "-" + String(format: "%.2f", abs(difference))
            variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
        else if (difference < 0) {
            variableDifferenceLabel.text = "+" + String(format: "%.2f", abs(difference))
            variableDifferenceLabel.textColor = UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1)
        }
        else {
            variableDifferenceLabel.text = "+/-" + String(format: "%.2f", abs(difference))
            variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
        lastTenLaborsSorted = lastTenLabors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
        barChart.rightAxis.axisMinimum = 0.0
        barChart.leftAxis.axisMinimum = 0.0
        barChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChartUpdate()
        barChart.animate(xAxisDuration: 1.5, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLaborTable(_:)), name: Notification.Name(rawValue: "updateLaborTable"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func chartFilterChanged(_ sender: UISegmentedControl) {
        var difference = 0.0
        if (chartSwitch.selectedSegmentIndex == 0) {
            variableLabel.text = "This Year"
            var yearSum = 0.0
            var yearEntries = 0
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let curYear = Calendar.current.component(.year, from: Date())
            for labor in self.labors {
                if (dateFormatter.string(from: labor.date! as Date) == String(curYear)) {
                    yearSum += labor.amount
                    yearEntries += 1
                }
            }
            variableAverageLabel.text = String(format: "%.2f", yearSum/Double(yearEntries))
        }
        else {
            variableLabel.text = "Last 10 Days"
            var sumTen = 0.0
            for labor in lastTenLabors {
                sumTen += labor.amount
            }
            variableAverageLabel.text = String(format: "%.2f", sumTen/Double(lastTenLabors.count))
        }
        difference = Double(allTimeAverageLabel.text!)! - Double(variableAverageLabel.text!)!
        if (difference > 0) {
            variableDifferenceLabel.text = "-" + String(format: "%.2f", abs(difference))
            variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
        else if (difference < 0) {
            variableDifferenceLabel.text = "+" + String(format: "%.2f", abs(difference))
            variableDifferenceLabel.textColor = UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1)
        }
        else {
            variableDifferenceLabel.text = "+/-" + String(format: "%.2f", abs(difference))
            variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
        self.tableView.reloadData()
        barChartUpdate()
        barChart.animate(xAxisDuration: 1.5, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
    }
    
    func barChartUpdate() {
        if (chartSwitch.selectedSegmentIndex == 0) {
            barChart.xAxis.labelCount = 12
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM"
            var numEntriesPerMonth = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
            var monthTotals = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
            for labor in allLaborsSorted {
                switch Int(dateFormatter.string(from: labor.date! as Date)) {
                case 1:
                    numEntriesPerMonth[0] += 1.0
                    monthTotals[0] += labor.amount
                    break
                case 2:
                    numEntriesPerMonth[1] += 1.0
                    monthTotals[1] += labor.amount
                    break
                case 3:
                    numEntriesPerMonth[2] += 1.0
                    monthTotals[2] += labor.amount
                    break
                case 4:
                    numEntriesPerMonth[3] += 1.0
                    monthTotals[3] += labor.amount
                    break
                case 5:
                    numEntriesPerMonth[4] += 1.0
                    monthTotals[4] += labor.amount
                    break
                case 6:
                    numEntriesPerMonth[5] += 1.0
                    monthTotals[5] += labor.amount
                    break
                case 7:
                    numEntriesPerMonth[6] += 1.0
                    monthTotals[6] += labor.amount
                    break
                case 8:
                    numEntriesPerMonth[7] += 1.0
                    monthTotals[7] += labor.amount
                    break
                case 9:
                    numEntriesPerMonth[8] += 1.0
                    monthTotals[8] += labor.amount
                    break
                case 10:
                    numEntriesPerMonth[9] += 1.0
                    monthTotals[9] += labor.amount
                    break
                case 11:
                    numEntriesPerMonth[10] += 1.0
                    monthTotals[10] += labor.amount
                    break
                case 12:
                    numEntriesPerMonth[11] += 1.0
                    monthTotals[11] += labor.amount
                    break
                default:
                    break
                }
            }
            for i in 0..<monthTotals.count{
                monthTotals[i] = monthTotals[i]/numEntriesPerMonth[i]
                if (monthTotals[i].isNaN) {
                    monthTotals[i] = 0.0
                }
            }
            barChart.xAxis.drawAxisLineEnabled = false
            barChart.xAxis.drawGridLinesEnabled = false
            setChart(dataEntryX: months, dataEntryY: monthTotals)
        }
        else {
            barChart.xAxis.labelCount = 10
            barChart.xAxis.drawAxisLineEnabled = false
            barChart.xAxis.drawGridLinesEnabled = false
            lastTenDays = [String]()
            for i in 0..<lastTenLabors.count{
                lastTenDays.insert(String((lastTenLabors[lastTenLabors.count - (i+1)].date! as Date).dayNumberOfWeek()!), at: 0)
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
            setChart(dataEntryX: lastTenDays, dataEntryY: lastTenLaborAmounts)
        }
        barChart.notifyDataSetChanged()
    }
    
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    func setChart(dataEntryX forX:[String],dataEntryY forY: [Double]) {
        var dataEntries:[BarChartDataEntry] = []
        for i in 0..<forX.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(forY[i]) , data: months as AnyObject?)
            dataEntries.append(dataEntry)
        }
        var dataSet: BarChartDataSet
        if (chartSwitch.selectedSegmentIndex == 0) {
            dataSet = BarChartDataSet(entries: dataEntries, label: "Average Labor")
        }
        else {
            dataSet = BarChartDataSet(entries: dataEntries, label: "Labor")
        }
        dataSet.setColor(UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1))
        let data = BarChartData(dataSet: dataSet)
        barChart.data = data
        let xAxisValue = barChart.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
    }
    
    @objc func updateLaborTable(_ notification: Notification) {
        let fetchRequest: NSFetchRequest<Labor> = Labor.fetchRequest()
        do {
            let labors = try PersistenceService.context.fetch(fetchRequest)
            let sortedLabors = labors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.labors = sortedLabors
            allLaborsSorted = self.labors
        } catch{}
        lastTenLabors = [Labor]()
        lastTenLaborAmounts = [Double]()
        for labor in allLaborsSorted {
            if (lastTenLabors.count < 10) {
                lastTenLabors.insert(labor, at: 0)
                lastTenLaborAmounts.insert(labor.amount, at: 0)
            }
            else {
                break
            }
        }
        while (lastTenLaborAmounts.count < 10) {
            lastTenLaborAmounts.insert(0.0, at: 0)
        }
        var sum = 0.0
        for labor in self.labors {
            sum += labor.amount
        }
        allTimeAverageLabel.text = String(format: "%.2f", sum/Double(self.labors.count))
        allTimeEntriesLabel.text = "Entries: " + String(self.labors.count)
        var difference = 0.0
        if (chartSwitch.selectedSegmentIndex == 0) {
            variableLabel.text = "This Year"
            var yearSum = 0.0
            var yearEntries = 0
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let curYear = Calendar.current.component(.year, from: Date())
            for labor in self.labors {
                if (dateFormatter.string(from: labor.date! as Date) == String(curYear)) {
                    yearSum += labor.amount
                    yearEntries += 1
                }
            }
            variableAverageLabel.text = String(format: "%.2f", yearSum/Double(yearEntries))
        }
        else {
            variableLabel.text = "Last 10 Days"
            var sumTen = 0.0
            for labor in lastTenLabors {
                sumTen += labor.amount
            }
            variableAverageLabel.text = String(format: "%.2f", sumTen/Double(lastTenLabors.count))
        }
        difference = Double(allTimeAverageLabel.text!)! - Double(variableAverageLabel.text!)!
        if (difference > 0) {
            variableDifferenceLabel.text = "-" + String(format: "%.2f", abs(difference))
            variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
        else if (difference < 0) {
            variableDifferenceLabel.text = "+" + String(format: "%.2f", abs(difference))
            variableDifferenceLabel.textColor = UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1)
        }
        else {
            variableDifferenceLabel.text = "+/-" + String(format: "%.2f", abs(difference))
            variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        }
        lastTenLaborsSorted = lastTenLabors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
        self.tableView.reloadData()
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
        if (chartSwitch.selectedSegmentIndex == 0) {
            return labors.count
        }
        else {
            return lastTenLabors.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (chartSwitch.selectedSegmentIndex == 0) {
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
        else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            cell.textLabel?.text = lastTenLaborsSorted[indexPath.row].name!
            cell.detailTextLabel?.text = dateFormatter.string(from: lastTenLaborsSorted[indexPath.row].date! as Date)
            let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
            label.text = String(lastTenLaborsSorted[indexPath.row].amount)
            label.textAlignment = .right
            cell.accessoryView = label
            return cell
        }
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
                allLaborsSorted = self.labors
            } catch{}
            lastTenLabors = [Labor]()
            lastTenLaborAmounts = [Double]()
            for labor in allLaborsSorted {
                if (lastTenLabors.count < 10) {
                    lastTenLabors.insert(labor, at: 0)
                    lastTenLaborAmounts.insert(labor.amount, at: 0)
                }
                else {
                    break
                }
            }
            while (lastTenLaborAmounts.count < 10) {
                lastTenLaborAmounts.insert(0.0, at: 0)
            }
            var sum = 0.0
            for labor in self.labors {
                sum += labor.amount
            }
            allTimeAverageLabel.text = String(format: "%.2f", sum/Double(self.labors.count))
            allTimeEntriesLabel.text = "Entries: " + String(self.labors.count)
            var difference = 0.0
            if (chartSwitch.selectedSegmentIndex == 0) {
                variableLabel.text = "This Year"
                var yearSum = 0.0
                var yearEntries = 0
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy"
                let curYear = Calendar.current.component(.year, from: Date())
                for labor in self.labors {
                    if (dateFormatter.string(from: labor.date! as Date) == String(curYear)) {
                        yearSum += labor.amount
                        yearEntries += 1
                    }
                }
                variableAverageLabel.text = String(format: "%.2f", yearSum/Double(yearEntries))
            }
            else {
                variableLabel.text = "Last 10 Days"
                var sumTen = 0.0
                for labor in lastTenLabors {
                    sumTen += labor.amount
                }
                variableAverageLabel.text = String(format: "%.2f", sumTen/Double(lastTenLabors.count))
            }
            difference = Double(allTimeAverageLabel.text!)! - Double(variableAverageLabel.text!)!
            if (difference > 0) {
                variableDifferenceLabel.text = "-" + String(format: "%.2f", abs(difference))
                variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
            }
            else if (difference < 0) {
                variableDifferenceLabel.text = "+" + String(format: "%.2f", abs(difference))
                variableDifferenceLabel.textColor = UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1)
            }
            else {
                variableDifferenceLabel.text = "+/-" + String(format: "%.2f", abs(difference))
                variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
            }
            lastTenLaborsSorted = lastTenLabors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.tableView.reloadData()
            barChartUpdate()
        }
    }
}

extension ViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if (chartSwitch.selectedSegmentIndex == 0) {
            return months[Int(value)]
        }
        else {
            return lastTenDays[Int(value)]
        }
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}


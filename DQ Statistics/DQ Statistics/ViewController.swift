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
    @IBOutlet weak var combinedChart: CombinedChartView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    var labors = [Labor]()
    var yearlyLabors = [Labor]()
    var lastTenLabors = [Labor]()
    var allTimeLaborTotals = [Double]()
    var allTimeLaborEntries = [Double]()
    var yearlyLaborTotals = [Double]()
    var yearlyLaborEntries = [Double]()
    var lastTenLaborTotals = [Double]()
    let months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var lastTenDays = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        customizeNavBar()
        axisFormatDelegate = self
        updateData()
        combinedChart.rightAxis.axisMinimum = 0.0
        combinedChart.leftAxis.axisMinimum = 0.0
        combinedChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        combinedChart.animate(xAxisDuration: 1.5, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLaborTable(_:)), name: Notification.Name(rawValue: "updateLaborTable"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    func combinedChartUpdate() {
        if (chartSwitch.selectedSegmentIndex == 0) {
            combinedChart.xAxis.labelCount = 11
            combinedChart.xAxis.drawAxisLineEnabled = false
            combinedChart.xAxis.drawGridLinesEnabled = false
            setChart(dataEntryX: months, allTimeY: allTimeLaborTotals, variableY: yearlyLaborTotals)
        }
        else {
            combinedChart.xAxis.labelCount = 9
            combinedChart.xAxis.drawAxisLineEnabled = false
            combinedChart.xAxis.drawGridLinesEnabled = false
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
            setChart(dataEntryX: lastTenDays, allTimeY: allTimeLaborTotals, variableY: lastTenLaborTotals)
        }
    }
    
    func setChart(dataEntryX forX:[String], allTimeY allTime: [Double], variableY variable:[Double]) {
        if (variable.count != allTime.count) {
            var variableData : [BarChartDataEntry] = [BarChartDataEntry]()
            
            for i in 0..<forX.count {
                variableData.append(BarChartDataEntry(x: Double(i), y: variable[i]))
            }
            let barChartSet: BarChartDataSet = BarChartDataSet(entries: variableData, label: "Last 10 Labors")
            barChartSet.setColor(UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1))
            let data: CombinedChartData = CombinedChartData()
            data.barData = BarChartData(dataSet: barChartSet)
            combinedChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: forX)
            combinedChart.data = data
        } else {
            var allTimeData : [ChartDataEntry] = [ChartDataEntry]()
            var variableData : [BarChartDataEntry] = [BarChartDataEntry]()
            
            for i in 0..<forX.count {
                allTimeData.append(ChartDataEntry(x: Double(i), y: allTime[i]))
                variableData.append(BarChartDataEntry(x: Double(i), y: variable[i]))
            }
            let lineChartSet = LineChartDataSet(entries: allTimeData, label: "All time labor average per month")
            lineChartSet.drawCircleHoleEnabled = false
            lineChartSet.circleRadius = 2
            lineChartSet.drawValuesEnabled = false
            let barChartSet: BarChartDataSet = BarChartDataSet(entries: variableData, label: "Yearly averages per month")
            barChartSet.setColor(UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1))
            
            let data: CombinedChartData = CombinedChartData()
            data.barData = BarChartData(dataSet: barChartSet)
            data.lineData = LineChartData(dataSet: lineChartSet)
            combinedChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: forX)
            combinedChart.xAxis.axisMinimum = -0.5
            combinedChart.xAxis.axisMaximum = Double(combinedChart.xAxis.labelCount - 1) - 0.5
            combinedChart.data = data
        }
    }
    
    func updateData() {
        let fetchRequest: NSFetchRequest<Labor> = Labor.fetchRequest()
        do {
            let labors = try PersistenceService.context.fetch(fetchRequest)
            let laborsSorted = labors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedDescending })
            self.labors = laborsSorted
        } catch{}
        yearlyLabors = [Labor]()
        lastTenLabors = [Labor]()
        allTimeLaborTotals = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        allTimeLaborEntries = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        yearlyLaborTotals = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        yearlyLaborEntries = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        lastTenLaborTotals = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        let curYear = Calendar.current.component(.year, from: Date())
        var laborNum = 9
        for labor in self.labors {
            if (laborNum >= 0) {
                lastTenLaborTotals[laborNum] = labor.amount
                lastTenLabors.append(labor)
                laborNum -= 1
            }
            let index = Int(monthFormatter.string(from: labor.date! as Date))! - 1
            allTimeLaborTotals[index] += labor.amount
            allTimeLaborEntries[index] += 1.0
            if (dateFormatter.string(from: labor.date! as Date) == String(curYear)) {
                yearlyLabors.insert(labor, at: 0)
                yearlyLaborEntries[index] += 1.0
                yearlyLaborTotals[index] += labor.amount
            }
        }
        lastTenLabors = lastTenLabors.sorted(by: { $0.date!.compare($1.date! as Date) == .orderedAscending })
        for i in 0..<allTimeLaborEntries.count {
            allTimeLaborTotals[i] = allTimeLaborTotals[i] / allTimeLaborEntries[i]
            if (allTimeLaborTotals[i].isNaN) { allTimeLaborTotals[i] = 0 }
            yearlyLaborTotals[i] = yearlyLaborTotals[i] / yearlyLaborEntries[i]
            if (yearlyLaborTotals[i].isNaN) { yearlyLaborTotals[i] = 0 }
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        var sum = 0.0
        for labor in self.labors {
            sum += labor.amount
        }
        allTimeAverageLabel.text = String(format: "%.2f", sum/Double(self.labors.count))
        allTimeEntriesLabel.text = "Entries: " + String(self.labors.count)
        var diff = 0.0
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
            diff = sum/Double(self.labors.count) - yearSum/Double(yearEntries)
        } else {
            variableLabel.text = "Last 10 Days"
            variableAverageLabel.text = numberFormatter.string(from: NSNumber(value: lastTenLaborTotals.reduce(0,+) / 10))!
            diff = sum/Double(self.labors.count) - lastTenLaborTotals.reduce(0,+) / 10
        }
        if (diff > 0) {
            variableDifferenceLabel.text = "-" + numberFormatter.string(from: NSNumber(value: abs(diff)))!
            variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        } else if (diff == 0) {
            variableDifferenceLabel.text = "+/-" + numberFormatter.string(from: NSNumber(value: abs(diff)))!
            variableDifferenceLabel.textColor = UIColor(red: 9/255, green: 158/255, blue: 4/255, alpha: 1)
        } else {
            variableDifferenceLabel.text = "+" + numberFormatter.string(from: NSNumber(value: abs(diff)))!
            variableDifferenceLabel.textColor = UIColor(red: 238/255, green: 62/255, blue: 66/255, alpha: 1)
        }
        self.tableView.reloadData()
        combinedChartUpdate()
    }
    
    @IBAction func chartFilterChanged(_ sender: UISegmentedControl) {
        updateData()
        combinedChart.animate(xAxisDuration: 1.5, yAxisDuration: 2.0, easingOption: .easeInOutQuart)
    }
    
    @objc func updateLaborTable(_ notification: Notification) {
        updateData()
    }
    
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
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
            let day = (labors[indexPath.row].date! as Date).dayNumberOfWeek()!
            var dayString = ""
            switch day {
            case 1:
                dayString = "Sun"
                break
            case 2:
                dayString = "Mon"
                break
            case 3:
                dayString = "Tue"
                break
            case 4:
                dayString = "Wed"
                break
            case 5:
                dayString = "Thu"
                break
            case 6:
                dayString = "Fri"
                break
            case 7:
                dayString = "Sat"
                break
            default:
                break
            }
            cell.detailTextLabel?.text = dayString + ": " + dateFormatter.string(from: labors[indexPath.row].date! as Date)
            let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
            label.text = String(labors[indexPath.row].amount)
            label.textAlignment = .right
            cell.accessoryView = label
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            cell.textLabel?.text = lastTenLabors[indexPath.row].name!
            let day = (lastTenLabors[indexPath.row].date! as Date).dayNumberOfWeek()!
            var dayString = ""
            switch day {
            case 1:
                dayString = "Sun"
                break
            case 2:
                dayString = "Mon"
                break
            case 3:
                dayString = "Tue"
                break
            case 4:
                dayString = "Wed"
                break
            case 5:
                dayString = "Thu"
                break
            case 6:
                dayString = "Fri"
                break
            case 7:
                dayString = "Sat"
                break
            default:
                break
            }
            cell.detailTextLabel?.text = dayString + ": " + dateFormatter.string(from: lastTenLabors[indexPath.row].date! as Date)
            let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
            label.text = String(lastTenLabors[indexPath.row].amount)
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
            updateData()
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


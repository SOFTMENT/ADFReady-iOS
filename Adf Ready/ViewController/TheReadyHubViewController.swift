//
//  TheReadyHubViewController.swift
//  Adf Ready
//
//  Created by Vijay Rathore on 16/11/24.
//

import UIKit
import DGCharts



class TheReadyHubViewController: UIViewController {
    
    @IBOutlet weak var steppingToADF: RoundedView!
    @IBOutlet weak var chartView: UIView!
    
    @IBOutlet weak var weekUntilStack: UIStackView!
    var stepsData: [StepData] = [] // Holds fetched steps data
    var lineChartView: LineChartView! // Chart view instance
    @IBOutlet weak var weeksUntilDayLbl: UILabel!
    var firstTime : Bool = false
    @IBOutlet weak var weeksView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        steppingToADF.isUserInteractionEnabled = true
        steppingToADF.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(steppingToADFButtonTapped)))
        
        weeksView.isUserInteractionEnabled = true
        weeksView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showActionSheet)))
        
        setupChartView()
        fetchStepsData()
        
        if let week = UserModel.data!.weeksUntil {
            self.weekUntilStack.isHidden = false
            self.weeksUntilDayLbl.text = "\(week) weeks"
        }
    }
    
    @objc func steppingToADFButtonTapped() {
        if UserModel.data?.stepEndDate != nil {
            self.performSegue(withIdentifier: "stepSeg", sender: nil)
        } else {
            firstTime = true
            self.showActionSheet()
        }
    }
    
    @objc func showActionSheet() {
        let actionSheet = UIAlertController(title: "Weeks until joining", message: nil, preferredStyle: .actionSheet)
        
        for week in 1...50 {
            actionSheet.addAction(UIAlertAction(title: "\(week)", style: .default, handler: { _ in
                self.ProgressHUDShow(text: "")
                if self.firstTime {
                    UserModel.data?.stepStartDate = Date()
                }
              
                UserModel.data?.weeksUntil = week
                self.weekUntilStack.isHidden = false
                self.weeksUntilDayLbl.text = "\(week) weeks"
                let calendar = Calendar.current
                let stepsPerDay = Double(7000) / Double(week * 7)
                if let endDate = calendar.date(byAdding: .day, value: week * 7, to: Date()) {
                    UserModel.data?.stepEndDate = endDate
                    UserModel.data?.perDayStepIncrement = Int(stepsPerDay)
                    FirebaseStoreManager.db.collection("Users").document(UserModel.data!.uid!).setData(["stepStartDate": self.firstTime ? Date() : UserModel.data!.stepStartDate!, "stepEndDate": endDate, "perDayStepIncrement": Int(stepsPerDay),"weeksUntil": week], merge: true) { error in
                        self.ProgressHUDHide()
                        if let error = error {
                            self.showError(error.localizedDescription)
                        } else {
                            self.performSegue(withIdentifier: "stepSeg", sender: nil)
                        }
                    }
                }
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func setupChartView() {
        // Initialize and configure the LineChartView
        lineChartView = LineChartView()
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.addSubview(lineChartView)
        
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: chartView.topAnchor),
            lineChartView.bottomAnchor.constraint(equalTo: chartView.bottomAnchor),
            lineChartView.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
            lineChartView.trailingAnchor.constraint(equalTo: chartView.trailingAnchor)
        ])
        
        lineChartView.rightAxis.enabled = false // Disable right Y-axis
        lineChartView.xAxis.labelPosition = .bottom // X-axis labels at the bottom
        lineChartView.xAxis.drawGridLinesEnabled = false // No grid lines for X-axis
        lineChartView.leftAxis.drawGridLinesEnabled = true // Enable grid lines for Y-axis
        lineChartView.legend.horizontalAlignment = .center
        lineChartView.legend.verticalAlignment = .top
        lineChartView.legend.form = .circle
        lineChartView.chartDescription.text = "Steps Progression"
        lineChartView.chartDescription.font = .systemFont(ofSize: 12)
        lineChartView.chartDescription.textColor = .darkGray
    }
    
    private func fetchStepsData() {
        if let startDate = UserModel.data!.stepStartDate {
            let calendar = Calendar.current
            let startDate = calendar.startOfDay(for: startDate.addingTimeInterval(-24 * 60 )) // 7 days ago
            let endDate = Date() // Now (today)

            StepCounterManager().fetchStepsData(startDate: startDate, endDate: endDate) { stepResults in
                DispatchQueue.main.async {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MMMM-yyyy"
                    
                    self.stepsData = stepResults.map { StepData(date: $0.key, totalSteps: $0.value) }
                    self.stepsData.sort {
                        guard let date1 = formatter.date(from: $0.date),
                              let date2 = formatter.date(from: $1.date) else { return false }
                        return date1 < date2
                    }
                    
                    self.updateChart()
                }
            }
        }
        else {
            updateChart()
        }
       
    }
    
    private func updateChart() {
        guard !stepsData.isEmpty else {
            lineChartView.data = nil
            lineChartView.noDataText = "No steps data available."
            lineChartView.noDataTextColor = .gray
            lineChartView.noDataFont = .systemFont(ofSize: 14)
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMMM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        // Sort stepsData by date
        stepsData.sort {
            guard let date1 = formatter.date(from: $0.date),
                  let date2 = formatter.date(from: $1.date) else { return false }
            return date1 < date2
        }

        // Keep only the last 10 records
        if stepsData.count > 10 {
            stepsData = Array(stepsData.suffix(10))
        }

        // Prepare data entries and X-axis labels
        var entries: [ChartDataEntry] = []
        var days: [String] = []

        for (index, stepData) in stepsData.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: Double(stepData.totalSteps)))
            if let day = stepData.date.components(separatedBy: "-").first {
                days.append(day)
            }
        }

        let dataSet = LineChartDataSet(entries: entries, label: "Steps")
        dataSet.colors = [.systemBlue]
        dataSet.circleColors = [.systemBlue]
        dataSet.circleRadius = 3.0
        dataSet.valueColors = [.darkGray]
        dataSet.valueFont = .systemFont(ofSize: 10)

        let chartData = LineChartData(dataSet: dataSet)
        lineChartView.data = chartData

        // Handle X-axis labels
        if days.count == 1 {
            // Add a dummy entry for better scaling when there’s only one data point
            days.append("")
            entries.append(ChartDataEntry(x: 1.0, y: 0.0)) // Add a dummy entry
            lineChartView.xAxis.valueFormatter = CustomAxisValueFormatter(values: days)
        } else if days.count > 6 {
            lineChartView.xAxis.valueFormatter = CustomAxisValueFormatter(values: Array(days.suffix(6)))
        } else {
            lineChartView.xAxis.valueFormatter = CustomAxisValueFormatter(values: days)
        }

        // Configure X-axis
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.setLabelCount(days.count, force: true)
        lineChartView.xAxis.labelRotationAngle = 0
        lineChartView.xAxis.labelPosition = .bottom

        // Configure Y-axis to handle a single data point
        lineChartView.leftAxis.axisMinimum = 0
        if stepsData.count == 1 {
            lineChartView.leftAxis.axisMaximum = max(Double(stepsData.first?.totalSteps ?? 0) * 1.5, 1000) // Add padding
        } else {
            lineChartView.leftAxis.resetCustomAxisMax()
        }

        lineChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
    }



}

class MyCustomAxisValueFormatter: AxisValueFormatter {
    private let values: [String]

    init(values: [String]) {
        self.values = values
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value.rounded()) // Round the value to the nearest index
        guard index >= 0 && index < values.count else {
            return "" // Return an empty string if the index is out of bounds
        }
        return values[index]
    }
}

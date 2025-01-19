import UIKit

class SteppingToAdfViewController: UIViewController {
    @IBOutlet weak var backView: UIImageView!
    @IBOutlet weak var todaysGoalLbl: UILabel!
    @IBOutlet weak var todaysCompletedLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mTitle: UILabel!
    
    let stepManager = StepCounterManager() // Step Counter Manager instance
    var stepsData: [StepData] = [] // Data source for the table view

    override func viewDidLoad() {
        super.viewDidLoad()

        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnTapped)))

        setupTableView()
        fetchStepsData()
        
        tableView.showsVerticalScrollIndicator = false
        todaysGoalLbl.text = "\(calculateTodaysGoal(from: UserModel.data!.stepStartDate!, to: Date()))"
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: UserModel.data!.stepStartDate!)
        let endOfDay = calendar.startOfDay(for: Date())
        
        // Calculate the difference in days
        let components = calendar.dateComponents([.day], from: startOfDay, to: endOfDay)
        mTitle.text = "Stepping towards ADF - Day \((components.day ?? 0) + 1)"
    }

    @objc func backBtnTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    func calculateTodaysGoal(from startDate: Date, to endDate: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.startOfDay(for: endDate)
        
        // Calculate the difference in days
        let components = calendar.dateComponents([.day], from: startOfDay, to: endOfDay)
        return  3000 + ((components.day ?? 0) * UserModel.data!.perDayStepIncrement!)
        
    }
    
    private func fetchStepsData() {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: UserModel.data!.stepStartDate!.addingTimeInterval(-24 * 60 )) // 7 days ago
        var endDate = Date() // Now (today)
        
        if endDate >= UserModel.data!.stepEndDate! {
            self.showToast(message: "You have reached your ADF goal!)")
            endDate = UserModel.data!.stepEndDate!
        }

        stepManager.requestAuthorization { [weak self] success in
            if success {
                self?.stepManager.fetchStepsData(startDate: startDate, endDate: endDate) { stepResults in
                    DispatchQueue.main.async {
                        guard let self = self else { return }

                        // Convert stepResults into StepData array
                        let outputFormatter = DateFormatter()
                        outputFormatter.dateFormat = "dd-MMMM-yyyy"

                        self.stepsData = stepResults.map { StepData(date: $0.key, totalSteps: $0.value) }
                        self.stepsData.sort {
                            guard let date1 = outputFormatter.date(from: $0.date),
                                  let date2 = outputFormatter.date(from: $1.date) else { return false }
                            return date1 > date2
                        }

                        // Update today's step count
                        if let todaySteps = stepResults[outputFormatter.string(from: Date())] {
                            self.todaysCompletedLbl.text = "You've completed \(todaySteps) steps today."
                        } else {
                            self.todaysCompletedLbl.text = "You've completed 0 steps today."
                            if self.stepsData.count == 0 {
                                let stepData = StepData(date: outputFormatter.string(from: Date()), totalSteps: 0)
                                self.stepsData.append(stepData)
                            }
                        }

                        // Reload table view
                        self.tableView.reloadData()
                    }
                }
            } else {
                print("HealthKit authorization failed.")
            }
        }
    }
    func convertToDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMMM-yyyy" // The format should match your string
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
        return formatter.date(from: dateString)
    }
}

extension SteppingToAdfViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stepsData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell", for: indexPath) as? StepTableViewCell else {
            return UITableViewCell()
        }

        let stepData = stepsData[indexPath.row]
        cell.stepsLbl.text = "Steps: \(stepData.totalSteps)"
        cell.dateLbl.text = stepData.date
        
        let goal = calculateTodaysGoal(from: UserModel.data!.stepStartDate!, to: self.convertToDate(from: stepData.date)!)
       
        if goal - stepData.totalSteps > 200 {
            cell.mView.backgroundColor = UIColor(red: 244/255, green: 67/255, blue: 54/255, alpha: 0.76)
            
        }
        else if goal - stepData.totalSteps > 0 && goal - stepData.totalSteps <= 200  {
            
            cell.mView.backgroundColor = UIColor(red: 255/255, green: 152/255, blue: 0/255, alpha: 0.76)
        }
        else if goal - stepData.totalSteps <= 0 {
            cell.mView.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 0.76)
        }

        return cell
    }
}

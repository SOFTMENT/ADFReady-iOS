import UIKit
import DGCharts

class ProfileViewController: UIViewController {
    @IBOutlet weak var serviceView: UIView!
    @IBOutlet weak var serviceLbl: UILabel!
    @IBOutlet weak var sessionCompletedLbl: UILabel!
   
    @IBOutlet weak var pushChart: UIView!
    @IBOutlet weak var sitChart: UIView!
    @IBOutlet weak var beepChart: UIView!
    
    var pushChartView: LineChartView!
    var sitChartView: LineChartView!
    var beepChartView: LineChartView!
    
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var adminPanelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = UserModel.data else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        if FirebaseStoreManager.auth.currentUser!.uid == "BIfLoGIMIqe10WM6T1YaaSgFHth1" {
            adminPanelBtn.isHidden = false
        }
        
        fullName.text = user.fullName ?? ""
        emailAddress.text = user.email ?? ""
        
        // Initialize charts
        setupChartViews()
        
        serviceView.isUserInteractionEnabled = true
        serviceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(serviceClicked)))
        
        if let service = user.service {
            serviceLbl.text = service
        }
    }
    
    @IBAction func adminPanelClicked(_ sender: Any) {
        self.beRootScreen(mIdentifier: Constants.StroyBoard.adminViewController)
    }
    
    @objc func serviceClicked() {
            showServiceSelection()
        }
    
    @objc func showServiceSelection() {
          let alertController = UIAlertController(title: "Select Service", message: nil, preferredStyle: .actionSheet)
          
        for state in Constants.services {
              let action = UIAlertAction(title: state, style: .default) { _ in
                  self.serviceLbl.text = state
                  self.setUserType(state)
                
              }
              alertController.addAction(action)
          }
          
          // Add a cancel option
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alertController.addAction(cancelAction)
          
          
          present(alertController, animated: true, completion: nil)
      }
    func setUserType(_ service : String) {
           self.ProgressHUDShow(text: "")
           UserModel.data?.service = service
           FirebaseStoreManager.db.collection("Users").document(FirebaseStoreManager.auth.currentUser!.uid)
               .setData(["service":service], merge: true) { error in
                   self.ProgressHUDHide()
                   if let error = error {
                       self.showError(error.localizedDescription)
                   }
                   else {
                       UserModel.data!.service = service
                       self.showToast(message: "Service has been changed.")
                       DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                           self.beRootScreen(mIdentifier: Constants.StroyBoard.tabBarViewController)
                           
                       }
                   }
                   
               }
               
           }
    
    @IBAction func logoutClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userId = FirebaseStoreManager.auth.currentUser!.uid
        let month = getCurrentMonth()
        setupChartData(userId: userId, month: month)
        
        let query = FirebaseStoreManager.db
            .collection("Users")
            .document(userId)
            .collection("Completed")
        
        let countQuery = query.count
        countQuery.getAggregation(source: .server) { snapshot, error in
            if let snapshot = snapshot {
               
                self.sessionCompletedLbl.text = "\(snapshot.count) Sessions Completed"
             //   let count = Int(truncating: snapshot.count)
                //self.updateBadge(for: count)
            }
            
        }
    }
    
    func setupChartViews() {
        pushChartView = LineChartView()
        sitChartView = LineChartView()
        beepChartView = LineChartView()
        
        setupChartView(pushChartView, in: pushChart)
        setupChartView(sitChartView, in: sitChart)
        setupChartView(beepChartView, in: beepChart)
    }
    
    func setupChartView(_ chartView: LineChartView, in containerView: UIView) {
        chartView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(chartView)
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: containerView.topAnchor),
            chartView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            chartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        chartView.backgroundColor = .white
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
    }
    
    func getCurrentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
    
    func setupChartData(userId: String, month: String) {
        let db = FirebaseStoreManager.db
        let dailyEntriesRef = db.collection("Users").document(userId).collection("pfa")
        
        dailyEntriesRef
            .whereField("submittedAt", isGreaterThanOrEqualTo: startOfMonth(month: month))
            .whereField("submittedAt", isLessThanOrEqualTo: endOfMonth(month: month))
            .order(by: "submittedAt")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching fitness data: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                var days: [String] = []
                var pushUps: [Double] = []
                var sitUps: [Double] = []
                var beepTests: [Double] = []
                
                for document in documents {
                    if let date = document.documentID.split(separator: "-").last,
                       let day = Int(date) {
                        days.append("\(day)")
                        let data = document.data()
                        pushUps.append(data["pushUps"] as? Double ?? 0.0)
                        sitUps.append(data["sitUps"] as? Double ?? 0.0)
                        beepTests.append(data["beepTest"] as? Double ?? 0.0)
                    }
                }
                
                self.updateChart(self.pushChartView, with: pushUps, days: days, label: "Push-Ups", color: .red)
                self.updateChart(self.sitChartView, with: sitUps, days: days, label: "Sit-Ups", color: .blue)
                self.updateChart(self.beepChartView, with: beepTests, days: days, label: "Beep Test", color: .green)
            }
    }
    
    func updateChart(_ chartView: LineChartView, with dataPoints: [Double], days: [String], label: String, color: UIColor) {
        var entries: [ChartDataEntry] = []
        for (index, value) in dataPoints.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: value))
        }
        
        let dataSet = LineChartDataSet(entries: entries, label: label)
        dataSet.colors = [color]
        dataSet.circleColors = [color]
        dataSet.circleRadius = 3.0
        
        let chartData = LineChartData(dataSet: dataSet)
        chartView.data = chartData
        
        chartView.xAxis.valueFormatter = CustomAxisValueFormatter(values: days)
        chartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5)
    }
    
    func startOfMonth(month: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        guard let date = formatter.date(from: month) else { return Date() }
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
    }
    
    func endOfMonth(month: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        guard formatter.date(from: month) != nil else { return Date() }
        let startOfNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth(month: month))!
        return Calendar.current.date(byAdding: .day, value: -1, to: startOfNextMonth)!
    }
    
//    func updateBadge(for count: Int) {
//        if count >= 5 && count < 10 {
//            earnedBadgeImg.image = UIImage(named: "blueready")
//        } else if count >= 10 && count < 20 {
//            earnedBadgeImg.image = UIImage(named: "redready")
//        } else if count >= 20 && count < 30 {
//            earnedBadgeImg.image = UIImage(named: "skyready")
//        } else if count >= 30 {
//            earnedBadgeImg.image = UIImage(named: "completeready")
//        }
//    }
}
// Custom X-Axis Value Formatter
class CustomAxisValueFormatter: AxisValueFormatter {
    private let values: [String]

    init(values: [String]) {
        self.values = values
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        guard index >= 0 && index < values.count else { return "" }
        return values[index]
    }
}

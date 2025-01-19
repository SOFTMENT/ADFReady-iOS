import UIKit
import HealthKit

class StepCounterManager {
    let healthStore = HKHealthStore()
    
    // Request authorization to access step count data
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        if HKHealthStore.isHealthDataAvailable() {
            let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
            healthStore.requestAuthorization(toShare: nil, read: [stepType]) { success, error in
                if let error = error {
                    print("Authorization Error: \(error.localizedDescription)")
                }
                completion(success)
            }
        } else {
            completion(false)
        }
    }
    
    // Fetch steps data for a given date range
    func fetchStepsData(startDate: Date, endDate: Date, completion: @escaping ([String: Int]) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        // Define a time predicate for the query
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Define the query to fetch step data
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: [.cumulativeSum],
            anchorDate: startDate,
            intervalComponents: DateComponents(day: 1)
        )
        
        // Process query results
        query.initialResultsHandler = { _, results, error in
            if let error = error {
                print("Error fetching step data: \(error.localizedDescription)")
                completion([:]) // Return empty data on error
                return
            }
            
            guard let results = results else {
                print("No step data available.")
                completion([:]) // Return empty data if no results
                return
            }
            
            var stepsData: [String: Int] = [:]
            
            // Formatter for generating the key format (e.g., "19-November-2024")
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd-MMMM-yyyy"
            
            results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: .count()))
                    let date = statistics.startDate
                    let dateString = outputFormatter.string(from: date) // Custom format
                    stepsData[dateString] = steps
                }
            }
            
            completion(stepsData)
        }
        
        // Execute the query
        healthStore.execute(query)
    }
}

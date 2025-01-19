//
//  GooglePlacesManager.swift
//  Royal Australian Navy Fitness
//
//  Created by Vijay Rathore on 26/01/24.
//

import Foundation
import AWSLocationXCF
import CoreLocation

struct Place {
    let name: String?
    let identifier: String?
    let coordinates: CLLocationCoordinate2D?  // Make sure this is optional if it can be absent
}



final class PlacesManager {
    static let shared = PlacesManager()
    private let client = AWSLocation.default()
    
    enum PlacesError: Error {
        case failedToFind
        case failedToFindCoordinates
    }
    
    private init() {}

    public func findPlaces(query: String, completion: @escaping (Result<[Place], Error>) -> Void) {
        let request = AWSLocationSearchPlaceIndexForTextRequest()
        request?.text = query
        // Set the index name you've created in your AWS Location Service
        request?.indexName = "RoyalAusFitnessIndex"
        // Optionally, you can specify the maximum number of results to return
        request?.maxResults = 10
        request?.filterCountries = ["AUS"]
        
        client.searchPlaceIndex(forText: request!) { response, error in
            guard let response = response, error == nil else {
                completion(.failure(PlacesError.failedToFind))
                return
            }
            
          
            let places: [Place] = response.results?.compactMap { result in
                guard let label = result.place?.label,
                      let placeId = result.placeId else {
                    return Place(name: nil, identifier: nil, coordinates: nil)
                }

                // If the coordinates are not available, the Place can still be returned with nil coordinates
                let coordinates: CLLocationCoordinate2D?
                if let lat = result.place?.geometry?.point?[1], let lon = result.place?.geometry?.point?[0] {
                    coordinates = CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
                } else {
                    coordinates = nil  // Coordinates are optional, so it's okay to set them to nil
                }
                
                // Return a Place with whatever information is available
                return Place(name: label, identifier: placeId, coordinates: coordinates)
            } ?? []  // In case results are nil, default to an empty array

            completion(.success(places))
            
            
           
        }
    }
    
  
}

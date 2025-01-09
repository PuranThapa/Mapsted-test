//
//  ApiService.swift
//  Mapsted Test
//
//  Created by Shree Ram on 07/01/25.
//

import Foundation

class ApiService {
    
    func fetchBuildingData(callBack: @escaping (Result<[Building], Error>) -> Void) {
        
        let stURL = BASE_URL + API_GET_BUILDING_DATA
        
        let url = URL(string: stURL)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error {
                callBack(.failure(error))
                return
            }
            
            let responseCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            if responseCode != 200 {
                callBack(.failure(AppError("Response error")))
                return
            }
            
            guard let data else {
                callBack(.failure(AppError("No data error")))
                return
            }
            
            do {
               let building = try JSONDecoder().decode([Building].self, from: data)
                callBack(.success(building))
            } catch let e {
                callBack(.failure(e))
                print("Error decoding: \(e)")
            }
        }.resume()
        
    }
    
    func fetchAnalyticData(callBack: @escaping (Result<[Analytic], Error>) -> Void) {
        
        let stURL = BASE_URL + API_GET_ANALYTIC_DATA
        
        let url = URL(string: stURL)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error {
                callBack(.failure(error))
                return
            }
            
            let responseCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            if responseCode != 200 {
                callBack(.failure(AppError("Response error")))
                return
            }
            
            guard let data else {
                callBack(.failure(AppError("No data error")))
                return
            }
            
            do {
                let analytic = try JSONDecoder().decode([Analytic].self, from: data)
                callBack(.success(analytic))
            } catch let e {
                callBack(.failure(e))
                print("Error decoding: \(e)")
            }
        }.resume()
        
    }
    
}

//
//  NetworkManager.swift
//  SeeSea
//
//  Created by 소정섭 on 9/20/24.
//

import Foundation

struct BeachData: Decodable {
    let response: Response
}
struct Response: Decodable {
    let body: Items
}
struct Items : Decodable {
    let items: Item
}
struct Item: Decodable {
    let item: [WaveHeight]
}
struct WaveHeight: Decodable {
    let beachNum: String
    let wh: String
}

enum APIEndPoint {
    case forecastData(date: String, time: String)
    case beachData(searchTime: String)
    case waterTemperature(searchTime: String)
    
    var path: String {
        switch self {
        case .forecastData:
            return "/getVilageFcstBeach"
        case .beachData:
            return "/getWhBuoyBeach"
        case .waterTemperature:
            return "/getTwBuoyBeach"
        }
    }
    func queryItems(beachNum: String) -> [URLQueryItem] {
        var items = [
            URLQueryItem(name: "dataType", value: "JSON"),
            URLQueryItem(name: "beach_num", value: beachNum)
        ]
        
        switch self {
        case .forecastData(let date, let time):
            items += [
                URLQueryItem(name: "base_date", value: date),
                URLQueryItem(name: "base_time", value: time),
                URLQueryItem(name: "numOfRows", value: "10000")
            ]
        case .beachData(let searchTime), .waterTemperature(let searchTime):
            items += [
                URLQueryItem(name: "searchTime", value: searchTime)
            ]
        }
        return items
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    private func createRequest(for endpoint: APIEndPoint, beachNum: String) -> URLRequest? {
        var compoenets = URLComponents(string: APIKey.baseURL + endpoint.path)
        compoenets?.queryItems = endpoint.queryItems(beachNum: beachNum)
        
        guard var urlString = compoenets?.url?.absoluteString else { return nil }
        urlString += "&serviceKey=\(APIKey.serviceKey)"
        
        guard let url = URL(string: urlString) else { return nil }
        
        return URLRequest(url: url)
    }
    
    func fetchForecastData(beachNum: String, completion: @escaping (Result<[ForecastItem], Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let currentTime = dateFormatter.string(from: Date())
        
        let calendar = Calendar.current
        let threeHoursAgo = calendar.date(byAdding: .hour, value: -3, to: Date())!
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmm"
        let baseTime = timeFormatter.string(from: threeHoursAgo)

        let endpoint = APIEndPoint.forecastData(date: currentTime, time: baseTime)
        guard let request = createRequest(for: endpoint, beachNum: beachNum) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            print("파도예보 요기다",request)

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            //debuging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
            }
            

            do {
                let decoder = JSONDecoder()
                let forecastResponse = try decoder.decode(ForecastResponse.self, from: data)
                completion(.success(forecastResponse.response.body.items.item))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchWaterData(beachNum: String, completion: @escaping (Result<WaveHeight, Error>) -> Void ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let currentTime = dateFormatter.string(from: Date())
        
        let endpoint = APIEndPoint.waterTemperature(searchTime: currentTime)
        guard let request = createRequest(for: endpoint, beachNum: beachNum) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        print("파고 요기다",request)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(BeachData.self, from: data)
                if let item = apiResponse.response.body.items.item.first {
                    completion(.success(item))
                } else {
                    completion(.failure(NetworkError.NoItems))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchBeachData(beachNum: String, completion: @escaping (Result<WaveHeight, Error>) -> Void ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let currentTime = dateFormatter.string(from: Date())
        
        let endpoint = APIEndPoint.beachData(searchTime: currentTime)
        guard let request = createRequest(for: endpoint, beachNum: beachNum) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        print("파고 요기다",request)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(BeachData.self, from: data)
                if let item = apiResponse.response.body.items.item.first {
                    completion(.success(item))
                } else {
                    completion(.failure(NetworkError.NoItems))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case NoItems
}


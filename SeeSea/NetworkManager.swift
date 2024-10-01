//
//  NetworkManager.swift
//  SeeSea
//
//  Created by 소정섭 on 9/20/24.
//

import Foundation

struct WhData: Decodable {
    let response: WhResponse
}
struct WhResponse: Decodable {
    let body: WhItems
}
struct WhItems : Decodable {
    let items: WhItem
}
struct WhItem: Decodable {
    let item: [WaveHeight]
}
struct WaveHeight: Decodable {
    let beachNum: String
    let wh: String
}

struct WtData: Decodable {
    let response: WtResponse
}
struct WtResponse: Decodable {
    let body: WtItems
}
struct WtItems : Decodable {
    let items: WtItem
}
struct WtItem: Decodable {
    let item: [WaveTemperature]
}
struct WaveTemperature: Decodable {
    let beachNum: String
    let tw: String
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
        let now = Date()
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let currentDate = dateFormatter.string(from: now)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmm"
        
        let baseTimes = [0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300]
        let apiProvisionTime = 10 // API 제공 시간은 각 base time 후 10분
        
        // 현재 시간에서 API 제공 시간을 뺀 시간 계산
        let adjustedDate = calendar.date(byAdding: .minute, value: -apiProvisionTime, to: now)!
        
        // 가장 가까운 이전 base_time 찾기
        var baseTime = baseTimes.last!
        for time in baseTimes.reversed() {
            let baseDate = calendar.date(bySettingHour: time / 100, minute: time % 100, second: 0, of: adjustedDate)!
            if baseDate <= adjustedDate {
                baseTime = time
                break
            }
        }
        
        let baseTimeString = String(format: "%04d", baseTime)
        
        print("Current time: \(timeFormatter.string(from: now))")
        print("Adjusted time: \(timeFormatter.string(from: adjustedDate))")
        print("Selected base time: \(baseTimeString)")
        
        let endpoint = APIEndPoint.forecastData(date: currentDate, time: baseTimeString)
        guard let request = createRequest(for: endpoint, beachNum: beachNum) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
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
    func fetchWhData(beachNum: String, completion: @escaping (Result<WaveHeight, Error>) -> Void ) {
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
                let apiResponse = try decoder.decode(WhData.self, from: data)
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
    
    func fetchWtData(beachNum: String, completion: @escaping (Result<WaveTemperature, Error>) -> Void ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let currentTime = dateFormatter.string(from: Date())
        
        let endpoint = APIEndPoint.waterTemperature(searchTime: currentTime)
        guard let request = createRequest(for: endpoint, beachNum: beachNum) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        print("수온 요기다",request)

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
                let apiResponse = try decoder.decode(WtData.self, from: data)
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
                let apiResponse = try decoder.decode(WhData.self, from: data)
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


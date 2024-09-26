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

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchBeachData(beachNum: String, completion: @escaping (Result<WaveHeight, Error>) -> Void ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        let currentTime = dateFormatter.string(from: Date())
        
        let baseURL = "https://apis.data.go.kr/1360000/BeachInfoservice/getWhBuoyBeach?serviceKey=\(APIKey.serviceKey)&dataType=JSON&beach_num=\(beachNum)&searchTime=\(currentTime)"
        
        //let queryItems = [
            //URLQueryItem(name: "serviceKey", value: APIKey.serviceKey),// serviceKey가 이미 인코딩되어 있으므로, 디코딩 후 다시 인코딩
//            URLQueryItem(name: "dataType", value: "JSON"),
//            URLQueryItem(name: "beach_num", value: beachNum),
//            URLQueryItem(name: "searchTime", value: currentTime)
       // ]
        
        let urlComps = URLComponents(string: baseURL)!
        //urlComps.queryItems = queryItems
        
        guard let url = urlComps.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task: Void = URLSession.shared.dataTask(with: url) { data, response, error in
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
            
//            //디버깅
//            if let responseString = String(data: data, encoding: .utf8) {
//                print("디버깅: \(responseString)")
//            }
            
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


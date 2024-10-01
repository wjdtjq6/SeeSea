//
//  WaveForecastViewModel.swift
//  SeeSea
//
//  Created by 소정섭 on 9/28/24.
//

import Foundation

struct ForecastResponse: Decodable {
    let response: ForecastResponseBody
}
struct ForecastResponseBody: Decodable {
    let body: ForecastBody
}
struct ForecastBody: Decodable {
    let items: ForecastItems
}
struct ForecastItems: Decodable {
    let item: [ForecastItem]
}
struct ForecastItem: Decodable {
    let category: String
    let fcstDate: String
    let fcstTime: String
    let fcstValue: String
    var uuu: String
    var vvv: String
    var wsd: String
    var tmp: String
    var wav: String
}

class WaveForecastViewModel: ObservableObject {
    @Published var forecastItems: [ForecastItem] = []
    
    func fetchForecastData(for beachNum: String) {
            NetworkManager.shared.fetchForecastData(beachNum: beachNum) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let items):
                        self?.processForecastItems(items)
                    case .failure(let error):
                        print("Error fetching forecast data: \(error)")
                    }
                }
            }
        }
    
    private func processForecastItems(_ items: [ForecastItem]) {
            var tempItems: [String: ForecastItem] = [:]
            
            for item in items {
                let key = item.fcstDate + item.fcstTime
                if var existingItem = tempItems[key] {
                    switch item.category {
                    case "UUU": existingItem.uuu = item.fcstValue
                    case "VVV": existingItem.vvv = item.fcstValue
                    case "WSD": existingItem.wsd = item.fcstValue
                    case "TMP": existingItem.tmp = item.fcstValue
                    case "WAV": existingItem.wav = item.fcstValue
                    default: break
                    }
                    tempItems[key] = existingItem
                } else {
                    tempItems[key] = item
                }
            }
            
            forecastItems = Array(tempItems.values).sorted { $0.fcstDate + $0.fcstTime < $1.fcstDate + $1.fcstTime }
        }
}

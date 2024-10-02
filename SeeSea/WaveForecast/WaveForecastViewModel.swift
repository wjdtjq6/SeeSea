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
}

struct CombinedForecastItem {
    let fcstDate: String
    let fcstTime: String
    let uuu: String
    let vvv: String
    let wsd: String
    let tmp: String
    let wav: String
    let sky: String
    let pty: String
}

class WaveForecastViewModel: ObservableObject {
    @Published var forecastItems: [ForecastItem] = []
    @Published var combinedForecastItems: [CombinedForecastItem] = []

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
        var tempItems: [String: [String: String]] = [:]
        
        for item in items {
            let key = item.fcstDate + item.fcstTime
            if tempItems[key] == nil {
                tempItems[key] = [:]
            }
            tempItems[key]?[item.category] = item.fcstValue
        }
        
        combinedForecastItems = tempItems.map { (key, value) in
            CombinedForecastItem(
                fcstDate: String(key.prefix(8)),
                fcstTime: String(key.suffix(4)),
                uuu: value["UUU"] ?? "",
                vvv: value["VVV"] ?? "",
                wsd: value["WSD"] ?? "",
                tmp: value["TMP"] ?? "",
                wav: value["WAV"] ?? "",
                sky: value["SKY"] ?? "",
                pty: value["PTY"] ?? ""
            )
        }.sorted { $0.fcstDate + $0.fcstTime < $1.fcstDate + $1.fcstTime }
    }
}

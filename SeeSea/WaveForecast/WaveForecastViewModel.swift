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
    //let id = UUID()
    let category: String
    let fcstDate: String
    let fcstTime: String
    let fcstValue: String
}
class WaveForecastViewModel: ObservableObject {
    @Published var forecastItems: [ForecastItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    let viewModel = BeachViewModel()
    init() {
        fetchData(Beach.init(name: "", coordinate: .dadaepo, beachNum: "", url: "", category: ""))
    }
    
    func fetchData(_ beach: Beach) {
        isLoading = true
        NetworkManager.shared.fetchForecastData(beachNum: beach.beachNum) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.forecastItems = items
                    print("성공하면 혁명아닙니까",items)
                case .failure(let error):
                    self?.error = error
                    print("실패하면 반역",error)
                }
            }
        }
    }
    
    var groupedForecastItems: [String: [ForecastItem]] {
        Dictionary(grouping: forecastItems, by: { $0.fcstDate })
    }
    
    func categoryItems(for date: String, time: String) -> [ForecastItem] {
        forecastItems.filter { $0.fcstDate == date && $0.fcstTime == time }
    }
    
    func categoryName(_ category: String) -> String {
        switch category {
        case "TMP": return "기온"
        case "UUU": return "동서바람성분"
        case "VVV": return "남북바람성분"
        case "VEC": return "풍향"
        case "WSD": return "풍속"
        case "SKY": return "하늘상태"
        case "PTY": return "강수형태"
        case "POP": return "강수확률"
        case "WAV": return "파고"
        case "PCP": return "1시간 강수량"
        case "REH": return "습도"
        case "SNO": return "1시간 신적설"
        case "TMN": return "일 최저기온"
        case "TMX": return "일 최고기온"
        default: return category
        }
    }
    
    func unitForCategory(_ category: String) -> String {
        switch category {
        case "TMP", "TMN", "TMX": return "℃"
        case "UUU", "VVV", "WSD": return "m/s"
        case "VEC": return "deg"
        case "POP", "REH": return "%"
        case "WAV": return "m"
        default: return ""
        }
    }
}

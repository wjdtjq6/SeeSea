//
//  BeachViewModel.swift
//  SeeSea
//
//  Created by 소정섭 on 9/19/24.
//

import Foundation
import CoreLocation

struct Beach {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let beachNum: String
}

struct BeachData: Decodable {
    let response: Response
}
struct Response: Decodable {
    let body: Items
}
struct Items : Decodable {
    let item: [WaveHeight]
}
struct WaveHeight: Decodable {
    let beachNum: String
    let wh: String
}

class BeachViewModel: ObservableObject {
    @Published var beaches: [Beach] = [
        Beach(name: "월정리 해수욕장", coordinate: .woljeongri, beachNum: "29"),
        Beach(name: "삼양검은 모래 해수욕장", coordinate: .samyangBlackSand, beachNum: "349"),
        Beach(name: "송정 해수욕장", coordinate: .songjeong, beachNum: "173"),
        Beach(name: "경포 해수욕장", coordinate: .gyeongpo, beachNum: "176"),
        Beach(name: "다대포 해수욕장", coordinate: .dadaepo, beachNum: "308"),
        Beach(name: "진하 해수욕장", coordinate: .jinha, beachNum: "313"),
        Beach(name: "곽지과물 해수욕장", coordinate: .gwakjiGwamul, beachNum: "345"),
        Beach(name: "협재 해수욕장", coordinate: .hyeopjae, beachNum: "346"),
        Beach(name: "중문ㆍ색달 해수욕장", coordinate: .jungmunSaekdal, beachNum: "347"),
        Beach(name: "이호테우 해수욕장", coordinate: .ihoTeu, beachNum: "348"),
        Beach(name: "함덕서우봉 해수욕장", coordinate: .hamdeokSeoubong, beachNum: "352"),
        Beach(name: "만리포 해수욕장", coordinate: .mallipo, beachNum: "70")
    ]
    @Published var beachData: [String: String] = [:]
    
    private var beachNumToName: [String: String] {
        Dictionary(uniqueKeysWithValues: beaches.map { ($0.beachNum, $0.name) })
    }

    func fetchBeachData() {
        for beach in beaches {
            fetchDataForBeach(beach)
        }
    }
    func fetchDataForBeach(_ beach: Beach) {
        NetworkManager.shared.fetchBeachData(beachNum: beach.beachNum) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let waveHeight):
                        if let beachName = self.beachNumToName[waveHeight.beachNum] {
                            self.beachData[beachName] = waveHeight.wh
                        }
                    case .failure(let error):
                        print("Error fetching data for \(beach.name): \(error)")
                }
            }
        }
    }
}


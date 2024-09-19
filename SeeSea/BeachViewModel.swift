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
    let wh: String
}

class BeachViewModel: ObservableObject {
    @Published var beaches: [Beach] = [
        Beach(name: "월정리 해수욕장", coordinate: .woljeongri),
        Beach(name: "삼양검은 모래 해수욕장", coordinate: .samyangBlackSand),
        Beach(name: "송정 해수욕장", coordinate: .songjeong),
        Beach(name: "경포 해수욕장", coordinate: .gyeongpo),
        Beach(name: "다대포 해수욕장", coordinate: .dadaepo),
        Beach(name: "진하 해수욕장", coordinate: .jinha),
        Beach(name: "곽지과물 해수욕장", coordinate: .gwakjiGwamul),
        Beach(name: "협재 해수욕장", coordinate: .hyeopjae),
        Beach(name: "중문ㆍ색달 해수욕장", coordinate: .jungmunSaekdal),
        Beach(name: "이호테우 해수욕장", coordinate: .ihoTeu),
        Beach(name: "함덕서우봉 해수욕장", coordinate: .hamdeokSeoubong),
        Beach(name: "만리포 해수욕장", coordinate: .mallipo)
    ]
    @Published var beachData: [String: BeachData] = [:]
    
    func fetchBeachData() {
        //API 호출을 통해 실시간 데이터를 가져오는 로직
        for beach in beaches     {
            //API 호출 및 데이터 파싱
            //let waveHeight = "0-1"
            //beachData[beach.name] = BeachData(wave: waveHeight)
            fetchDataForBeach(beach)
        }
    }
    func fetchDataForBeach(_beach: Beach) {
        guard let url = URL(string: )
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(BeachData.self, from: <#T##Data#>)
    }
}


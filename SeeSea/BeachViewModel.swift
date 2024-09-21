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
    var wh: String
    let url: String
}

class BeachViewModel: ObservableObject {
    @Published var beaches: [Beach] = [
        Beach(name: "월정리 해수욕장", coordinate: .woljeongri, beachNum: "29", wh: "N/A", url: "http://cctv.trendworld.kr/cctv/woljeongri.php"),
        Beach(name: "삼양검은 모래 해수욕장", coordinate: .samyangBlackSand, beachNum: "349", wh: "N/A", url: "http://cctv.trendworld.kr/cctv/samyangbeach.php"),
        Beach(name: "송정 해수욕장", coordinate: .songjeong, beachNum: "173", wh: "N/A", url: "https://www.surfholic.co.kr/surfholic/wave.php?str_region=%EB%B6%80%EC%82%B0%EB%B3%B8%EC%A0%90(%EC%86%A1%EC%A0%95)&region="),
        Beach(name: "경포 해수욕장", coordinate: .gyeongpo, beachNum: "176", wh: "N/A", url: "https://www.surfholic.co.kr/surfholic/wave.php?str_region=%EC%84%9C%ED%94%84%ED%99%80%EB%A6%AD%EA%B0%95%EB%A6%89%EA%B2%BD%ED%8F%AC&region=-grgp"),
        Beach(name: "다대포 해수욕장", coordinate: .dadaepo, beachNum: "308", wh: "N/A", url: "https://www.surfholic.co.kr/surfholic/wave.php?str_region=%EC%84%9C%ED%94%84%ED%99%80%EB%A6%AD%EB%8B%A4%EB%8C%80%ED%8F%AC&region=-ddp"),
        Beach(name: "진하 해수욕장", coordinate: .jinha, beachNum: "313", wh: "N/A", url: "https://www.surfholic.co.kr/surfholic/wave.php?str_region=%EC%84%9C%ED%94%84%ED%99%80%EB%A6%AD%EC%9A%B8%EC%82%B0&region=-us"),
        Beach(name: "곽지과물 해수욕장", coordinate: .gwakjiGwamul, beachNum: "345", wh: "N/A", url: "http://cctv.trendworld.kr/cctv/gwakji.php"),
        Beach(name: "협재 해수욕장", coordinate: .hyeopjae, beachNum: "346", wh: "N/A", url: "http://cctv.trendworld.kr/cctv/hyeopjae.php"),
        Beach(name: "중문ㆍ색달 해수욕장", coordinate: .jungmunSaekdal, beachNum: "347", wh: "N/A", url: "http://cctv.trendworld.kr/cctv/jungmunhaesuyokjang.php"),
        Beach(name: "이호테우 해수욕장", coordinate: .ihoTeu, beachNum: "348", wh: "N/A", url: "http://cctv.trendworld.kr/cctv/iho.php"),
        Beach(name: "함덕서우봉 해수욕장", coordinate: .hamdeokSeoubong, beachNum: "352", wh: "N/A", url: "http://cctv.trendworld.kr/cctv/hamdeok.php"),
        Beach(name: "만리포 해수욕장", coordinate: .mallipo, beachNum: "70", wh: "N/A", url: "http://220.95.232.18/camera/79_0.jpg")
    ]
    
    private var beachNumToIndex: [String: Int] {
        Dictionary(uniqueKeysWithValues: beaches.enumerated().map { ($1.beachNum, $0) })
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
                        if let index = self.beachNumToIndex[waveHeight.beachNum] {
                            self.beaches[index].wh = waveHeight.wh
                        }
                    case .failure(let error):
                        print("Error fetching data for \(beach.name): \(error)")
                }
            }
        }
    }
}


//
//  BeachViewModel.swift
//  SeeSea
//
//  Created by 소정섭 on 9/19/24.
//

import Foundation
import CoreLocation
import RealmSwift

class FavoriteBeach: Object {
    @Persisted(primaryKey: true) var name: String
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

struct Beach: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let beachNum: String
    var wh = "Loading..."
    let url: String
    let category: String
}

class BeachViewModel: ObservableObject {
    @Published var beaches: [Beach] = [
        Beach(name: "월정리 해수욕장", coordinate: .woljeongri, beachNum: "29", url: "http://cctv.trendworld.kr/cctv/woljeongri.php", category: "제주"),
        Beach(name: "삼양 해수욕장", coordinate: .samyangBlackSand, beachNum: "349", url: "http://cctv.trendworld.kr/cctv/samyangbeach.php", category: "제주"),
        Beach(name: "송정 해수욕장", coordinate: .songjeong, beachNum: "173", url: "https://www.surfholic.co.kr/surfholic/wave.php?str_region=%EB%B6%80%EC%82%B0%EB%B3%B8%EC%A0%90(%EC%86%A1%EC%A0%95)&region=", category: "부산"),
        Beach(name: "경포 해수욕장", coordinate: .gyeongpo, beachNum: "176", url: "https://www.surfholic.co.kr/surfholic/wave.php?str_region=%EC%84%9C%ED%94%84%ED%99%80%EB%A6%AD%EA%B0%95%EB%A6%89%EA%B2%BD%ED%8F%AC&region=-grgp", category: "강릉"),
        Beach(name: "다대포 해수욕장", coordinate: .dadaepo, beachNum: "308", url: "https://www.surfholic.co.kr/surfholic/wave.php?str_region=%EC%84%9C%ED%94%84%ED%99%80%EB%A6%AD%EB%8B%A4%EB%8C%80%ED%8F%AC&region=-ddp", category: "부산"),
        Beach(name: "진하 해수욕장", coordinate: .jinha, beachNum: "313", url: "https://www.surfholic.co.kr/surfholic/wave.php?str_region=%EC%84%9C%ED%94%84%ED%99%80%EB%A6%AD%EC%9A%B8%EC%82%B0&region=-us", category: "울산"),
        Beach(name: "곽지 해수욕장", coordinate: .gwakjiGwamul, beachNum: "345", url: "http://cctv.trendworld.kr/cctv/gwakji.php", category: "제주"),
        Beach(name: "협재 해수욕장", coordinate: .hyeopjae, beachNum: "346", url: "http://cctv.trendworld.kr/cctv/hyeopjae.php", category: "제주"),
        Beach(name: "중문 해수욕장", coordinate: .jungmunSaekdal, beachNum: "347", url: "http://cctv.trendworld.kr/cctv/jungmunhaesuyokjang.php", category: "제주"),
        Beach(name: "이호테우 해수욕장", coordinate: .ihoTeu, beachNum: "348", url: "http://cctv.trendworld.kr/cctv/iho.php", category: "제주"),
        Beach(name: "함덕 해수욕장", coordinate: .hamdeokSeoubong, beachNum: "352", url: "http://cctv.trendworld.kr/cctv/hamdeok.php", category: "제주"),
        Beach(name: "만리포 해수욕장", coordinate: .mallipo, beachNum: "70", url: "http://220.95.232.18/camera/79_0.jpg", category: "서해")
    ]
    @Published var selectedCategory = "전체"
    private var realm: Realm
    @Published var favoriteBeachNames: Set<String> = []

    init() {
        realm = try! Realm()
        loadFavorites()
    }

    private func loadFavorites() {
        let favorites = realm.objects(FavoriteBeach.self)
        favoriteBeachNames = Set(favorites.map({ $0.name }))
    }
    
    var filteredBeaches: [Beach] {
        if selectedCategory == "전체" {
            return beaches
        } else if selectedCategory == "관심지역" {
            return beaches.filter { favoriteBeachNames.contains($0.name) }
        } else {
            return beaches.filter { $0.category == selectedCategory }
        }
    }
    
    func toggleFavorite(for beach: Beach) {
        if favoriteBeachNames.contains(beach.name) {
            try! realm.write({
                realm.delete(realm.objects(FavoriteBeach.self).filter("name == %@", beach.name))
            })
            favoriteBeachNames.remove(beach.name)
        } else {
            try! realm.write({
                realm.add(FavoriteBeach(name: beach.name))
            })
            favoriteBeachNames.insert(beach.name)
        }
        objectWillChange.send()
    }
    
    func isFavorite(_ beach: Beach) -> Bool {
        return favoriteBeachNames.contains(beach.name)
    }
    
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


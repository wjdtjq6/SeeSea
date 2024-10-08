//
//  BeachViewModel.swift
//  SeeSea
//
//  Created by 소정섭 on 9/19/24.
//

import Foundation
import CoreLocation

struct Beach: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let beachNum: String
    var wh = "Loading..."
    var wt = "Loading..."
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
    //private var realm: Realm
    private let databaseManager: DataBase
    @Published var favoriteBeachNames: Set<String> = []
    
    init(databaseManager: DataBase = DataBaseManager.shared) {
        //realm = try! Realm()
        self.databaseManager = databaseManager
        loadFavorites()
        //print(realm.configuration.fileURL)
    }
    
    private func loadFavorites() {
        let favorites = databaseManager.read(FavoriteBeach.self)//realm.objects(FavoriteBeach.self)
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
            if let favotiteToDelete = databaseManager.read(FavoriteBeach.self).filter("name == %@", beach.name).first {
                databaseManager.delete(favotiteToDelete)
            }
            favoriteBeachNames.remove(beach.name)
        } else {
            let newFavorite = FavoriteBeach(name: beach.name)
            databaseManager.write(newFavorite)
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
    
    func fetchWhData() {
        for beach in beaches {
            fetchWaveHeight(beach)
        }
    }
    func fetchWaveHeight(_ beach: Beach) {
        NetworkManager.shared.fetchBeachData(beachNum: beach.beachNum) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let waveHeight):
                    if let index = self.beachNumToIndex[waveHeight.beachNum] {
                        self.beaches[index].wh = waveHeight.wh
                    }
                case .failure(let error):
                    print("Error fetchWhData for \(beach.name): \(error)")
                }
            }
        }
    }
    //WaveForecat
    func fetchWtData() {
        for beach in beaches {
            fetchWaterTemperature(beach)
        }
    }
    func fetchWaterTemperature(_ beach: Beach) {
        NetworkManager.shared.fetchWtData(beachNum: beach.beachNum) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let waterTemp):
                    if let index = self.beachNumToIndex[waterTemp.beachNum] {
                        self.beaches[index].wt = waterTemp.tw
                    }
                case .failure(let error):
                    print("Error fetchWaterTemperature for \(beach.name): \(error)")
                }
            }
        }
    }
    //Diary
    func saveDiaryEntry(beachName: String, date: Date, content: String) {
        let entry = DiaryEntry(beachName: beachName, date: date, content: content)
        databaseManager.write(entry)
    }
    
    func getDiaryEntries(for beachName: String) -> [DiaryEntry] {
        let entries = databaseManager.read(DiaryEntry.self).filter("beachName == %@", beachName)
        return Array(entries).reversed()
    }
    
    func updateDiaryEntry(_ entry: DiaryEntry, newContent: String) {
        databaseManager.write(entry)
    }
    
    func deleteDiaryEntry(_ entry: DiaryEntry) {
        databaseManager.delete(entry)
    }
}


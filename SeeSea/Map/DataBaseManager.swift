//
//  DataBaseManager.swift
//  SeeSea
//
//  Created by 소정섭 on 9/27/24.
//

import Foundation
import RealmSwift

protocol DataBase {
    func read<T: Object>(_ object: T.Type) -> Results<T>
    func write<T: Object>(_ object: T)
    func delete<T: Object>(_ object: T)
    func sort<T: Object>(_ object: T.Type, by keyPath: String, ascending: Bool) -> Results<T>
}

class DiaryEntry: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var beachName: String = ""
    @Persisted var date: Date = Date()
    @Persisted var content: String = ""
    
    convenience init(beachName: String, date: Date, content: String) {
        self.init()
        self.beachName = beachName
        self.date = date
        self.content = content
    }
}

class FavoriteBeach: Object {
    @Persisted(primaryKey: true) var name: String
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

final class DataBaseManager: DataBase {
    static let shared = DataBaseManager()
    private let database: Realm
    
    private init() {
        self.database = try! Realm()
    }
    
    func getLocationOfDefaultRealm() {
        print("Realm is located at:", database.configuration.fileURL!)
    }
    
    func read<T: Object>(_ object: T.Type) -> Results<T> {
        return database.objects(object)
    }
    
    func write<T: Object>(_ object: T) {
        do {
            try database.write {
                database.add(object, update: .modified)
            }
        } catch {
            print(error)
        }
    }
    func delete<T: Object>(_ object: T) {
        do {
            try database.write {
                database.delete(object)
            }
        } catch {
            print(error)
        }
    }
    func sort<T: Object>(_ object: T.Type, by keyPath: String, ascending: Bool = true) -> Results<T> {
        return database.objects(object).sorted(byKeyPath: keyPath, ascending: ascending)
    }
}


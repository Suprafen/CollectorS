//
//  RealmManager.swift
//  collector
//
//  Created by Ivan Pryhara on 15.12.21.
//

import Foundation
import RealmSwift

class RealmManager {
    var realm = try! Realm()
    
    func getData() -> [Item] {
        //Take objects from data base.
       let objects = realm.objects(Item.self).sorted(byKeyPath: "_id")
       var items: [Item] = []
       //Populate items.
       for item in objects {
           items.append(item)
       }
        return items
    }
    
    //Save single item to the Realm.
    func save(_ item: Item) {
        print("Save transtaction id - \(item._id)")
        try! realm.write{
            realm.add(item, update: .modified)
        }
    }
    //Save everything to the Realm.
    func save(_ items: [Item]) {
        try! realm.write{
            realm.add(items)
        }
    }
    //Delete particular item in the Realm.
    func delete(item: Item) {
        guard !realm.objects(Item.self).isEmpty  else {return}
        try! realm.write{
            realm.delete(item)
        }
    }
    //Delete everything in the Realm.
    //This method has not been used yet.
    func deleteAllData(items: [Item]) -> String {
        guard !realm.objects(Item.self).isEmpty else {return "Can't delete empty collection"}
        try! realm.write{
            realm.deleteAll()
        }
        return "Data has been eradicated!"
    }
}

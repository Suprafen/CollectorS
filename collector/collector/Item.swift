//
//  Item.swift
//  collector
//
//  Created by Ivan Pryhara on 13.12.21.
//

import Foundation
import RealmSwift
import UIKit


class Item: Object {
    @Persisted (primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var dateOfCreation = Date()
    @Persisted var imageDataDirectory: String?
    @Persisted var itemDescription: String?
    @Persisted var noteText: String?
    
    static let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let imagesDataFolderURL = directory.appendingPathComponent("ImagesData")
    
   convenience init(name: String, dateOfCreation: Date, imageDataDirectory: String?, itemDescription: String?, noteText: String?) {
        self.init()
        self.name = name
        self.dateOfCreation = dateOfCreation
        self.imageDataDirectory = imageDataDirectory ?? nil
        self.itemDescription = itemDescription ?? nil
        self.noteText = noteText ?? nil
    }
    
    
    static func saveImageData(_ data: Data, toDirectory directory: String?) -> String {
        
        if !FileManager.default.fileExists(atPath: imagesDataFolderURL.path) {
            do {
                try FileManager.default.createDirectory(at: imagesDataFolderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
            
        //Just for making sure.
        //I changed path to particular directory for each file;
        //Cause path can be changed time to time, so it's not working idea to save the whole file's way.
        //I save only a file name with extension, then give it to the func.
        //Func create new working url by adding Images Data Folder URL and given directory.
        
        if let directory = directory {
            //If Item has had image before.
            
            //Create URL for given path.
            let imageDataURL = imagesDataFolderURL.appendingPathComponent(directory)
            
            //Try to save data to URL.
            try? data.write(to: imageDataURL, options: .noFileProtection)

            //Return the same directory as has been given, because nothing has changed.
            return directory
        } else {
            //If new Item
            
            //Create Image Data Directory by adding extension to hash value.
            let imageDataDirectory = "\(data.hashValue).plist"
            //Create URL by appending path component that just has been created.
            let imageDataURL = imagesDataFolderURL.appendingPathComponent(imageDataDirectory)
            //Try to save data to URL.
            try? data.write(to: imageDataURL, options: .noFileProtection)
            //Return new created directory.
            return imageDataDirectory
        }
    }
    
    //Func for retrieving data for specific directory.
    static func retrieveData(forDirectory directory: String) -> Data? {
        
        //Create URL for given path.
        let imageDataURL = imagesDataFolderURL.appendingPathComponent(directory)
        //retrieveData from given URL.
        guard let codedImage = try? Data(contentsOf: imageDataURL) else {return nil}

        return codedImage
    }

    static func deleteData(inDirectory directory: String) {
        try! FileManager.default.removeItem(at: imagesDataFolderURL.appendingPathComponent(directory))
    }
}

//
//  SongManager.swift
//  MusicPlay
//
//  Created by ZverikRS on 25.03.2024.
//

import UIKit
import CoreData

// MARK: - class

final class SongManager {
    
    // MARK: - public properties
    
    static let shared: SongManager = {
        .init()
    }()
    
    // MARK: - private properties
    
    private let coreDateName: String = "CoreDate"
    private let objectName: String = "SongEntity"
    
    private lazy var persistentContainer: NSPersistentContainer? = {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }()
    
    // MARK: - initializers
    
    private init() {
    }
    
    // MARK: create
    
    @discardableResult
    func create(title: String, data: Data) -> SongEntity? {
        if let context: NSManagedObjectContext = persistentContainer?.viewContext {
            let object = NSEntityDescription.insertNewObject(forEntityName: objectName, into: context) as! SongEntity
            object.title = title
            object.data = data
            
            do {
                try context.save()
                return object
            } catch let error {
                print("🔴 \(#fileID) \(#function):\(#line) ~ error: \(error)")
                return nil
            }
        } else {
            return nil
        }
    }
    
    // MARK: read
    
    func featch(title: String) -> SongEntity? {
        if let context: NSManagedObjectContext = persistentContainer?.viewContext {
            let request = NSFetchRequest<SongEntity>(entityName: objectName)
            request.fetchLimit = 1
            request.predicate = .init(format: "title == %@", title)
            
            do {
                let objects = try context.fetch(request)
                return objects.first
            } catch let error {
                print("🔴 \(#fileID) \(#function):\(#line) ~ error: \(error)")
                return nil
            }
        } else {
            return nil
        }
    }
    
    func featch() -> [SongEntity]? {
        if let context: NSManagedObjectContext = persistentContainer?.viewContext {
            let request = NSFetchRequest<SongEntity>(entityName: objectName)
            
            do {
                let objects = try context.fetch(request)
                return objects
            } catch let error {
                print("🔴 \(#fileID) \(#function):\(#line) ~ error: \(error)")
                return nil
            }
        } else {
            return nil
        }
    }
    
    // MARK: update
    
    func update(_ object: SongEntity) {
        if let context: NSManagedObjectContext = persistentContainer?.viewContext {
            do {
                try context.save()
            } catch let error {
                print("🔴 \(#fileID) \(#function):\(#line) ~ error: \(error)")
            }
        }
    }
    
    // MARK: delete
    
    func delete(_ object: SongEntity) {
        if let context: NSManagedObjectContext = persistentContainer?.viewContext {
            context.delete(object)
            
            do {
                try context.save()
            } catch let error {
                print("🔴 \(#fileID) \(#function):\(#line) ~ error: \(error)")
            }
        }
    }
}

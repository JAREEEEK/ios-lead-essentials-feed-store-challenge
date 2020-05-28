
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager {
    public static let shared = CoreDataManager()
    
    private let identifier: String = "com.essentialdeveloper.FeedStoreChallenge"
    private let model: String = "FeedStoreDataModel"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let messageKitBundle = Bundle(identifier: self.identifier)
        let modelURL = messageKitBundle?.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL!)
        
        let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError()
            }
        }
        
        return container
    }()
    
    public func insertCoreDataFeedImage(with feedImage: LocalFeedImage, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        createCoreDataFeedImage(with: feedImage, context: context)
        save(context: context, completion: completion)
    }
    
    public func insertCoreDataCache(with data: (feed: [LocalFeedImage], timestamp: Date), completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let coreDataFeed = data.feed.map { createCoreDataFeedImage(with: $0, context: context) }
        createCoreDataCache(with: (coreDataFeed, data.timestamp), context: context)
        save(context: context) { _ in }
    }
    
    public func fetchCache() -> CoreDataCache? {
        let context = persistentContainer.viewContext
        return CoreDataCache.fetch(with: context)
    }
    
    public func clearData(for entity: String) {
        let context = persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        let _ = try? context.execute(request)
    }
    
    @discardableResult
    private func createCoreDataFeedImage(with feedImage: LocalFeedImage, context: NSManagedObjectContext) -> CoreDataFeedImage {
        guard let coreDataFeedImage = NSEntityDescription.insertNewObject(forEntityName: "CoreDataFeedImage", into: context) as? CoreDataFeedImage
            else { fatalError("Failed to insert new core data object") }
        
        coreDataFeedImage.id = feedImage.id
        coreDataFeedImage.feedImagedescription = feedImage.description
        coreDataFeedImage.location = feedImage.location ?? ""
        coreDataFeedImage.url = feedImage.url
        
        return coreDataFeedImage
    }
    
    @discardableResult
    private func createCoreDataCache(with data: (feed: [CoreDataFeedImage], timestamp: Date), context: NSManagedObjectContext) -> CoreDataCache {
        guard let coreDataCache = NSEntityDescription.insertNewObject(forEntityName: "CoreDataCache", into: context) as? CoreDataCache
        else { fatalError("Failed to insert new core data object") }
        coreDataCache.feed = NSOrderedSet(array: data.feed)
        coreDataCache.timestamp = data.timestamp
        
        return coreDataCache
    }
    
    private func save(context: NSManagedObjectContext, completion: @escaping (Error?) -> Void) {
        do {
            try context.save()
        } catch {
            completion(error)
        }
    }
}

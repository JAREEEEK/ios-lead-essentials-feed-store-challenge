//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Yaroslav Nosik on 29.05.2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd").flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public static let model: NSManagedObjectModel = {
        let bundle: Bundle = Bundle(for: CoreDataCache.self)
        let modelPath = bundle.path(forResource: "FeedStoreDataModel", ofType: "momd")!
        let modelURL = URL(fileURLWithPath: modelPath)
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    public init(storeURL: URL, bundle: Bundle) throws {
        self.container = try NSPersistentContainer.load(modelName: "FeedStoreDataModel", url: storeURL, in: bundle)
        self.context = container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let context = self.context
        context.perform {
            do {
                CoreDataCache.fetch(with: context).map(context.delete)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                // clear cache before inserting the new one
                CoreDataCache.fetch(with: context).map(context.delete)
                // insert new cache
                CoreDataCache.create(with: (feed, timestamp), in: context)
                // save context
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            if let cache = CoreDataCache.fetch(with: context) {
                completion(.found(feed: cache.feedImageModels(), timestamp: cache.timestamp))
            } else {
                completion(.empty)
            }
        }
    }
}

//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Yaroslav Nosik on 29.05.2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
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

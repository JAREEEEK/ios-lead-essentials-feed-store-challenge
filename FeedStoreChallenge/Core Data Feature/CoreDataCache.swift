//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(CoreDataCache)
public class CoreDataCache: NSManagedObject {
    @NSManaged public var timestamp: Date
    @NSManaged public var feed: NSOrderedSet
    
    public class func createUniqueInstance(with data: (feed: [LocalFeedImage], timestamp: Date), in context: NSManagedObjectContext) throws {
        try fetch(with: context).map(context.delete)
        let coreDataFeedImages = CoreDataFeedImage.coreDataFeed(with: data.feed, in: context)
        let cache = CoreDataCache(context: context)
        cache.feed = coreDataFeedImages
        cache.timestamp = data.timestamp
    }
    
    public class func fetch(with context: NSManagedObjectContext) throws -> CoreDataCache? {
        let request = CoreDataCache.fetchRequest()
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first as? CoreDataCache
    }
        
    public func feedImageModels() -> [LocalFeedImage] {
        feed.compactMap { ($0 as? CoreDataFeedImage)?.localFeedImage }
    }
}

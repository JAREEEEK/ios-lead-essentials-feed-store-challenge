//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(CoreDataCache)
public class CoreDataCache: NSManagedObject {
    @NSManaged public var timestamp: Date
    @NSManaged public var feed: NSOrderedSet
    
    public class func create(with data: (feed: NSOrderedSet, timestamp: Date), in context: NSManagedObjectContext) {
        let cache = CoreDataCache(context: context)
        cache.feed = data.feed
        cache.timestamp = data.timestamp
    }
    
    public class func fetch(with context: NSManagedObjectContext) -> CoreDataCache? {
        let request = CoreDataCache.fetchRequest()
        return try? context.fetch(request).first as? CoreDataCache
    }
    
    public class func clearCache(with context: NSManagedObjectContext) {
        CoreDataCache.fetch(with: context).map(context.delete)
        try? context.save()
    }
        
    public func feedImageModels() -> [LocalFeedImage] {
        feed.compactMap { ($0 as? CoreDataFeedImage)?.localFeedImage }
    }
}

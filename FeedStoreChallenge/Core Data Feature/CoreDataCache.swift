//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(CoreDataCache)
public class CoreDataCache: NSManagedObject {
    @NSManaged public var timestamp: Date
    @NSManaged public var feed: NSOrderedSet
        
    public func feedImageModels() -> [LocalFeedImage] {
        feed.compactMap { $0 as? CoreDataFeedImage }.map { LocalFeedImage(id: $0.id, description: $0.feedImagedescription, location: $0.location, url: $0.url)}
    }
}

//
//  CoreDataFeedImage.swift
//  FeedStoreChallenge
//
//  Created by Yaroslav Nosik on 28.05.2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

@objc(CoreDataFeedImage)
public class CoreDataFeedImage: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var feedImagedescription: String?
    @NSManaged public var url: URL
    @NSManaged public var location: String?
    @NSManaged public var cache: CoreDataCache
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataFeedImage> {
        return NSFetchRequest<CoreDataFeedImage>(entityName: "CoreDataFeedImage")
    }
    
}

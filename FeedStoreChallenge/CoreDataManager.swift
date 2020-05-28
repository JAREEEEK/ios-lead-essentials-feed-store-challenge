
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager {
    public static let shared = CoreDataManager()
    
    private let identifier: String = Bundle.main.bundleIdentifier ?? ""
    private let model: String = "FeedStoreDataModel"
    
    lazy var persistentContainer: NSPersistentContainer = {
        let messageKitBundle = Bundle(identifier: self.identifier)
        let modelURL = messageKitBundle!.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        
        let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError()
            }
        }
        
        return container
    }()
}

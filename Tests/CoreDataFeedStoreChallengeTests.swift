
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

private class CoreDataFeedStore: FeedStore {
    
    static let model: NSManagedObjectModel = {
        let bundle: Bundle = Bundle(for: CoreDataCache.self)
        let modelPath = bundle.path(forResource: "FeedStoreDataModel", ofType: "momd")!
        let modelURL = URL(fileURLWithPath: modelPath)
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
        
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    init(container: NSPersistentContainer) {
        self.container = container
        self.context = container.newBackgroundContext()
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
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
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
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
    
    func retrieve(completion: @escaping RetrievalCompletion) {
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

class CoreDataFeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
    
//
//   We recommend you to implement one test at a time.
//   Uncomment the test implementations one by one.
//      Follow the process: Make the test pass, commit, and move to the next one.
//
    
    override func setUp() {
        super.setUp()
        clearDataBeforeTest()
    }
    
    override func tearDown() {
        super.tearDown()
        clearDataAfterTest()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()

        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()

        assertThatSideEffectsRunSerially(on: sut)
    }
    
    // - MARK: Helpers
    
    private func makeSUT() -> FeedStore {
        let container = getLoadedTestPersistentContainer()
        return CoreDataFeedStore(container: container)
    }
    
    private func getLoadedTestPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "FeedStoreDataModel", managedObjectModel: CoreDataFeedStore.model)
        container.loadPersistentStores { (_, _) in }
        return container
    }
    
    private func clearDataBeforeTest() {
        clearTestData()
    }
    
    private func clearDataAfterTest() {
        clearTestData()
    }
    
    private func clearTestData() {
        let container = getLoadedTestPersistentContainer()
        let context = container.newBackgroundContext()
        CoreDataCache.clearCache(with: context)
    }
}

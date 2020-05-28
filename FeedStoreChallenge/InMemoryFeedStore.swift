//
//  InMemoryFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Yaroslav Nosik on 28.05.2020.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class InMemoryFeedStore: FeedStore {
    
    private struct InMemoryCache {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    
    private var cache: InMemoryCache?
    
    public init() { }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        if cache != nil {
            cache = nil
        }
        completion(nil)
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        cache = InMemoryCache(feed: feed, timestamp: timestamp)
        completion(nil)
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        if let cache = cache {
            completion(.found(feed: cache.feed, timestamp: cache.timestamp))
        } else {
            completion(.empty)
        }
    }
}

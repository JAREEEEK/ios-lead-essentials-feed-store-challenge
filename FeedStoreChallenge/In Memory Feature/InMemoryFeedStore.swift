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
    private let queue = DispatchQueue(label: "InMemoryDispatchQueue", qos: .userInitiated, attributes: .concurrent)
    
    public init() { }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            if self.cache != nil {
                self.cache = nil
            }
            completion(nil)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            self.cache = InMemoryCache(feed: feed, timestamp: timestamp)
            completion(nil)
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let cache = self.cache
        queue.async {
            if let cache = cache {
                completion(.found(feed: cache.feed, timestamp: cache.timestamp))
            } else {
                completion(.empty)
            }
        }
    }
}

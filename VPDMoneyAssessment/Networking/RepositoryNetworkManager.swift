//
//  RepositoryNetworkManager.swift
//  VPDMoneyAssessment
//
//  Created by Adewale Sanusi on 24/09/2024.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    private let endpoint = "https://api.github.com/repositories"
    private var currentPage = 1
    private let itemsPerPage = 30 // https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28
    private let cache = NSCache<NSString, NSArray>()
    
    func fetchRepositories(page: Int, completion: @escaping (Result<[Repository], Error>) -> Void) {
        let cacheKey = NSString(string: "repositories_page_\(page)")
        
        // checks if data is available in cache
        if let cachedRepositories = cache.object(forKey: cacheKey) as? [Repository] {
            completion(.success(cachedRepositories))
            return
        }
        
        guard var urlComponents = URLComponents(string: endpoint) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "since", value: "\((page - 1) * itemsPerPage)"),
            URLQueryItem(name: "per_page", value: "\(itemsPerPage)")
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data not found"])
                completion(.failure(error))
                return
            }
            
            do {
                let decodeStrategy = JSONDecoder()
                decodeStrategy.keyDecodingStrategy = .convertFromSnakeCase
                
                let repositories = try decodeStrategy.decode([Repository].self, from: data)
                
                // cache the fetched data
                self.cache.setObject(repositories as NSArray, forKey: cacheKey)
                
                completion(.success(repositories))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

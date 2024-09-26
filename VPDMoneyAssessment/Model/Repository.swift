//
//  RepositoryModel.swift
//  VPDMoneyAssessment
//
//  Created by Adewale Sanusi on 23/09/2024.
//

import Foundation

struct Repository: Codable {
    let id: Int
    let name: String
    let owner: Owner
    let description: String?
    let htmlUrl: String
}

struct Owner: Codable {
    let id: Int
    let login: String
    let avatarUrl: String
    let url: String
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
}

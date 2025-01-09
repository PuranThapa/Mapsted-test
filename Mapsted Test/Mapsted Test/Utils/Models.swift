//
//  Models.swift
//  Mapsted Test
//
//  Created by Shree Ram on 07/01/25.
//

// Building Model
struct Building: Codable {
    let buildingID: Int
    let buildingName: String
    let city: String
    let state: String
    let country: String

    enum CodingKeys: String, CodingKey {
        case buildingID = "building_id"
        case buildingName = "building_name"
        case city
        case state
        case country
    }
}

// Analytic model
struct Analytic: Codable {
    let manufacturer: String
    let marketName: String
    let codename: String
    let model: String
    let usageStatistics: UsageStatistics

    enum CodingKeys: String, CodingKey {
        case manufacturer
        case marketName = "market_name"
        case codename
        case model
        case usageStatistics = "usage_statistics"
    }
}

// Purchase model
struct Purchase: Codable {
    let itemID: Int
    let itemCategoryID: Int
    let cost: Double

    enum CodingKeys: String, CodingKey {
        case itemID = "item_id"
        case itemCategoryID = "item_category_id"
        case cost
    }
}

// SessionInfo model
struct SessionInfo: Codable {
    let buildingID: Int
    let purchases: [Purchase]

    enum CodingKeys: String, CodingKey {
        case buildingID = "building_id"
        case purchases
    }
}

// UsageStatistics model
struct UsageStatistics: Codable {
    let sessionInfos: [SessionInfo]

    enum CodingKeys: String, CodingKey {
        case sessionInfos = "session_infos"
    }
}

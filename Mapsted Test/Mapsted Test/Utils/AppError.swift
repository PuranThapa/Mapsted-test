//
//  AppError.swift
//  Mapsted Test
//
//  Created by Shree Ram on 07/01/25.
//

import Foundation

struct AppError : LocalizedError
{
    var errorDescription: String? { return mMsg }
    var failureReason: String? { return mMsg }
    var recoverySuggestion: String? { return "" }
    var helpAnchor: String? { return "" }

    private var mMsg : String

    init(_ description: String)
    {
        mMsg = description
    }
}

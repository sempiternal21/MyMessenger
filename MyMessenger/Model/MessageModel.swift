//
//  MessageModel.swift
//  MyMessenger
//
//  Created by Danil Antonov on 29.01.2024.
//

import Foundation

// MARK: - RealMessageModel
struct RealMessageModel: Codable {
    let channel, event: String?
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    let message: Message?
}

// MARK: - Message
struct Message: Codable {
    let id, fromUserID: Int?
    let body, time: String?
    var real: Bool?
    let messageIndex: Int?
}

//
//  CurrentUser.swift
//  MyMessenger
//
//  Created by Danil Antonov on 29.01.2024.
//

import Foundation
import UIKit

class CurrentUser {
    static var currentUserId: Int {
        switch UIDevice.current.identifierForVendor?.uuidString {
        case "461752E7-0F2E-4287-909B-2B44FD7CC785":
            return 1
        default:
            return 2
        }
    }
}

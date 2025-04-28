//
//  User.swift
//  FridgeAI
//
//  Created by Michael Ilic on 28.04.25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
}

extension User {
    static var mock_User: User = User(id: NSUUID().uuidString, name: "Michael Ilic", email: "michi.ilic@hotmail.com")
}

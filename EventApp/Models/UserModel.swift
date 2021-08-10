//
//  UserModel.swift
//  EventApp
//
//  Created by Admin on 11/20/20.
//

import Foundation

class UserModel: NSObject {
    
    var userID = ""
    var fname = ""
    var lname = ""
    var email = ""
    var device_tokens: [String] = []
    
    override init() {
        super.init()
    }
    
    init(dict: [String: Any]) {
        if let val = dict["userID"] as? String               { userID = val }
        if let val = dict["fname"] as? String                { fname = val }
        if let val = dict["lname"] as? String                { lname = val }
        if let val = dict["email"] as? String                { email = val }
        if let val = dict["tokens"] as? [String]             { device_tokens = val }
    }
}

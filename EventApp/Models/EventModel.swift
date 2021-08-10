//
//  EventModel.swift
//  EventApp
//
//  Created by Admin on 11/22/20.
//

import Foundation

class EventModel: NSObject {
    
    var id = ""
    var title = ""
    var start = 0
    var end = 0
    var email = ""
    var phone = ""
    var detail = ""
    var userID = ""
    
    override init() {
        super.init()
    }
    
    init(dict: [String: Any]) {
        if let val = dict["id"] as? String               { id = val }
        if let val = dict["title"] as? String            { title = val }
        if let val = dict["start"] as? Int               { start = val }
        if let val = dict["end"] as? Int                 { end = val }
        if let val = dict["email"] as? String            { email = val }
        if let val = dict["phone"] as? String            { phone = val }
        if let val = dict["detail"] as? String           { detail = val }
        if let val = dict["userID"] as? String           { userID = val }
    }
    
//    func getJSON() -> [String: Any] {
//        let body: [String: Any] = [
//            "id": id,
//            "title" : title,
//            "start": start,
//            "end": end,
//            "email": email,
//            "phone": phone,
//            "detail": detail,
//            "userID": userID
//        ]
//        
//        return body
//    }
}

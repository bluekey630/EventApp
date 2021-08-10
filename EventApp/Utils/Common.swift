//
//  Common.swift
//  EventApp
//
//  Created by Admin on 11/20/20.
//

import Foundation
import UIKit

class Common {
    static let shared = Common()
    private init() {
        print("NavManager Initialized")
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func timestampToDateString(timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    func convertDateToTimestamp(date: String) -> Int64 {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy hh:mm aa"
        let dt = df.date(from: date)
        let dateStamp = dt!.timeIntervalSince1970
        let dateSt = Int64(dateStamp)
        return dateSt
    }
    
    func convertTimestampToTime(timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        let dateFormatter = DateFormatter()

        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "hh:mm aa" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)

        return strDate
    }
}

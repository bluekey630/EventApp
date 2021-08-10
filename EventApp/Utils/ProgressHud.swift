//
//  ProgressHud.swift
//  EventApp
//
//  Created by Admin on 11/20/20.
//

import Foundation
import JGProgressHUD
import UIKit

class ProgressHud {
    static let shared = ProgressHud()
    let hud = JGProgressHUD(style: .light)
    
    private init() {}
    
    func show(view: UIView, msg: String) {
        hud.textLabel.text = msg
        hud.show(in: view)
    }
    
    func dismiss() {
        //hud.dismiss(afterDelay: 3.0)
        hud.dismiss()
    }
    
}

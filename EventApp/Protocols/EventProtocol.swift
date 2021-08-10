//
//  EventProtocol.swift
//  EventApp
//
//  Created by Admin on 11/22/20.
//

import Foundation

protocol EventProtocol {
    func createdNewEvent()
    func updatedEvent()
    func removedNewEvent()
    func requestEditEvent(event: EventModel)
}

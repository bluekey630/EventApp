//
//  EventViewController.swift
//  EventApp
//
//  Created by Admin on 11/20/20.
//

import UIKit
import Firebase
import CalendarKit
import LIDateUtility
import FSCalendar

class EventViewController: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarView: DayView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var events = [EventDescriptor]()
    var eventModels = [EventModel]()
    var curDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        getMyAccount()
    }
    
    func configureView() {
        calendar.scope = .week
        calendar.delegate = self
        calendar.dataSource = self
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.dayHeaderView.isHidden = true
        print(calendarView.dayHeaderView.frame.width)
        calendarView.headerHeight = 0
        showTitle(date: Date())
    }
    
    func getMyAccount() {
        ProgressHud.shared.show(view: view, msg: "")
        if GlobalData.myAccount.userID.count == 0 {
            Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid).getDocument(completion: {
                snapshot, error in
                
                if error != nil {
                    ProgressHud.shared.dismiss()
                    self.showAlert(title: "Error", msg: error!.localizedDescription)
                } else {
                    if snapshot!.exists {
                        let data = snapshot!.data()
                        let user = UserModel(dict: data!)
                        GlobalData.myAccount = user
                        self.loadEvents()
                    } else {
                        ProgressHud.shared.dismiss()
                    }
                }
            })
        } else {
            loadEvents()
        }
    }
    
    func loadEvents() {
        self.events = []
        self.eventModels = []
        
        Firestore.firestore().collection("Events").getDocuments(completion: {
            snapshot, error in
            
            ProgressHud.shared.dismiss()
            if error != nil {
                self.showAlert(title: "Error", msg: error!.localizedDescription)
            } else {
                if !snapshot!.isEmpty {
                    let ary = snapshot!.documents
                    for item in ary {
                        let eventModel = EventModel(dict: item.data())
                        self.eventModels.append(eventModel)
                        let event = MyEvent()

                        event.eventID = eventModel.id
                        event.startDate = Date(timeIntervalSince1970: TimeInterval(eventModel.start))
                        event.endDate = Date(timeIntervalSince1970: TimeInterval(eventModel.end))
                        event.text = eventModel.title
                        event.color = (eventModel.userID == GlobalData.myAccount.userID ? UIColor.green : UIColor.red)
                        event.isAllDay = false
                        self.events.append(event)
                    }
                }
            }
            
            self.calendarView.reloadData()
            self.calendar.reloadData()
        })
    }
    
    func showTitle(date: Date) {
        let df = DateFormatter()
        df.dateFormat = "MMMM/yyyy"
        let now = df.string(from: date)
        lblTitle.text = now
    }
    
    @IBAction func onToday(_ sender: Any) {
//        print(calendarView.dayHeaderView.frame.height)
        curDate = Date()
        calendarView.move(to: Date())
        calendar.select(curDate)
    }
    
    @IBAction func onForward(_ sender: Any) {
        curDate = LIDateUtility.addNumberOfDaysToDate(date: curDate, count: 7)
        calendarView.move(to: curDate)
        calendar.select(curDate)
    }
    
    @IBAction func onBackward(_ sender: Any) {
        curDate = LIDateUtility.subtractNumberOfDaysFromDate(date: curDate, count: 7)
        calendarView.move(to: curDate)
        calendar.select(curDate)
    }
    
    @IBAction func onAdd(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateEventViewController") as! CreateEventViewController
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}

extension EventViewController: DayViewDelegate {
    
    func dayViewDidSelectEventView(_ eventView: EventView) {
        print("Selected Event")
        let event = eventView.descriptor as! MyEvent
        for e in eventModels {
            if e.id == event.eventID {
                let vc = storyboard?.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
                vc.eventModel = e
                vc.delegate = self
                present(vc, animated: true, completion: nil)
                break
            }
        }
    }
    
    func dayViewDidLongPressEventView(_ eventView: EventView) {
        
    }
    
    func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        
    }
    
    func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        
    }
    
    func dayViewDidBeginDragging(dayView: DayView) {
        
    }
    
    func dayViewDidTransitionCancel(dayView: DayView) {
        
    }
    
    func dayView(dayView: DayView, willMoveTo date: Date) {
        
    }
    
    func dayView(dayView: DayView, didMoveTo date: Date) {
        curDate = date
        showTitle(date: date)
        
        calendar.select(date)
    }
    
    func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        
    }
}

extension EventViewController: EventDataSource {
    func eventsForDate(_ date: Date) -> [EventDescriptor] {
        return events
    }
}

extension EventViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var isExist = false
        for event in eventModels {
            if Common.shared.timestampToDateString(timestamp: event.start) == Common.shared.timestampToDateString(timestamp: Int(date.timeIntervalSince1970)) ||
                Common.shared.timestampToDateString(timestamp: event.end) == Common.shared.timestampToDateString(timestamp: Int(date.timeIntervalSince1970)) {
                isExist = true
                break
            }
        }
        
        return isExist ? 1 : 0
    }
}

extension EventViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        curDate = date
        showTitle(date: date)
        
        calendar.select(date)
        calendarView.move(to: date)
    }
}


extension EventViewController: EventProtocol {
    func requestEditEvent(event: EventModel) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateEventViewController") as! CreateEventViewController
        vc.delegate = self
        vc.eventModel = event
        present(vc, animated: true, completion: nil)
    }
    
    func createdNewEvent() {
        loadEvents()
    }
    
    func updatedEvent() {
        loadEvents()
    }
    
    func removedNewEvent() {
        loadEvents()
    }
}

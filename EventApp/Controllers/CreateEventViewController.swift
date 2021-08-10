//
//  CreateEventViewController.swift
//  EventApp
//
//  Created by Admin on 11/21/20.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase
import DatePicker

class CreateEventViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnCreate: UIButton!
    
    @IBOutlet weak var txtTitle: SkyFloatingLabelTextField!
    @IBOutlet weak var txtDate: SkyFloatingLabelTextField!
    @IBOutlet weak var txtStartTime: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEndTime: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPhone: SkyFloatingLabelTextField!
    @IBOutlet weak var txtDetail: UITextView!
    
    var delegate: EventProtocol?
    var isEdit = false
    var eventModel: EventModel!
    
    var selectedDate: Date!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    func configureView() {
        if eventModel != nil {
            isEdit = true
            lblTitle.text = "Edit Event"
            btnCreate.setTitle("Update Event", for: .normal)
            
            txtTitle.text = eventModel.title
            txtDate.text = Common.shared.timestampToDateString(timestamp: eventModel.start)
            txtStartTime.text = Common.shared.convertTimestampToTime(timestamp: Int64(eventModel.start))
            txtEndTime.text = Common.shared.convertTimestampToTime(timestamp: Int64(eventModel.end))
            txtEmail.text = eventModel.email
            txtPhone.text = eventModel.phone
            txtDetail.text = eventModel.detail
        }
        
        let startPicker = UIDatePicker()
        startPicker.datePickerMode = .time
        startPicker.preferredDatePickerStyle = .wheels
        txtStartTime.inputView = startPicker
        startPicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
        
        let endPicker = UIDatePicker()
        endPicker.datePickerMode = .time
        endPicker.preferredDatePickerStyle = .wheels
        txtEndTime.inputView = endPicker
        endPicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)
    }
    
    @objc func startTimeChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        txtStartTime.text = formatter.string(from: sender.date)
    }
    
    @objc func endTimeChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        txtEndTime.text = formatter.string(from: sender.date)
    }

    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDate(_ sender: Any) {
        
        txtTitle.resignFirstResponder()
        txtStartTime.resignFirstResponder()
        txtEndTime.resignFirstResponder()
        txtEmail.resignFirstResponder()
        txtPhone.resignFirstResponder()
        txtDetail.resignFirstResponder()
        
        let minDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 1990)
        let maxDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 2030)
        let datePicker = DatePicker()
        datePicker.setup(beginWith: Date(), min: minDate!, max: maxDate!) {
            selected, date in

            if selected, let selectedDate = date {
                self.selectedDate = selectedDate
                self.txtDate.text = Common.shared.timestampToDateString(timestamp: Int(selectedDate.timeIntervalSince1970))
            }
        }

        datePicker.show(in: self, on: sender as! UIButton)
    }
    
    @IBAction func onStartTime(_ sender: Any) {
        let timeSelector = TimeSelector()
        timeSelector.date = Date()
        timeSelector.timeSelected = {
            timeSelector in
            
            self.txtStartTime.text = "\(String(format: "%02d", timeSelector.hours)):\(String(format: "%02d", timeSelector.minutes)) \(timeSelector.isAm ? "AM" : "PM")"
        }
        timeSelector.overlayAlpha = 0.8
        timeSelector.presentOnView(view: view)
    }
    
    
    @IBAction func onEndtime(_ sender: Any) {
        let timeSelector = TimeSelector()
        timeSelector.date = Date()
        timeSelector.timeSelected = {
            timeSelector in
            
            self.txtEndTime.text = "\(String(format: "%02d", timeSelector.hours)):\(String(format: "%02d", timeSelector.minutes)) \(timeSelector.isAm ? "AM" : "PM")"
        }
        timeSelector.overlayAlpha = 0.8
        timeSelector.presentOnView(view: view)
    }
    
    @IBAction func onCreateEvent(_ sender: Any) {
        let title = txtTitle.text ?? ""
        let date = txtDate.text ?? ""
        let startTime = txtStartTime.text ?? ""
        let endTime = txtEndTime.text ?? ""
        let email = txtEmail.text ?? ""
        let phone = txtPhone.text ?? ""
        let detail = txtDetail.text ?? ""
        
        if title.count == 0 {
            showAlert(title: "Warning", msg: "Please enter event title.")
            return
        }
        
        if date.count == 0 {
            showAlert(title: "Warning", msg: "Please enter event date.")
            return
        }
        
        if startTime.count == 0 {
            showAlert(title: "Warning", msg: "Please enter start time.")
            return
        }
        
        if endTime.count == 0 {
            showAlert(title: "Warning", msg: "Please enter end time.")
            return
        }
        
        let start = Common.shared.convertDateToTimestamp(date: date + " " + startTime)
        let end = Common.shared.convertDateToTimestamp(date: date + " " + endTime)
        
        if start >= end {
            showAlert(title: "Warning", msg: "Please selet evnet time again.")
            return
        }
        
        if detail.count == 0 {
            showAlert(title: "Warning", msg: "Please enter event detail.")
            return
        }
        
        var id = UUID().uuidString
        
        if isEdit {
            id = eventModel.id
        }
        
        let body: [String: Any] = [
            "id": id,
            "title": title,
            "start": start,
            "end": end,
            "email": email,
            "phone": phone,
            "detail": detail,
            "userID": GlobalData.myAccount.userID
        ]
        
        Firestore.firestore().collection("Events").document(id).setData(body)
        dismiss(animated: true, completion: {
            self.delegate?.createdNewEvent()
        })
    }
}

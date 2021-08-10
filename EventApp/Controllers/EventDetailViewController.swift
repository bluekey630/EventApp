//
//  EventDetailViewController.swift
//  EventApp
//
//  Created by Admin on 11/22/20.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField
import MessageUI

class EventDetailViewController: UIViewController {

    @IBOutlet weak var actionView: UIView!
    @IBOutlet weak var scrollTopMargin: NSLayoutConstraint!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var txtTitle: SkyFloatingLabelTextField!
    @IBOutlet weak var txtDate: SkyFloatingLabelTextField!
    @IBOutlet weak var txtStartTime: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEndTime: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPhone: SkyFloatingLabelTextField!
    @IBOutlet weak var txtDetail: UITextView!
    
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnSms: UIButton!
    
    var eventModel: EventModel!
    var delegate: EventProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    func configureView() {
        txtTitle.text = eventModel.title
        txtDate.text = Common.shared.timestampToDateString(timestamp: eventModel.start)
        txtStartTime.text = Common.shared.convertTimestampToTime(timestamp: Int64(eventModel.start))
        txtEndTime.text = Common.shared.convertTimestampToTime(timestamp: Int64(eventModel.end))
        txtEmail.text = eventModel.email
        txtPhone.text = eventModel.phone
        txtDetail.text = eventModel.detail
        
        btnEmail.setImage(eventModel.email.count == 0 ? UIImage(named: "ic_email_gray") : UIImage(named: "ic_email"), for: .normal)
        btnCall.setImage(eventModel.phone.count == 0 ? UIImage(named: "ic_call_gray") : UIImage(named: "ic_call"), for: .normal)
        btnSms.setImage(eventModel.phone.count == 0 ? UIImage(named: "ic_sms_gray") : UIImage(named: "ic_sms"), for: .normal)
        
        if GlobalData.myAccount.userID != eventModel.userID {
            actionView.isHidden = true
            scrollTopMargin.constant = 0
            btnEdit.isHidden = true
            btnDelete.isHidden = true
        }
    }

    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onEmail(_ sender: Any) {
        
        if eventModel.email.count == 0 {
            return
        }
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([eventModel.email])
            present(mail, animated: true)
        }
    }
    
    @IBAction func onCall(_ sender: Any) {
        if eventModel.phone.count == 0 {
            return
        }
        
        guard let number = URL(string: "tel://\(eventModel.phone)") else {
            return
        }
        
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }
    
    @IBAction func onSMS(_ sender: Any) {
        if eventModel.phone.count == 0 {
            return
        }
        
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.recipients = [eventModel.phone]
            controller.messageComposeDelegate = self
            present(controller, animated: true)
        }
    }
    
    @IBAction func onEdit(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.delegate?.requestEditEvent(event: self.eventModel)
        })
    }
    
    @IBAction func onDelete(_ sender: Any) {
        
        let attributedTitle = NSAttributedString(string: "Delete", attributes: [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedString.Key.foregroundColor : UIColor.red
        ])
        
        let alert = UIAlertController(title: "", message: "Are you sure to delete this event?", preferredStyle: .alert)
        
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
            Firestore.firestore().collection("Events").document(self.eventModel.id).delete()
            self.dismiss(animated: true, completion: {
                self.delegate?.removedNewEvent()
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
}

extension EventDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension EventDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true)
    }
}

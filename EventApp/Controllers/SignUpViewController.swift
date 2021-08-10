//
//  SignUpViewController.swift
//  EventApp
//
//  Created by Admin on 11/20/20.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var txtFname: SkyFloatingLabelTextField!
    @IBOutlet weak var txtLname: SkyFloatingLabelTextField!
    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var txtConfirm: SkyFloatingLabelTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    func configureView() {
        
    }

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCreateAccount(_ sender: Any) {
        let fname = txtFname.text ?? ""
        let lname = txtLname.text ?? ""
        let email = txtEmail.text ?? ""
        let password = txtPassword.text ?? ""
        let confirm = txtConfirm.text ?? ""
        
        if fname.count == 0 {
            showAlert(title: "Warning", msg: "Please enter first name.")
            return
        }
        
        if lname.count == 0 {
            showAlert(title: "Warning", msg: "Please enter last name.")
            return
        }
        
        if email.count == 0 {
            showAlert(title: "Warning", msg: "Please enter email address.")
            return
        }
        
        if !Common.shared.isValidEmail(testStr: email) {
            showAlert(title: "Warning", msg: "Invalid Email.")
            return
        }
        
        if password.count == 0 {
            showAlert(title: "Warning", msg: "Please enter password.")
            return
        }
        
        if password.count < 6 {
            showAlert(title: "Warning", msg: "Password should be minimum 6 characters.")
            return
        }
        
        if password != confirm {
            showAlert(title: "Warning", msg: "Password was not matched with confirm password.")
            return
        }
        
        ProgressHud.shared.show(view: view, msg: "")
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            authResult, error in
            
            ProgressHud.shared.dismiss()
            
            if error != nil {
                self.showAlert(title: "Error", msg: error!.localizedDescription)
            } else {
                if authResult != nil {
                    let userID = authResult!.user.uid
                    
                    var body: [String: Any] = [
                        "userID": userID,
                        "fname": fname,
                        "lname": lname,
                        "email": email
                    ]
                    
                    GlobalData.myAccount.userID = userID
                    GlobalData.myAccount.fname = fname
                    GlobalData.myAccount.lname = lname
                    GlobalData.myAccount.email = email
                    
                    let token = UserDefaults.standard.string(forKey: "device_token") ?? ""
                    if token.count > 0 {
                        body["tokens"] = [token]
                        GlobalData.myAccount.device_tokens = [token]
                    }
                    
                    Firestore.firestore().collection("Users").document(userID).setData(body)
                    self.gotoMain()
                }
            }
        })
    }
    
    func gotoMain() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}

//
//  LoginViewController.swift
//  EventApp
//
//  Created by Admin on 11/20/20.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: SkyFloatingLabelTextField!
    @IBOutlet weak var txtPassword: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        
        if Auth.auth().currentUser != nil {
            gotoMain()
        }
    }
    
    func configureView() {
        
    }

    @IBAction func onLogin(_ sender: Any) {
        let email = txtEmail.text ?? ""
        let password = txtPassword.text ?? ""
        
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
        
        ProgressHud.shared.show(view: view, msg: "")
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            user, error in
            
            ProgressHud.shared.dismiss()
            
            if error != nil {
                self.showAlert(title: "Error", msg: error!.localizedDescription)
            } else {
                if user != nil {
                    let userID = user!.user.uid
                    self.getUserDetail(userID: userID)
                }
            }
        })
    }
    
    func getUserDetail(userID: String) {
        Firestore.firestore().collection("Users").document(userID).getDocument(completion: {
            snapshot, error in
            
            if error != nil {
                self.showAlert(title: "Error", msg: error!.localizedDescription)
            } else {
                if snapshot!.exists {
                    let user = UserModel(dict: snapshot!.data()!)
                    GlobalData.myAccount = user
                    
                    let token = UserDefaults.standard.string(forKey: "device_token") ?? ""
                    if token.count > 0 {
                        var isExist = false
                        for tk in user.device_tokens {
                            if token == tk {
                                isExist = true
                                break
                            }
                        }
                        
                        if !isExist {
                            GlobalData.myAccount.device_tokens.append(token)
                        }
                        
                        Firestore.firestore().collection("Users").document(userID).updateData(["tokens": GlobalData.myAccount.device_tokens])
                        
                        self.gotoMain()
                    } else {
                        self.gotoMain()
                    }
                }
            }
        })
    }
    
    func gotoMain() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func onCreateAccount(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func onForgotPassword(_ sender: Any) {
        
    }
}

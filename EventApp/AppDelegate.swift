//
//  AppDelegate.swift
//  EventApp
//
//  Created by Admin on 11/20/20.
//

import UIKit
import IQKeyboardManagerSwift
import OneSignal
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = {
            notification in
            
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "reload_task"), object: nil)
        }
        
        let notificationOpendBlock: OSHandleNotificationActionBlock = {
            result in
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "received_notification"), object: result!.notification.payload.additionalData)
//            }
            
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.setLocationShared(false)
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: Constants.ONESIGNAL_APPID,
                                                handleNotificationReceived: notificationReceivedBlock,
                                                handleNotificationAction: notificationOpendBlock,
                                                settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            
        })
        OneSignal.add(self as OSSubscriptionObserver)
        
        FirebaseApp.configure()
        
        return true
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if let playerId = stateChanges.to.userId {
            UserDefaults.standard.set(playerId, forKey: "device_token")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


//
//  AppDelegate.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 04/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  let center = UNUserNotificationCenter.current()
  
  var window: UIWindow?
  var coordinator: ApplicationCoordinator?
  var blurEffectView: UIVisualEffectView?
  var badgeNumber: Int = 0

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    GMSServices.provideAPIKey("AIzaSyB2OVOcSmY5XoJYA0j2BlKEv37JPniSG54")
    
    self.window = UIWindow()
    self.window?.makeKeyAndVisible()
    
    self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if granted {
        print("Разрешение получено")
      } else {
        print("Разрешение не получено")
      }
    }
    self.center.delegate = self
    UIApplication.shared.applicationIconBadgeNumber = 0
    self.badgeNumber = UIApplication.shared.applicationIconBadgeNumber
    
    self.coordinator = ApplicationCoordinator()
    self.coordinator?.start()

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    let blurEffect = UIBlurEffect(style: .light)
    self.blurEffectView = UIVisualEffectView(effect: blurEffect)
    self.blurEffectView?.frame = UIScreen.main.bounds
    self.blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight] //для поддержки поворота устройства
    self.window?.addSubview(blurEffectView!)
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    self.blurEffectView?.removeFromSuperview()
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    self.setReminderNotification()
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    self.center.removeAllPendingNotificationRequests()
    UIApplication.shared.applicationIconBadgeNumber = self.badgeNumber - 1
    self.badgeNumber = UIApplication.shared.applicationIconBadgeNumber
  }

  func applicationWillTerminate(_ application: UIApplication) {
    self.setReminderNotification()
  }

  private func setReminderNotification() {
    self.center.removeAllPendingNotificationRequests()
    self.center.getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized:
        self.sendNotificationRequest(
          content: self.makeNotificationContent(),
          trigger: self.makeIntervalNotificationTrigger()
        )
      case .denied:
        return
      case .provisional:
        self.sendNotificationRequest(
          content: self.makeNotificationContent(),
          trigger: self.makeIntervalNotificationTrigger()
        )
      case .notDetermined:
        self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
          if granted {
            print("Разрешение получено")
          } else {
            print("Разрешение не получено")
          }
        }
      }
    }
  }

  private func makeNotificationContent() -> UNNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = "Напоминание"
    content.subtitle = "RouteTracker не используется"
    content.body = "Вы давно не использовали приложение RouteTracker. Нажмите на уведомление, чтобы вернуться к использованию"
    content.badge = self.badgeNumber + 1 as NSNumber
    return content
  }
  
  private func makeIntervalNotificationTrigger() -> UNNotificationTrigger {
    return UNTimeIntervalNotificationTrigger(timeInterval: 30 * 60, repeats: false)
  }
  
  private func sendNotificationRequest(content: UNNotificationContent, trigger: UNNotificationTrigger) {
    let request = UNNotificationRequest(
      identifier: "reminder",
      content: content,
      trigger: trigger)
    self.center.add(request) { error in
      if let error = error {
        print(error.localizedDescription)
      }
    }
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    if response.notification.request.identifier == "reminder" &&
      response.actionIdentifier == UNNotificationDefaultActionIdentifier {
      UIApplication.shared.keyWindow?.rootViewController?.showAlert(title: "Приветствие", message: "Поздравляем с возвращением к использованию приложения!")
    }
    completionHandler()
  }
}


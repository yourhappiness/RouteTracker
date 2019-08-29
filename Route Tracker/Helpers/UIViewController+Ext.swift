//
//  UIViewController+Ext.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 11/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

// MARK: - Показывает alertVC с нужным текстом
public extension UIViewController {
  public func showAlert(title: String, message: String) {
    let alertVC = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert)
    let okAction = UIAlertAction(title: "ОК", style: .destructive, handler: nil)
    alertVC.addAction(okAction)
    self.present(alertVC, animated: true, completion: nil)
  }
}

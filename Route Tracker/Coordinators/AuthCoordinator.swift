//
//  AuthCoordinator.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 11/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

/// Координатор для авторизации
final public class AuthCoordinator: BaseCoordinator {
  
  /// Замыкание, вызываемое при завершении работы координатора
  public var onFinishFlow: (() -> Void)?
  
  private var rootController: LoginViewController?
  
  /// Показывает модуль входа
  override public func start() {
    self.showLoginModule()
  }
  
  private func showLoginModule() {
    guard let controller = UIStoryboard(name: "Login", bundle: nil)
      .instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
      else {return}
    
    let rootController = controller
    self.setAsRoot(rootController)
    self.rootController = rootController
    
    controller.onLogin = { [weak self] in
      self?.onFinishFlow?()
    }
  }
}

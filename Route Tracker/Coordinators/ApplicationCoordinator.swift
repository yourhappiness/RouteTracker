//
//  ApplicationCoordinator.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 11/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import Foundation

/// Координатор вызывается при запуске приложения
final public class ApplicationCoordinator: BaseCoordinator {
  
  /// Показывает сценарий авторизации
  override public func start() {
    if UserDefaults.standard.bool(forKey: "isLogin") {
      self.toMain()
    } else {
      self.toLogin()
    }
  }
  
  private func toMain() {
    let coordinator = MainCoordinator()
    coordinator.onFinishFlow = { [weak self, weak coordinator] in
      self?.removeDependency(coordinator)
      self?.start()
    }
    self.addDependency(coordinator)
    coordinator.start()
  }
  
  private func toLogin() {
    let coordinator = AuthCoordinator()
    coordinator.onFinishFlow = { [weak self, weak coordinator] in
      self?.removeDependency(coordinator)
      self?.start()
    }
    self.addDependency(coordinator)
    coordinator.start()
  }
}

//
//  MainCoordinator.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 11/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

/// Координатор для главного экрана
final public class MainCoordinator: BaseCoordinator {
  
  /// Замыкание, вызываемое при завершении работы координатора
  public var onFinishFlow: (() -> Void)?
  
  private var rootController: UINavigationController?
  
  /// Показывает контроллер карты
  override public func start() {
    self.showMapModule()
  }
  
  private func showMapModule() {
    guard let controller = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "MapViewController") as? MapViewController
      else {return}
    let rootController = UINavigationController(rootViewController: controller)
    self.setAsRoot(rootController)
    self.rootController = rootController
    
    controller.onLogout = { [weak self] in
      self?.onFinishFlow?()
    }
  }
}

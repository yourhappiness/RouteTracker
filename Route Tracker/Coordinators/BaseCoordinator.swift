//
//  BaseCoordinator.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 11/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit

/// Абстрактный класс-координатор
public class BaseCoordinator {
  
  private var childCoordinators: [BaseCoordinator] = []
  
  /// Функция переопределяется в наследниках
  public func start() {
  }
  
  /// Добавляет координатор в дочерние зависимые
  ///
  /// - Parameter coordinator: координатор
  public func addDependency(_ coordinator: BaseCoordinator) {
    for element in self.childCoordinators where element === coordinator {
      return
    }
    self.childCoordinators.append(coordinator)
  }
  
  /// Удаляет координатор из дочерних зависимых
  ///
  /// - Parameter coordinator: координатор
  public func removeDependency(_ coordinator: BaseCoordinator?) {
    guard
      self.childCoordinators.isEmpty == false,
      let coordinator = coordinator
      else {return}
    for (index, element) in self.childCoordinators.reversed().enumerated() where element === coordinator {
      self.childCoordinators.remove(at: index)
      break
    }
  }
  
  /// Установка root контроллера для приложения
  ///
  /// - Parameter controller: контроллер
  public func setAsRoot(_ controller: UIViewController) {
    UIApplication.shared.keyWindow?.rootViewController = controller
  }
}

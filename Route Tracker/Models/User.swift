//
//  User.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 10/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import Foundation
import RealmSwift

/// Модель для хранения данных для входа пользователя
public class User: Object {
  @objc
  private dynamic var login = ""
  /// Пароль пользователя
  @objc
  public dynamic var password = ""
  
  /// Назначение первичного ключа для объекта
  ///
  /// - Returns: название переменной - первичного ключа
  override public static func primaryKey() -> String? {
    return "login"
  }
  
  /// Инициализатор
  ///
  /// - Parameters:
  ///   - login: логин пользователя
  ///   - password: пароль пользователя
  public convenience init(login: String, password: String) {
    self.init()
    self.login = login
    self.password = password
  }
}

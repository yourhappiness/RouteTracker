//
//  DatabaseService.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 07/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import Foundation
import RealmSwift

/// Сервис для работы с базой данных
public class DatabaseService {
  
  private let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
  private var realm: Realm?
  
  /// Инициализатор
  public init() {
    self.getRealm()
    print(self.realm?.configuration.fileURL as Any)
  }
  
  private func getRealm() {
    self.realm = try? Realm(configuration: self.configuration)
  }
  
  /// Сохраняет данные в базе данных
  ///
  /// - Parameter data: данные для сохранения
  public func saveData <T: Object> (_ data: [T], update: Bool = false) {
    let updatePolicy: Realm.UpdatePolicy
    if update {
      updatePolicy = .modified
    } else {
      updatePolicy = .error
    }
    try? self.realm?.write {
      self.realm?.add(data, update: updatePolicy)
    }
  }
  
  /// Загружает данные из базы
  ///
  /// - Returns: результат запроса к базе
  public func loadData <T: Object> (type: T.Type) -> Results<T>? {
    return self.realm?.objects(type)
  }
  
  /// Ищет в базе пользователя с заданным логином
  ///
  /// - Parameter login: логин пользователя
  /// - Returns: данные пользователя
  public func searchForUser (login: String) -> Results<User>? {
    return self.realm?.objects(User.self).filter("login == %@", login)
  }
  
  /// Удаляет данные из базы
  ///
  /// - Parameter data: данные для удаления
  public func deleteData <T: Object> (_ data: [T]) {
    try? self.realm?.write {
      self.realm?.delete(data)
    }
  }
}

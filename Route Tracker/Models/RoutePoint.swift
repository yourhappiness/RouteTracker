//
//  RoutePoint.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 07/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

/// Модель точки маршрута для хранения в Realm
public class RoutePoint: Object {
  @objc
    private dynamic var latitude = 0.0
  @objc
    private dynamic var longitude = 0.0
  
  /// Инициализация с помощью CLLocationCoordinate2D
  ///
  /// - Parameter coordinate: координаты
  public convenience required init(_ coordinate: CLLocationCoordinate2D) {
    self.init()
    self.latitude = coordinate.latitude
    self.longitude = coordinate.longitude
  }
  
  /// Выполняет преобразование в тип CLLocationCoordinate2D
  ///
  /// - Returns: координату в нужном формате
  public func makeCLLocationCoordinate2D() -> CLLocationCoordinate2D {
    let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    return coordinate
  }
}

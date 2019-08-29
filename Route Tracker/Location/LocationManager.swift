//
//  LocationManager.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 19/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

/// Менеджер для отслеживания местоположения
final public class LocationManager: NSObject {
  /// Статический экземпляр
  public static let instance = LocationManager()
  /// Переменная для хранения текущего местоположения
  public let location: Variable<CLLocation?> = Variable(nil)
  
  private override init() {
    super.init()
    self.configureLocationManager()
  }
  
  private let locationManager = CLLocationManager()
  
  /// Начинает отслеживать геопозицию
  public func startUpdatingLocation() {
    self.locationManager.startUpdatingLocation()
  }
  
  /// Заканчивает отслеживать геопозицию
  public func stopUpdatingLocation() {
    self.locationManager.stopUpdatingLocation()
  }
  
  private func configureLocationManager() {
    self.locationManager.delegate = self
    self.locationManager.allowsBackgroundLocationUpdates = true
    self.locationManager.pausesLocationUpdatesAutomatically = false
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    self.locationManager.startMonitoringSignificantLocationChanges()
    self.locationManager.requestAlwaysAuthorization()
  }
}

extension LocationManager: CLLocationManagerDelegate {
  /// Выполняет сдвиг карты и добавление точки в маршрут при изменении местоположения
  ///
  /// - Parameters:
  ///   - manager: CLLocation менеджер
  ///   - locations: список местоположений в хронологическом порядке
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.location.value = locations.last
  }
  
  /// Выводит описание ошибки при возникновении ошибки определения местоположения
  ///
  /// - Parameters:
  ///   - manager: CLLocation менеджер
  ///   - error: ошибка
  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}

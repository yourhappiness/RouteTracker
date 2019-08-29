//
//  MapViewController.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 04/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit
import GoogleMaps
import RealmSwift
import RxSwift

/// Контроллер для отображения карты
public class MapViewController: UIViewController {
  
  /// Вью для отображения карты
  @IBOutlet public weak var mapView: GMSMapView!
  @IBOutlet weak var routePathButton: UIButton!
  
  /// Замыкание, вызываемое при нажатии кнопки выход
  public var onLogout: (() -> Void)?
  
  private let locationManager = LocationManager.instance
  private let disposeBag = DisposeBag()
  
  private var route: GMSPolyline?
  private var routePath: GMSMutablePath?
  private var isTracking: Bool = false
  private var hasSavedRoute: Bool = false
  private var databaseService = DatabaseService()
  private var marker: GMSMarker?
  private var markerView: UIImageView?
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.configureLocationManager()
    self.configureRightNavButton()
    self.configureLeftNavButton()
    self.configureRoutePathButton()
  }
  
  private func configureLocationManager() {
    self.locationManager
      .location
      .asObservable()
      .bind { [weak self] location in
        guard let location = location else {return}
        self?.routePath?.add(location.coordinate)
        self?.route?.path = self?.routePath
        if UserDefaults.standard.bool(forKey: "hasAvatar") {
          guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else {return}
          let imageFile = documentsDirectory.appendingPathComponent("image.png").path
          if self?.marker != nil {
            self?.marker?.map = nil
          }
          self?.marker = GMSMarker(position: location.coordinate)
          self?.marker?.map = self?.mapView
          self?.markerView = UIImageView(image: UIImage(contentsOfFile: imageFile))
          self?.markerView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
          self?.markerView?.layer.cornerRadius = 30 / 2
          self?.markerView?.layer.masksToBounds = true
          self?.marker?.iconView = self?.markerView
          self?.marker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        }
        let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
        self?.mapView.animate(to: position)
    }
    .disposed(by: self.disposeBag)
  }
  
  private func configureRightNavButton() {
    let rightNavigationButton = UIButton(type: .custom)
    rightNavigationButton.titleLabel?.numberOfLines = 0
    rightNavigationButton.titleLabel?.lineBreakMode = .byWordWrapping
    rightNavigationButton.titleLabel?.textAlignment = .center
    rightNavigationButton.setTitleColor(.blue, for: .normal)

    if self.isTracking {
      rightNavigationButton.setTitle("Закончить трек", for: .normal)
      rightNavigationButton.addTarget(self, action: #selector(self.stopTracking), for: .touchUpInside)
    } else {
      rightNavigationButton.setTitle("Начать новый трек", for: .normal)
      rightNavigationButton.addTarget(self, action: #selector(self.startTracking), for: .touchUpInside)
    }
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightNavigationButton)
  }
  
  private func configureLeftNavButton() {
    let leftNavigationButton = UIButton(type: .custom)
    leftNavigationButton.setTitleColor(.blue, for: .normal)
    leftNavigationButton.setTitle("Выход", for: .normal)
    leftNavigationButton.addTarget(self, action: #selector(self.leftNavButtonPressed), for: .touchUpInside)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftNavigationButton)
  }
  
  private func configureRoutePathButton() {
    self.routePathButton.titleLabel?.textAlignment = .center
    self.routePathButton.setTitleColor(.blue, for: .normal)
    guard self.hasSavedRoute || self.isTracking else {
      self.routePathButton.isHidden = true
      return
    }
    self.routePathButton.setTitle("Отобразить предыдущий маршрут", for: .normal)
    self.routePathButton.isHidden = false
    self.routePathButton.addTarget(self, action: #selector(self.routePathButtonPressed(_:)), for: .touchUpInside)
  }
  
  @objc
  private func startTracking() {
    self.route?.map = nil
    self.route = GMSPolyline()
    self.routePath = GMSMutablePath()
    self.route?.map = self.mapView
    if CLLocationManager.locationServicesEnabled() {
      self.locationManager.startUpdatingLocation()
    }
    self.isTracking = true
    self.configureRoutePathButton()
    self.configureRightNavButton()
  }
  
  @objc
  private func stopTracking() {
    self.locationManager.stopUpdatingLocation()
    self.isTracking = false
    
    if let previousPoints = self.databaseService.loadData(type: RoutePoint.self) {
      var savedPoints: [RoutePoint] = []
      for point in previousPoints {
        savedPoints.append(point)
      }
      self.databaseService.deleteData(savedPoints)
    }
    
    var routePoints: [RoutePoint] = []
    guard let path = self.routePath, path.count() > 0 else {
      self.configureRightNavButton()
      self.configureRoutePathButton()
      return
    }
    self.hasSavedRoute = true
    let pathLength = path.count()
    for index in UInt(0)...(pathLength - 1) {
      let coordinate = path.coordinate(at: index)
      let routePoint = RoutePoint(coordinate)
      routePoints.append(routePoint)
    }
    self.databaseService.saveData(routePoints)
    
    self.configureRightNavButton()
    self.configureRoutePathButton()
  }
  
  @IBAction func routePathButtonPressed(_ sender: Any) {
    if self.isTracking {
      let alertVC = UIAlertController(
        title: "Выполняется слежение",
        message: "Для продолжения необходимо остановить слежение",
        preferredStyle: .alert)
      let okAction = UIAlertAction(title: "ОК", style: .destructive, handler: { _ in
        self.stopTracking()
        self.showSavedRoute()
      })
      let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: { _ in
        return
      })
      alertVC.addAction(okAction)
      alertVC.addAction(cancelAction)
      self.present(alertVC, animated: true, completion: nil)
    } else {
      self.showSavedRoute()
    }
  }
  
  @IBAction func chooseAvatarButtonPressed(_ sender: Any) {
    guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {return}
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.allowsEditing = true
    imagePickerController.delegate = self
    self.present(imagePickerController, animated: true)
  }
  
  @objc
  private func leftNavButtonPressed() {
    UserDefaults.standard.set(false, forKey: "isLogin")
    self.onLogout?()
  }
  
  private func showSavedRoute() {
    guard let savedPoints = self.databaseService.loadData(type: RoutePoint.self) else { return }
    self.routePath = GMSMutablePath()
    for point in savedPoints {
      let coordinate = point.makeCLLocationCoordinate2D()
      self.routePath?.add(coordinate)
    }
    self.route?.path = self.routePath
    let bounds: GMSCoordinateBounds = GMSCoordinateBounds.init(path: self.routePath ?? GMSMutablePath())
    let cameraUpdate: GMSCameraUpdate = GMSCameraUpdate.fit(bounds)
    self.mapView.moveCamera(cameraUpdate)
  }
}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension MapViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  /// Закрывает контроллер при нажатии кнопки отмена
  ///
  /// - Parameter picker: контроллер-пикер
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
  }
  
  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let image = extractImage(from: info)
    guard let documentsDirectory = FileManager.default.urls(
      for: .documentDirectory,
      in: .userDomainMask).first else {return}
    let imageFile = documentsDirectory.appendingPathComponent("image.png").path
    let fileExists = FileManager.default.fileExists(atPath: imageFile)
    if fileExists {
      do {
        try FileManager.default.removeItem(atPath: imageFile)
        UserDefaults.standard.set(false, forKey: "hasAvatar")
      } catch {
        print(error.localizedDescription)
      }
    }
    let PngImage = image?.pngData()
    FileManager.default.createFile(atPath: imageFile, contents: PngImage, attributes: nil)
    UserDefaults.standard.set(true, forKey: "hasAvatar")
    self.markerView?.image = image
    picker.dismiss(animated: true)
  }
  
  private func extractImage(from info: [UIImagePickerController.InfoKey : Any]) -> UIImage? {
    if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      return image
    } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      return image
    } else {
      return nil
    }
  }
}

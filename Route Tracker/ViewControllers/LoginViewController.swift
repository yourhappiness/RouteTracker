//
//  LoginViewController.swift
//  Route Tracker
//
//  Created by Anastasia Romanova on 11/08/2019.
//  Copyright © 2019 Anastasia Romanova. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {

  @IBOutlet weak var loginTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var registerButton: UIButton!
  
  private let disposeBag = DisposeBag()
  private var databaseService = DatabaseService()
  
  /// Замыкание, вызываемое при успешной авторизации
  public var onLogin: (() -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configureLoginBindings()
    self.configureRegisterBindings()
  }
  
  private func configureLoginBindings() {
    Observable.combineLatest(
      self.loginTextField.rx.text,
      self.passwordTextField.rx.text
    )
      .map { login, password in
        return !(login ?? "").isEmpty && (password ?? "").count >= 6
      }
        .bind { [weak loginButton] inputFilled in
          loginButton?.isEnabled = inputFilled
      }
    .disposed(by: self.disposeBag)
  }
  
  private func configureRegisterBindings() {
    Observable.combineLatest(
      self.loginTextField.rx.text,
      self.passwordTextField.rx.text
      )
      .map { login, password in
        return !(login ?? "").isEmpty && (password ?? "").count >= 6
      }
      .bind { [weak registerButton] inputFilled in
        registerButton?.isEnabled = inputFilled
    }
    .disposed(by: self.disposeBag)
  }
  
  @IBAction func login(_ sender: Any) {
    guard
      let login = self.loginTextField.text,
      let password = self.passwordTextField.text
      else { return }
    guard let user = self.databaseService.searchForUser(login: login)?.first else {
      self.showAlert(title: "Ошибка", message: "Пользователь с такими данными незарегистрирован")
      return
    }
    if user.password == password {
      UserDefaults.standard.set(true, forKey: "isLogin")
      self.onLogin?()
    } else {
      self.showAlert(title: "Ошибка", message: "Неверный пароль")
    }
  }
  
  @IBAction func register(_ sender: Any) {
    guard
      let login = self.loginTextField.text,
      let password = self.passwordTextField.text
      else { return }
    let newUser = User(login: login, password: password)
    if self.databaseService.searchForUser(login: login)?.first != nil {
      self.databaseService.saveData([newUser], update: true)
      self.showAlert(title: "Изменение пароля", message: "Пароль успешно изменен")
    } else {
      self.databaseService.saveData([newUser])
      self.showAlert(title: "Регистрация", message: "Пользователь успешно зарегистрирован")
    }
  }
  
}

//
//  SignUpViewModel.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/06.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel {
    enum Text {
        static let emailPlaceholder = "이메일 주소"
        static let nicknamePlaceholder = "닉네임"
        static let passwordPlaceholder = "비밀번호"
        static let passwordCheckPlaceholder = "비밀번호 확인"
    }

    enum Mode {
        case signUp
        case login

        var navigationTitle: String {
            switch self {
            case .signUp:
                return "새싹농장 가입하기"
            case .login:
                return "새싹농장 로그인"
            }
        }

        var buttonTitle: String {
            switch self {
            case .signUp:
                return "시작하기"
            case .login:
                return "로그인"
            }
        }
    }

    private let disposeBag = DisposeBag()
    var mode: Mode = .signUp
    let startButtonTapped = PublishSubject<Void>()
    let emailText = BehaviorSubject<String>(value: "")
    let nicknameText = BehaviorSubject<String>(value: "")
    let passwordText = BehaviorSubject<String>(value: "")
    let passwordCheckText = BehaviorSubject<String>(value: "")

    let isValid = BehaviorSubject<Bool>(value: false)
    let isEmailValid = BehaviorSubject<Bool>(value: false)
    let isNicknameValid = BehaviorSubject<Bool>(value: false)
    let isPasswordValid = BehaviorSubject<Bool>(value: false)
    let isPasswordCheckValid = BehaviorSubject<Bool>(value: false)
    let isPasswordEqualToPasswordCheck = BehaviorSubject<Bool>(value: false)

    init() {
        _ = emailText.map(checkEmailValid(email:))
            .bind(to: isEmailValid)
        _ = nicknameText.map(checkNicknameValid(nickname:))
            .bind(to: isNicknameValid)
        _ = passwordText.map(checkPasswordValid(password:))
            .bind(to: isPasswordValid)
        _ = passwordCheckText.map(checkPasswordCheckValid(passwordCheck:))
            .bind(to: isPasswordCheckValid)
        bindPasswordisEqualToPasswordCheck()
        bindIsValid()
    }

    private func checkEmailValid(email: String) -> Bool {
        return email.contains("@")
    }

    private func checkNicknameValid(nickname: String) -> Bool {
        return !nickname.isEmpty
    }

    private func checkPasswordValid(password: String) -> Bool {
        return !password.isEmpty
    }

    private func checkPasswordCheckValid(passwordCheck: String) -> Bool {
        return !passwordCheck.isEmpty
    }

    private func bindPasswordisEqualToPasswordCheck() {
        Observable.combineLatest(passwordText, passwordCheckText) {
            $0 == $1
        }.bind(to: isPasswordEqualToPasswordCheck)
            .disposed(by: disposeBag)
    }

    private func bindIsValid() {
        Observable.combineLatest(
            self.isEmailValid,
            self.isNicknameValid,
            self.isPasswordValid,
            self.isPasswordCheckValid,
            self.isPasswordEqualToPasswordCheck) { email, nickname, password, passwordCheck, passwardEqual -> Bool in
                if self.mode == .signUp {
                    return email && nickname && password && passwordCheck && passwardEqual
                } else {
                    return email && password
                }
            }
            .bind(to: self.isValid)
            .disposed(by: self.disposeBag)

    }
}

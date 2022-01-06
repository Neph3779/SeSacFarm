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

    private let disposeBag = DisposeBag()
    let startButtonTapped = PublishSubject<Void>()
    let emailText = BehaviorSubject<String>(value: "")
    let nicknameText = BehaviorSubject<String>(value: "")
    let passwordText = BehaviorSubject<String>(value: "")
    let passwordCheckText = BehaviorSubject<String>(value: "")

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
        _ = startButtonTapped.subscribe(onNext: { _ in
            print("tapped")
        })
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
}

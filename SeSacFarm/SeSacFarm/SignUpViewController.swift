//
//  SignUpViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/03.
//

import UIKit
import SnapKit
import RxSwift

final class SignUpViewController: UIViewController {
    private let signUpViewModel = SignUpViewModel()
    private var disposeBag = DisposeBag()
    private let signUpStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        return stackView
    }()
    private let emailTextField = UITextField()
    private let nicknameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let passwordCheckTextField = UITextField()
    private let startButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bind()
        setNavigationBar()
        setSignUpStackView()
        setTextFields()
        setStartButton()
    }

    private func bind() {
        emailTextField.rx.text.orEmpty
            .bind(to: signUpViewModel.emailText)
            .disposed(by: disposeBag)
        nicknameTextField.rx.text.orEmpty
            .bind(to: signUpViewModel.nicknameText)
            .disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty
            .bind(to: signUpViewModel.passwordText)
            .disposed(by: disposeBag)
        passwordCheckTextField.rx.text.orEmpty
            .bind(to: signUpViewModel.passwordCheckText)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(signUpViewModel.isEmailValid,
                           signUpViewModel.isNicknameValid,
                           signUpViewModel.isPasswordValid,
                           signUpViewModel.isPasswordCheckValid,
                           signUpViewModel.isPasswordEqualToPasswordCheck) {
                emailValid, nicknameValid, passwordValid, passwordCheckValid, passwordEqual -> Bool in
                if emailValid && nicknameValid && passwordValid && passwordCheckValid && passwordEqual {
                    self.startButton.backgroundColor = .systemGreen
                    return true
                } else {
                    self.startButton.backgroundColor = .gray
                    return false
                }
            }.bind(to: startButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    private func setNavigationBar() {
        navigationItem.title = "새싹농장 가입하기"
        navigationController?.navigationBar.tintColor = .black
    }

    private func setSignUpStackView() {
        view.addSubview(signUpStackView)
        signUpStackView.snp.makeConstraints { stackView in
            stackView.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    private func setTextFields() {
        view.addSubview(signUpStackView)
        [emailTextField, nicknameTextField, passwordTextField, passwordCheckTextField].forEach { textField in
            signUpStackView.addArrangedSubview(textField)
            textField.borderStyle = .roundedRect
        }

        emailTextField.placeholder = SignUpViewModel.Text.emailPlaceholder
        nicknameTextField.placeholder = SignUpViewModel.Text.nicknamePlaceholder
        passwordTextField.placeholder = SignUpViewModel.Text.passwordPlaceholder
        passwordCheckTextField.placeholder = SignUpViewModel.Text.passwordCheckPlaceholder
    }

    private func setStartButton() {
        startButton.backgroundColor = .gray
        startButton.setTitle("시작하기", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        signUpStackView.addArrangedSubview(startButton)
    }
}

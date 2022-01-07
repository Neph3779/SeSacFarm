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
    private var signUpViewModel = SignUpViewModel()
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

    init(mode: SignUpViewModel.Mode) {
        super.init(nibName: nil, bundle: nil)
        signUpViewModel.mode = mode
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

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
                var valid = false
                if self.signUpViewModel.mode == .signUp {
                    valid = emailValid && nicknameValid &&
                    passwordValid && passwordCheckValid && passwordEqual ? true : false
                } else if self.signUpViewModel.mode == .login {
                    valid = emailValid && passwordValid ? true : false
                }

                if valid {
                    self.startButton.backgroundColor = .systemGreen
                    return true
                } else {
                    self.startButton.backgroundColor = .gray
                    return false
                }
            }.bind(to: startButton.rx.isEnabled)
            .disposed(by: disposeBag)

        startButton.rx.tap // TODO: 이 끔찍한 코드들 해결 필요
            .subscribe(onNext: {
                if self.signUpViewModel.mode == .signUp {
                    SesacNetwork.shared.register(userName: self.nicknameTextField.text!,
                                                 email: self.emailTextField.text!,
                                                 password: self.passwordTextField.text!) { _ in
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(PostsViewController(), animated: true)
                        }
                    }
                } else if self.signUpViewModel.mode == .login {
                    SesacNetwork.shared.login(identifier: self.emailTextField.text!,
                                              password: self.passwordTextField.text!) { _ in
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(PostsViewController(), animated: true)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func setNavigationBar() {
        let navigationTitle = signUpViewModel.mode == .signUp ? "새싹농장 가입하기" : "새싹농장 로그인"
        navigationItem.title = navigationTitle
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
        if signUpViewModel.mode == .signUp {
            [emailTextField, nicknameTextField, passwordTextField, passwordCheckTextField].forEach { textField in
                signUpStackView.addArrangedSubview(textField)
                textField.borderStyle = .roundedRect
            }
        } else if signUpViewModel.mode == .login {
            [emailTextField, passwordTextField].forEach { textField in
                signUpStackView.addArrangedSubview(textField)
                textField.borderStyle = .roundedRect
            }
        }

        emailTextField.placeholder = SignUpViewModel.Text.emailPlaceholder
        nicknameTextField.placeholder = SignUpViewModel.Text.nicknamePlaceholder
        passwordTextField.placeholder = SignUpViewModel.Text.passwordPlaceholder
        passwordCheckTextField.placeholder = SignUpViewModel.Text.passwordCheckPlaceholder
//        emailTextField.textContentType = .emailAddress
//        nicknameTextField.textContentType = .name
        [passwordTextField, passwordCheckTextField].forEach {
            $0.isSecureTextEntry = true
//            $0.textContentType = .password 공부해볼 키워드들
        }
    }

    private func setStartButton() {
        let buttonTitle = signUpViewModel.mode == .signUp ? "시작하기" : "로그인"
        startButton.backgroundColor = .gray
        startButton.setTitle(buttonTitle, for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        signUpStackView.addArrangedSubview(startButton)
    }
}

//
//  SignUpViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/03.
//

import UIKit
import SnapKit
import Toast
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

        signUpViewModel.isValid
            .subscribe(
                onNext: { valid in
                    self.startButton.isEnabled = valid ? true : false
                    self.startButton.backgroundColor = valid ? .systemGreen : .gray
                })
            .disposed(by: disposeBag)

        startButton.rx.tap
            .subscribe(
                onNext: {
                    if self.signUpViewModel.mode == .signUp {
                        SesacNetwork.shared.register(userName: self.nicknameTextField.text!,
                                                     email: self.emailTextField.text!,
                                                     password: self.passwordTextField.text!,
                                                     completion: self.loginRegisterCompletion(_:))
                    } else if self.signUpViewModel.mode == .login {
                        SesacNetwork.shared.login(identifier: self.emailTextField.text!,
                                                  password: self.passwordTextField.text!,
                                                  completion: self.loginRegisterCompletion(_:))
                    }
                })
            .disposed(by: disposeBag)
    }

    private func loginRegisterCompletion(_ result: Result<RegisterLoginResult, SesacNetworkError>) {
        switch result {
        case .success:
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(PostsViewController(), animated: true)
            }
        case .failure:
            DispatchQueue.main.async {
                var toastStyle = ToastStyle()
                toastStyle.titleAlignment = .center
                self.view.makeToast("이메일과 비밀번호를 다시 확인해주세요", duration: 2,
                                    position: .bottom, title: "로그인 실패", style: toastStyle)
            }
        }
    }

    private func setNavigationBar() {
        navigationItem.title = signUpViewModel.mode.navigationTitle
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
        [passwordTextField, passwordCheckTextField].forEach {
            $0.isSecureTextEntry = true
        }
    }

    private func setStartButton() {
        startButton.setTitle(signUpViewModel.mode.buttonTitle, for: .normal)
        startButton.backgroundColor = .gray
        startButton.setTitleColor(.white, for: .normal)
        signUpStackView.addArrangedSubview(startButton)
    }
}

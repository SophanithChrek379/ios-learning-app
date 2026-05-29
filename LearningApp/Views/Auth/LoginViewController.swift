import UIKit

class LoginViewController: UIViewController {

    private let viewModel = AuthViewModel()

    /// Called when login succeeds, so the app can swap the root to the task list.
    var onLoginSuccess: (() -> Void)?

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome back"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.borderStyle = .roundedRect
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let goToRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don't have an account? Sign up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()

        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        goToRegisterButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(goToRegisterButton)
        view.addSubview(spinner)

        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 48),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordField.heightAnchor.constraint(equalToConstant: 48),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            spinner.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            spinner.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -16),

            goToRegisterButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            goToRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async { self?.updateUI() }
        }
    }

    @MainActor
    private func updateUI() {
        if viewModel.isLoading {
            spinner.startAnimating()
            loginButton.isEnabled = false
        } else {
            spinner.stopAnimating()
            loginButton.isEnabled = true
        }

        if let message = viewModel.errorMessage {
            showAlert(message)
        }

        if viewModel.didSucceed {
            onLoginSuccess?()
        }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func didTapLogin() {
        let email = emailField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = passwordField.text ?? ""

        /// Tiny check so we don't even hit the network with empty fields.
        guard !email.isEmpty, !password.isEmpty else {
            showAlert("Please type your email and password.")
            return
        }

        Task {
            await viewModel.login(email: email, password: password)
        }
    }

    @objc private func didTapRegister() {
        let registerVC = RegisterViewController()
        registerVC.onRegisterSuccess = { [weak self] in
            /// After a successful sign-up, jump straight into the app.
            self?.onLoginSuccess?()
        }
        navigationController?.pushViewController(registerVC, animated: true)
    }
}

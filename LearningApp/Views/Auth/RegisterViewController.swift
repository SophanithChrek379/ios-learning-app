import UIKit

class RegisterViewController: UIViewController {

    private let viewModel = AuthViewModel()

    /// Called when sign-up succeeds, so the app can swap to the task list.
    var onRegisterSuccess: (() -> Void)?

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create your account"
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
        field.placeholder = "Password (8+ characters)"
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
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
        title = "Sign up"
        setupLayout()
        bindViewModel()

        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
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

            signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),

            spinner.centerYAnchor.constraint(equalTo: signUpButton.centerYAnchor),
            spinner.trailingAnchor.constraint(equalTo: signUpButton.trailingAnchor, constant: -16),
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
            signUpButton.isEnabled = false
        } else {
            spinner.stopAnimating()
            signUpButton.isEnabled = true
        }

        if let message = viewModel.errorMessage {
            showAlert(message)
        }

        if viewModel.didSucceed {
            onRegisterSuccess?()
        }
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func didTapSignUp() {
        let email = emailField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let password = passwordField.text ?? ""

        guard !email.isEmpty else {
            showAlert("Please type your email.")
            return
        }
        guard password.count >= 8 else {
            showAlert("Password must be at least 8 characters.")
            return
        }

        Task {
            await viewModel.register(email: email, password: password)
        }
    }
}

import UIKit

class LoginViewController: UIViewController {

    private let viewModel = AuthViewModel()

    /// Called when login succeeds, so the app can swap the root to the task list.
    var onLoginSuccess: (() -> Void)?

    // MARK: - Design tokens
    /// Same "Kinetic Efficiency" palette as the Splash screen.
    private enum Tokens {
        static let background       = UIColor(hex: 0xF9F9F9)
        static let surface          = UIColor.white
        static let primary          = UIColor(hex: 0xB31F14) // Todoist red
        static let onSurface        = UIColor(hex: 0x1A1A1A)
        static let onSurfaceVariant = UIColor(hex: 0x5B403C) // muted brown for labels
        static let placeholder      = UIColor(hex: 0xBDBDBD)
        static let fieldBorder      = UIColor(hex: 0xE2E2E2)
        static let fieldBackground  = UIColor(hex: 0xF4F4F4)
    }

    // MARK: - Branding (top)

    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Tokens.primary
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
        let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let appTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "TaskFlow"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = Tokens.onSurface
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fuel your productivity with kinetic focus."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = Tokens.onSurfaceVariant
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Card

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = Tokens.surface
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emailCaption = LoginViewController.makeCaption("EMAIL")
    private let passwordCaption = LoginViewController.makeCaption("PASSWORD")

    private lazy var emailField: PaddedTextField = {
        let field = PaddedTextField()
        field.placeholder = "alex@example.com"
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.font = .systemFont(ofSize: 16)
        field.textColor = Tokens.onSurface
        field.backgroundColor = Tokens.fieldBackground
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = Tokens.fieldBorder.cgColor
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 52).isActive = true

        /// Left mail icon — sits in a fixed 48pt-wide container so the
        /// placeholder text starts cleanly to the right of it.
        field.leftView = LoginViewController.makeIconView(systemName: "envelope")
        field.leftViewMode = .always
        return field
    }()

    private lazy var passwordField: PaddedTextField = {
        let field = PaddedTextField()
        field.placeholder = "••••••••"
        field.isSecureTextEntry = true
        field.font = .systemFont(ofSize: 16)
        field.textColor = Tokens.onSurface
        field.backgroundColor = Tokens.fieldBackground
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = Tokens.fieldBorder.cgColor
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 52).isActive = true

        /// Left lock icon
        field.leftView = LoginViewController.makeIconView(systemName: "lock")
        field.leftViewMode = .always

        /// Right "show password" eye — a tappable button with the same
        /// padding as the left icon, so it lines up with the field edges.
        let eyeButton = UIButton(type: .system)
        let eyeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        eyeButton.setImage(UIImage(systemName: "eye", withConfiguration: eyeConfig), for: .normal)
        eyeButton.tintColor = Tokens.onSurfaceVariant
        eyeButton.frame = CGRect(x: 0, y: 0, width: 48, height: 52)
        eyeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
        field.rightView = eyeButton
        field.rightViewMode = .always
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(
            string: "Log In  →",
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                .foregroundColor: UIColor.white,
            ]
        )
        button.setAttributedTitle(title, for: .normal)
        button.backgroundColor = Tokens.primary
        button.tintColor = .white
        button.layer.cornerRadius = 14
        button.layer.shadowColor = Tokens.primary.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Footer

    private let footerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let footerLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account?"
        label.font = .systemFont(ofSize: 15)
        label.textColor = Tokens.onSurfaceVariant
        return label
    }()

    private let goToRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        let title = NSAttributedString(
            string: "Sign up",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                .foregroundColor: UIColor(hex: 0xB31F14),
            ]
        )
        button.setAttributedTitle(title, for: .normal)
        return button
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.color = .white
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tokens.background
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupLayout()
        bindViewModel()

        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        goToRegisterButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup

    private func setupLayout() {
        iconContainer.addSubview(iconImageView)

        view.addSubview(iconContainer)
        view.addSubview(appTitleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(cardView)
        view.addSubview(footerStack)

        cardView.addSubview(emailCaption)
        cardView.addSubview(emailField)
        cardView.addSubview(passwordCaption)
        cardView.addSubview(passwordField)
        cardView.addSubview(loginButton)
        loginButton.addSubview(spinner)

        footerStack.addArrangedSubview(footerLabel)
        footerStack.addArrangedSubview(goToRegisterButton)

        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            /// Icon — sits about a quarter of the way down
            iconContainer.topAnchor.constraint(equalTo: safe.topAnchor, constant: 80),
            iconContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 64),
            iconContainer.heightAnchor.constraint(equalToConstant: 64),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            appTitleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 14),
            appTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            /// Card
            cardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            emailCaption.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            emailCaption.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            emailCaption.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            emailField.topAnchor.constraint(equalTo: emailCaption.bottomAnchor, constant: 8),
            emailField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            passwordCaption.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 18),
            passwordCaption.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            passwordCaption.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            passwordField.topAnchor.constraint(equalTo: passwordCaption.bottomAnchor, constant: 8),
            passwordField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 54),
            loginButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),

            spinner.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            spinner.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -20),

            /// Footer
            footerStack.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            footerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordField.isSecureTextEntry.toggle()
        let iconName = passwordField.isSecureTextEntry ? "eye" : "eye.slash"
        sender.setImage(UIImage(systemName: iconName), for: .normal)
    }

    // MARK: - Small helpers

    /// The uppercased, slightly-letter-spaced caption above each field
    /// (EMAIL, PASSWORD). Matches the DESIGN.md `label-md` token.
    private static func makeCaption(_ text: String) -> UILabel {
        let label = UILabel()
        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor(hex: 0x5B403C),
                .kern: 1.0,
            ]
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    /// Builds the small icon container used as a text field's `leftView`.
    /// The container has a fixed 48pt width with the SF Symbol centered
    /// inside it, so the placeholder text always starts cleanly to the right.
    private static func makeIconView(systemName: String) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 52))

        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let icon = UIImageView(image: UIImage(systemName: systemName, withConfiguration: config))
        icon.tintColor = UIColor(hex: 0x5B403C)
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),
        ])
        return container
    }
}

// MARK: - Padded text field

/// A text field whose text rect respects whatever `leftView` / `rightView`
/// we've installed, so the placeholder never sits underneath the icons.
/// UIKit already inserts `leftView` and `rightView` outside our text rect —
/// we just nudge a few extra points of breathing room on each side.
final class PaddedTextField: UITextField {

    /// Where the placeholder / typed text lives.
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        paddedTextRect(forBounds: bounds)
    }

    /// Where the caret + text live while the user is typing.
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        paddedTextRect(forBounds: bounds)
    }

    /// Same rect for the placeholder — keeps things aligned in both states.
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        paddedTextRect(forBounds: bounds)
    }

    /// Slot the icons in vertically centered, flush against the edges.
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let leftView = leftView else { return .zero }
        return CGRect(x: 0,
                      y: (bounds.height - leftView.bounds.height) / 2,
                      width: leftView.bounds.width,
                      height: leftView.bounds.height)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let rightView = rightView else { return .zero }
        return CGRect(x: bounds.width - rightView.bounds.width,
                      y: (bounds.height - rightView.bounds.height) / 2,
                      width: rightView.bounds.width,
                      height: rightView.bounds.height)
    }

    /// Insets the bounds by the actual leftView/rightView widths so text
    /// can never overlap them, plus a tiny gap on each side for breathing room.
    private func paddedTextRect(forBounds bounds: CGRect) -> CGRect {
        let leftInset  = (leftView?.bounds.width  ?? 0) + 4
        let rightInset = (rightView?.bounds.width ?? 0) + 4
        return bounds.inset(by: UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset))
    }
}

// MARK: - Tiny helper

/// Same hex initializer used on the Splash screen, scoped private to
/// this file so it doesn't clash with the splash's copy.
private extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >>  8) & 0xFF) / 255.0
        let b = CGFloat( hex        & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

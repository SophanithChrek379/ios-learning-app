import UIKit

class ProfileViewController: UIViewController {

    // MARK: - UI

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 120, weight: .regular)
        imageView.image = UIImage(systemName: "person.crop.circle.fill",
                                  withConfiguration: config)
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello there"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "your.email@example.com"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"

        setupLayout()
        loadUserEmail()

        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(logoutButton)

        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 40),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -24),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    /// Ask the server "who am I?" and show the email.
    /// We use the token that's already saved from login.
    private func loadUserEmail() {
        Task {
            do {
                let user = try await AuthService.shared.me()
                await MainActor.run {
                    self.emailLabel.text = user.email
                }
            } catch {
                await MainActor.run {
                    self.emailLabel.text = "Could not load profile"
                }
            }
        }
    }

    // MARK: - Actions

    @objc private func didTapLogout() {
        /// Ask first, in case the tap was accidental.
        let alert = UIAlertController(title: "Logout?",
                                      message: "You'll need to sign in again next time.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        /// 1. Forget the saved token.
        AuthService.shared.logout()

        /// 2. Ask the SceneDelegate to swap the window back to the Login screen.
        let scene = view.window?.windowScene
        let sceneDelegate = scene?.delegate as? SceneDelegate
        sceneDelegate?.switchToLogin()
    }
}

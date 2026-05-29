import UIKit

class SplashViewController: UIViewController {

    /// Called once the progress bar finishes filling up.
    /// The SceneDelegate uses this to swap the root window to
    /// either Login or the Task list.
    var onFinish: (() -> Void)?

    // MARK: - Design tokens
    /// Pulled straight from `DESIGN.md` (the "Kinetic Efficiency" theme).
    /// Keeping them in one place makes it easy to tweak the look later.
    private enum Tokens {
        static let background        = UIColor(hex: 0xF9F9F9)
        static let primary           = UIColor(hex: 0xB31F14) // Todoist red
        static let primaryFixed      = UIColor(hex: 0xFFDAD4) // soft pink tint
        static let onSurfaceVariant  = UIColor(hex: 0x5B403C) // muted text
        static let trackColor        = UIColor(hex: 0xE2E2E2) // surface-container-highest
    }

    // MARK: - Subviews

    /// The warm pink-to-cream wash behind everything.
    private let gradientLayer = CAGradientLayer()

    /// Red rounded square that holds the app icon.
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Tokens.primary
        view.layer.cornerRadius = 24 // rounded-xl from DESIGN.md
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// The white check-in-a-circle that sits inside the red square.
    private let iconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 56, weight: .bold)
        let image = UIImage(systemName: "checkmark.circle", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    /// The grey track for the progress bar.
    private let progressTrack: UIView = {
        let view = UIView()
        view.backgroundColor = Tokens.trackColor
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// The red bar that fills the track as the app loads.
    private let progressFill: UIView = {
        let view = UIView()
        view.backgroundColor = Tokens.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// We animate this constraint from 0 to the full track width.
    private var progressFillWidth: NSLayoutConstraint!

    /// "FOCUS & FLOW" pinned to the bottom.
    private let taglineLabel: UILabel = {
        let label = UILabel()
        /// `label-md` from DESIGN.md: 12px / 600 weight / 0.05em letter-spacing.
        /// `.kern` in points roughly matches `letter-spacing` in CSS.
        label.attributedText = NSAttributedString(
            string: "FOCUS & FLOW",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: Tokens.onSurfaceVariant,
                .kern: 1.2,
            ]
        )
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Tokens.background
        setupGradient()
        setupLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// The gradient layer is plain Core Animation, so it doesn't
        /// auto-layout — we resize it by hand whenever the view changes.
        gradientLayer.frame = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateProgressBar()
    }

    // MARK: - Setup

    private func setupGradient() {
        /// A soft pink corner that fades into the off-white background.
        gradientLayer.colors = [
            Tokens.primaryFixed.withAlphaComponent(0.55).cgColor,
            Tokens.background.cgColor,
        ]
        gradientLayer.locations = [0.0, 0.6]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0) // top-left
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 1.0) // bottom-right
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupLayout() {
        iconContainer.addSubview(iconImageView)
        progressTrack.addSubview(progressFill)

        view.addSubview(iconContainer)
        view.addSubview(progressTrack)
        view.addSubview(taglineLabel)

        /// Start at 0 width — we'll animate it open in `viewDidAppear`.
        progressFillWidth = progressFill.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            /// App icon — perfectly centered
            iconContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 96),
            iconContainer.heightAnchor.constraint(equalToConstant: 96),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),

            /// Progress bar — sits 24pt below the icon (the `lg` spacing token)
            progressTrack.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 24),
            progressTrack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressTrack.widthAnchor.constraint(equalToConstant: 240),
            progressTrack.heightAnchor.constraint(equalToConstant: 4),

            /// The red fill grows inside the track from left to right
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),
            progressFillWidth,

            /// Tagline — pinned to the bottom safe area
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taglineLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
        ])
    }

    // MARK: - Animation

    private func animateProgressBar() {
        /// Grow the red fill to the full width of the track.
        progressFillWidth.constant = 240

        UIView.animate(
            withDuration: 1.5,
            delay: 0,
            options: [.curveEaseInOut],
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                /// Tiny pause so the full bar is visible for a moment,
                /// then tell whoever is listening that we're done.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.onFinish?()
                }
            }
        )
    }
}

// MARK: - Tiny helper

/// Lets us write `UIColor(hex: 0xB31F14)` instead of dividing each channel by 255.
private extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >>  8) & 0xFF) / 255.0
        let b = CGFloat( hex        & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}

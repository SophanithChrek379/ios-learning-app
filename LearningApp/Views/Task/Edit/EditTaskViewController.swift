import UIKit

class EditTaskViewController: UIViewController {

    var task: TaskItem?
    var viewModel: TaskViewModel?

    private lazy var doneBarButton = UIBarButtonItem(
        title: "Done", style: .done, target: self, action: #selector(didTapDone)
    )

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .systemBackground
        field.borderStyle = .none
        field.layer.cornerRadius = 12
        field.font = .systemFont(ofSize: 16)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.rightViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusRow: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let statusRowLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark as done"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statusSwitch: UISwitch = {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondarySystemBackground
        title = "Edit Task"
        navigationController?.navigationBar.prefersLargeTitles = false

        setupNavBar()
        setupLayout()
        fillInTaskData()
        wireBindings()
    }

    @objc private func toggleSwitch() {
        task?.isCompleted = statusSwitch.isOn
    }
    
    // MARK: - Did Appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }

    // MARK: - Setup

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = doneBarButton
    }

    private func setupLayout() {
        /// Build the status row: label on the left, switch on the right
        statusRow.addSubview(statusRowLabel)
        statusRow.addSubview(statusSwitch)

        /// Add everything to the screen
        view.addSubview(titleLabel)
        view.addSubview(titleTextField)
        view.addSubview(statusLabel)
        view.addSubview(statusRow)

        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            /// Title section
            titleLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),

            /// Status section
            statusLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            statusRow.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            statusRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statusRow.heightAnchor.constraint(equalToConstant: 50),

            /// "Mark as done" label inside the row
            statusRowLabel.leadingAnchor.constraint(equalTo: statusRow.leadingAnchor, constant: 16),
            statusRowLabel.centerYAnchor.constraint(equalTo: statusRow.centerYAnchor),

            /// Switch on the right side of the row
            statusSwitch.trailingAnchor.constraint(equalTo: statusRow.trailingAnchor, constant: -16),
            statusSwitch.centerYAnchor.constraint(equalTo: statusRow.centerYAnchor),
        ])
    }

    private func fillInTaskData() {
        titleTextField.text = task?.title
        statusSwitch.isOn = task?.isCompleted ?? false
    }
    
    private func wireBindings() {
        // Listen for when the user flips the switch
        statusSwitch.addTarget(self, action: #selector(toggleSwitch), for: .valueChanged)

        // Listen for when the user types in the title field
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    // MARK: - Actions

    @objc private func didTapDone() {
        /// 1. Make sure we have a task to update
        guard var updated = task else { return }

        /// 2. Take the latest values from the UI
        updated.title = titleTextField.text ?? ""
        
        /// This line, already implemented in "@objc private func toggleSwitch()"
        // updated.isCompleted = statusSwitch.isOn

        /// 3. Go back to the list right away (feels snappy)
        navigationController?.popViewController(animated: true)

        /// 4. Save to the server in the background
        Task {
            await viewModel?.updateTask(updated)
        }
    }
    
    @objc private func textFieldDidChange() {
        let hasText = !(titleTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        doneBarButton.isEnabled = hasText
    }
}

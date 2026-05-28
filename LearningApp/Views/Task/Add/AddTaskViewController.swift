import UIKit

class AddTaskViewController: UIViewController {
    
    private let titleLabel: UILabel = {
       let label = UILabel()
       label.text = "Title"
       label.font = .systemFont(ofSize: 14, weight: .medium)
       label.textColor = .secondaryLabel
       label.translatesAutoresizingMaskIntoConstraints = false
       return label
   }()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "What needs doing?"
        field.backgroundColor = .systemBackground
        field.borderStyle = .none
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.systemGray5.cgColor
        field.layer.cornerRadius = 12
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .done
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 10))
        field.rightView = spacerView
        field.rightViewMode = .always
        
        return field
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addButton: UIButton = {
       let button = UIButton(type: .system)
       button.setTitle("Add", for: .normal)
       button.backgroundColor = .secondarySystemBackground
       button.setTitleColor(.secondaryLabel, for: .normal)
       button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
       button.layer.cornerRadius = 20
       button.isEnabled = false
       button.translatesAutoresizingMaskIntoConstraints = false
       return button
   }()
    
    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let titleNavLabel: UILabel = {
        let label = UILabel()
        label.text = "New Task"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    var onTaskAdded: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    private func setupView() {
        view.backgroundColor = .secondarySystemBackground

        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
//            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
    }
    
    private func setupLayout() {
        headerStack.addArrangedSubview(cancelButton)
        headerStack.addArrangedSubview(titleNavLabel)
        headerStack.addArrangedSubview(addButton)

        view.addSubview(headerStack)
        view.addSubview(titleLabel)
        view.addSubview(textField)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            cancelButton.widthAnchor.constraint(equalToConstant: 90),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),

            addButton.widthAnchor.constraint(equalToConstant: 90),
            addButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc private func didTapAdd() {
        guard let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        onTaskAdded?(text)
        dismiss(animated: true)
    }

    @objc private func textFieldDidChange() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        addButton.isEnabled = hasText
        addButton.setTitleColor(hasText ? .white : .secondaryLabel, for: .normal)
        addButton.backgroundColor = hasText ? .systemBlue : .secondarySystemBackground
    }
}

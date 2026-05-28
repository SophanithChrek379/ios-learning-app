import UIKit

class TaskListViewController: UIViewController {

    @IBOutlet weak var tableViewOutlet: UITableView!
    
    private let viewModel = TaskViewModel()

    private let refreshControl = UIRefreshControl()

    private var isShowingInitialSkeleton: Bool {
        viewModel.isLoading && viewModel.numberOfTasks() == 0 && !refreshControl.isRefreshing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        bindViewModel()
        loadData()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Tasks"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(fabButton)
        fabButton.addTarget(self, action: #selector(didTapFAB), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            fabButton.widthAnchor.constraint(equalToConstant: 56),
            fabButton.heightAnchor.constraint(equalToConstant: 56),
            fabButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            fabButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }
    
    private func setupTableView() {
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        tableViewOutlet.refreshControl = refreshControl
        tableViewOutlet.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
        tableViewOutlet.register(TaskSkeletonCell.self, forCellReuseIdentifier: TaskSkeletonCell.reuseIdentifier)
        tableViewOutlet.contentInset.top = 24 // = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        tableViewOutlet.contentInset.bottom = 60
        
        refreshControl.addTarget(self, action: #selector(refreshTasks), for: .valueChanged)
    }
    
    private func loadData() {
        Task {
            await viewModel.loadTasks()
        }
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }
    
    @MainActor
    private func updateUI() {
        if !viewModel.isLoading {
            refreshControl.endRefreshing()
        }

        if let error = viewModel.errorMessage {
            print("Error:", error)
        }

        tableViewOutlet.isUserInteractionEnabled = !isShowingInitialSkeleton
        tableViewOutlet.reloadData()
    }
    
    @objc private func refreshTasks() {
        Task {
            await viewModel.loadTasks()
        }
    }
    
    private let fabButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.cornerRadius = 28
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        return button
    }()
    
    @objc
    private func didTapFAB() {
        
        let addVC = AddTaskViewController()
        addVC.modalPresentationStyle = .pageSheet
        addVC.onTaskAdded = { [weak self] taskTitle in
            Task {
                await self?.viewModel.addTask(title: taskTitle)
            }
        }

        present(addVC, animated: true)
    }
}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowingInitialSkeleton {
            return 8
        }

        return viewModel.numberOfTasks()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowingInitialSkeleton {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TaskSkeletonCell.reuseIdentifier,
                for: indexPath
            ) as! TaskSkeletonCell
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        let task = viewModel.task(at: indexPath.row)

        if task.isCompleted {
            let attributeText = NSAttributedString(
                string: task.title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.secondaryLabel
                ])
            cell.textLabel?.attributedText = attributeText
        } else {
            let normalText = NSAttributedString(
                string: task.title,
                attributes: [
                    .strikethroughStyle: 0,
                    .foregroundColor: UIColor.label
                ])
            cell.textLabel?.attributedText = normalText
        }
        return cell
    }
}

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isShowingInitialSkeleton else { return }

        tableView.deselectRow(at: indexPath, animated: true)

        // 1. Get the task the user tapped
        let task = viewModel.task(at: indexPath.row)

        // 2. Create the edit screen and hand it the task + the view model
        let editVC = EditTaskViewController()
        editVC.task = task
        editVC.viewModel = viewModel

        // 3. Push it onto the navigation stack
        navigationController?.pushViewController(editVC, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        guard !isShowingInitialSkeleton else { return }

        let lastRow = viewModel.numberOfTasks() - 1
        if indexPath.row == lastRow {
            Task {
                await viewModel.loadMoreTasks()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isShowingInitialSkeleton else { return nil }
        let task = viewModel.task(at: indexPath.row)

        let done = UIContextualAction(style: .normal, title: "Done") { action, view, value in
                print("Done clicked")
        }
        
        let undo = UIContextualAction(style: .normal, title: "Undo") { action, view, value in
                print("Undo clicked")
        }

        undo.image = UIImage(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
        undo.backgroundColor = .systemOrange

        done.image = UIImage(systemName: "checkmark.circle.fill")
        done.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [task.isCompleted ? undo : done])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isShowingInitialSkeleton else { return nil }

        let delete = UIContextualAction(style: .destructive, title: "Delete") { action, view, value in
            print("Delete clicked")
        }
        delete.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

private final class TaskSkeletonCell: UITableViewCell {
    static let reuseIdentifier = "TaskSkeletonCell"

    private let titleLine = TaskSkeletonCell.makeSkeletonView(width: 220)
    private let subtitleLine = TaskSkeletonCell.makeSkeletonView(width: 140)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.subviews.forEach { view in
            view.layer.sublayers?.forEach { layer in
                layer.frame = view.bounds
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        startAnimating()
    }

    private func setupView() {
        selectionStyle = .none
        isUserInteractionEnabled = false
        backgroundColor = .systemBackground

        let stackView = UIStackView(arrangedSubviews: [titleLine, subtitleLine])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 72)
        ])

        startAnimating()
    }

    private func startAnimating() {
        [titleLine, subtitleLine].forEach { view in
            view.layer.removeAllAnimations()

            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.45
            animation.toValue = 1.0
            animation.duration = 0.8
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            view.layer.add(animation, forKey: "taskSkeletonPulse")
        }
    }

    private static func makeSkeletonView(width: CGFloat) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.heightAnchor.constraint(equalToConstant: 14)
        ])

        return view
    }
}

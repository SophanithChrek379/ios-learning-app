import UIKit

class TaskListViewController: UIViewController {

    @IBOutlet weak var tableViewOutlet: UITableView!
    
    private let viewModel = TaskViewModel()
    
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private let refreshControl = UIRefreshControl()
    
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
        view.addSubview(loadingIndicator)
        view.addSubview(fabButton)
        fabButton.addTarget(self, action: #selector(didTapFAB), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
        if viewModel.isLoading && !refreshControl.isRefreshing {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }

        if !viewModel.isLoading {
            refreshControl.endRefreshing()
        }

        if let error = viewModel.errorMessage {
            print("Error:", error)
        }

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
        return viewModel.numberOfTasks()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        let lastRow = viewModel.numberOfTasks() - 1
        if indexPath.row == lastRow {
            Task {
                await viewModel.loadMoreTasks()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = UIContextualAction(style: .normal, title: "Done") { action, view, value in
                print("Done clicked")
        }
        
        done.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [done])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { action, view, value in
            print("Delete clicked")
        }
        delete.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

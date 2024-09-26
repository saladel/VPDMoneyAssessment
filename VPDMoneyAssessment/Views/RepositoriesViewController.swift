//
//  RepositoriesViewController.swift
//  VPDMoneyAssessment
//
//  Created by Adewale Sanusi on 25/09/2024.
//

import UIKit

class RepositoriesViewController: UIViewController {
    
    private let tableView = UITableView()
    private var repositories: [Repository] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    private var isLoading = false
    private var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Repositories"
        
        setupTableView()
        
        setupActivityIndicator()
        
        fetchRepositories()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        
        // pull to refresh
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        let paginationLoadingView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        let paginationIndicator = UIActivityIndicatorView(style: .medium)
        paginationIndicator.center = paginationLoadingView.center
        paginationLoadingView.addSubview(paginationIndicator)
        tableView.tableFooterView = paginationLoadingView
    }
   
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchRepositories(isRefreshing: Bool = false) {
        guard !isLoading else { return }
        isLoading = true
        
        if isRefreshing {
            currentPage = 1
        }
        
        // progress view indicator
        activityIndicator.startAnimating()
        
        NetworkManager.shared.fetchRepositories(page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.refreshControl.endRefreshing()
                self?.isLoading = false
                (self?.tableView.tableFooterView as? UIView)?.subviews.first(where: { $0 is UIActivityIndicatorView })?.removeFromSuperview()
            }
            switch result {
            case .success(let repos):
                if isRefreshing {
                    self?.repositories = repos
                } else {
                    self?.repositories.append(contentsOf: repos)
                }
                self?.currentPage += 1
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch repositories: \(error)")
                DispatchQueue.main.async {
                    self?.showError(error)
                }
            }
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
        // shows error message if the repositories array is empty
        if repositories.isEmpty {
            let errorMessage = UILabel()
            errorMessage.text = "Failed to load repositories."
            errorMessage.textAlignment = .center
            errorMessage.textColor = .systemGray
            errorMessage.frame = tableView.bounds
            tableView.backgroundView = errorMessage
        } else {
            tableView.backgroundView = nil
        }
    }
    
    @objc private func refreshData() {
        fetchRepositories(isRefreshing: true)
    }
}

// UITableViewDataSource & UITableViewDelegate
extension RepositoriesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: indexPath) as? RepositoryCell else {
            fatalError("Unable to dequeue RepositoryCell")
        }
        let repository = repositories[indexPath.row]
        cell.configure(with: repository)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let repository = repositories[indexPath.row]
        let repositoryDetailVC = RepositoryDetailViewController(repository: repository)
        navigationController?.pushViewController(repositoryDetailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            loadMoreRepositories()
        }
    }
    
    private func loadMoreRepositories() {
        guard !isLoading else { return }
        
        isLoading = true
        (tableView.tableFooterView)?.subviews.first(where: { $0 is UIActivityIndicatorView })?.isHidden = false
        
        fetchRepositories(isRefreshing: false)
    }
}

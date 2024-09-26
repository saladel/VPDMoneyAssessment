//
//  RepositoryDetailViewController.swift
//  VPDMoneyAssessment
//
//  Created by Adewale Sanusi on 25/09/2024.
//

import UIKit

class RepositoryDetailViewController: UIViewController {

    let repository: Repository

    init(repository: Repository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupSubviews()
        
    }

    private func setupSubviews() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        // name of repo
        let repositoryName = UILabel()
        repositoryName.text = repository.name
        repositoryName.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        stackView.addArrangedSubview(repositoryName)

        // repo description
        let repositoryDescription = UILabel()
        repositoryDescription.text = repository.description
        repositoryDescription.font = UIFont.preferredFont(forTextStyle: .body)
        repositoryDescription.numberOfLines = 0
        stackView.addArrangedSubview(repositoryDescription)

        let createdByLabel = UILabel()
        createdByLabel.text = "Created by:"
        createdByLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        createdByLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        stackView.addArrangedSubview(createdByLabel)

        let ownerInfoStack = UIStackView()
        ownerInfoStack.axis = .horizontal
        ownerInfoStack.alignment = .bottom
        ownerInfoStack.spacing = 5
        ownerInfoStack.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(ownerInfoStack)

        // owner image
        let ownerImageView = UIImageView()
        ownerImageView.contentMode = .scaleAspectFit
        ownerImageView.clipsToBounds = true
        ownerImageView.layer.cornerRadius = 8
        ownerImageView.translatesAutoresizingMaskIntoConstraints = false
        ownerInfoStack.addArrangedSubview(ownerImageView)

        let ownerInfoLabelStack = UIStackView()
        ownerInfoLabelStack.axis = .vertical
        ownerInfoLabelStack.alignment = .leading
        ownerInfoLabelStack.spacing = 2
        ownerInfoLabelStack.translatesAutoresizingMaskIntoConstraints = false
        ownerInfoStack.addArrangedSubview(ownerInfoLabelStack)
        
        // repo owner
        let ownerLogin = UILabel()
        ownerLogin.text = repository.owner.login
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let boldDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)
        ownerLogin.font = UIFont(descriptor: boldDescriptor ?? fontDescriptor, size: 0)
        ownerInfoLabelStack.addArrangedSubview(ownerLogin)
        
        // link to repo
        let linkToRepo = UILabel()
        linkToRepo.text = repository.htmlUrl
        linkToRepo.textColor = .blue
        linkToRepo.font = UIFont.preferredFont(forTextStyle: .caption1)
        linkToRepo.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openRepositoryLink))
        linkToRepo.addGestureRecognizer(tapGesture)
        ownerInfoLabelStack.addArrangedSubview(linkToRepo)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            ownerImageView.widthAnchor.constraint(equalToConstant: 40),
            ownerImageView.heightAnchor.constraint(equalToConstant: 40)
        ])

        if let url = URL(string: repository.owner.avatarUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async { [weak self] in
                        ownerImageView.image = image
                    }
                }
            }
        } else {
            ownerImageView.image = UIImage(systemName: "person")?
                .withRenderingMode(.alwaysOriginal)
        }
    }
    
    @objc private func openRepositoryLink() {
        guard let url = URL(string: repository.htmlUrl) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

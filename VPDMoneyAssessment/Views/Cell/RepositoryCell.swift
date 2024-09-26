//
//  RepositoryCell.swift
//  VPDMoneyAssessment
//
//  Created by Adewale Sanusi on 25/09/2024.
//

import UIKit

class RepositoryCell: UITableViewCell {
    private let repoName = UILabel()
    private let repoOwnerImage = UIImageView()
    private let repoOwnerName = UILabel()
    private let dividerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // repo name
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)
        repoName.font = UIFont(descriptor: boldFontDescriptor ?? fontDescriptor, size: 0)
        contentView.addSubview(repoName)
        repoName.translatesAutoresizingMaskIntoConstraints = false
        
        // divider
        dividerView.backgroundColor = .systemGray6
        contentView.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        
        // owner image
        repoOwnerImage.contentMode = .scaleAspectFit
        repoOwnerImage.clipsToBounds = true
        repoOwnerImage.layer.cornerRadius = 10 // Half of the frame size
        contentView.addSubview(repoOwnerImage)
        repoOwnerImage.translatesAutoresizingMaskIntoConstraints = false
        
        // owner name
        contentView.addSubview(repoOwnerName)
        repoOwnerName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            repoName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            repoName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            repoName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dividerView.topAnchor.constraint(equalTo: repoName.bottomAnchor, constant: 5),
            dividerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerView.heightAnchor.constraint(equalToConstant: 0.3),
            
            repoOwnerImage.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 5),
            repoOwnerImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            repoOwnerImage.widthAnchor.constraint(equalToConstant: 20),
            repoOwnerImage.heightAnchor.constraint(equalToConstant: 20),
            repoOwnerImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            repoOwnerName.centerYAnchor.constraint(equalTo: repoOwnerImage.centerYAnchor),
            repoOwnerName.leadingAnchor.constraint(equalTo: repoOwnerImage.trailingAnchor, constant: 10),
            repoOwnerName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with repository: Repository) {
        repoName.text = repository.name
        repoOwnerName.text = repository.owner.login
        
        // loads image
        if let url = URL(string: repository.owner.avatarUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.repoOwnerImage.image = image
                    }
                }
            }.resume()
        }
    }
}

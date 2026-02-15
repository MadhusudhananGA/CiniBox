//
//  MovieTableViewCell.swift
//  CiniBox
//
//

import UIKit

final class MovieTableViewCell: UITableViewCell {
    static let reuseIdentifier = "MovieTableViewCell"
    
    private var currentPosterURL: URL?

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor.secondarySystemBackground
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 2
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .systemYellow
        return label
    }()

    private let favoriteIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemYellow
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        accessoryType = .disclosureIndicator

        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(favoriteIconView)

        let padding: CGFloat = 12

        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
            posterImageView.widthAnchor.constraint(equalToConstant: 80),
            posterImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: favoriteIconView.leadingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            ratingLabel.topAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.bottomAnchor, constant: 4),
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            ratingLabel.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor),

            favoriteIconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoriteIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            favoriteIconView.widthAnchor.constraint(equalToConstant: 20),
            favoriteIconView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentPosterURL = nil
        posterImageView.image = nil
        favoriteIconView.image = nil
    }

    func configure(with movie: Movie, isFavorite: Bool, runtimeMinutes: Int?) {
        titleLabel.text = movie.title

        var metaParts: [String] = []
        if let year = movie.formattedReleaseYear {
            metaParts.append(year)
        }
        if let runtimeMinutes {
            let hours = runtimeMinutes / 60
            let minutes = runtimeMinutes % 60
            if hours > 0 {
                metaParts.append("\(hours)h \(minutes)m")
            } else {
                metaParts.append("\(minutes)m")
            }
        }
        subtitleLabel.text = metaParts.isEmpty ? " " : metaParts.joined(separator: " • ")

        ratingLabel.text = "★ \(movie.formattedRating)"

        let favoriteImageName = isFavorite ? "star.fill" : "star"
        favoriteIconView.image = UIImage(systemName: favoriteImageName)

        currentPosterURL = movie.posterURL
        ImageLoader.shared.loadImage(from: movie.posterURL, into: posterImageView, placeholder: nil) { [weak self] loadedURL, image in
            guard let self, self.currentPosterURL == loadedURL else { return }
            self.posterImageView.image = image
        }
    }
}


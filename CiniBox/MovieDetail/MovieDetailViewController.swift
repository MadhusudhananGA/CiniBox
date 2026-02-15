//
//  MovieDetailViewController.swift
//  CiniBox
//
//

import UIKit
import SafariServices

final class MovieDetailViewController: UIViewController, MovieDetailViewProtocol {
    var presenter: MovieDetailPresenterProtocol!

    private let movie: Movie

    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let ratingLabel = UILabel()
    private let genresLabel = UILabel()
    private let castLabel = UILabel()
    private let overviewLabel = UILabel()
    private let trailerButton = UIButton(type: .system)

    private var trailerURL: URL?

    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Details"

        setupViews()
        presenter.viewDidLoad()
    }

    private func setupViews() {
        setupScrollView()
        setupContentView()
        setupPosterImageView()
        setupTitleLabel()
        setupSubtitleLabel()
        setupRatingLabel()
        setupGenresLabel()
        setupCastLabel()
        setupOverviewLabel()
        setupTrailerButton()

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, ratingLabel, genresLabel, castLabel])
        setupHeaderStack(headerStack: headerStack)

        let overviewTitleLabel = UILabel()
        setupOverviewTitleLabel(label: overviewTitleLabel)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        contentView.addArrangedSubview(posterImageView)
        contentView.addArrangedSubview(headerStack)
        contentView.addArrangedSubview(overviewTitleLabel)
        contentView.addArrangedSubview(overviewLabel)
        contentView.addArrangedSubview(trailerButton)

        setupNavigationBar()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 12
    }

    private func setupPosterImageView() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 12
        posterImageView.backgroundColor = UIColor.secondarySystemBackground
        NSLayoutConstraint.activate([
            posterImageView.heightAnchor.constraint(equalToConstant: 260)
        ])
    }

    private func setupTitleLabel() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.numberOfLines = 0
    }

    private func setupSubtitleLabel() {
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
    }

    private func setupRatingLabel() {
        ratingLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        ratingLabel.textColor = .systemYellow
    }

    private func setupGenresLabel() {
        genresLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        genresLabel.textColor = .secondaryLabel
        genresLabel.numberOfLines = 0
    }

    private func setupCastLabel() {
        castLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        castLabel.textColor = .secondaryLabel
        castLabel.numberOfLines = 0
    }

    private func setupOverviewLabel() {
        overviewLabel.font = UIFont.preferredFont(forTextStyle: .body)
        overviewLabel.numberOfLines = 0
    }

    private func setupTrailerButton() {
        trailerButton.setTitle("Play Trailer", for: .normal)
        trailerButton.setTitle("No Trailer Available", for: .disabled)
        trailerButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        trailerButton.backgroundColor = .systemBlue
        trailerButton.setTitleColor(.white, for: .normal)
        trailerButton.setTitleColor(.systemGray, for: .disabled)
        trailerButton.layer.cornerRadius = 8
        trailerButton.addTarget(self, action: #selector(didTapTrailer), for: .touchUpInside)
    }

    private func setupHeaderStack(headerStack: UIStackView) {
        headerStack.axis = .vertical
        headerStack.spacing = 4
    }

    private func setupOverviewTitleLabel(label: UILabel) {
        label.text = "Overview"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
    }

    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "star"),
            style: .plain,
            target: self,
            action: #selector(didTapFavorite)
        )
    }

    var controller: UIViewController { self }

    func showBasicInfo(for movie: Movie) {
        ImageLoader.shared.loadImage(from: movie.backdropURL ?? movie.posterURL, into: posterImageView)

        titleLabel.text = movie.title

        if let year = movie.formattedReleaseYear {
            subtitleLabel.text = year
        } else {
            subtitleLabel.text = nil
        }

        ratingLabel.text = "★ \(movie.formattedRating)"
        overviewLabel.text = movie.overview.isEmpty ? "No overview available." : movie.overview
        genresLabel.text = "Genres: —"
        castLabel.text = "Cast: —"
        trailerButton.isEnabled = true
        trailerButton.setTitle("Loading...", for: .normal)
        trailerButton.backgroundColor = .systemGray5
        trailerURL = nil
    }

    func showDetails(subtitle: String, rating: String, genres: String, cast: String, overview: String) {
        subtitleLabel.text = subtitle
        ratingLabel.text = rating
        genresLabel.text = genres
        castLabel.text = cast
        overviewLabel.text = overview
    }

    func updateFavorite(isFavorite: Bool) {
        let imageName = isFavorite ? "star.fill" : "star"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
    }

    func showNoTrailerAlert() {
        let alert = UIAlertController(title: "No Trailer", message: "No trailer is available for this movie.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }


    @objc private func didTapFavorite() {
        presenter.didTapFavorite()
    }

    func setTrailerEnabled(_ enabled: Bool, url: URL?) {
        trailerURL = url
        
        if enabled && url != nil {
            trailerButton.isEnabled = true
            trailerButton.backgroundColor = .systemBlue
            trailerButton.setTitle("Play Trailer", for: .normal)
        } else {
            trailerButton.isEnabled = true
            trailerButton.backgroundColor = .systemGray5
            trailerButton.setTitle("No Trailer Available", for: .normal)
        }
    }

    @objc private func didTapTrailer() {
        guard let url = trailerURL else {
            presenter.didTapTrailer()
            return
        }

        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
}


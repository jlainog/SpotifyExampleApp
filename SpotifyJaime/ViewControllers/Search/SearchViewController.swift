//
//  SearchViewController.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AlertOnboarding

class SearchViewController: UIViewController {
    private let albumCellHeight : CGFloat = 200.0
    private let headerHeight : CGFloat = 60.0
    private let isNOTFreshInstallKey = "isFreshInstallKey"
    fileprivate let controller = SearchController(service: SearchWebService())
    fileprivate var searchBarController: SearchBarController!
    fileprivate var activityIndicatorView: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60),
                                                                                             type: .lineScalePulseOut,
                                                                                             color: UIColor.green)
    @IBOutlet weak var collectionView : UICollectionView!

    override func viewDidLoad() {
        searchBarController = SearchBarController(self, placeHolder: "Search Artist")
        searchBarController.onDidClickSearchButton = { [weak self] in
            self?.showActivityIndicator()
            self?.controller.search(byQuery: $0)
        }
        controller.delegate = self
        collectionView.register(UICollectionReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        showTutorial()
    }
    
}

extension SearchViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return controller.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller.sections[section].count()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = controller.sections[indexPath.section]
        
        switch section {
        case .topArtist(let artist, let vm):
            return cellForArtist(indexPath, artist: artist, imageViewModel: vm)
        case .artist(let artists, let imageVieModels):
            let artist = artists[indexPath.item]
            let vm = imageVieModels[indexPath.item]
            
            return cellForArtist(indexPath, artist: artist, imageViewModel: vm)
        case .albums(let albums, let imageVieModels):
            let album = albums[indexPath.item]
            let vm = imageVieModels[indexPath.item]
            
            return cellForAlbum(indexPath, album: album, imageViewModel: vm)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        let section = controller.sections[indexPath.section]
        let button = UIButton(frame: view.frame)
        
        button.backgroundColor = .clear
        button.isEnabled = false
        
        switch section {
        case .topArtist(_, _):
            button.setTitle("Top Artist", for: .normal)
        case .artist(_, _):
            button.setTitle("Artists >", for: .normal)
            button.isEnabled = true
            button.addTarget(self, action: #selector(presentArtists), for: .touchUpInside)
        case .albums(_, _):
            button.setTitle("Albums", for: .normal)
        }
        
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(button)
        button.addConstraintsToFillSuperView()
        view.backgroundColor = UIColor.darkGray
        return view
    }
    
    func cellForArtist(_ indexPath: IndexPath,
                       artist: Artist,
                       imageViewModel: ImageViewModel) -> ArtistCollectionViewCell {
        let identifier = String(describing: ArtistCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ArtistCollectionViewCell
        
        imageViewModel.loadImageIn(imageView: cell.imageView)
        cell.configure(artist)
        return cell
    }
    
    func cellForAlbum(_ indexPath: IndexPath,
                      album: Album,
                      imageViewModel: ImageViewModel) -> AlbumCollectionViewCell  {
        let identifier = String(describing: AlbumCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! AlbumCollectionViewCell
        let albumViewModel = AlbumViewModel(album: album)
        
        cell.name.text = albumViewModel.name
        cell.availability.text = albumViewModel.availableMarkets
        imageViewModel.loadImageIn(imageView: cell.imageView, roundImage: false)
        return cell
    }
}

extension SearchViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = controller.sections[indexPath.section]
        
        switch section {
        case .topArtist(let artist, _):
            presentAlbums(artist)
        case .artist(let artists, _):
            let artist = artists[indexPath.item]
            presentAlbums(artist)
        case .albums(let albums, _):
            let album = albums[indexPath.item]
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: AlbumDetailViewController.self)) as! AlbumDetailViewController
            
            viewController.set(artist: nil, album: album)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension SearchViewController: SearchControllerDelegate {
    private func checkForUnSatisfiedSearch() {
        if controller.sections.count == 0 {
            let message = "Your Search : \"" + controller.query + "\" has no results"
            let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    private func resetCollectionIfNeeded() {
        collectionView.contentOffset = CGPoint.zero
    }
    
    func didLoadResults() {
        if controller.retrevingResults == true { return }
        
        resetCollectionIfNeeded()
        checkForUnSatisfiedSearch()
        collectionView.reloadData()
        hideActivityIndicator()
    }
    
    func didFail() {
        if controller.retrevingResults == true { return }
        
        hideActivityIndicator()
        
        guard let message = controller.errorMessage else { return }
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var size = view.bounds.size
        
        size.height = headerHeight
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = (collectionViewLayout as! UICollectionViewFlowLayout)
        let minimumLineSpacing = flowLayout.minimumLineSpacing
        let sectionInsets = flowLayout.sectionInset
        let offset = (minimumLineSpacing + sectionInsets.left + sectionInsets.right)
        var size = flowLayout.itemSize
        let section = controller.sections[indexPath.section]
        
        switch section {
        case .topArtist(_, _): return size
        case .artist(_, _): return size
        case .albums(_, _): break
        }
        
        size.height = albumCellHeight
        size.width = (collectionView.bounds.width - offset) / 2
        return size
    }
}

extension SearchViewController : AlertOnboardingDelegate {
    func alertOnboardingNext(_ nextStep: Int) { }
    
    func alertOnboardingSkipped(_ currentStep: Int, maxStep: Int) {
        UserDefaults.standard.set(true, forKey: isNOTFreshInstallKey)
    }
    
    func alertOnboardingCompleted() {
        UserDefaults.standard.set(true, forKey: isNOTFreshInstallKey)
    }
    
    func showTutorial() {
        let isNotFreshInstall = UserDefaults.standard.bool(forKey: isNOTFreshInstallKey)
        
        if isNotFreshInstall { return }
        
        let arrayOfImage = ["tutorial1", "tutorial2"]
        let arrayOfTitle = ["Hello", "Example"]
        let arrayOfDescription = ["Welcome this is an Example App",
                                  "This App use Spotify API to search for Artist"]
        let alertView = AlertOnboarding(arrayOfImage: arrayOfImage,
                                        arrayOfTitle: arrayOfTitle,
                                        arrayOfDescription: arrayOfDescription)
        
        alertView.delegate = self
        alertView.show()
    }
}

private extension SearchViewController {
    @objc func presentArtists() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchArtistViewController.self)) as! SearchArtistViewController
        
        viewController.setQuery(controller.query)
        navigationController?.pushViewController(viewController, animated: true)
    }
    func presentAlbums(_ artist: Artist) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArtistsAlbumsViewController.self)) as! ArtistsAlbumsViewController
        
        viewController.setArtist(artist)
        navigationController?.pushViewController(viewController, animated: true)
    }
    func showActivityIndicator() {
        activityIndicatorView.center = view.center
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        collectionView.isHidden = true
    }
    func hideActivityIndicator() {
        collectionView.isHidden = false
        activityIndicatorView.stopAnimating()
    }
}

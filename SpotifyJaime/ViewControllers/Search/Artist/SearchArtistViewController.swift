//
//  SearchArtistViewController.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/16/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AlertOnboarding

final class SearchArtistViewController: UIViewController {
    fileprivate let controller = SearchArtistController(service: ServiceFactory.artistService())
    fileprivate var searchBarController: SearchBarController!
    fileprivate var endlessScrollHandler: EndlessScrollHandler!
    fileprivate var activityIndicatorView: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60),
                                                                                             type: .lineScalePulseOut,
                                                                                             color: UIColor.green)
    @IBOutlet weak var collectionView : UICollectionView!
    
    func setQuery(_ query: String) {
        controller.search(byQuery: query)
    }
    
    override func viewDidLoad() {
        searchBarController = SearchBarController(self, placeHolder: "Search Artist")
        searchBarController.onDidClickSearchButton = {
            self.showActivityIndicator()
            self.controller.search(byQuery: $0)
        }
        controller.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !controller.query.isEmpty {
            searchBarController.searchBar.isHidden = true
        }
        
        super.viewWillAppear(animated)
        endlessScrollHandler = EndlessScrollHandler(refreshLoaderHeight: collectionView.bounds.size.height * 1.5)
        endlessScrollHandler.scrollViewDidReachEnd = {
            self.controller.fetchNextPage()
        }
        endlessScrollHandler.scrollViewIsReachingEnd = {
            self.controller.fetchNextPage()
        }
    }
}

extension SearchArtistViewController: SearchArtistControllerDelegate {
    
    private func checkForUnSatisfiedSearch() {
        if controller.initialPage + 1 == controller.page,
            controller.artists.count == 0 {
            let message = "Your Search : \"" + controller.query + "\" has no results"
            let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    private func resetCollectionIfNeeded() {
        if controller.initialPage + 1 == controller.page {
            collectionView.contentOffset = CGPoint.zero
            endlessScrollHandler.resetScroll()
        }
    }
    
    func didLoadArtists() {
        resetCollectionIfNeeded()
        checkForUnSatisfiedSearch()
        collectionView.reloadData()
        hideActivityIndicator()
    }
    
    func didFail() {
        hideActivityIndicator()
        
        guard let message = controller.errorMessage else { return }
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
}

extension SearchArtistViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        endlessScrollHandler.scrollViewDidScroll(scrollView)
    }
}

extension SearchArtistViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller.artists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let artist = controller.artists[indexPath.item]
        let imageViewModel = controller.artistImages[indexPath.item]
        let identifier = String(describing: ArtistCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ArtistCollectionViewCell
        
        imageViewModel.loadImageIn(imageView: cell.imageView)
        cell.configure(artist)
        return cell
    }
}

extension SearchArtistViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let artist = controller.artists[indexPath.item]
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArtistsAlbumsViewController.self)) as! ArtistsAlbumsViewController
        
        viewController.setArtist(artist)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

private extension SearchArtistViewController {
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

//
//  ArtistsAlbumsViewController.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/18/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ArtistsAlbumsViewController: UIViewController {
    fileprivate let controller = ArtistAlbumsController(service: ServiceFactory.artistAlbumsService())
    fileprivate var endlessScrollHandler: EndlessScrollHandler!
    fileprivate var activityIndicatorView: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 60, height: 60),
                                                                                             type: .lineScalePulseOut,
                                                                                             color: UIColor.green)
    @IBOutlet weak var collectionView : UICollectionView!
    
    func setArtist(_ artist: Artist) {
        controller.fetchAlbums(byArtists: artist)
        showActivityIndicator()
    }
    
    override func viewDidLoad() {
        controller.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
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

extension ArtistsAlbumsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = (collectionViewLayout as! UICollectionViewFlowLayout)
        let minimumLineSpacing = flowLayout.minimumLineSpacing
        let sectionInsets = flowLayout.sectionInset
        let offset = (minimumLineSpacing + sectionInsets.left + sectionInsets.right)
        var size = flowLayout.itemSize
        let aspectRatio = size.height / size.width
        
        size.width = (collectionView.bounds.width - offset) / 2
        size.height = aspectRatio * size.width
        return size
    }
}

extension ArtistsAlbumsViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let album = controller.albums[indexPath.item]
        let imageViewModel = controller.albumsImages[indexPath.item]
        let identifier = String(describing: AlbumCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! AlbumCollectionViewCell
        let albumViewModel = AlbumViewModel(album: album)
        
        cell.name.text = albumViewModel.name
        cell.availability.text = albumViewModel.availableMarkets
        imageViewModel.loadImageIn(imageView: cell.imageView, roundImage: false)
        return cell
    }
}

extension ArtistsAlbumsViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let album = controller.albums[indexPath.item]
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: AlbumDetailViewController.self)) as! AlbumDetailViewController

        viewController.set(artist: controller.artist, album: album)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ArtistsAlbumsViewController: ArtistAlbumsControllerDelegate {
    
    private func checkForUnSatisfiedSearch() {
        if controller.initialPage + 1 == controller.page,
            controller.albums.count == 0 {
            let message = "Your Search : \"" + controller.artist.name + "\" has no results"
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
    
    func didLoadAlbums() {
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

extension ArtistsAlbumsViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        endlessScrollHandler.scrollViewDidScroll(scrollView)
    }
}

private extension ArtistsAlbumsViewController {
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

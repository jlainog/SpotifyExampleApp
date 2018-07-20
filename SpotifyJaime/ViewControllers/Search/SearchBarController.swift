//
//  SearchController.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/16/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit

class SearchBarController : NSObject, UISearchBarDelegate {
    let searchController = CustomUISearchController(searchResultsController: nil)
    var searchBar : UISearchBar { return searchController.searchBar }
    var onDidClickSearchButton : ((String) -> Void)? = nil
    var onTextDidChange : ((String) -> Void)? = nil
    private weak var root : UIViewController?
    
    init(_ root: UIViewController, placeHolder: String) {
        self.root = root
        super.init()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.delegate = self
        root.navigationItem.titleView = searchController.searchBar
        applyStyle(placeHolder: placeHolder)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        root?.definesPresentationContext = true
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        func removeSpecialCharsFromString(_ str: String) -> String {
            struct Constants {
                static let validChars = Set("\"\\“\\’\\‘\\`\\”\\“\\„»«\'")
            }
            return String(str.filter { !Constants.validChars.contains($0) })
        }
        
        let cleanText = removeSpecialCharsFromString(searchText).lowercased()
        
        searchBar.text = cleanText.replacingOccurrences(of: "null", with: "")
        
        guard let searchTerm = searchBar.text?.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
            !searchTerm.isEmpty else {
                return
        }
        onTextDidChange?(searchTerm)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text?.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
            !searchTerm.isEmpty else {
                searchController.isActive = false
                return
        }
        
        searchController.dismiss(animated: true, completion: {
            self.searchController.isActive = false
            self.searchController.searchBar.text = searchTerm
        })
        onDidClickSearchButton?(searchTerm)
    }
    
    private func applyStyle(placeHolder: String) {
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = UIColor.clear
        searchBar.placeholder = placeHolder
    }
}

class CustomUISearchController: UISearchController {
    let customSearchBar = CustomUISearchBar()
    override var searchBar: UISearchBar { return customSearchBar }
}

class CustomUISearchBar: UISearchBar {
    override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) { /* void */ }
}

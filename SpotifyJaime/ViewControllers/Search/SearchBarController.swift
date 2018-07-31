//
//  SearchController.swift
//  SpotifyJaime
//
//  Created by Jaime Andres Laino Guerra on 7/16/18.
//  Copyright © 2018 Jaime Andres Laino Guerra. All rights reserved.
//

import UIKit

class Throttler {
    private let queue: DispatchQueue = DispatchQueue.global(qos: .background)
    private var workItem : DispatchWorkItem = DispatchWorkItem(block: {})
    private var lastRun : Date = Date.distantPast
    private var interval : TimeInterval = 4
    
    init(seconds: Int) {
        self.interval = TimeInterval(seconds)
    }
    
    func cancel() {
        workItem.cancel()
    }
    
    func thottle(block: @escaping () -> Void) {
        workItem.cancel()
        workItem = DispatchWorkItem(block: { [weak self] in
            self?.lastRun = Date()
            block()
        })
        
        let delay : Double = secondsSinceLastRun() > interval ? 0 : interval
        queue.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let item = self?.workItem else { return }
            DispatchQueue.main.async(execute: item)
        }
    }
    
    private func secondsSinceLastRun() -> Double {
        let now = Date()
        
        return now.timeIntervalSince(lastRun).rounded()
    }
}

class SearchBarController : NSObject, UISearchBarDelegate {
    let searchController = CustomUISearchController(searchResultsController: nil)
    var searchBar : UISearchBar { return searchController.searchBar }
    var onDidClickSearchButton : ((String) -> Void)? = nil
    var onTextDidChange : ((String) -> Void)? = nil
    var onTextDidClear : (() -> Void)? = nil
    private weak var root : UIViewController?
    private let throttler = Throttler(seconds: 2)
    private let minCharactersToSearch = 2
    
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
            !searchTerm.isEmpty,
            searchTerm.count > minCharactersToSearch else {
                throttler.cancel()
                onTextDidClear?()
                return
        }
        
        throttler.thottle { [weak self] in
            self?.onTextDidChange?(searchTerm)
        }
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

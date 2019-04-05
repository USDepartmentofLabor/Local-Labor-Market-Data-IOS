//
//  SearchItemViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 2/25/19.
//  Copyright © 2019 Department of Labor. All rights reserved.
//

import UIKit

class SearchItemViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var searchController = UISearchController(searchResultsController: nil)

    var viewModel: SearchItemViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        title = "Search"
        
        setupSearch()
        extendedLayoutIncludesOpaqueBars = true
    }
    
    func setupSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.autocapitalizationType = .none
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.showsCancelButton = false
        searchController.delegate = self
        
        definesPresentationContext = true
        searchController.searchBar.tintColor = .white
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor(hex: 0x979797)
            textfield.tintColor = UIColor(hex: 0x979797)
            if let backgroundview = textfield.subviews.first {

                backgroundview.backgroundColor = UIColor.white
                // Rounded corner
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItemDetail",
            let vc = segue.destination as? ItemViewController {
            if let selectedIndexPath = tableView.indexPathForSelectedRow,
                let selectedItem = viewModel.searchResults?[selectedIndexPath.row] {
                vc.viewModel = viewModel.itemViewModel.createInstance(forParent: selectedItem)
                vc.title = selectedItem.title
            }
        }
    }
}

extension SearchItemViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.searchResults?.removeAll()

        if searchText.count > 2 {
            let itemType = type(of: viewModel.itemViewModel.parentItem) 
            viewModel.searchResults = itemType.searchItem(context: CoreDataManager.shared().viewManagedContext, searchStr: searchText)
        }
        
        tableView.reloadData()
    }
    
}

extension SearchItemViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
}

extension SearchItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCellId") as! SearchItemTableViewCell
        
        let item = viewModel.searchResults?[indexPath.row]
        cell.itemLabel?.text = item?.titleWithParents
        
        return cell
    }
}



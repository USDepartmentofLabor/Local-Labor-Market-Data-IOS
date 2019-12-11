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
    
    @IBOutlet weak var noResultsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    
    func setupView() {
        let itemType = type(of: viewModel.itemViewModel.parentItem)
        
        let subTitle: String
        if itemType == OE_Occupation.self {
            subTitle = "Occupations"
        }
        else {
            subTitle = "Industries"
        }
        
        title = "Search \(subTitle)"

        setupSearch()
        extendedLayoutIncludesOpaqueBars = true
    }
    
    func setupSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.autocapitalizationType = .none
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = .default
        searchController.delegate = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let searchPlaceholderStr: String
        let itemType = type(of: viewModel.itemViewModel.parentItem)
        if itemType == OE_Occupation.self {
            searchPlaceholderStr = "Type occupation"
        }
        else {
            searchPlaceholderStr = "Type Industries"
        }
        
        searchController.searchBar.placeholder = searchPlaceholderStr
        
        navigationController?.definesPresentationContext = true
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.backgroundColor = .systemBackground
        } else {
            searchController.searchBar.searchTextField.backgroundColor = .white
        }
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.textColor = .label
        }
        else {
            searchController.searchBar.searchTextField.textColor = UIColor(hex: 0x979797)
        }
//        searchController.searchBar.tintColor = .white
        searchController.searchBar.delegate = self
//        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
//            textfield.textColor = UIColor(hex: 0x979797)
//            textfield.tintColor = UIColor(hex: 0x979797)
//            if let backgroundview = textfield.subviews.first {
//
//                backgroundview.backgroundColor = UIColor.white
//                // Rounded corner
//                backgroundview.layer.cornerRadius = 10;
//                backgroundview.clipsToBounds = true;
//            }
//        }
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
            
            noResultsView.isHidden = viewModel.hasSearchResults
        }
        else {
            noResultsView.isHidden = true
        }
        
        tableView.reloadData()
    }
}

extension SearchItemViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
//        searchController.searchBar.showsCancelButton = false
    }
}

extension SearchItemViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let announcementStr = "Found \(viewModel.searchResults?.count ?? 0) results"
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementStr)
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

extension SearchItemViewController: UITableViewDelegate {
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        searchController.searchBar.resignFirstResponder()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(actionKeyboardDidShow(with:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(actionKeyboardWillHide(with:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        searchController.searchBar.resignFirstResponder()
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func actionKeyboardDidShow(with notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: AnyObject],
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
            else { return }
        
        var contentInset = self.tableView.contentInset
        contentInset.bottom += keyboardFrame.height
        
        self.tableView.contentInset = contentInset
        self.tableView.scrollIndicatorInsets = contentInset
    }
    
    @objc private func actionKeyboardWillHide(with notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        self.tableView.contentInset = contentInset
        self.tableView.scrollIndicatorInsets = contentInset
    }

}



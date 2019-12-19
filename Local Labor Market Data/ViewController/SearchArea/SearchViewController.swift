//
//  SearchViewController.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/20/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var areaSegment: UISegmentedControl!
    
    @IBOutlet weak var historyContainerView: UIView!
    @IBOutlet weak var searchContainerHeightConstraint: NSLayoutConstraint!
    
    let currentLocationTitle = "Current Location"
    let nationalTitle = "National"
    
    var currentZip: String?
    
    var scope:[(title: String, type: AreaType)] =
            [("Metro Area", .metro),
             ("State", .state),
             ("County", .county)]
    
    lazy var locationManager = CLLocationManager()
    var locationStatus: CLAuthorizationStatus = .notDetermined {
        didSet {
            tableView.reloadData()
        }
    }
    
    let dataUtil = DataUtil(managedContext: CoreDataManager.shared().viewManagedContext)

    // Area Section is last section
    var areaSection: Int {
        get {
            return numberOfSections(in: tableView) - 1
        }
    }
    // National Section is Above area Section
    // Only when Search is not active
    var nationalSection: Int {
        get {

            return displayNational ? areaSection - 1 : -1
        }
    }
    
    var displayNational: Bool {
        get {
            return searchController.isActive ? false : true
        }
    }

    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var currentLocationHeightConstraint: NSLayoutConstraint!
    
    var sections : [(rowIndex: Int, title: String)] = Array()
    var areas:[Area]? {
        didSet {
            sections.removeAll()
            guard let areas = areas else {return}
            var prevPrefix = ""
            for (index, area) in (areas.enumerated()) {
                let title = area.title ?? ""
                let nextPrefix = String(title[title.startIndex])
                
                if nextPrefix != prevPrefix {
                    let newSection = (rowIndex: index, title: nextPrefix)
                    sections.append(newSection)
                    prevPrefix = nextPrefix
                }
            }
            
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let titleStr = "\(Bundle.main.appName)"
        self.title = titleStr
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
//        historyContainerView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        title = Bundle.main.appName
        
        let infoItem = UIBarButtonItem.infoButton(target: self, action: #selector(infoClicked(sender:)))
        navigationItem.rightBarButtonItem = infoItem
        
        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible
        
        tableView.register(UINib(nibName: SearchSectionTableHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: SearchSectionTableHeaderView.reuseIdentifier)
        tableView.sectionHeaderHeight = UITableView.automaticDimension;
        tableView.estimatedSectionHeaderHeight = 50
        tableView.sectionIndexColor = UIColor(named: "AppBlue")
        areaSegment.setios12Style()
        
        checkCurrentLocation()
        areas = dataUtil.searchArea(forArea: .metro)
        
        searchController.searchBar.placeholder = "Zip, Metro Area, State, County"
//        searchController.searchBar.scopeButtonTitles = scope.map {$0.title}
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.searchBarStyle = .default
        navigationItem.hidesSearchBarWhenScrolling = false
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.backgroundColor = .systemBackground
            searchController.searchBar.searchTextField.textColor = .placeholderText
        }
        else if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor(hex: 0x979797)
            textfield.tintColor = UIColor(hex: 0x979797)
            if let backgroundview = textfield.subviews.first {

                backgroundview.backgroundColor = UIColor.white
                // Rounded corner
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
        
        navigationItem.searchController = searchController
        setupAccessibility()
    }
    
    func setupAccessibility() {
        tableView.isAccessibilityElement = false
        let font = Style.scaledFont(forDataType: .searchAreaSegment, for: traitCollection)
        areaSegment.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
    }
    
    func checkCurrentLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let area = sender as? Area, let navVC = segue.destination as? UINavigationController,
            let areaVC =  navVC.topViewController as? AreaViewController {
            areaVC.area = area
        }
        
        if let splitVC = splitViewController,
            let navVC = segue.destination as? UINavigationController,
                let detailVC = navVC.topViewController {
            detailVC.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem
//            if detailVC is AboutViewController {
                detailVC.navigationItem.leftItemsSupplementBackButton = true
            splitVC.preferredDisplayMode = .primaryHidden
//            }
        }
    }
}

// MARK: Actions
extension SearchViewController {
    @IBAction func areaSegmentChanged(_ sender: Any) {
        guard let segmentControl = sender as? UISegmentedControl else { return }
        
        let areaType = scope[segmentControl.selectedSegmentIndex].type
        
        var searchText = searchController.searchBar.text
        if searchText == currentLocationTitle {
            searchText = currentZip
        }
        updateFilteredContent(type: areaType, searchText: searchText, withUserAction: true)
    }

    @objc fileprivate func infoClicked(sender: Any?) {
        performSegue(withIdentifier: "showInfo", sender: self)
        searchController.isActive = false
    }
    
    func displayNationalReports() {
        performSegue(withIdentifier: "showMetroArea", sender: dataUtil.nationalArea())
//        let vc = MetroStateViewController.instantiateFromStoryboard()
//        vc.area = dataUtil.nationalArea()
//        if let splitVC = splitViewController {
//            let navController = UINavigationController(rootViewController: vc)
//            splitVC.showDetailViewController(navController, sender: nil)
//        }
//        else {
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
}


// MARK: TableView DataSource
extension SearchViewController: UITableViewDataSource {
    // 1 section if location is disabled
    // 2 sections if location is Enabled
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections = 1
        
        // Check if need to display Current Location
        if locationStatus == .authorizedWhenInUse {
            if searchController.searchBar.text != currentLocationTitle {
                numOfSections += 1
            }
        }
        
        // Check if need to display National
        if displayNational {
            numOfSections += 1
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numRows: Int
        // If section is the last section, then return
        if section == areaSection {
            numRows = areas?.count ?? 0
        }
        else {
            numRows = 0
        }
        
        return numRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if let c = tableView.dequeueReusableCell(withIdentifier: "cellID") {
            cell = c
        }
        else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        }
        if let area = areas?[indexPath.row] {
            cell.indentationLevel = 4
            cell.textLabel?.scaleFont(forDataType: .areaNameList, for: traitCollection)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = area.title
            cell.accessibilityLabel = area.accessibilityStr
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    func titleForHeaderInSection(section: Int) -> String? {

        let sectionTitle: String
        if section == areaSection {
//            let scopeIndex = searchController.searchBar.selectedScopeButtonIndex
            let scopeIndex = areaSegment.selectedSegmentIndex
            sectionTitle = scope[scopeIndex].title
        }
        else if section == nationalSection {
            sectionTitle = nationalTitle
        }
        else {
            sectionTitle = currentLocationTitle
        }

        return sectionTitle
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map{ $0.title }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        let rowIndex = sections[index].rowIndex
        tableView.scrollToRow(at: IndexPath(row: rowIndex, section: areaSection), at: .top, animated: true)
        return -1
    }
}

// MARK: TableView Delegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let area = areas?[indexPath.row] else {return}
        
        if let title = area.title {
            SearchHistoryManager.shared().add(searchText: title)
        }
        let segueIdentifier: String?
//        tableView.deselectRow(at: indexPath, animated: false)
        if area is Metro {
            segueIdentifier = "showMetroArea"
        }
        else if area is State {
            segueIdentifier = "showStateArea"
        }
        else if area is County {
            segueIdentifier = "showCountyArea"
        }
        else {
            segueIdentifier = nil
        }
        
        if let segueId = segueIdentifier {
            performSegue(withIdentifier: segueId, sender: area)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchSectionTableHeaderView.reuseIdentifier) as? SearchSectionTableHeaderView
                else { return nil }
        
        let sectionTitle = titleForHeaderInSection(section: section)
        sectionHeaderView.titleLabel.text = sectionTitle
        if sectionTitle == currentLocationTitle {
            sectionHeaderView.imageView.image = #imageLiteral(resourceName: "place")
            sectionHeaderView.isAccessibilityElement = true
            sectionHeaderView.accessibilityTraits = UIAccessibilityTraits.button
        }
        else if sectionTitle == nationalTitle {
            sectionHeaderView.imageView.image = #imageLiteral(resourceName: "flag")
            sectionHeaderView.isAccessibilityElement = true
            sectionHeaderView.accessibilityTraits = UIAccessibilityTraits.button
        }
        else {
            sectionHeaderView.imageView.image = #imageLiteral(resourceName: "globe")
            sectionHeaderView.isAccessibilityElement = true
            sectionHeaderView.accessibilityTraits = UIAccessibilityTraits.header
        }
//        sectionHeaderView.accessibilityTraits = UIAccessibilityTraits.header
        sectionHeaderView.accessibilityLabel = sectionTitle
        sectionHeaderView.section = section
        sectionHeaderView.delegate = self
        return sectionHeaderView
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}

// MARK: SectionHeaderView Delegate
extension SearchViewController: SearchSectionHeaderDelegate {
    func sectionHeader(_ sectionHeader: SearchSectionTableHeaderView, didSelectSection section: Int) {
        if section == areaSection {
            return
        }
        else if section == nationalSection {
            displayNationalReports()
        }
        else {
            getCurrentLocation()
            searchController.searchBar.text = currentLocationTitle
            searchController.isActive = true
        }
    }
}

// MARK: SearchController Delegate
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText == currentLocationTitle {
            getCurrentLocation()
            return
        }
        
//        let scopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
        let scopeButtonIndex = areaSegment.selectedSegmentIndex
        updateFilteredContent(type:scope[scopeButtonIndex].type, searchText: searchText)
    }
    
    func updateFilteredContent(type: AreaType, searchText: String?, withUserAction userAction: Bool = false) {

        areas = dataUtil.searchArea(forArea: type, forText: searchText)
        
        UIAccessibility.post(notification: .screenChanged, argument: areaSegment)
        // If search results returned 0 for Metro
        if (areas == nil || areas!.count == 0) &&
            !userAction && type == .metro {
            
            // if County return any results, then go to County
            if let counties = dataUtil.searchArea(forArea: .county, forText: searchText), counties.count > 0 {
                areaSegment.selectedSegmentIndex = scope.endIndex-1
//                searchController.searchBar.selectedScopeButtonIndex = scope.endIndex-1
                updateFilteredContent(type:scope[scope.endIndex-1].type, searchText: searchText)
            }
        }
    }
}

// MARK SearchBar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let areaType = scope[selectedScope].type
        
        var searchText = searchBar.text
        if searchText == currentLocationTitle {
           searchText = currentZip
        }
        updateFilteredContent(type: areaType, searchText: searchText, withUserAction: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if areaSegment.selectedSegmentIndex != scope.startIndex {
            areaSegment.selectedSegmentIndex = scope.startIndex
        }
//        if searchController.searchBar.selectedScopeButtonIndex != scope.startIndex {
//            searchController.searchBar.selectedScopeButtonIndex = scope.startIndex
//        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let announcementStr = "Found \(areas?.count ?? 0) results"
        UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: announcementStr)
//        historyContainerView.isHidden = true
        UIAccessibility.post(notification: .screenChanged, argument: areaSegment)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        historyContainerView.isHidden = false
    }
}


extension SearchViewController {
    func getCurrentLocation() {
        currentZip = nil
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
}

// MARK: LocationManager Delegate
extension SearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {return}
        
        CLGeocoder().reverseGeocodeLocation(location,
                                            completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks?[0]
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
        
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
    }

    func displayLocationInfo(_ placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
//            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
//            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
//            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
//
//            print(postalCode)
            
            if let zipCode = postalCode {
                currentZip = zipCode
                let scopeButtonIndex = areaSegment.selectedSegmentIndex
//                let scopeButtonIndex = searchController.searchBar.selectedScopeButtonIndex
                updateFilteredContent(type:scope[scopeButtonIndex].type, searchText: zipCode)
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
    
}

extension SearchViewController: UISplitViewControllerDelegate {
    func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewController.DisplayMode {
        
        if svc.displayMode == UISplitViewController.DisplayMode.primaryOverlay ||
            svc.displayMode == UISplitViewController.DisplayMode.primaryHidden {
//            return UISplitViewController.DisplayMode.allVisible
            return UISplitViewController.DisplayMode.primaryOverlay
        }
        
        return UISplitViewController.DisplayMode.primaryHidden
    }
}

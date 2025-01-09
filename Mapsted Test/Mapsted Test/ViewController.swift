//
//  ViewController.swift
//  Mapsted Test
//
//  Created by Shree Ram on 07/01/25.
//

import UIKit
import Toast

class ViewController: UIViewController {

    @IBOutlet var viewBackSelectionColl: [UIView]!
    @IBOutlet weak var lblManufacturer: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblItem: UILabel!
    @IBOutlet weak var lblBuilding: UILabel!
    
    @IBOutlet weak var lblManufacturerCost: UILabel!
    @IBOutlet weak var lblCategoryCost: UILabel!
    @IBOutlet weak var lblCountryCost: UILabel!
    @IBOutlet weak var lblStateCost: UILabel!
    @IBOutlet weak var lblTotalItems: UILabel!
    
    var buildingData: [Building]!
    var analyticsData: [String: [Analytic]]!
    
    var activityIndicatorAlert: UIAlertController?
    
    var filteredCategoryIds: [String]!
    var filteredItemIds: [String]!
    var filteredCountires: [String]!
    var filteredStates: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for viewBack in viewBackSelectionColl {
            viewBack.layer.cornerRadius = 4
            viewBack.clipsToBounds = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLoadingAlert(title: "Loading")
        fetchBuildingData()
        fetchAnalyticData()
    }
    
    //select menu button actions
    @IBAction func itemSelectionActionPerformed(_ sender: UIButton) {
        if analyticsData == nil {
            let alertController = UIAlertController(title: "Error", message: "No data found for calculating cost. Please try to Refresh data!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Refresh", style: .default) { action in
                DispatchQueue.main.async {
                    self.showLoadingAlert(title: "Loading")
                }
                self.fetchBuildingData()
                self.fetchAnalyticData()
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        if sender.tag > 0 && lblManufacturer.text == "Manufacturer" {
            self.view.makeToast("Please select manufacturer first", duration: 3.0, position: .bottom)
            return
        }
        
        switch sender.tag {
            case 0:
            openPickerForManufecturerSelection()
            case 1:
            openPickerForItemCategorySelection()
            case 2:
            openPickerForCountrySelection()
            case 3:
            openPickerForStateSelection()
            case 4:
            openPickerForItemIdSelection()
        default:
            break
        }
    }
    
    func openPickerForManufecturerSelection() {
        let picker = BottomSheetPickerVC(data: Array(analyticsData.keys)) {selectedValue in
            DispatchQueue.main.async {
                self.lblManufacturer.text = selectedValue
                self.filterWholeDataAccordingToManufacturer(manufacturer: selectedValue)
            }
        }
        picker.modalPresentationStyle = .pageSheet
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(picker, animated: true, completion: nil)
    }
    
    func openPickerForItemCategorySelection() {
        
        if filteredCategoryIds == nil {
            self.view.makeToast("There is no ids for cost calculations", duration: 3.0, position: .bottom)
            return
        }
        
        let picker = BottomSheetPickerVC(data: filteredCategoryIds) {selectedValue in
            DispatchQueue.main.async {
                self.lblCategory.text = selectedValue
                self.totalItemCategoryCost(itemCategoryID: selectedValue)
            }
        }
        picker.modalPresentationStyle = .pageSheet
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(picker, animated: true, completion: nil)
    }
    
    func openPickerForCountrySelection() {
        if filteredCountires == nil {
            self.view.makeToast("There is no countries for cost calculations", duration: 3.0, position: .bottom)
            return
        }
        let picker = BottomSheetPickerVC(data: filteredCountires) {selectedValue in
            DispatchQueue.main.async {
                self.lblCountry.text = selectedValue
                self.totalCostAccordingToCountry(country: selectedValue)
            }
        }
        picker.modalPresentationStyle = .pageSheet
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(picker, animated: true, completion: nil)
    }
    
    func openPickerForStateSelection() {
        if filteredStates == nil {
            self.view.makeToast("There is no states for cost calculations", duration: 3.0, position: .bottom)
            return
        }
        let picker = BottomSheetPickerVC(data: filteredStates) {selectedValue in
            DispatchQueue.main.async {
                self.lblState.text = selectedValue
                self.totalCostAccordingToState(state: selectedValue)
            }
        }
        picker.modalPresentationStyle = .pageSheet
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(picker, animated: true, completion: nil)
    }
    
    func openPickerForItemIdSelection() {
        
        if filteredItemIds == nil {
            self.view.makeToast("There is no item ids for calculations", duration: 3.0, position: .bottom)
            return
        }
        
        let picker = BottomSheetPickerVC(data: filteredItemIds) {selectedValue in
            DispatchQueue.main.async {
                self.lblItem.text = selectedValue
                self.totalCountOfItemId(itemId: selectedValue)
            }
        }
        picker.modalPresentationStyle = .pageSheet
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(picker, animated: true, completion: nil)
    }
    
    func filterWholeDataAccordingToManufacturer(manufacturer: String) {
        
        let filterManufacturerAnalytics = analyticsData[manufacturer] ?? []
        var totalCost = 0.0
        var itemCategoryIDs = Set<String>()
        var itemIDs = Set<String>()
        var countries = Set<String>()
        var states = Set<String>()
        
        var buildingPurchaseTotals: [Int: Double] = [:]
        
        for analytic in filterManufacturerAnalytics {
            for sessionInfo in analytic.usageStatistics.sessionInfos {
                
                let totalCostForSession = sessionInfo.purchases.reduce(0) { $0 + $1.cost }
                // total cost
                totalCost += totalCostForSession
                buildingPurchaseTotals[sessionInfo.buildingID, default: 0] += totalCostForSession
                
                // unique itemCategoryIDs and itemIDs
                sessionInfo.purchases.forEach { purchase in
                    itemCategoryIDs.insert("\(purchase.itemCategoryID)")
                    itemIDs.insert("\(purchase.itemID)")
                }
                
                // Find the building for the current buildingID
                if let building = buildingData.first(where: { $0.buildingID == sessionInfo.buildingID }) {
                    countries.insert(building.country)
                    states.insert(building.state)
                }
            }
        }
        
        // find the building name from the buildingData
        if let highestBuildingID = buildingPurchaseTotals.max(by: { $0.value < $1.value })?.key {
            lblBuilding.text = buildingData.first(where: { $0.buildingID == highestBuildingID })?.buildingName
        }else {
            lblBuilding.text = "Building Name"
        }
        
        self.filteredStates = Array(states)
        self.filteredCountires = Array(countries)
        self.filteredItemIds = Array(itemIDs)
        self.filteredCategoryIds = Array(itemCategoryIDs)
        
        self.lblManufacturerCost.text = String(format: "$%.2f", totalCost)
        
        self.clearFields()
        
    }
    
    func totalCostAccordingToCountry(country: String) {
        let buildingIDsForCountry = buildingData
                .filter { $0.country == country }
                .map { $0.buildingID }
        let filterManufacturerAnalytics = analyticsData[lblManufacturer.text!] ?? []
        let totalCost = filterManufacturerAnalytics.flatMap { analytic in
                analytic.usageStatistics.sessionInfos.filter { sessionInfo in
                    buildingIDsForCountry.contains(sessionInfo.buildingID)
                }.flatMap { sessionInfo in
                    sessionInfo.purchases.map { $0.cost }
                }
            }.reduce(0, +)
        lblCountryCost.text = String(format: "$%.2f", totalCost)
    }
    
    func totalCostAccordingToState(state: String) {
        let buildingIDsForCountry = buildingData
            .filter { $0.state == state }
                .map { $0.buildingID }
        let filterManufacturerAnalytics = analyticsData[lblManufacturer.text!] ?? []
        let totalCost = filterManufacturerAnalytics.flatMap { analytic in
                analytic.usageStatistics.sessionInfos.filter { sessionInfo in
                    buildingIDsForCountry.contains(sessionInfo.buildingID)
                }.flatMap { sessionInfo in
                    sessionInfo.purchases.map { $0.cost }
                }
            }.reduce(0, +)
        lblStateCost.text = String(format: "$%.2f", totalCost)
    }
    
    func totalCountOfItemId(itemId: String) {
        let filterManufacturerAnalytics = analyticsData[lblManufacturer.text!] ?? []
        let totalItems = filterManufacturerAnalytics.flatMap { analytic in
                analytic.usageStatistics.sessionInfos.flatMap { sessionInfo in
                    sessionInfo.purchases.filter { $0.itemID == Int(itemId)! }
                }
        }.count
        self.lblTotalItems.text = "\(totalItems)"
    }
    
    func totalItemCategoryCost(itemCategoryID: String) {
        let filterManufacturerAnalytics = analyticsData[lblManufacturer.text!] ?? []
        let totalCost = filterManufacturerAnalytics.flatMap { analytic in
                analytic.usageStatistics.sessionInfos.flatMap { sessionInfo in
                    sessionInfo.purchases.filter { $0.itemCategoryID == Int(itemCategoryID)! }
                }
            }.reduce(0) { $0 + $1.cost }
        
        self.lblCategoryCost.text = String(format: "$%.2f", totalCost)
    }
    
    //Default set
    func clearFields() {
        self.lblItem.text = "Item_id"
        self.lblState.text = "State"
        self.lblCountry.text = "Country"
        self.lblCategory.text = "Item_category_id"
        self.lblTotalItems.text = "0"
        self.lblCategoryCost.text = "$"
        self.lblCountryCost.text = "$"
        self.lblStateCost.text = "$"
    }
    
}

//MARK: Loading Alert Controller
extension ViewController {
    func showLoadingAlert(title: String?,_ message: String? = "  \n") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()

        alert.view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -20)
        ])

        self.present(alert, animated: true, completion: nil)

        activityIndicatorAlert = alert
    }

    func dismissActivityIndicatorAlert() {
        activityIndicatorAlert!.dismiss(animated: true)
        activityIndicatorAlert = nil
    }
}

//MARK: API Calling
extension ViewController {
    
    func fetchBuildingData() {
        ApiService().fetchBuildingData { result in
            switch result {
            case .success(let data):
                self.buildingData = data
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.view.makeToast(error.localizedDescription, duration: 3.0, position: .bottom)
                }
            }
        }
    }
    
    func fetchAnalyticData() {
        ApiService().fetchAnalyticData { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.analyticsData = Dictionary(grouping: data, by: { $0.manufacturer })
                    self.dismissActivityIndicatorAlert()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.dismissActivityIndicatorAlert()
                    self.view.makeToast(error.localizedDescription, duration: 3.0, position: .bottom)
                }
                print(error)
            }
        }
    }
    
}

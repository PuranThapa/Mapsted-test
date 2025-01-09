//
//  BottomSheetPickerVC.swift
//  Mapsted Test
//
//  Created by Shree Ram on 08/01/25.
//

import UIKit

class BottomSheetPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    
    private var data: [String]!
    private var callBack: ((String) -> Void)!
    
    init(data: [String],_ callBack: @escaping ((String) -> Void)) {
        super.init(nibName: nil, bundle: nil)
        self.data = data
        self.callBack = callBack
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callBack(data[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
}

//
//  HistoryTableViewController.swift
//  ZFSafari
//
//  Created by 郑峰 on 2022/12/19.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    var dataArray:Array<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "historyCellID")
        
        dataArray = UserDefaults.standard.value(forKey: "History") as! Array<String>?
        let item = UIBarButtonItem(title: "DeleteAll", style: .plain, target: self, action: #selector(deleteAll))
        self.navigationItem.rightBarButtonItem = item
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isToolbarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isToolbarHidden = false
    }
    
    // MARK: - action
    
    @objc func deleteAll() {
        UserDefaults.standard.set([], forKey: "History")
        UserDefaults.standard.synchronize()
        dataArray = []
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray!.count
    }
    
    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCellID", for: indexPath)
        cell.textLabel?.text = dataArray![indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (self.navigationController?.viewControllers.first as! ViewController).loadURL(urlString: dataArray![indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

//
//  HouseComController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/19/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
class HouseComController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet var tblJSON: UITableView!
    @IBOutlet var searchButton: UIBarButtonItem!
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var numOfRows = 0
    let searchBar = UISearchBar().self
    //search function variables
    var filteredComs = [[String:AnyObject]]()
    var shouldShowSearch = false
    
    func createSearchBar() {
        
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search Legislators"
        searchBar.delegate = self
        
        
        self.tabBarController?.navigationItem.rightBarButtonItem = searchButton
    }
    func filter() {
        if self.tabBarController?.navigationItem.rightBarButtonItem?.image == (UIImage(named: "Search-22.png")) {
            self.tabBarController?.navigationItem.titleView = searchBar
            searchButton.image = UIImage(named: "Cancel-22.png")
        } else {
            self.tabBarController?.navigationItem.titleView = nil
            self.navigationItem.title = "Legislators"
            searchButton.image = UIImage(named: "Search-22.png")
        }
    }
    @IBAction func filterComs(_ sender: Any) {
        filter()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Loading Congress Data")
        createSearchBar()
        self.tabBarController?.navigationItem.rightBarButtonItem = searchButton
        let url = "http://congressinfo-env.us-west-1.elasticbeanstalk.com/congress/congress.php?dbType=committees"
        
        
        Alamofire.request(url).responseJSON { (responseJSON) -> Void in
            if((responseJSON.result.value) != nil) {
                let swiftyJsonVar = JSON(responseJSON.result.value!)
                if let resData = swiftyJsonVar["results"].arrayObject {
                    self.arrRes = resData as! [[String:AnyObject]]
                    let res = resData as! [[String:AnyObject]]
                    self.arrRes = res.filter { $0["chamber"] as! String == "house" }
                    self.arrRes = self.arrRes.sorted { ($0["name"] as? String)! < ($1["name"] as? String)! }
                }
                if self.arrRes.count > 0 {
                    self.numOfRows = self.arrRes.count
                    self.tblJSON.reloadData()
                    SwiftSpinner.hide()
                }
            }
        }
        self.tblJSON.contentInset = UIEdgeInsetsMake(-45, 0, 0, 0);
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(shouldShowSearch) {
            return filteredComs.count
        } else {
            return self.numOfRows
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJSON.dequeueReusableCell(withIdentifier: "comCell", for: indexPath)
        var cur : [String:AnyObject]
        if(shouldShowSearch) {
            cur = self.filteredComs[indexPath.row]
        } else {
            cur = self.arrRes[indexPath.row]
        }
        cell.textLabel?.text = cur["name"] as! String?
        cell.detailTextLabel?.text = cur["committee_id"] as? String
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    public func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        filteredComs = self.arrRes.filter({(obj) -> Bool in
            let f = obj["name"] as? String
            return f!.range(of: searchString!) != nil
        })
        self.tblJSON.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            shouldShowSearch = true
            filteredComs = self.arrRes.filter({(obj) -> Bool in
                let f = obj["name"] as? String
                return f!.range(of: searchText) != nil
            })
            
        } else {
            shouldShowSearch = false
        }
        self.tblJSON.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comDetail" {
            let comDetailVC = segue.destination as! CommitteeDetailController
            if let cell = self.tblJSON.indexPathForSelectedRow {
                comDetailVC.com = self.arrRes[cell.row]
            }
            self.tabBarController?.tabBar.isHidden = true
        }
    }
}

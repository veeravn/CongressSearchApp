//
//  ActiveBillController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/18/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
class ActiveBillController: UITableViewController,UISearchBarDelegate  {

    @IBOutlet var tblJSON: UITableView!
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var numOfRows = 0
    let searchBar = UISearchBar().self
    //search function variables
    var filteredBills = [[String:AnyObject]]()
    var shouldShowSearch = false
    
    func createSearchBar() {
        
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search Legislators"
        searchBar.delegate = self
        
        
        self.navigationItem.titleView = searchBar
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        
        let url = "http://congressinfo-env.us-west-1.elasticbeanstalk.com/congress/congress.php?dbType=bills&activeStatus=true"

        
        Alamofire.request(url).responseJSON { (responseJSON) -> Void in
            if((responseJSON.result.value) != nil) {
                let swiftyJsonVar = JSON(responseJSON.result.value!)
                if let resData = swiftyJsonVar["results"].arrayObject {
                    self.arrRes = resData as! [[String:AnyObject]]
                    self.arrRes = self.arrRes.sorted { ($0["bill_id"] as? String)! < ($1["bill_id"] as? String)! }
                }
                if self.arrRes.count > 0 {
                    self.numOfRows = self.arrRes.count
                    self.tblJSON.reloadData()
                }
            }
        }

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(shouldShowSearch) {
            return self.filteredBills.count
        }
        return self.numOfRows
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJSON.dequeueReusableCell(withIdentifier: "billCell", for: indexPath)
        var cur : [String:AnyObject]
        if(shouldShowSearch) {
            cur = self.filteredBills[indexPath.row]
        } else {
            cur = self.arrRes[indexPath.row]
        }
        cell.textLabel?.text = cur["official_title"] as? String
        
        return cell
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "billDetail", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "billDetail" {
//
            let billDetailVC = segue.destination as! BillDetailController
            if let cell = self.tblJSON.indexPathForSelectedRow {
                billDetailVC.bill = billAt(indexPath: cell as NSIndexPath)
            }
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    func billAt(indexPath: NSIndexPath) -> [String:AnyObject] {
        //let leg = self.arrRes[indexPath.section]
        return self.arrRes[indexPath.row]
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearch = true
        searchBar.endEditing(true)
        self.tblJSON.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            shouldShowSearch = true
            filteredBills = self.arrRes.filter({(obj) -> Bool in
                let t = obj["official_title"] as? String
                return t!.range(of: searchText) != nil
            })
            
        } else {
            shouldShowSearch = false
        }
        self.tblJSON.reloadData()
    }
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}

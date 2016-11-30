//
//  NewBillController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/19/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
class NewBillController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var searchButton: UIBarButtonItem!
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
        
        
        self.tabBarController?.navigationItem.rightBarButtonItem = searchButton
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createSearchBar()
        
        let url = "http://congressinfo-env.us-west-1.elasticbeanstalk.com/congress/congress.php?dbType=bills&activeStatus=false"
        
        tblJSON.estimatedRowHeight = 125
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
        self.tblJSON.contentInset = UIEdgeInsetsMake(-40, 0, 0, 0);
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    @IBAction func filterBills(_ sender: Any) {
        filter()
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
    public func formatDate(dateString : String) -> String {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.medium
        df.dateFormat = "yyyy-MM-dd"
        let intro = df.date(from: dateString)!
        df.dateFormat = "dd MMM yyyy"
        return df.string(from: intro)
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(shouldShowSearch) {
            return self.filteredBills.count
        }
        return self.numOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = Bundle.main.loadNibNamed("BillListCell", owner: self, options: nil)?.first as! BillListCell
        var cur : [String:AnyObject]
        if(shouldShowSearch) {
            cur = self.filteredBills[indexPath.row]
        } else {
            cur = self.arrRes[indexPath.row]
        }
        cell.id?.text = cur["bill_id"] as? String
        cell.title?.text = cur["official_title"]?.stringValue
        cell.date.text = formatDate(dateString: (cur["introduced_on"] as? String)!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "billDetail", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "billDetail" {
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
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }

    

}

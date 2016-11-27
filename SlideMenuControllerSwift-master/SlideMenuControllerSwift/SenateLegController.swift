//
//  SenateLegController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/15/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//
import UIKit
import SwiftyJSON
import Alamofire
class SenateLegController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var tblJSON: UITableView!
    @IBOutlet var filterButton: UIBarButtonItem!
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var numOfRows = 0
    var letters = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    var indexOfLetters = [String]()
    let searchBar = UISearchBar().self
    //search function variables
    var filteredLegs = [[String:AnyObject]]()
    var shouldShowSearch = false
    
    func createSearchBar() {
        
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search Legislators"
        searchBar.delegate = self
        
        
        self.navigationItem.titleView = nil
        self.navigationItem.title = "Legislators"
        self.tabBarController?.navigationItem.rightBarButtonItem = filterButton
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        indexOfLetters = self.letters.characters.split(separator: " ").map(String.init)
        createSearchBar()
        let url = "http://congressinfo-env.us-west-1.elasticbeanstalk.com/congress/congress.php?dbType=legislators"
        self.tabBarController?.navigationItem.rightBarButtonItem = filterButton
        Alamofire.request(url).responseJSON { (responseJSON) -> Void in
            if((responseJSON.result.value) != nil) {
                let swiftyJsonVar = JSON(responseJSON.result.value!)
                if let resData = swiftyJsonVar["results"].arrayObject {
                    let res = resData as! [[String:AnyObject]]
                    self.arrRes = res.filter { $0["chamber"] as! String == "senate" }
                    self.arrRes = self.arrRes.sorted { ($0["last_name"] as? String)! < ($1["last_name"] as? String)! }
                }
                if self.arrRes.count > 0 {
                    self.numOfRows = self.arrRes.count
                    self.tblJSON.reloadData()
                }
            }
        }
        self.tblJSON.contentInset = UIEdgeInsetsMake(-45, 0, 0, 0);
    }
    
    @IBAction func filterLegs(_ sender: Any) {
        filter()
    }
    
    
    func filter() {
        if self.tabBarController?.navigationItem.rightBarButtonItem?.image == (UIImage(named: "Search-22.png")) {
            self.tabBarController?.navigationItem.titleView = searchBar
            filterButton.image = UIImage(named: "Cancel-22.png")
        } else {
            self.tabBarController?.navigationItem.titleView = nil
            self.navigationItem.title = "Legislators"
            filterButton.image = UIImage(named: "Search-22.png")
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(shouldShowSearch) {
            return filteredLegs.count
        } else {
            return self.numOfRows
        }
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJSON.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? LegCell
        var cur : [String:AnyObject]
        if(shouldShowSearch) {
            cur = self.filteredLegs[indexPath.row]
        } else {
            cur = self.arrRes[indexPath.row]
        }
        
        let first = cur["first_name"] as? String
        let last = cur["last_name"] as? String
        cell?.legname?.text = last! + ", " + first!
        cell?.legstate?.text = cur["state_name"] as? String
        
        let id = cur["bioguide_id"] as? String
        let imageurl = "https://theunitedstates.io/images/congress/original/" + id! + ".jpg"
        let i = URL(string: imageurl)
        let data = try? Data(contentsOf: i!)
        cell?.legimage.image = UIImage(data: data!)
        
        
        return cell!

    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
//        return indexOfLetters.count;
        return 1
    }// Default is 1 if not implemented
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.navigationItem.rightBarButtonItem = filterButton
        self.tabBarController?.navigationItem.titleView = nil
        filterButton.image = UIImage(named: "Search-22.png")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "legislatorDetail" {
            let legDetailVC = segue.destination as! LegislatorDetailViewController
            if let cell = self.tblJSON.indexPathForSelectedRow {
                legDetailVC.leg = legAt(indexPath: cell as NSIndexPath)
                //legDetailVC.returnId
            }
            
            
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    func legAt(indexPath: NSIndexPath) -> [String:AnyObject] {
        //let leg = self.arrRes[indexPath.section]
        return self.arrRes[indexPath.row]
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearch = true
        searchBar.endEditing(true)
        self.tblJSON.reloadData()
    }

    //Search functions
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            shouldShowSearch = true
            print(searchText)
            //            print(self.arrRes[100]["first_name"]!)
            
            filteredLegs = self.arrRes.filter({(obj) -> Bool in
                //                print(obj)
                let f = obj["first_name"] as? String
                let l = obj["last_name"] as? String
                return f!.range(of: searchText) != nil || l!.range(of: searchText) != nil
            })
            
        } else {
            shouldShowSearch = false
        }
        self.tblJSON.reloadData()
    }
    public func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        filteredLegs = self.arrRes.filter({(obj) -> Bool in
            //                print(obj)
            let f = obj["first_name"] as? String
            let l = obj["last_name"] as? String
            return f!.range(of: searchString!) != nil || l!.range(of: searchString!) != nil
        })
        self.tblJSON.reloadData()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
}

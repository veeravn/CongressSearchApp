//
//  HouseLegController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/15/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
///Users/veerav/Desktop/workspace/CongressSearchApp/CongressSearchApp/StateLegController.swift

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
class HouseLegController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var filterButton: UIBarButtonItem!
    @IBOutlet var tblJSON: UITableView!
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
    var legSection = [String]()
    //array to hold the first letter of the last names as the key and the array of legislator objects as the value
    var legDict = [String:[[String:AnyObject]]]()
    func generateLegsDict() {
        for leg in self.arrRes  {
            let lname = leg["last_name"] as? String
            let key = "\(lname![(lname!.startIndex)])"
            
            if var legValues = legDict[key] {
                legValues.append(leg as [String:AnyObject])
                legDict[key] = legValues
            } else {
                legDict[key] = [leg as [String:AnyObject]]
            }
        }
        legSection = [String](legDict.keys).sorted()
    }
    var flegSection = [String]()
    var flegDict = [String:[[String:AnyObject]]]()
    func generateFilterLegsDict() {
        for leg in self.filteredLegs  {
            let lname = leg["last_name"] as? String
            let key = "\(lname![(lname!.startIndex)])"
            
            if var legValues = flegDict[key] {
                legValues.append(leg as [String:AnyObject])
                flegDict[key] = legValues
            } else {
                flegDict[key] = [leg as [String:AnyObject]]
            }
        }
        flegSection = [String](flegDict.keys).sorted()
    }

    @IBAction func filterLegs(_ sender: Any) {
    
        if self.tabBarController?.navigationItem.rightBarButtonItem?.image == (UIImage(named: "Search-22.png")) {
            self.tabBarController?.navigationItem.titleView = searchBar
            filterButton.image = UIImage(named: "Cancel-22.png")
        } else {
            self.tabBarController?.navigationItem.titleView = nil
            self.navigationItem.title = "Legislators"
            filterButton.image = UIImage(named: "Search-22.png")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Loading Congress Data")
        createSearchBar()
        let url = "http://congressinfo-env.us-west-1.elasticbeanstalk.com/congress/congress.php?dbType=legislators"
        self.navigationItem.rightBarButtonItem = filterButton
        Alamofire.request(url).responseJSON { (responseJSON) -> Void in
            if((responseJSON.result.value) != nil) {
                let swiftyJsonVar = JSON(responseJSON.result.value!)
                if let resData = swiftyJsonVar["results"].arrayObject {
                    let res = resData as! [[String:AnyObject]]
                    self.arrRes = res.filter { $0["chamber"] as! String == "house" }
                    self.arrRes = self.arrRes.sorted { ($0["last_name"] as? String)! < ($1["last_name"] as? String)! }
                }
                if self.arrRes.count > 0 {
                    self.numOfRows = self.arrRes.count
                    self.generateLegsDict()
                    self.tblJSON.reloadData()
                    SwiftSpinner.hide()
                }
            }
        }
        let appearance = UITabBarItem.appearance()
        self.tblJSON.contentInset = UIEdgeInsetsMake(-45, 0, 0, 0);
    }
    override func viewDidAppear(_ animated: Bool) {
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.navigationItem.rightBarButtonItem = filterButton
        self.tabBarController?.navigationItem.titleView = nil
        filterButton.image = UIImage(named: "Search-22.png")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(shouldShowSearch) {
            let legKey = flegSection[section]
            if let legValues = flegDict[legKey] {
                return legValues.count
            }
            return 0
        } else {
            let legKey = legSection[section]
            if let legValues = legDict[legKey] {
                return legValues.count
            }
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJSON.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? LegCell
        var cur : [String:AnyObject]
        if(shouldShowSearch) {
            let legKey = flegSection[indexPath.section]
            if flegDict[legKey] != nil {
                let curSec = flegDict[legKey]
                cur = (curSec?[indexPath.row])!
                let first = cur["first_name"] as? String
                let last = cur["last_name"] as? String
                cell?.legname?.text = last! + ", " + first!
                cell?.legstate?.text = cur["state_name"] as? String
                
                let id = cur["bioguide_id"] as? String
                let imageurl = "https://theunitedstates.io/images/congress/original/" + id! + ".jpg"
                let i = URL(string: imageurl)
                let data = try? Data(contentsOf: i!)
                cell?.legimage.image = UIImage(data: data!)
                
            }
        } else {
            let legKey = legSection[indexPath.section]
            if legDict[legKey] != nil {
                let curSec = legDict[legKey]
                cur = (curSec?[indexPath.row])!
                let first = cur["first_name"] as? String
                let last = cur["last_name"] as? String
                cell?.legname?.text = last! + ", " + first!
                cell?.legstate?.text = cur["state_name"] as? String
                
                let id = cur["bioguide_id"] as? String
                let imageurl = "https://theunitedstates.io/images/congress/original/" + id! + ".jpg"
                let i = URL(string: imageurl)
                let data = try? Data(contentsOf: i!)
                cell?.legimage.image = UIImage(data: data!)
                
            }
        }
        return cell!
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
        if(shouldShowSearch) {
            return flegSection.count
        } else {
            return legSection.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(shouldShowSearch) {
            return flegSection[section]
        } else {
            return legSection[section]
        }
    }
    
    // Index
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if(shouldShowSearch) {
            return flegSection
        } else {
            return legSection
        }
    }// return list of section titles to display in section index view (e.g. "ABCD...Z#")
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return legSection.index(of: title)!
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "legislatorDetail" {
            let legDetailVC = segue.destination as! LegislatorDetailViewController
            if let cell = self.tblJSON.indexPathForSelectedRow {
                legDetailVC.leg = legAt(indexPath: cell as NSIndexPath)
            }
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    func legAt(indexPath: NSIndexPath) -> [String:AnyObject] {
        let legKey = legSection[indexPath.section]
        let legs = self.legDict[legKey]
        return (legs?[indexPath.row])!
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearch = true
        searchBar.endEditing(true)
        generateFilterLegsDict()
        self.tblJSON.reloadData()
    }
    
    //Search functions
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            shouldShowSearch = true
            filteredLegs = self.arrRes.filter({(obj) -> Bool in
                let f = obj["first_name"] as? String
                let l = obj["last_name"] as? String
                return f!.range(of: searchText) != nil || l!.range(of: searchText) != nil
            })
            generateFilterLegsDict()
        } else {
            shouldShowSearch = false
            
        }
        generateLegsDict()
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
        generateFilterLegsDict()
        self.tblJSON.reloadData()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}


//
//  StateLegController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/15/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
class StateLegController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var stateFilterButton: UIBarButtonItem!
    @IBOutlet var statepicker: UIPickerView!
    @IBOutlet var tblJSON: UITableView!
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var numOfRows = 0
    let states : [String] = ["All States", "Alaska", "Alabama", "Arkansas", "American Samoa",
                             "Arizona", "California", "Colorado", "Connecticut",
                             "District of Columbia", "Delaware", "Florida",
                             "Georgia", "Guam", "Hawaii", "Iowa", "Idaho",
                             "Illinois", "Indiana", "Kansas", "Kentucky",
                             "Louisiana", "Massachusetts", "Maryland", "Maine",
                             "Michigan", "Minnesota", "Missouri", "Mississippi",
                             "Montana", "North Carolina", "North Dakota", "Nebraska",
                             "New Hampshire", "New Jersey", "New Mexico", "Nevada",
                             "New York", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
                             "Puerto Rico", "Rhode Island", "South Carolina",
                             "South Dakota", "Tennessee", "Texas", "Utah", "Virginia",
                             "Virgin Islands", "Vermont", "Washington", "Wisconsin",
                             "West Virginia", "Wyoming"]
    //search function variables
    var filteredLegs = [[String:AnyObject]]()
    var shouldShowSearch = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
//
        self.statepicker.isHidden = true
        let url = "http://congressinfo-env.us-west-1.elasticbeanstalk.com/congress/congress.php?dbType=legislators"
        SwiftSpinner.show("Loading Congress Data")
        Alamofire.request(url).responseJSON { (responseJSON) -> Void in
            if((responseJSON.result.value) != nil) {
                let swiftyJsonVar = JSON(responseJSON.result.value!)
                if let resData = swiftyJsonVar["results"].arrayObject {
                    self.arrRes = resData as! [[String:AnyObject]]
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
        self.tblJSON.contentInset = UIEdgeInsetsMake(-45, 0, 0, 0);
    }
    
    @IBAction func showStateFilter(_ sender: Any) {
        self.statepicker.isHidden = false
        self.tblJSON.isHidden = true
    }
    
    //Legislator indexing
    //array to hold the indexes of letters
    var legSection = [String]()
    //array to hold the first letter of the last names as the key and the array of legislator objects as the value
    var legDict = [String:[[String:AnyObject]]]()
    func generateLegsDict() {
        for leg in self.arrRes  {
            let lname = leg["state_name"] as? String
            let key = "\(lname![(lname!.startIndex)])"
            
            if var legValues = legDict[key] {
                legValues.append(leg as [String:AnyObject])
                legDict[key] = legValues
            } else {
                legDict[key] = [leg as [String:AnyObject]]
            }
        }
        for key in legDict.keys {
            var legValues = legDict[key]
            legValues = legValues?.sorted {
                switch ($0["state_name"] as? String,$1["state_name"] as? String) {
                case let (lhs,rhs) where lhs == rhs:
                    return ($0["last_name"] as? String)! < ($1["last_name"] as? String)!
                case let (lhs, rhs):
                    return lhs! < rhs!
                }
            }
            legDict[key] = legValues
        }
        legSection = [String](legDict.keys).sorted()
    }
    var flegSection = [String]()
    var flegDict = [String:[[String:AnyObject]]]()
    func generateFilterLegsDict() {
        for leg in self.filteredLegs  {
            let lname = leg["state_name"] as? String
            let key = "\(lname![(lname!.startIndex)])"
            
            if var legValues = flegDict[key] {
                legValues.append(leg as [String:AnyObject])
                flegDict[key] = legValues
            } else {
                flegDict[key] = [leg as [String:AnyObject]]
            }
        }
        for key in flegDict.keys {
            var legValues = flegDict[key]
            legValues = legValues?.sorted {
                switch ($0["state_name"] as? String,$1["state_name"] as? String) {
                case let (lhs,rhs) where lhs == rhs:
                    return ($0["last_name"] as? String)! < ($1["last_name"] as? String)!
                case let (lhs, rhs):
                    return lhs! < rhs!
                }
            }
            flegDict[key] = legValues
        }
        flegSection = [String](flegDict.keys).sorted()
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.navigationItem.rightBarButtonItem = stateFilterButton
        self.tabBarController?.navigationItem.titleView = nil
        stateFilterButton.title = "Filter"
        stateFilterButton.image = nil
        statepicker.isHidden = true
        tblJSON.tableHeaderView = nil
    }
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    }// tell table which section corresponds to section title/index (e.g. "B",1))
    
    
    // Data manipulation - insert and delete support
    
    // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
    // Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "legislatorDetail" {
            let legDetailVC = segue.destination as! LegislatorDetailViewController
            if let cell = self.tblJSON.indexPathForSelectedRow {
                legDetailVC.leg = legAt(indexPath: cell as NSIndexPath)

            }
            self.tabBarController?.tabBar.isHidden = true
            self.removeNavigationBarItem()
        }
    }
    func legAt(indexPath: NSIndexPath) -> [String:AnyObject] {
        let legKey = legSection[indexPath.section]
        let legs = self.legDict[legKey]
        return (legs?[indexPath.row])!
    }
    //filter by state pickerview functions
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return states.count
    }
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row]
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.statepicker.isHidden = true
        self.tblJSON.isHidden = false
        let selState = states[row]
        if selState == "All States" {
            shouldShowSearch = false
        } else {
            shouldShowSearch = true
            filteredLegs = self.arrRes.filter({(obj) -> Bool in
            //                print(obj)
                let s = obj["state_name"] as? String
                return s!.range(of: selState) != nil
            })
            generateFilterLegsDict()
        }
        tblJSON.reloadData()
    }

}

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
class StateLegController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet var statepicker: UIPickerView!
    @IBOutlet var tblJSON: UITableView!
    var arrRes = [[String:AnyObject]]() //Array of dictionary
    var numOfRows = 0
    var letters = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    var indexOfLetters = [String]()
    //search function variables
    var filteredLegs = [[String:AnyObject]]()
    var shouldShowSearch = false

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.statepicker.isHidden = true
//        indexOfLetters = self.letters.characters.split(separator: " ").map(String.init)
        
        let url = "http://congressinfo-env.us-west-1.elasticbeanstalk.com/congress/congress.php?dbType=legislators"

        
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
                }
            }
        }
    }
    
    //Legislator indexing
    //array to hold the indexes of letters
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

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(shouldShowSearch) {
            return filteredLegs.count
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
    }
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJSON.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? LegCell
        var cur : [String:AnyObject]
        if(shouldShowSearch) {
            cur = self.filteredLegs[indexPath.row]
        } else {
            let legKey = legSection[indexPath.section]
            if legDict[legKey] != nil {
                let curSec = legDict[legKey]
                cur = (curSec?[indexPath.row])!
                let first = cur["first_name"] as? String
                let last = cur["last_name"] as? String
                cell?.legname?.text = first! + " " + last!
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
//        if(shouldShowSearch) {
//            return 1
//        } else {
//            return numOfRows;
//        }
        return legSection.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return legSection[section]
    }
    
    // Index
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return legSection
    }// return list of section titles to display in section index view (e.g. "ABCD...Z#")
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return 0;
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
        }
    }
    func legAt(indexPath: NSIndexPath) -> [String:AnyObject] {
        let legKey = legSection[indexPath.section]
        let legs = self.legDict[legKey]
        return (legs?[indexPath.row])!
    }

}
extension UIPickerViewDelegate {
    
}
extension UIPickerViewDataSource {
    
}

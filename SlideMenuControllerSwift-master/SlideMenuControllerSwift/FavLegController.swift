//
//  FavLegController.swift
//  SlideMenuControllerSwift
//
//  Created by Veerav Naidu on 11/23/16.
//  Copyright © 2016 Yuji Hato. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
class FavLegController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblJSON: UITableView!
    var favLegs : [String] = []
    var favLegDetails : [[String:AnyObject]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tblJSON.contentInset = UIEdgeInsetsMake(-45, 0, 0, 0);
        // Do any additional setup after loading the view.
    }
    func getFavs() {
        if UserDefaults.standard.array(forKey: "favLegs") != nil {
            favLegs = UserDefaults.standard.array(forKey: "favLegs") as! [String]
            favLegDetails = []
            for leg in favLegs {
                let data = leg.data(using: String.Encoding.utf8)!
                let swiftyJsonVar = JSON(data: data)
                let legDict = (swiftyJsonVar.dictionaryObject as? [String:AnyObject])
                self.favLegDetails.append(legDict!)
            }
        }
        self.favLegDetails = self.favLegDetails.sorted { ($0["last_name"] as? String)! < ($1["last_name"] as? String)! }
        generateLegsDict()
        self.tblJSON.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        SwiftSpinner.show("Loading Favorite Data")
        getFavs()
        SwiftSpinner.hide()
    }
    var legSection = [String]()
    //array to hold the first letter of the last names as the key and the array of legislator objects as the value
    var legDict = [String:[[String:AnyObject]]]()
    func generateLegsDict() {
        legSection = [String]()
        legDict = [String:[[String:AnyObject]]]()
        for leg in self.favLegDetails  {
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
        let legKey = legSection[section]
        if let legValues = legDict[legKey] {
            return legValues.count
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJSON.dequeueReusableCell(withIdentifier: "legCell", for: indexPath) as? LegCell
        let legKey = legSection[indexPath.section]
        if legDict[legKey] != nil {
            let curSec = legDict[legKey]
            let leg = (curSec?[indexPath.row])!
            let first = leg["first_name"] as? String
            let last = leg["last_name"] as? String
            cell?.legname?.text = last! + ", " + first!
            cell?.legstate?.text = leg["state_name"] as? String
            
            let imageurl = "https://theunitedstates.io/images/congress/original/" + (leg["bioguide_id"] as? String)! + ".jpg"
            let i = URL(string: imageurl)
            let data = try? Data(contentsOf: i!)
            cell?.legimage.image = UIImage(data: data!)
        }
        return cell!
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
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
        return legSection.index(of: title)!
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "legislatorDetail" {
            let legDetailVC = segue.destination as! LegislatorDetailViewController
            if let indexPath = self.tblJSON.indexPathForSelectedRow {
                let legKey = legSection[indexPath.section]
                let legs = self.legDict[legKey]
                legDetailVC.leg = (legs?[indexPath.row])!
            }
            self.tabBarController?.tabBar.isHidden = true
            self.removeNavigationBarItem()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

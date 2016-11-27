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
class FavLegController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblJSON: UITableView!
    var favLegs : [String] = []
    var favLegDetails : [[String:AnyObject]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        favLegs = UserDefaults.standard.array(forKey: "favLegs") as! [String]
        for leg in favLegs {
            let data = leg.data(using: String.Encoding.utf8)!
            let swiftyJsonVar = JSON(data: data)
            let legDict = (swiftyJsonVar.dictionaryObject as? [String:AnyObject])
            self.favLegDetails.append(legDict!)
        }
        self.tblJSON.contentInset = UIEdgeInsetsMake(-45, 0, 0, 0);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favLegDetails.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJSON.dequeueReusableCell(withIdentifier: "legCell", for: indexPath) as? LegCell
        let leg = favLegDetails[indexPath.row]
        let first = leg["first_name"] as? String
        let last = leg["last_name"] as? String
        cell?.legname?.text = last! + ", " + first!
        cell?.legstate?.text = leg["state_name"] as? String
        
        let imageurl = "https://theunitedstates.io/images/congress/original/" + (leg["bioguide_id"] as? String)! + ".jpg"
        let i = URL(string: imageurl)
        let data = try? Data(contentsOf: i!)
        cell?.legimage.image = UIImage(data: data!)
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "legislatorDetail" {
            let legDetailVC = segue.destination as! LegislatorDetailViewController
            if let cell = self.tblJSON.indexPathForSelectedRow {
                legDetailVC.leg = favLegDetails[cell.row]
                
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

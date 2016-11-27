//
//  FavComController.swift
//  SlideMenuControllerSwift
//
//  Created by Veerav Naidu on 11/23/16.
//  Copyright © 2016 Yuji Hato. All rights reserved.
//

import UIKit
import SwiftyJSON
class FavComController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tblJSON: UITableView!
    var favComs : [String] = []
    var favComDetails : [[String:AnyObject]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        favComs = UserDefaults.standard.array(forKey: "favLegs") as! [String]
        for com in favComs {
            let data = com.data(using: String.Encoding.utf8)!
            let swiftyJsonVar = JSON(data: data)
            let comDict = (swiftyJsonVar.dictionaryObject as? [String:AnyObject])
            self.favComDetails.append(comDict!)
        }
        self.tblJSON.contentInset = UIEdgeInsetsMake(-45, 0, 0, 0);
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favComDetails.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJSON.dequeueReusableCell(withIdentifier: "comCell", for: indexPath)
        let com = favComDetails[indexPath.row]
        cell.textLabel?.text = com["name"] as? String
        cell.detailTextLabel?.text = com["committee_id"] as? String
        
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comDetail" {
            let comDetailVC = segue.destination as! CommitteeDetailController
            if let cell = self.tblJSON.indexPathForSelectedRow {
                comDetailVC.com = favComDetails[cell.row]
                
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

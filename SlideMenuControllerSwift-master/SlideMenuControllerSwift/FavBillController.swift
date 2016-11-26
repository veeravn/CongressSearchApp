//
//  FavBillController.swift
//  SlideMenuControllerSwift
//
//  Created by Veerav Naidu on 11/23/16.
//  Copyright © 2016 Yuji Hato. All rights reserved.
//

import UIKit
import SwiftyJSON
class FavBillController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblJSON: UITableView!
    var favBills : [String] = []
    var favBillDetails : [[String:AnyObject]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        favBills = UserDefaults.standard.array(forKey: "favBills") as! [String]
        for bill in favBills {
            let data = bill.data(using: String.Encoding.utf8)!
            let swiftyJsonVar = JSON(data: data)
            let legDict = (swiftyJsonVar.dictionaryObject as? [String:AnyObject])
            self.favBillDetails.append(legDict!)
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favBillDetails.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblJSON.dequeueReusableCell(withIdentifier: "billCell", for: indexPath)
        let cur = self.favBillDetails[indexPath.row]
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.text = cur["official_title"] as? String
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "billDetail" {
            let billDetailVC = segue.destination as! BillDetailController
            if let cell = self.tblJSON.indexPathForSelectedRow {
                billDetailVC.bill = favBillDetails[cell.row]
                
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

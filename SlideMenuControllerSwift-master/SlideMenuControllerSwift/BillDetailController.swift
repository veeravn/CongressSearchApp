//
//  BillDetailController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/18/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit
import SwiftyJSON
class BillDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var bill : [String:AnyObject] = [:]
    let keys = ["bill_id", "bill_type", "sponsor", "last_action_at", "pdf", "chamber", "last_vote", "active"]
    @IBOutlet var billTitle: UITextView!
    @IBOutlet var detailTable: UITableView!
    
    @IBOutlet var button: UIBarButtonItem!
    var favBills : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        billTitle.text = bill["official_title"] as! String!
        
        if UserDefaults.standard.array(forKey: "favBills") != nil {
            favBills = UserDefaults.standard.array(forKey: "favBills") as! [String]
            updateStar()
        }
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.detailTable.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! BillDetailCell
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.dateFormat = "yyyy-MM-dd"
        var actionDate :Date? = nil
        if let action = self.bill["last_action_at"] as? String {
            let ind = action.index(action.startIndex, offsetBy: 10)
            actionDate = formatter.date(from: action.substring(to: ind))!
        }
        var voteDate :Date? = nil
        if let vote = self.bill["last_vote_at"] as? String {
            let ind = vote.index(vote.startIndex, offsetBy: 10)
            voteDate = formatter.date(from: vote.substring(to: ind))!
        }
        let lastVersion = self.bill["last_version"]
        let urls = lastVersion?["urls"] as! [String:AnyObject]
        let pdfurl = URL(string: urls["pdf"] as! String)
        let sponsor = self.bill["sponsor"]
        let st = sponsor?["title"] as! String
        let sf = sponsor?["first_name"] as! String
        let sl = sponsor?["last_name"] as! String
        let sname = st + ". " + sf + " " + sl
        let history = self.bill["history"]
        let active = history?["active"] as? Bool
        
        
//        let pdf = URL(string: (pdfurl as! String?))
        formatter.dateFormat = "dd MMM yyyy"
        cell.detail.isHidden = false
        cell.pdf.isHidden = true
        switch keys[indexPath.row] {
        case "bill_id":
            cell.title.text = "Bill ID"
            cell.detail.text = self.bill[keys[indexPath.row]] as! String?
            break
        case "bill_type":
            cell.title.text = "Bill Type"
            cell.detail.text = self.bill[keys[indexPath.row]] as! String?
            break
        case "sponsor":
            cell.title.text = "Sponsor"
            cell.detail.text = sname
            break
        case "last_action_at":
            cell.title.text = "Last Action"
            if actionDate != nil {
                cell.detail.text = formatter.string(from: actionDate!)
            } else {
                cell.detail.text = "N/A"
            }
            break
        case "pdf":
            cell.detail.isHidden = true
            cell.pdf.isHidden = false
            cell.title.text = "PDF"
            cell.pdf.setTitle("PDF Link", for: .normal)
            cell.pdfurl = pdfurl
            break
        case "chamber":
            cell.title.text = "Chamber"
            if self.bill["chamber"] as! String? == "house" {
                cell.detail.text = "House"
            } else {
                cell.detail.text = "Senate"
            }
            break
        case "last_vote":
            cell.title.text = "Last Vote"
            if voteDate != nil {
                cell.detail.text = formatter.string(from: voteDate!)
            } else {
                cell.detail.text = "N/A"
            }
            break
        case "active":
            cell.title.text = "Status"
            if active! {
                cell.detail.text = "Active"
            } else {
                cell.detail.text = "New"
            }
            break
        default:
            cell.title.text = ""
            cell.detail.text = " "
            break
        }
        return cell
    }
    func saveBill() {
        let favs = UserDefaults.standard
        var json : Data
        var jsonData : String = ""
        var exists : Bool = false
        for fav in favBills {
            let id = bill["bill_id"] as? String
            if fav.range(of: id!) != nil {
                jsonData = fav
                exists = true
                break
            }
        }
        do {
            if !exists {
                try json = JSONSerialization.data(withJSONObject: bill, options: JSONSerialization.WritingOptions.prettyPrinted)
                jsonData = NSString(data: json, encoding: UInt.init()) as! String
            }
        } catch {
            print(error)
        }
        if favBills.count == 0 {
            button.image = UIImage(named: "Christmas Star Filled-44.png")
            favBills.append(jsonData)
            favs.set(favBills, forKey: "favBills")
        } else if exists {
            button.image = UIImage(named: "Christmas Star-44.png")
            let index = favBills.index(of: jsonData)
            favBills.remove(at: index!)
            favs.set(favBills, forKey: "favBills")
            
        } else {
            button.image = UIImage(named: "Christmas Star Filled-44.png")
            favBills.append(jsonData)
            favs.set(favBills, forKey: "favBills")
        }
    }
    func updateStar() {
        for bill in favBills {
            let data = bill.data(using: String.Encoding.utf8)!
            let swiftyJsonVar = JSON(data: data)
            let billDict = (swiftyJsonVar.dictionaryObject as? [String:AnyObject])
            if (billDict?["bill_id"] as? String) == (self.bill["bill_id"]as? String)  {
                button.image = UIImage(named: "Christmas Star Filled-44.png")
                break
            }
        }

    }
    @IBAction func saveFavBill(_ sender: Any) {
        saveBill()
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

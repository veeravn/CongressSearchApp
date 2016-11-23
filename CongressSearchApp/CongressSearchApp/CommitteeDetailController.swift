//
//  CommitteeDetailController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/19/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit

class CommitteeDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var com : [String:AnyObject] = [:]
    let keys = ["committee_id", "parent_committee_id", "chamber", "office", "contact"]
    @IBOutlet var comTitle : UITextView!
    @IBOutlet var detailTable : UITableView!
    @IBOutlet var favComStar: UIBarButtonItem!
    
    @IBOutlet var button: UIBarButtonItem!
    var favComs : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        comTitle.text = com["name"] as! String!
        favComs = UserDefaults.standard.array(forKey: "favComs" ) as! [String]
        updateStar(id: (self.com["committee_id"] as? String)!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.detailTable.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! ComDetailCell
        
        switch keys[indexPath.row] {
        case "committee_id":
            cell.title.text = "Committee ID"
            cell.detail.text = self.com["committee_id"] as! String?
            break
        case "parent_committee_id":
            cell.title.text = "Parent Committee ID"
            if (self.com["parent_committee_id"] != nil) {
                cell.detail.text = self.com["parent_committee_id"] as! String?
            } else {
            cell.detail.text = "N.A."
            }
            break
        case "chamber":
            cell.title.text = "Chamber"
            if self.com["chamber"] as! String? == "house" {
                cell.detail.text = "House"
            } else if self.com["chamber"] as! String? == "senate" {
                cell.detail.text = "Senate"
            } else {
                cell.detail.text = "Joint"
            }
            break
        case "office":
            cell.title.text = "Office"
            if (self.com["office"] != nil) {
                cell.detail.text = self.com["office"] as! String?
            } else {
                cell.detail.text = "N.A."
            }
            break
        case "contact":
            cell.title.text = "Contact"
            if (self.com["phone"] != nil) {
                cell.detail.text = self.com["phone"] as! String?
            } else {
                cell.detail.text = "N.A."
            }
            break
        default:
            cell.title.text = ""
            cell.detail.text = " "
            break
        }
        return cell
    }
    @IBAction func saveFavCom(_ sender: Any) {
        let id = self.com["committee_id"] as? String!
        saveCom(id: id!)
    }
    func saveCom(id:String) {
        let favcoms = UserDefaults.standard
        if favComs.count == 0 {
            button.image = UIImage(named: "Christmas Star Filled-50.png")
            favComs.append(id)
            favcoms.set(favComs, forKey: "favComs")
            return
        }
        if favComs.contains(id) {
            button.image = UIImage(named: "Christmas Star Filled-50.png")
            
            let index = favComs.index(of: id)
            favComs.remove(at: index!)
            favcoms.set(favComs, forKey: "favComs")
            
        } else {
            button.image = UIImage(named: "Christmas Star-50.png")
            favComs.append(id)
            favcoms.set(favComs, forKey: "favComs")
        }
        let favs = UserDefaults.standard.array(forKey: "favComs") as! [String]
        print(favs)
    }
    func updateStar(id:String) {
        if favComs.contains(id) {
            button.image = UIImage(named: "Christmas Star Filled-50.png")
        }
    }

}

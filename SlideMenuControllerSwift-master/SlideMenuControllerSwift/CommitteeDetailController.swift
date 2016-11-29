//
//  CommitteeDetailController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/19/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit
import SwiftyJSON
class CommitteeDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var com : [String:AnyObject] = [:]
    let keys = ["committee_id", "parent_committee_id", "chamber", "office", "contact"]
    @IBOutlet var comTitle : UITextView!
    @IBOutlet var detailTable : UITableView!
    @IBOutlet var favComStar: UIBarButtonItem!
    
    var favComs : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = favComStar
        comTitle.text = com["name"] as! String!
        if UserDefaults.standard.array(forKey: "favComs" ) != nil {
            favComs = UserDefaults.standard.array(forKey: "favComs" ) as! [String]
            updateStar()
        }
        
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
        saveCom()
    }
    func saveCom() {
        let favs = UserDefaults.standard
        var json : Data
        var jsonData : String = ""
        var exists : Bool = false
        for fav in favComs {
            let id = com["committee_id"] as? String
            if fav.range(of: id!) != nil {
                jsonData = fav
                exists = true
                break
            }
        }
        do {
            if !exists {
                try json = JSONSerialization.data(withJSONObject: com, options: JSONSerialization.WritingOptions.prettyPrinted)
                jsonData = NSString(data: json, encoding: UInt.init()) as! String
            }
        } catch {
            print(error)
        }
        if favComs.count == 0 {
            favComStar.image = UIImage(named: "Christmas Star Filled-44.png")
            favComs.append(jsonData)
            favs.set(favComs, forKey: "favComs")
        } else if exists {
            favComStar.image = UIImage(named: "Christmas Star-44.png")
            let index = favComs.index(of: jsonData)
            favComs.remove(at: index!)
            favs.set(favComs, forKey: "favComs")
            
        } else {
            favComStar.image = UIImage(named: "Christmas Star Filled-44.png")
            favComs.append(jsonData)
            favs.set(favComs, forKey: "favComs")
        }
    }
    func updateStar() {
        for com in favComs {
            let data = com.data(using: String.Encoding.utf8)!
            let swiftyJsonVar = JSON(data: data)
            let comDict = (swiftyJsonVar.dictionaryObject as? [String:AnyObject])
            if (comDict?["committee_id"] as? String) == (self.com["committee_id"] as? String) {
                favComStar.image = UIImage(named: "Christmas Star Filled-44.png")
                break
            }
        }
    }

}

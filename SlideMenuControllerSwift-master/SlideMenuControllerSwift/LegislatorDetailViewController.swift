//
//  LegislatorDetailViewController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/17/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit
import SwiftyJSON
class LegislatorDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var leg : [String:AnyObject] = [:]
    let keys = ["first_name", "last_name", "state_name", "birthday", "gender", "chamber", "fax", "twitter_id", "facebook_id", "website", "office", "term_end"]
    var favLegs : [String] = []
    
    @IBOutlet var legImage: UIImageView!
    @IBOutlet var detailTable: UITableView!
    @IBOutlet var button: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let id = leg["bioguide_id"] as? String
        let imageurl = "https://theunitedstates.io/images/congress/original/" + id! + ".jpg"
        let i = URL(string: imageurl)
        let data = try? Data(contentsOf: i!)
        self.legImage.image = UIImage(data: data!)
        // Do any additional setup after loading the view.
        favLegs = UserDefaults.standard.array(forKey: "favLegs") as! [String]
        updateStar()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.detailTable.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! LegDetailCell
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.dateFormat = "yyyy-MM-dd"
        let birth = self.leg["birthday"] as! String?
        let birthDate = formatter.date(from: birth!)
        let term = self.leg["term_end"] as! String?
        let term_end = formatter.date(from: term!)
        var twitterurl : URL
        if let twitter = self.leg["twitter_id"] {
            twitterurl = URL(string: "https://www.twitter.com/" + (twitter as! String))!
        } else {
            twitterurl = URL(string: "N.A.")!
        }
        var facebookurl : URL
        if let fb = self.leg["facebook_id"] {
            facebookurl = URL(string: "https://www.facebook.com/" + (fb as! String))!
        } else {
            facebookurl = URL(string: "N.A.")!
        }
        let weburl = URL(string: (self.leg["website"] as! String?)!)
        formatter.dateFormat = "dd MMM yyyy"
        switch keys[indexPath.row] {
        case "first_name":
            cell.title.text = "First Name"
            cell.detail.text = self.leg[keys[indexPath.row]] as! String?
            break
        case "last_name":
            cell.title.text = "Last Name"
            cell.detail.text = self.leg[keys[indexPath.row]] as! String?
            break
        case "state_name":
            cell.title.text = "State Name"
            cell.detail.text = self.leg[keys[indexPath.row]] as! String?
            break
        case "birthday":
            cell.title.text = "Birth Date"
            cell.detail.text = formatter.string(from: birthDate!)
            break
        case "gender":
            cell.title.text = "Gender"
            if self.leg["gender"] as! String? == "M" {
                cell.detail.text = "Male"
            } else {
                cell.detail.text = "Female"
            }
            break
        case "chamber":
            cell.title.text = "Chamber"
            let imagev = UIImageView()
            if self.leg["chamber"] as! String? == "house" {
                let i = URL(string: "http://cs-server.usc.edu:45678/hw/hw8/images/h.png")
                let data = try? Data(contentsOf: i!)
                imagev.image = UIImage(data: data!)
                cell.addSubview(imagev)
                cell.detail.text = "House"
                
            } else {
                let i = URL(string: "http://cs-server.usc.edu:45678/hw/hw8/images/s.svg")
                let data = try? Data(contentsOf: i!)
                imagev.image = UIImage(data: data!)
                cell.detail.text = "Senate"
            }
            break
        case "fax":
            cell.title.text = "Fax No."
            if let faxNo = self.leg[keys[indexPath.row]] {
                cell.detail.text = (faxNo as! String)
            } else {
                cell.detail.text = "N.A."
            }
            break
        case "twitter_id":
            cell.title.text = "Twitter Link"
            cell.detail.text = twitterurl.absoluteString
            break
        case "facebook_id":
            cell.title.text = "Facebook Link"
            cell.detail.text = facebookurl.absoluteString
            break
        case "website":
            cell.title.text = "Website Link"
            cell.detail.text = weburl?.absoluteString
            break
        case "office":
            cell.title.text = "Office No."
            cell.detail.text = self.leg[keys[indexPath.row]] as! String?
            break
        case "term_end":
            cell.title.text = "Term Ends on"
            cell.detail.text = formatter.string(from: term_end!)
            break
            
        default:
            cell.title.text = ""
            cell.detail.text = " "
            break
        }
        
        
        return cell
    }
    func saveLeg(id:String) {
        let favs = UserDefaults.standard
        var json : Data
        var jsonData : String = ""
        do {
        try json = JSONSerialization.data(withJSONObject: leg, options: JSONSerialization.WritingOptions.prettyPrinted)
            jsonData = NSString(data: json, encoding: UInt.init()) as! String
        } catch {
            print(error)
        }
        
        if favLegs.count == 0 {
            button.image = UIImage(named: "Christmas Star Filled-44.png")
            favLegs.append(jsonData)
            favs.set(favLegs, forKey: "favLegs")
        } else if favLegs.contains(jsonData) {
            button.image = UIImage(named: "Christmas Star-44.png")
            
            let index = favLegs.index(of: jsonData)
            favLegs.remove(at: index!)
            favs.set(favLegs, forKey: "favLegs")
            
        } else {
            button.image = UIImage(named: "Christmas Star Filled-44.png")
            favLegs.append(jsonData)
            favs.set(favLegs, forKey: "favLegs")
        }
    }
    func updateStar() {
        for leg in favLegs {
            let data = leg.data(using: String.Encoding.utf8)!
            let swiftyJsonVar = JSON(data: data)
            let legDict = (swiftyJsonVar.dictionaryObject as? [String:AnyObject])
            if (legDict?["bioguide_id"] as? String) == (self.leg["bioguide_id"] as? String) {
                button.image = UIImage(named: "Christmas Star Filled-44.png")
                break
            }
        }
    }

    @IBAction func saveFavLeg(_ sender: Any) {
        let id = self.leg["bioguide_id"] as? String!
        saveLeg(id: id!)
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

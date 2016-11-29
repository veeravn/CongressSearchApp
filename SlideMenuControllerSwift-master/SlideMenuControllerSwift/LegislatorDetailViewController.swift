//
//  LegislatorDetailViewController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/17/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit
import SwiftyJSON
class LegislatorDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {
    
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
        if (UserDefaults.standard.array(forKey: "favLegs") != nil) {
            favLegs = UserDefaults.standard.array(forKey: "favLegs") as! [String]
            updateStar()
        }
        

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
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
        let weburl : URL
        if let web = (self.leg["website"] as? String) {
            weburl = URL(string: (web))!
        } else {
            weburl = URL(string: "N.A.")!
        }
        formatter.dateFormat = "dd MMM yyyy"
        
        cell.detail.isHidden = false
        switch keys[indexPath.row] {
        case "first_name":
            cell.hyperLink.isHidden = true
            cell.title.text = "First Name"
            cell.detail.text = self.leg["first_name"] as! String?
            break
        case "last_name":
            cell.hyperLink.isHidden = true
            cell.title.text = "Last Name"
            cell.detail.text = self.leg["last_name"] as! String?
            break
        case "state_name":
            cell.hyperLink.isHidden = true
            cell.title.text = "State Name"
            cell.detail.text = self.leg["birthday"] as! String?
            break
        case "birthday":
            cell.hyperLink.isHidden = true
            cell.title.text = "Birth Date"
            cell.detail.text = formatter.string(from: birthDate!)
            break
        case "gender":
            cell.hyperLink.isHidden = true
            cell.title.text = "Gender"
            if self.leg["gender"] as! String? == "M" {
                cell.detail.text = "Male"
            } else {
                cell.detail.text = "Female"
            }
            break
        case "chamber":
            cell.hyperLink.isHidden = true
            cell.title.text = "Chamber"
            if self.leg["chamber"] as! String? == "house" {
                cell.detail.text = "House"
            } else {
                cell.detail.text = "Senate"
            }
            break
        case "fax":
            cell.hyperLink.isHidden = true
            cell.title.text = "Fax No."
            if let fax = (self.leg["fax"] as? String) {
                cell.detail.text = fax
            } else {
                cell.detail.text = "N.A."
            }
            break
        case "twitter_id":
            
            cell.title.text = "Twitter Link"
            if twitterurl.absoluteString != "N.A." {
                cell.detail.isHidden = true
                cell.hyperLink.setTitle("Twitter Link", for: .normal)
                cell.website = twitterurl
            } else {
                cell.detail.text = twitterurl.absoluteString
                cell.hyperLink.isHidden = true
            }
            break
        case "facebook_id":
            cell.title.text = "Facebook Link"
            if facebookurl.absoluteString != "N.A." {
                cell.detail.isHidden = true
                cell.hyperLink.isHidden = false
                cell.hyperLink.setTitle("Facebook Link", for: .normal)
                cell.website = facebookurl
            } else {
                cell.detail.text = facebookurl.absoluteString
                cell.hyperLink.isHidden = true
            }
            break
        case "website":
            cell.title.text = "Website Link"
            if weburl.absoluteString != "N.A." {
                cell.hyperLink.isHidden = false
                cell.detail.isHidden = true
                cell.hyperLink.setTitle("Website Link", for: .normal)
                cell.website = weburl
            } else {
                cell.detail.text = weburl.absoluteString
                cell.hyperLink.isHidden = true
            }
            break
        case "office":
            cell.hyperLink.isHidden = true
            cell.title.text = "Office No."
            cell.detail.text = self.leg["office"] as! String?
            break
        case "term_end":
            cell.hyperLink.isHidden = true
            cell.title.text = "Term Ends on"
            cell.detail.text = formatter.string(from: term_end!)
            break
            
        default:
            cell.hyperLink.isHidden = true
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
        var exists : Bool = false
        for fav in favLegs {
            let id = leg["bioguide_id"] as? String
            if fav.range(of: id!) != nil {
                jsonData = fav
                exists = true
                break
            }
        }
        do {
            if !exists {
                try json = JSONSerialization.data(withJSONObject: leg, options: JSONSerialization.WritingOptions.prettyPrinted)
                jsonData = NSString(data: json, encoding: UInt.init()) as! String
            }
        } catch {
            print(error)
        }
        
        if favLegs.count == 0 {
            button.image = UIImage(named: "Christmas Star Filled-44.png")
            favLegs.append(jsonData)
            favs.set(favLegs, forKey: "favLegs")
        } else if exists {
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

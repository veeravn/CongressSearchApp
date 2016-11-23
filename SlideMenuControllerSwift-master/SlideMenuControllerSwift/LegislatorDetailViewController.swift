//
//  LegislatorDetailViewController.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/17/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit

class LegislatorDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var leg : [String:AnyObject] = [:]
    let keys = ["first_name", "last_name", "state_name", "birthday", "gender", "chamber", "fax", "twitter_id", "website", "office", "term_end"]
    var returnId : String = ""
    @IBOutlet var legImage: UIImageView!
    @IBOutlet var detailTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let id = leg["bioguide_id"] as? String
        let imageurl = "https://theunitedstates.io/images/congress/original/" + id! + ".jpg"
        let i = URL(string: imageurl)
        let data = try? Data(contentsOf: i!)
        self.legImage.image = UIImage(data: data!)
        
        // Do any additional setup after loading the view.
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
        if let twitter = self.leg["twitter_id"] as! String? {
            twitterurl = URL(string: "https://www.twitter.com/" + twitter)!
        } else {
            twitterurl = URL(string: "N.A.")!
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
            if self.leg["chamber"] as! String? == "house" {
                cell.detail.text = "House"
            } else {
                cell.detail.text = "Senate"
            }
            break
        case "fax":
            cell.title.text = "Fax No."
            if let faxNo = self.leg[keys[indexPath.row]] as! String? {
                cell.detail.text = faxNo
            } else {
                cell.detail.text = "N.A."
            }
            break
        case "twitter_id":
            cell.title.text = "Twitter Link"
            cell.detail.text = twitterurl.absoluteString
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

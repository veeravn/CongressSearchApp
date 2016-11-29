//
//  BillDetailCell.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/18/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit

class BillDetailCell: UITableViewCell {

    @IBOutlet var pdf: UIButton!
    @IBOutlet var detail: UILabel!
    @IBOutlet var title: UILabel!
    var pdfurl : URL? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func openPDF(_ sender: Any) {
        if pdfurl != nil {
            UIApplication.shared.openURL(pdfurl!)
        }
    }
}

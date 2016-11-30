//
//  ImageHeaderCell.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 11/3/15.
//  Copyright © 2015 Yuji Hato. All rights reserved.
//

import UIKit

class ImageHeaderView : UIView {
    
    @IBOutlet weak var backgroundImage : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let i = URL(string: "http://opengovfoundation.org/assets/Sunlight-Foundation.png")
        let data = try? Data(contentsOf: i!)
        let sunImage = UIImage(data: data!)
        self.backgroundColor = UIColor(hex: "E0E0E0")
        self.backgroundImage.image = sunImage
    }
}

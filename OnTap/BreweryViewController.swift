//
//  BreweryViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 1/3/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire


class BreweryViewController: BaseInfoController
{
//    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var established: UITextView!
    @IBOutlet weak var location: UITextView!
    @IBOutlet weak var website: UITextView!
    @IBOutlet weak var descriptionText: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        var navBar = UINavigationBar()
        self.title = super.nameStr
        
        
        BreweryDBapi().searchBreweryByID(id) {
            (result: Dictionary<String,AnyObject>?) in
            self.setLabels(result!)
            self.image = result!["imageStr"] as String
            self.getLabelImage(self.image)
        }
        
    }
    
    func setLabels(data: NSDictionary)
    {
//        self.nameStr = data["name"] as String
        let description = data["description"] as String
        let website = data["website"] as String
//        let styleDescription = data["styleDescription"] as String
        let established = data["established"] as String
//        let city = data["city"] as String
//        let country = data["country"] as String
        self.image = data["imageStr"] as String
        
        BreweryDBapi().getLabelImage(self.image) {
            (newImage: UIImage) in
            var myImage = newImage
            self.labelImage.image = myImage
        }
        
        self.established.text = "Established: \(established)"
        self.website.text = "Web: \(website)"
//        self.location.text = "Location: \(city), \(country)"
        self.descriptionText.text = description
//        self.styleDescription.text = styleDescription
    }

}
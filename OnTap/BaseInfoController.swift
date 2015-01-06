//
//  BaseInfoController.swift
//  OnTap
//
//  Created by Nick Martinson on 1/3/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire

class BaseInfoController: UIViewController, UIScrollViewDelegate
{
    var request: Alamofire.Request?
    var image = ""
    var beerID = ""
    var nameStr:String = ""
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var labelImage: UIImageView!
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(true)
        scrollView.contentSize = UIScreen.mainScreen().bounds.size
        self.scrollView.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    
    /******************************************************************************************
    *   Prevents the scrollview from horizontal scrolling
    ******************************************************************************************/
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y)
    }

    /******************************************************************************************
    *
    ******************************************************************************************/
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func getLabelImage(imageStr: String)
    {
        Alamofire.request(.GET,imageStr).responseImage({ (request, _, image, error) -> Void in
            if error == nil && image != nil{
                self.labelImage.image = image
            }
        })
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func sidebarButtonPressed(sender: AnyObject)
    {
        revealViewController().revealToggle(sender)
    }
    
}
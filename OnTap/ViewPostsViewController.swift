//
//  ViewPostsViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 1/4/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ViewPostViewController: UIViewController
{
    var beerID = ""
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewWillAppear(animated: Bool)
    {
        var friendsRequest = FBRequest.requestForMyFriends()
        friendsRequest.startWithCompletionHandler { (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            if !(error != nil)
            {
                let resultDict = result as NSDictionary
                let data = resultDict["data"] as NSArray
                let element = data[0] as NSDictionary
                let id = element["id"] as String
                println("Result dic: \(data)")
            }
        }
        
        var postQuery = PFQuery(className: "Post")
        postQuery.whereKey("beerID", equalTo: beerID)
        postQuery.findObjectsInBackgroundWithBlock{
            (objects: [AnyObject]!, error: NSError!) -> Void in
            let results = objects as NSArray
            println(results)
            var yPos:CGFloat = 85.0
            for(var i = 0; i < results.count; i++)
            {
                let imageURL = results[i].objectForKey("imageURL") as String
                var image = UIImageView(frame: CGRectMake(16.0, yPos, 80.0, 50.0))
                self.getLabelImage(imageURL, newImage: image)
                var text = UITextView(frame: CGRectMake(115.0, yPos,460.0, 50.0))
                text.text = results[i].objectForKey("textContent") as String
                self.view.addSubview(text)
                self.view.addSubview(image)
                yPos += 70
            }
        }
        
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func backButtonPressed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func getLabelImage(imageStr: String, newImage: UIImageView)
    {
        Alamofire.request(.GET,imageStr).responseImage({ (request, _, image, error) -> Void in
            if error == nil && image != nil{
                newImage.image = image
            }
        })
    }
    
}
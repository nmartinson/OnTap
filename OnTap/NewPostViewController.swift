//
//  NewPostViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 1/4/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit

class NewPostViewController: UIViewController
{
    @IBOutlet weak var textField: UITextView!
    var beerID = ""
    
    override func viewWillAppear(animated: Bool) {
        textField.select(self)
        println(beerID)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject)
    {
        let post = textField.text
        
        if FBSession.activeSession().isOpen
        {
            FBRequest.requestForMe().startWithCompletionHandler{(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                if error == nil
                {
                    let user = result as NSDictionary
                    let facebookID = result["id"] as String
                    let imageURL = "http://graph.facebook.com/\(facebookID)/picture?type=large"
//                    println(user)
                    
                    var newPost = PFObject(className: "Post")
                    newPost.setObject(post, forKey: "textContent")
                    newPost.setObject(facebookID, forKey: "UID")
                    newPost.setObject(self.beerID, forKey: "beerID")
                    newPost.setObject(imageURL, forKey: "imageURL")
//                    newPost.setObject(PFUser.currentUser(), forKey: "postForBeer")
                    newPost.saveInBackgroundWithBlock{
                        (success: Bool, error: NSError!) -> Void in
                        if success
                        {
                            println("Dismiss")
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            })
                        }
                        else
                        {
                            println("Error \(error)")
                        }
                    }
                    
                }
            }
        }
        else
        {
            println("Not logged in")
        }
        
        

    }
    
}
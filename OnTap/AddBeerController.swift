//
//  AddBeerController.swift
//  OnTap
//
//  Created by Nick Martinson on 12/23/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AddBeerController: UIViewController
{
    @IBOutlet weak var beerNameText: UITextField!
    @IBOutlet weak var brewerNameText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var errorField: UILabel!
    var upc = ""
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewDidAppear(animated: Bool)
    {
        errorField.hidden = true
        println("add beer \(upc)")
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func submitButtonPressed(sender: AnyObject)
    {
        let name = self.beerNameText.text
        let brewer = self.brewerNameText.text
        var item = name.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        let price = self.priceText.text
        if(name != "")
        {
            var url = "http://www.outpan.com/api/edit-name.php?apikey=3a3657604cc7b7f103cfce13c9c01839&barcode=\(upc)&name=\(item)"
            
            Alamofire.request(.GET, url, parameters: nil).responseJSON{ (_,_, data, _) -> Void in }
            dismissViewControllerAnimated(true, completion: { () -> Void in
//                CodeViewController().callBreweryDB(name)
            })
        }
        else
        {
            errorField.hidden = false
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
}
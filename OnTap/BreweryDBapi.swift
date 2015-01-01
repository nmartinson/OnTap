//
//  BreweryDBapi.swift
//  OnTap
//
//  Created by Nick Martinson on 12/26/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

extension Alamofire.Request
{
    class func imageResponseSerializer() -> Serializer{
        return { request, response, data in
            if( data == nil) {
                return (nil,nil)
            }
            let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
            
            return (image, nil)
        }
    }
    
    func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self{
        return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
            completionHandler(request, response, image as? UIImage, error)
        })
    }
}

class BreweryDBapi
{
    /******************************************************************************************
    *
    ******************************************************************************************/
    func searchByID(id: String, completion:(result: Dictionary<String,AnyObject>?) -> Void)
    {
        var beerDict:Dictionary<String,AnyObject>?
        var brewURL = "http://api.brewerydb.com/v2/beers?ids=\(id)&type=beer&p=1&withBreweries=Y&key=dacc2d3e348d431bbe07adca89ac2113"
        Alamofire.request(.GET, brewURL, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
            let json = JSON(data!)
//            println(data)
            let totalResults = json["totalResults"].intValue
            
            if totalResults > 0
            {
                let description = json["data"][0]["description"].stringValue
                let styleDescription = json["data"][0]["style"]["description"].stringValue
                var abv:Float? = json["data"][0]["abv"].floatValue
                var ibu:Float? = json["data"][0]["ibu"].floatValue
                var name = json["data"][0]["name"].stringValue
                var imageStr = json["data"][0]["labels"]["medium"].stringValue
                
                //brewery info
                var breweryDesc = json["data"][0]["breweries"][0]["description"].stringValue
                breweryDesc = breweryDesc.stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString("\r", withString: "")
                let breweryEstablished = json["data"][0]["breweries"][0]["established"].stringValue
                let breweryImage = json["data"][0]["breweries"][0]["images"]["medium"].stringValue
                let breweryCountry = json["data"][0]["breweries"][0]["locations"][0]["country"]["displayName"].stringValue
                let breweryCity = json["data"][0]["breweries"][0]["locations"][0]["locality"].stringValue
                if abv == nil
                {
                    abv = 0
                }
                if ibu == nil
                {
                    ibu = 0
                }
                if imageStr == ""
                {
                    imageStr = "http://www.brewerydb.com/img/glassware/pint_medium.png"
                }
                
                beerDict = ["description": description, "styleDescription": styleDescription, "abv": abv!, "ibu": ibu!, "name": name, "imageStr": imageStr]
            }
            completion(result: beerDict)
        }
    }
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func searchByName(name: String, completion:(result: Dictionary<String,AnyObject>?) -> Void)
    {
        var beerDict:Dictionary<String,AnyObject>?
        var item = name
        item = item.stringByReplacingOccurrencesOfString(" ", withString: "+").lowercaseString
        
        var brewURL = "http://api.brewerydb.com/v2/search?q=\(item)&type=beer&p=1&key=dacc2d3e348d431bbe07adca89ac2113"
//        println(brewURL)
        Alamofire.request(.GET, brewURL, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
//            println(data)
            let json = JSON(data!)
            let description = json["data"][0]["description"].stringValue
            let styleDescription = json["data"][0]["style"]["description"].stringValue
            let name = json["data"][0]["name"].stringValue
            var abv:Float? = json["data"][0]["abv"].floatValue
            var ibu:Float? = json["data"][0]["ibu"].floatValue
            var imageStr = json["data"][0]["labels"]["medium"].stringValue
            var idStr = json["data"][0]["id"].stringValue
            if abv == nil
            {
                abv = 0
            }
            if ibu == nil
            {
                ibu = 0
            }

            if imageStr == ""
            {
                imageStr = "http://www.brewerydb.com/img/glassware/pint_medium.png"
            }
            beerDict = ["description": description, "styleDescription": styleDescription, "abv": abv!, "ibu": ibu!, "name": name, "imageStr": imageStr, "id": idStr]
        }
        println(beerDict)
        completion(result: beerDict)
    }
 
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func getLabelImage(imageStr: String, completion:(newImage: UIImage) -> Void)
    {
        var labelImage:UIImage = UIImage()
        
        Alamofire.request(.GET,imageStr).responseImage({ (request, _, image, error) -> Void in
            if error == nil && image != nil{
                labelImage = image!
            }
        })
        completion(newImage: labelImage)
    }
    
}



























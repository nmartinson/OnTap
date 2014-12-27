//
//  BreweryDBapi.swift
//  OnTap
//
//  Created by Nick Martinson on 12/26/14.
//  Copyright (c) 2014 Nick Martinson. All rights reserved.
//

import Foundation
import Alamofire

class BreweryDBapi
{
    /******************************************************************************************
    *
    ******************************************************************************************/
    func searchByID(id: String)
    {
        var brewURL = "http://api.brewerydb.com/v2/search?q=\(id)&type=beer&p=1&key=dacc2d3e348d431bbe07adca89ac2113"
        Alamofire.request(.GET, brewURL, parameters: nil).responseJSON{ (_,_, data, _) -> Void in
            println(data!)
            let json = JSON(data!)
            let totalResults = json["totalResults"].intValue
            
            if totalResults > 0
            {
                let description = json["data"][0]["description"].stringValue
                let styleDescription = json["data"][0]["style"]["description"].stringValue
                let abv = json["data"][0]["abv"].floatValue
                let ibu = json["data"][0]["ibu"].floatValue
                var name = json["data"][0]["name"].stringValue
                var image = json["data"][0]["labels"]["medium"].stringValue
            }
        }
        
    }

}
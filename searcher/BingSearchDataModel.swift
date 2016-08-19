//
//  BingSearchDataModel.swift
//  searcher
//
//  Created by Vlad Konon on 07.07.16.
//  Copyright © 2016 Vladimir Konon. All rights reserved.
//

import Foundation
/// model for respresenting search data
class BingSearchDataModel {
    let dateLastCrawled:NSDate?
    let displayUrl:String?
    let _id:String?
    let name:String?
    let snippet:String?
    let url:String?
    
    init(dictionary:NSDictionary){
        
        if let dateSting = dictionary["dateLastCrawled"] {
            let formater =  NSDateFormatter()
            formater.dateFormat = "yyyy-MM-dd'T'hh:mm:ss" // "2016-07-07T09:21:00"
            dateLastCrawled = formater.dateFromString(dateSting as! String)
        }
        else{
            dateLastCrawled = nil
        }
        displayUrl = dictionary["displayUrl"] as? String
        _id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        snippet = dictionary["snippet"] as? String
        url = dictionary["url"] as? String
    }
}
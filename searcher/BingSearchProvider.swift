//
//  BingSearchProvider.swift
//  searcher
//
//  Created by Vlad Konon on 07.07.16.
//  Copyright © 2016 Vladimir Konon. All rights reserved.
//

import Foundation

// api key - should use own  - get it https://www.microsoft.com/cognitive-services/en-us/bing-web-search-api

let kBingKey1 = "e946d9fdee814e469ecd73321145d7f1"

// search api gate
let kBingSearchURL = "https://api.cognitive.microsoft.com/bing/v5.0/search" //[?q][&count][&offset][&mkt][&safesearch]
class BingSearchProvider {
    static var searchProvider = BingSearchProvider() //static instance of provider
    /**
     Get search results from BING API
 
 
     Creates and sends BING API usage request
 
 
     @param query string of query
     @param count how limit count of query (default = 20)
     @param skip how much result skip from begining (default = 0)
     @param completion completion closure

    */
    func searchForString(query:String, count:Int = 20, skip:Int = 0, completion:([AnyObject]?,NSError?) -> Void) {

        if query.isEmpty || count == 0 {
            completion(nil,nil)
        }
        //set paramaters in url
        let queryString = String(format: kBingSearchURL+"?q=%@&count=%li&offset=%li",query,count,skip)
        let request = NSMutableURLRequest(URL: NSURL(string: queryString)!)
        // api key set
        request.addValue(kBingKey1, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        // we want json
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        // get method
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, responce, error) in
            let HTTPResponce = responce as? NSHTTPURLResponse
            var _result:[AnyObject]? = nil
            var _error = error
            // we should allways send completion
            defer {
                completion(_result,error)
            }
            if error == nil && HTTPResponce!.statusCode == 200 {
                if let _data = data  {
                    do {
                        //serializing response data
                        let serResult = try NSJSONSerialization.JSONObjectWithData(_data, options: NSJSONReadingOptions(rawValue: 0))
                        if let rDict = serResult as? [String:AnyObject]  {
                            
                            if let webPages = rDict["webPages"] as? [String:AnyObject]  {
                                // here array of results
                                if let valueArray = webPages["value"]{
                                    _result = valueArray as? [AnyObject];
                                }
                            }
                        }
                    }
                    catch let error as NSError{
                        // serializing error
                        _error = error
                    }
                }
            }
        }
        task.resume()
        
    }
}


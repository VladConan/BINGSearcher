//
//  DetailWebViewController.swift
//  searcher
//
//  Created by Vlad Konon on 07.07.16.
//  Copyright © 2016 Vladimir Konon. All rights reserved.
//

import UIKit

class DetailWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var url:NSURL? {
        didSet{
            // if web view is avalable load url
            if webView != nil{
                loadUrl()
            }
        }
    }
    func loadUrl(){
        if url  != nil {
            let request =  NSURLRequest(URL: url!)
            webView.loadRequest(request)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // show navigation bar hidden by search view
        navigationController?.navigationBarHidden = false
        //navigationController?.hidesBarsOnSwipe = false
        loadUrl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

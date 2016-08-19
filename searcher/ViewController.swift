//
//  ViewController.swift
//  searcher
//
//  Created by Vladimir Konon on 7/6/16.
//  Copyright © 2016 Vladimir Konon. All rights reserved.
//

import UIKit

let kSeachCellIdentifer = "searchCell"
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,UIGestureRecognizerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bottomConstrait: NSLayoutConstraint!

    var searchData:[BingSearchDataModel]?
    var lastSearchString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Back to results"
        navigationController?.navigationBarHidden = true
        searchBar.delegate = self
        // adding search bar to navigation bar to be able show/hide it while scrolling  
//        let _searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: self.view.frame.width,height: 44))
//        self.navigationItem.titleView = _searchBar
//        searchBar = _searchBar
//        searchBar.delegate = self
//        searchBar.placeholder = "Search"
        
        // adding keyboard show/hide notification
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification)
        }
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidHideNotification, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification)
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         navigationController?.navigationBarHidden = true
        //navigationController?.hidesBarsOnSwipe = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchData != nil {
            return searchData!.count
        }
        return 0  // only for test
    }
    // setup cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kSeachCellIdentifer, forIndexPath: indexPath) as! SearchTableViewCell
        // load model to cell
        if let model = searchData?[indexPath.row]{
            cell.titleLabel.text = model.name
            cell.briefLabel.text = model.snippet
            if indexPath.row == searchData!.count-1 {
                // in case of last row load more data
                loadData()
            }
        }
        // remove delimiter offset
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }
    // If this code is absent UITableView fills down with empty cell and draws delimiter for each
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil;
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil;
    }
    // show details on cell tap
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !searchBar.isFirstResponder() {
            // if no keyboard start segue immediately
            self.performSegueWithIdentifier("showDetail", sender: indexPath)
        }
        else{
            // else delay then start
            searchBar.resignFirstResponder()
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("showDetail", sender: indexPath)
            });
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showDetail" {
            // if showing detail set URL for detail view
            if let path = sender as! NSIndexPath? {
                let model = self.searchData![path.row]
                if let url = model.url {
                    let controller  = segue.destinationViewController as! DetailWebViewController
                    controller.url = NSURL(string: url,
                                           relativeToURL: nil);
                }
                tableView.deselectRowAtIndexPath(path, animated: true)
                
            }
        }
    }
    // hiding kayboard if search started
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if (searchBar.text!.isEmpty){
            // reset data if empty search
            self.searchData = nil
            lastSearchString = nil
            tableView.reloadData()
        }
        else{
            if let searchString = searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())
            {
                if lastSearchString != searchString {
                    // reset if new search string
                    searchData = nil
                }
                lastSearchString = searchString
                loadData()
            }
            
        }
        searchBar.resignFirstResponder()
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // reset last search string
        lastSearchString = nil
    }
    func loadData()  {
        var skip:Int = 0
        if searchData != nil{
            // need skip if not first page
            skip = searchData!.count
        }
        if lastSearchString != nil {
            BingSearchProvider.searchProvider.searchForString(lastSearchString!, count: 20, skip: skip) { (result, error) in
                if error == nil {
                    if result != nil {
                        var needScrollToTop = false
                        if self.searchData == nil {
                            self.searchData = [BingSearchDataModel]()
                            needScrollToTop = true
                        }
                        for data in result! {
                            let model = BingSearchDataModel(dictionary: data as! NSDictionary)
                            self.searchData!.append(model)
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                            // if we somewhere lower and new search results loaded: scroll to top
                            if needScrollToTop {
                                self.tableView.scrollRectToVisible(CGRectMake(0.0,0.0, self.tableView.frame.width, 44), animated: true);
                            }
                        })
                        
                    }
                }
                else {
                    print(error?.localizedDescription)
                }
            }
        }
    }
    // retrieving back search field if dragging back table view
//    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if velocity.y < -1.1 {
//            navigationController?.setNavigationBarHidden(false, animated: true)
//        }
//    }
    // MARK: keyboard hide/show notification to set bottom offset
    var kbSize = CGSizeZero
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo:NSDictionary = notification.userInfo!
        kbSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)!.CGRectValue().size
        let time:Double =  userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        var curve:UInt = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.unsignedIntegerValue;
        curve = curve << 16;
        UIView.animateWithDuration(time, delay: 0, options: [.LayoutSubviews, UIViewAnimationOptions(rawValue:curve)], animations: {
                self.bottomConstrait.constant = self.kbSize.height
            }, completion: nil)

    }
    @objc func keyboardWillHide(notification:NSNotification){
        let userInfo:NSDictionary = notification.userInfo!
        let time:Double =  userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        var curve:UInt = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.unsignedIntegerValue;
        curve = curve << 16;
        UIView.animateWithDuration(time, delay: 0, options: [.LayoutSubviews,UIViewAnimationOptions(rawValue:curve)], animations: {
            self.bottomConstrait.constant = 0
            }, completion: nil)
    }
}


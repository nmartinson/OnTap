//
//  PlaceWebViewController.swift
//  OnTap
//
//  Created by Nick Martinson on 1/26/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation


class PlaceWebViewController: UIViewController, UIWebViewDelegate
{
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var webViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var webView: UIWebView!
    var url = ""
    var navTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = navTitle
        let URLRequest = NSURL(string: url)
        let request = NSURLRequest(URL: URLRequest!)
        webView.loadRequest(request)
    }
    
    @IBAction func backButtonPressed(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in })
    }
 
    func webViewDidFinishLoad(webView: UIWebView) {
        // elements 87, 89, 202
        let jsCommand = "var element = document.getElementById('87'); element.parentElement.removeChild(element);"
        let jsHREFCommand = "document.getElementById('18').getAttribute('href');"
        webView.stringByEvaluatingJavaScriptFromString(jsCommand)
//        let href = webView.stringByEvaluatingJavaScriptFromString(jsHREFCommand)
//        println("href: \(href)")
        webViewTopConstraint.constant = 46.0
        webView.updateConstraints()
    }
    
    
    
}
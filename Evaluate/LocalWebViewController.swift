//
//  LocalWebViewController.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-25.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import UIKit

class LocalWebViewController : UIViewController {
	@IBOutlet var webView: UIWebView?
	
	var urlToDisplay: URL? {
		didSet {
			applyURL()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		applyURL()
	}
	
	fileprivate func applyURL() {
		if let url = urlToDisplay {
			self.navigationItem.title = url.lastPathComponent.components(separatedBy: ".").first
			
			let request = URLRequest(url: url)
			webView?.loadRequest(request)
		}
	}
}

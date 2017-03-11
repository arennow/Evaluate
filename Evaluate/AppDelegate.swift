//
//  AppDelegate.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-18.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow? {
		didSet {
			if let window = window, let recs = window.gestureRecognizers {
				for rec in recs {
					if rec.delaysTouchesBegan {
						rec.delaysTouchesBegan = false
					}
				}
			}
		}
	}
}

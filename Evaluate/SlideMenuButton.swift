//
//  SlideMenuButton.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-25.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import UIKit

class SlideMenuButton : UIButton {
	var menuController: SlideMenuTableViewController?
	private var menuIsVisible = false
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		commonInitialization()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonInitialization()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		commonInitialization()
	}
	
	private func commonInitialization() {
		self.addTarget(self, action: "touchDown", forControlEvents: .TouchDown)
		self.addTarget(self, action: "touchUp", forControlEvents: .TouchUpInside)
		self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "infoPan:"))
	}
	
	@objc private func touchDown() {
		appearMenu()
	}
	
	@objc private func touchUp() {
		disappearMenu()
	}
	
	@objc private func infoPan(gesture: UIPanGestureRecognizer) {
		switch gesture.state {
		case .Began:
			appearMenu()
			
		case .Ended:
			if let mc = menuController, let selectedIP = mc.tableView.indexPathForSelectedRow() {
				mc.tableView.delegate?.tableView!(mc.tableView, didSelectRowAtIndexPath: selectedIP)
			}
			
			fallthrough
		case .Cancelled:
			fallthrough
		case .Failed:
			disappearMenu();
			return
			
		case .Possible:
			println("\(__FUNCTION__): \(gesture.state.rawValue) happened. Odd.")
			return
			
		case .Changed:
			break
		}
		
		let loc = gesture.locationInView(menuController?.view)
		
		if let mc = menuController {
			if mc.view.bounds.contains(loc) {
				let indexPathUnderFinger = mc.tableView.indexPathForRowAtPoint(loc)
				mc.tableView.selectRowAtIndexPath(indexPathUnderFinger, animated: false, scrollPosition: .Top)
			} else {
				if let selected = mc.tableView.indexPathForSelectedRow() {
					mc.tableView.deselectRowAtIndexPath(selected, animated: false)
				}
			}
		}
	}
	
	private func appearMenu() {
		if let mc = menuController where !menuIsVisible {
			mc.view.transform = CGAffineTransformMakeScale(1, 1)
			var frame = CGRect(origin: self.frame.origin, size: mc.preferredSize)
			frame.origin.y -= frame.size.height
			
			mc.view.frame = frame
			mc.view.center = mc.view.frame.pointInCorner(.Bottom, .Left)
			mc.view.transform = CGAffineTransformMakeScale(0.001, 0.001)

			self.superview?.addSubview(mc.view)

			UIView.animateWithDuration(0.333) {
				mc.view.transform = CGAffineTransformMakeScale(1, 1)
				mc.view.frame = frame
			}
			
			menuIsVisible = true
		}
	}
	
	private func disappearMenu() {
		if let mc = menuController where menuIsVisible {
			UIView.animateWithDuration(0.333,
				animations: {
					mc.view.center = mc.view.frame.pointInCorner(.Bottom, .Left)
					mc.view.transform = CGAffineTransformMakeScale(0.001, 0.001)
				},
				completion: { (_) -> Void in
					mc.view.removeFromSuperview()
					self.menuIsVisible = false
				}
			)
		}
	}
}
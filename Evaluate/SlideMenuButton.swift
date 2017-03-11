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
	fileprivate var menuIsVisible = false
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.commonInitialization()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.commonInitialization()
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.commonInitialization()
	}
	
	fileprivate func commonInitialization() {
		self.addTarget(self, action: #selector(SlideMenuButton.touchDown), for: .touchDown)
		self.addTarget(self, action: #selector(SlideMenuButton.touchUp), for: .touchUpInside)
		self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(SlideMenuButton.infoPan(_:))))
	}
	
	@objc fileprivate func touchDown() {
		self.appearMenu()
	}
	
	@objc fileprivate func touchUp() {
		self.disappearMenu()
	}
	
	@objc fileprivate func infoPan(_ gesture: UIPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			self.appearMenu()
			
		case .ended:
			if let mc = self.menuController, let selectedIP = mc.tableView.indexPathForSelectedRow {
				mc.tableView.delegate?.tableView!(mc.tableView, didSelectRowAt: selectedIP)
			}
			
			fallthrough
		case .cancelled:
			fallthrough
		case .failed:
			disappearMenu();
			return
			
		case .possible:
			print("\(#function): \(gesture.state.rawValue) happened. Odd.")
			return
			
		case .changed:
			break
		}
		
		let loc = gesture.location(in: self.menuController?.view)
		
		if let mc = self.menuController {
			if mc.view.bounds.contains(loc) {
				let indexPathUnderFinger = mc.tableView.indexPathForRow(at: loc)
				mc.tableView.selectRow(at: indexPathUnderFinger, animated: false, scrollPosition: .top)
			} else {
				if let selected = mc.tableView.indexPathForSelectedRow {
					mc.tableView.deselectRow(at: selected, animated: false)
				}
			}
		}
	}
	
	fileprivate func appearMenu() {
		if let mc = self.menuController, !self.menuIsVisible {
			mc.view.transform = CGAffineTransform(scaleX: 1, y: 1)
			var frame = CGRect(origin: self.frame.origin, size: mc.preferredSize)
			frame.origin.y -= frame.size.height
			
			mc.view.frame = frame
			mc.view.center = mc.view.frame.pointInCorner(.bottom, .left)
			mc.view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)

			self.superview?.addSubview(mc.view)

			UIView.animate(withDuration: 0.333, animations: {
				mc.view.transform = CGAffineTransform(scaleX: 1, y: 1)
				mc.view.frame = frame
			}) 
			
			self.menuIsVisible = true
		}
	}
	
	fileprivate func disappearMenu() {
		if let mc = self.menuController, self.menuIsVisible {
			UIView.animate(withDuration: 0.333,
				animations: {
					mc.view.center = mc.view.frame.pointInCorner(.bottom, .left)
					mc.view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
				},
				completion: { (_) -> Void in
					mc.view.removeFromSuperview()
					self.menuIsVisible = false
				}
			)
		}
	}
}

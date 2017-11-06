//
//  SlideMenuButton.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-25.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import UIKit

class SlideMenuButton : UIButton {
	var rootConfiguration = Array<SlideMenuTableViewController.CellConfiguration>()
	private var menuControllers = Array<SlideMenuTableViewController>()
	
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
	
	private func commonInitialization() {
		self.addTarget(self, action: #selector(SlideMenuButton.touchDown), for: .touchDown)
		self.addTarget(self, action: #selector(SlideMenuButton.touchUp), for: .touchUpInside)
		self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(SlideMenuButton.infoPan(_:))))
	}
	
	@objc private func touchDown() {
		guard self.menuControllers.isEmpty else { return }
		
		let newMenu = SlideMenuTableViewController(cellConfigurations: self.rootConfiguration)
		self.menuControllers.append(newMenu)
		newMenu.presentAgainst(self)
	}
	
	@objc private func touchUp() {
		self.disappearMenu()
	}
	
	private func disappearMenu() {
		func disappearLast(from arr: Array<SlideMenuTableViewController>, completion: @escaping ()->Void) {
			if let last = arr.last {
				last.disappear(atSpeed: .fast, completion: {
					disappearLast(from: Array(arr.dropLast()), completion: completion)
				})
			} else {
				completion()
			}
		}

		let menusToDisappear = self.menuControllers
		
		disappearLast(from: menusToDisappear) {
			self.menuControllers.removeAll()
		}
	}
	
	@objc private func infoPan(_ gesture: UIPanGestureRecognizer) {
		switch gesture.state {
		case .began:
			return
			
		case .ended:
			if let mc = self.menuControllers.last, let selectedIP = mc.tableView.indexPathForSelectedRow {
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
		
		let locInSuperview = gesture.location(in: self.superview)
		
		let mc = self.menuControllers.reversed().first(where: { $0.view.frame.contains(locInSuperview) })
		
		if let mc = mc {
			func submenuConfigs(for indexPath: IndexPath) -> Array<SlideMenuTableViewController.CellConfiguration>? {
				if let config = mc.cellConfigurations.optionalValue(at: indexPath.row), case let .submenu(submenuConfigs) = config.behavior {
					return submenuConfigs
				} else {
					return nil
				}
			}
			
			let locInMC = gesture.location(in: mc.view)
			let indexPathUnderFinger = mc.tableView.indexPathForRow(at: locInMC)
			
			if let indexPathUnderFinger = indexPathUnderFinger {
				mc.tableView.selectRow(at: indexPathUnderFinger, animated: false, scrollPosition: .none)
				
				if self.menuControllers.last == mc, let configs = submenuConfigs(for: indexPathUnderFinger) {
					let newMenu = SlideMenuTableViewController(cellConfigurations: configs)
					newMenu.originatingIndexPath = indexPathUnderFinger
					self.menuControllers.append(newMenu)
					newMenu.presentAgainst(indexPathUnderFinger, ofOtherMenuVC: mc)
				}
			}
			
			if let mcIndex = self.menuControllers.index(of: mc) {
				for afterMC in self.menuControllers.dropFirst(mcIndex+1).reversed() {
					afterMC.deselectAllRows()
					
					if afterMC.originatingIndexPath == indexPathUnderFinger {
						continue
					}
					
					afterMC.disappear(completion: nil)
					self.menuControllers.removeLast()
				}
			}
		}
	}
}

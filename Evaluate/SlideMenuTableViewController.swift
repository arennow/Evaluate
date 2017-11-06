//
//  SlideMenuTableViewController.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-30.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import UIKit

class SlideMenuTableViewController: UITableViewController {
	struct CellConfiguration {
		enum Behavior {
			case action(() -> Void)
			case submenu(Array<CellConfiguration>)
		}
		
		let title: String
		let behavior: Behavior
		
		init(_ title: String, _ behavior: Behavior) {
			self.title = title
			self.behavior = behavior
		}
	}
	
	fileprivate enum PresentationStyle {
		case view, otherMenu
	}
	
	fileprivate static let cellIdentifier = "cell"
	fileprivate var presentationStyle: PresentationStyle?
	
	var cellConfigurations: Array<CellConfiguration>
	var originatingIndexPath: IndexPath?
	var isVisible: Bool { return self.presentationStyle != nil }
	var preferredSize: CGSize {
		return CGSize(width: 150, height: 44 * CGFloat(self.cellConfigurations.count))
	}
	
	init(cellConfigurations: Array<CellConfiguration>) {
		self.cellConfigurations = cellConfigurations
		
		super.init(style: .plain)
	}
	
	required convenience init?(coder aDecoder: NSCoder) {
		self.init(cellConfigurations: [])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: SlideMenuTableViewController.cellIdentifier)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.cellConfigurations.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SlideMenuTableViewController.cellIdentifier)!
		
		if let cellConfig = self.cellConfigurations.optionalValue(at: indexPath.row) {
			cell.textLabel!.text = cellConfig.title
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cellConfig = self.cellConfigurations.optionalValue(at: indexPath.row), case let .action(closure) = cellConfig.behavior {
			closure()
		}
	}
	
	func deselectAllRows() {
		if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: selectedIndexPath, animated: false)
		}
	}
}

extension SlideMenuTableViewController {
	enum AnimationSpeed: TimeInterval {
		case normal = 0.333
		case fast = 0.1666
	}
	
	func presentAgainst(_ view: UIView) {
		guard !self.isVisible else { return }
		
		self.view.translatesAutoresizingMaskIntoConstraints = true
		
		self.view.transform = CGAffineTransform.identity
		var frame = CGRect(origin: view.frame.origin, size: self.preferredSize)
		frame.origin.y -= frame.size.height
		
		self.view.frame = frame
		self.view.center = self.view.frame.pointInCorner(.bottom, .left)
		self.view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
		
		view.superview?.addSubview(self.view)
		
		UIView.animate(withDuration: 0.333, animations: {
			self.view.transform = CGAffineTransform.identity
			self.view.frame = frame
		})
		
		self.presentationStyle = .view
	}
	
	func presentAgainst(_ indexPath: IndexPath, ofOtherMenuVC otherMenuVC: SlideMenuTableViewController) {
		guard !self.isVisible else { return }
		guard otherMenuVC.isVisible else { return }
		
		self.presentationStyle = .otherMenu
		
		self.view.translatesAutoresizingMaskIntoConstraints = false
		otherMenuVC.view.superview?.addSubview(self.view)
		
		let presentingCell = otherMenuVC.tableView.cellForRow(at: indexPath)!
		
		let submenuSize = self.preferredSize
		
		let views: Dictionary<String, UIView> = ["other": otherMenuVC.view, "submenu": self.view]
		let metrics: Dictionary<String, NSNumber> = ["width": submenuSize.width as NSNumber, "height": submenuSize.height as NSNumber]
		
		var constraints = Array<NSLayoutConstraint>()
		constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[other][submenu(width)]",
		                                                              options: [],
		                                                              metrics: metrics,
		                                                              views: views))
		constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[submenu(height)]",
		                                                              options: [],
		                                                              metrics: metrics,
		                                                              views: views))
		constraints.append(NSLayoutConstraint(item: self.view,
		                                      attribute: .top,
		                                      relatedBy: .equal,
		                                      toItem: presentingCell,
		                                      attribute: .top,
		                                      multiplier: 1,
		                                      constant: 0))
		
		NSLayoutConstraint.activate(constraints)
		
		self.presentationStyle = .otherMenu
	}
	
	func disappear(atSpeed speed: AnimationSpeed = .normal, completion: (()->Void)?) {
		guard let presentationStyle = self.presentationStyle else { return }
		
		let verticalSide: CGRect.VerticalSide
		
		switch presentationStyle {
		case .view:
			verticalSide = .bottom
		case .otherMenu:
			verticalSide = .top
		}
		
		UIView.animate(withDuration: speed.rawValue,
					   animations: {
						self.view.center = self.view.frame.pointInCorner(verticalSide, .left)
						self.view.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
		},
					   completion: { (_) -> Void in
						self.view.removeFromSuperview()
						self.presentationStyle = nil
						completion?()
		})
	}
}

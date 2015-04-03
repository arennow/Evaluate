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
		let title: String
		let action: (String -> Void)?
	}
	
	private static let cellIdentifier = "cell"
	var cellConfigurations = [CellConfiguration]()
	var preferredSize: CGSize {
		return CGSize(width: 200, height: 44 * CGFloat(cellConfigurations.count))
	}
	
	convenience init(cellConfigurations: [CellConfiguration]) {
		self.init()
		
		self.cellConfigurations = cellConfigurations
	}
	
	override func viewDidLoad() {
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: SlideMenuTableViewController.cellIdentifier)
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cellConfigurations.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(SlideMenuTableViewController.cellIdentifier) as! UITableViewCell
		
		if let cellConfig = cellConfigurations.objectOrNilAtIndex(indexPath.row) {
			cell.textLabel!.text = cellConfig.title
		}
		
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let cellConfig = cellConfigurations.objectOrNilAtIndex(indexPath.row), let action = cellConfig.action {
			action(cellConfig.title)
		}
	}
}
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
		let action: ((String) -> Void)?
	}
	
	fileprivate static let cellIdentifier = "cell"
	var cellConfigurations = [CellConfiguration]()
	var preferredSize: CGSize {
		return CGSize(width: 200, height: 44 * CGFloat(cellConfigurations.count))
	}
	
	convenience init(cellConfigurations: [CellConfiguration]) {
		self.init()
		
		self.cellConfigurations = cellConfigurations
	}
	
	override func viewDidLoad() {
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: SlideMenuTableViewController.cellIdentifier)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cellConfigurations.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SlideMenuTableViewController.cellIdentifier)!
		
		if let cellConfig = cellConfigurations.optionalValue(at: indexPath.row) {
			cell.textLabel!.text = cellConfig.title
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cellConfig = cellConfigurations.optionalValue(at: indexPath.row), let action = cellConfig.action {
			action(cellConfig.title)
		}
	}
}

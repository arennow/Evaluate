//
//  Convenience.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-25.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import UIKit

extension UIViewController {
	@IBAction func dismiss() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
}

extension CGRect {
	enum VerticalSide {
		case Top, Bottom
	}
	
	enum HorizontalSide {
		case Left, Right
	}
	
	func pointInCorner(vert: VerticalSide, _ horiz: HorizontalSide) -> CGPoint {
		return CGPoint(
			x: horiz == .Left ? self.minX : self.maxX,
			y: vert == .Top ? self.minY : self.maxY)
	}
}

func performBlockOnMainThreadAfterDelay(delay: Double, block: Void -> Void) {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
}

func <<<T>(inout lhs: [T], rhs: T) {
	lhs.append(rhs)
}

func +=<T>(inout lhs: [T], rhs: [T]) {
	lhs = lhs+rhs
}
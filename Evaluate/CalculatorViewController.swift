//
//  CalculatorViewController.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-18.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import UIKit
import iAd

func +<K, V>(lhs: Dictionary<K, V>, rhs: Dictionary<K, V>) -> Dictionary<K, V> {
	var outDict = Dictionary<K,V>()
	
	for (k, v) in lhs {
		outDict[k] = v
	}
	
	for (k, v) in rhs {
		outDict[k] = v
	}
	
	return outDict
}

class CalculatorViewController: UIViewController, ADBannerViewDelegate, UITextFieldDelegate {
	@IBOutlet var inputTextField: UITextField!
	@IBOutlet var outputTextScrollView: UIScrollView!
	@IBOutlet var bannerViewTopMarginConstraint: NSLayoutConstraint!
	@IBOutlet var bannerView: ADBannerView!
	@IBOutlet var infoButton: SlideMenuButton!
	let muParserWrapper = MuParserWrapper()
	var lastInput = String()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Disable system keyboard
		inputTextField.inputView = UIView(frame: CGRect(origin: CGPointZero, size: CGSizeZero))
		inputTextField.tintColor = UIColor.darkGrayColor()
		infoButton.backgroundColor = outputTextScrollView.backgroundColor
		
		let action = {
			(str: String) -> Void in
			println("You tapped \(str)")
		}
		
		infoButton.menuController = SlideMenuTableViewController(cellConfigurations:
			[
				SlideMenuTableViewController.CellConfiguration(title: "Ad-Free Upgrade", action: action),
				SlideMenuTableViewController.CellConfiguration(title: "Legal", action: {
					[weak self]
					_ in

					if let this = self {
						this.performSegueWithIdentifier(R.segue.localWebView, sender: this)
					}
				}),
				SlideMenuTableViewController.CellConfiguration(title: "Last", action: {
					[weak self]
					_ in
					
					if let this = self {
						this.inputTextField.text = this.lastInput
					}
				})
			]
		)
	}
	
	@IBAction func inputButtonPushed(sender: UIButton) {
		inputTextField.text! += sender.currentTitle!
	}
	
	@IBAction func equalsButtonPushed() {
		let typedExpression = inputTextField.text
		
		if typedExpression.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
			lastInput = typedExpression
		}
		
		switch muParserWrapper.evaluate(lastInput) {
		case .Success(let result, let mangledExpression):
			inputTextField.text = nil
			
			addExpression(mangledExpression, andResultToDisplay: result)
			
		case .Failure(let errorMessage):
			let alertController = UIAlertController(title: "Syntax Error", message: errorMessage, preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
			
			self.presentViewController(alertController, animated: true, completion: nil)
		}
		
		scrollToBottomOfScrollView()
	}
	
	@IBAction func deleteButtonPushed() {
		var currentString = inputTextField.text!
		
		if currentString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
			if let selectedRange = inputTextField.selectedTextRange {
				if selectedRange.empty {
					inputTextField.deleteBackward()
				} else {
					inputTextField.replaceRange(selectedRange, withText: "")
				}
			} else {
				currentString.removeAtIndex(currentString.endIndex.predecessor())
				
				// This shouldn't be necessary. It's probably a bug that it is, but whatever
				dispatch_async(dispatch_get_main_queue()) {
					self.inputTextField.text = currentString
				}
			}
		}
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
	override func shouldAutorotate() -> Bool {
		return true
	}
	
	func bannerViewDidLoadAd(banner: ADBannerView!) {
		bannerViewTopMarginConstraint.constant = 0
		CalculatorViewController.animateConstraintChangesInView(banner)
		scrollToBottomOfScrollView()
	}
	
	func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
		bannerViewTopMarginConstraint.constant = -banner.frame.size.height
		CalculatorViewController.animateConstraintChangesInView(banner)
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		self.equalsButtonPushed()
		
		return true
	}
	
	private func addExpression(expression: String, andResultToDisplay result: Double) {
		func appendString(string: NSAttributedString) {
			func sizeOfString(string: NSAttributedString) -> CGSize {
				var rect = string.boundingRectWithSize(CGSize(width: outputTextScrollView.frame.size.width, height: 0),
					options: .UsesLineFragmentOrigin | .UsesFontLeading,
					context: nil)
				
				rect.size.width = outputTextScrollView.frame.size.width - 10 // For the scroll bar and equal space on the other side
				
				return rect.size
			}
			
			let previousContentSize = outputTextScrollView.contentSize
			let additionSize = sizeOfString(string)
			
			let label = UILabel(frame: CGRect(origin: CGPoint(x: 5 /* to counter the space for the scroll bar */, y: previousContentSize.height),
				size: additionSize))
			label.attributedText = string
			
			outputTextScrollView.addSubview(label)
			outputTextScrollView.contentSize.height = previousContentSize.height+additionSize.height
		}
		
		let basicAttributes: [NSObject : AnyObject] = [
			NSForegroundColorAttributeName : UIColor.whiteColor(),
			NSFontAttributeName : UIFont.systemFontOfSize(inputTextField.font.pointSize)
		]
		
		let leftAlignmentAttributes: [NSObject : AnyObject] = [
			NSParagraphStyleAttributeName : {let x = NSMutableParagraphStyle();x.alignment = .Left; return x}()
		]
		
		let rightAlignmentAttributes: [NSObject: AnyObject] = [
			NSParagraphStyleAttributeName : {let x = NSMutableParagraphStyle();x.alignment = .Right; return x}()
		]
	
		let expressionAttributedString = NSAttributedString(string: expression, attributes: basicAttributes + leftAlignmentAttributes)
		
		let answerString = NSString(format: "%g", result) as String
		
		let answerAttributedString = NSAttributedString(string: answerString, attributes: basicAttributes + rightAlignmentAttributes)
		
		appendString(expressionAttributedString)
		appendString(answerAttributedString)
	}
	
	private func scrollToBottomOfScrollView() {
		if outputTextScrollView.contentSize.height > outputTextScrollView.frame.size.height {
			outputTextScrollView.setContentOffset(CGPoint(x: 0, y: outputTextScrollView.contentSize.height - outputTextScrollView.frame.size.height), animated: true)
		}
	}
	
	private static func animateConstraintChangesInView(view: UIView) {
		UIView.animateWithDuration(0.333) {
			view.superview?.layoutIfNeeded()
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == R.segue.localWebView {
			if let navCon = segue.destinationViewController as? UINavigationController, let webVC = navCon.childViewControllers.first as? LocalWebViewController {
				webVC.urlToDisplay = NSBundle.mainBundle().URLForResource("Legal", withExtension: "html")
			}
		}
	}
}
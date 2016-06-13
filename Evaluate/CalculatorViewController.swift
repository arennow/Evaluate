//
//  CalculatorViewController.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-18.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import UIKit

func +<K, V>(lhs: Dictionary<K, V>, rhs: Dictionary<K, V>) -> Dictionary<K, V> {
	var outDict = lhs
	
	for (k, v) in rhs {
		outDict[k] = v
	}
	
	return outDict
}

postfix operator =! {}

class CalculatorViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet var inputTextField: UITextField!
	@IBOutlet var outputTextScrollView: UIScrollView!
	@IBOutlet var infoButton: SlideMenuButton!
	let muParserWrapper = MuParserWrapper()
	
	var lastInput = String()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Disable system keyboard
		inputTextField.inputView = UIView(frame: CGRect(origin: CGPointZero, size: CGSizeZero))
		inputTextField.tintColor = UIColor.darkGrayColor()
		infoButton.backgroundColor = outputTextScrollView.backgroundColor
		
		infoButton.menuController = SlideMenuTableViewController(cellConfigurations:
			[
				.init(title: "Legal", action: {
					[weak self]
					_ in

					if let this = self {
						this.performSegueWithIdentifier(R.segue.calculatorViewController.localWebView, sender: this)
					}
				}),
				.init(title: "Clear", action: {
					[weak self]
					_ in
					
					if let this = self {
						this.clearScrollView()
					}
				}),
				.init(title: "Last", action: {
					[weak self]
					_ in
					
					if let this = self {
						this.inputTextField.text = this.lastInput
					}
				})
			]
		)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		inputTextField.becomeFirstResponder()
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		
		coordinator.animateAlongsideTransition({ (_) -> Void in
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
	
	@IBAction func inputButtonPushed(sender: UIButton) {
		let insertionText = sender.currentTitle!
		
		if let range = inputTextField.selectedTextRange {
			inputTextField.replaceRange(range, withText: insertionText)
		} else {
			inputTextField.text! += insertionText
		}
	}
	
	@IBAction func equalsButtonPushed() {
		let typedExpression = inputTextField.text!
		
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
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		self.equalsButtonPushed()
		
		return true
	}
	
	private func addExpression(expression: String, andResultToDisplay result: Double) {
		func appendString(string: NSAttributedString) {
			func sizeOfString(string: NSAttributedString) -> CGSize {
				var rect = string.boundingRectWithSize(CGSize(width: outputTextScrollView.frame.size.width, height: 0),
					options: [.UsesLineFragmentOrigin, .UsesFontLeading],
					context: nil)
				
				rect.size.width = outputTextScrollView.frame.size.width - 10 // For the scroll bar and equal space on the other side
				
				return rect.size
			}
			
			let previousContentSize = outputTextScrollView.contentSize
			let additionSize = sizeOfString(string)
			
			let label = UILabel(frame: CGRect(origin: CGPoint(x: 5 /* to counter the space for the scroll bar */, y: previousContentSize.height),
				size: additionSize))
			label.attributedText = string
			label.autoresizingMask = .FlexibleWidth
			
			outputTextScrollView.addSubview(label)
			outputTextScrollView.contentSize.height = previousContentSize.height+additionSize.height
		}
		
		let basicAttributes: [String : AnyObject] = [
			NSForegroundColorAttributeName : UIColor.whiteColor(),
			NSFontAttributeName : inputTextField.font!
		]
		
		let leftAlignmentAttributes: [String : AnyObject] = [
			NSParagraphStyleAttributeName : {let x = NSMutableParagraphStyle();x.alignment = .Left; return x}()
		]
		
		let rightAlignmentAttributes: [String: AnyObject] = [
			NSParagraphStyleAttributeName : {let x = NSMutableParagraphStyle();x.alignment = .Right; return x}()
		]
		
		let expressionAttributedString = NSAttributedString(string: expression, attributes: basicAttributes + leftAlignmentAttributes)
		
		let answerString = String(format: "%g", result)
		
		let answerAttributedString = NSAttributedString(string: answerString, attributes: basicAttributes + rightAlignmentAttributes)
		
		appendString(expressionAttributedString)
		appendString(answerAttributedString)
	}
	
	private func scrollToBottomOfScrollView() {
		if outputTextScrollView.contentSize.height > outputTextScrollView.frame.size.height {
			UIView.animate(duration: 1.0/3.0, options: .BeginFromCurrentState) {
				let offset = CGPoint(x: 0, y: self.outputTextScrollView.contentSize.height - self.outputTextScrollView.frame.size.height)
				self.outputTextScrollView.setContentOffset(offset, animated: false)
			}
		}
	}
	
	private func clearScrollView() {
		for view in self.outputTextScrollView.subviews where view is UILabel {
			view.removeFromSuperview()
		}
		self.outputTextScrollView.contentSize = CGSize.zero
	}
	
	private static func animateConstraintChangesInView(view: UIView, completion: ((Bool) -> Void)? = nil) {
		UIView.animateWithDuration(0.333,
			delay: 0,
			options: .BeginFromCurrentState,
			animations: {
				view.superview?.layoutIfNeeded()
			},
			completion: completion)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == R.segue.calculatorViewController.localWebView.identifier {
			if let navCon = segue.destinationViewController as? UINavigationController, let webVC = navCon.childViewControllers.first as? LocalWebViewController {
				webVC.urlToDisplay = NSBundle.mainBundle().URLForResource("Legal", withExtension: "html")
			}
		}
	}
}
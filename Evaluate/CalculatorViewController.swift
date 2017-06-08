//
//  CalculatorViewController.swift
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-18.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet fileprivate var inputTextField: UITextField!
	@IBOutlet fileprivate var outputTextScrollView: UIScrollView!
	@IBOutlet private var infoButton: SlideMenuButton!
	let muParserWrapper = MuParserWrapper()
	
	var lastInput = String()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Disable system keyboard
		self.inputTextField.inputView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize.zero))
		self.inputTextField.tintColor = .darkGray
		self.infoButton.backgroundColor = self.outputTextScrollView.backgroundColor
		
		let submenu: Array<SlideMenuTableViewController.CellConfiguration> = [
			.init("rand", .action({ [weak self] in self?.insertTextAtCarat("rand()") })),
			.init("factorial", .action({ [weak self] in self?.insertTextAtCarat("fact(Prev)") })),
			.init("round", .action({ [weak self] in self?.insertTextAtCarat("round(Prev)") }))
		]
		
		self.infoButton.rootConfiguration =	[
			.init("Functions", .submenu(submenu)),
			.init("Legal", .action({ [weak self] in
				if let this = self {
					this.performSegue(withIdentifier: R.segue.calculatorViewController.localWebView, sender: this)
				}
			})),
			.init("Clear", .action({ [weak self] in
				self?.clearScrollView()
			})),
			.init("Last", .action({ [weak self] in
				self?.inputTextField.text = self?.lastInput
			}))
		]
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.inputTextField.becomeFirstResponder()
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { (_) -> Void in
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
	
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.equalsButtonPushed()
		
		return true
	}
	
	fileprivate func addExpression(_ expression: String, andResultToDisplay result: Double) {
		func appendString(_ string: NSAttributedString) {
			func sizeOfString(_ string: NSAttributedString) -> CGSize {
				var rect = string.boundingRect(with: CGSize(width: outputTextScrollView.frame.size.width, height: 0),
					options: [.usesLineFragmentOrigin, .usesFontLeading],
					context: nil)
				
				rect.size.width = self.outputTextScrollView.frame.size.width - 10 // For the scroll bar and equal space on the other side
				
				return rect.size
			}
			
			let previousContentSize = self.outputTextScrollView.contentSize
			let additionSize = sizeOfString(string)
			
			let label = UILabel(frame: CGRect(origin: CGPoint(x: 5 /* to counter the space for the scroll bar */, y: previousContentSize.height),
				size: additionSize))
			label.attributedText = string
			label.autoresizingMask = .flexibleWidth
			
			self.outputTextScrollView.addSubview(label)
			self.outputTextScrollView.contentSize.height = previousContentSize.height+additionSize.height
		}
		
		let basicAttributes: [String : AnyObject] = [
			NSForegroundColorAttributeName : UIColor.white,
			NSFontAttributeName : self.inputTextField.font!
		]
		
		let leftAlignmentAttributes: [String : AnyObject] = [
			NSParagraphStyleAttributeName : {let x = NSMutableParagraphStyle();x.alignment = .left; return x}()
		]
		
		let rightAlignmentAttributes: [String: AnyObject] = [
			NSParagraphStyleAttributeName : {let x = NSMutableParagraphStyle();x.alignment = .right; return x}()
		]
		
		let expressionAttributedString = NSAttributedString(string: expression, attributes: basicAttributes + leftAlignmentAttributes)
		
		let answerString = String(format: "%g", result)
		
		let answerAttributedString = NSAttributedString(string: answerString, attributes: basicAttributes + rightAlignmentAttributes)
		
		appendString(expressionAttributedString)
		appendString(answerAttributedString)
	}
	
	fileprivate func scrollToBottomOfScrollView() {
		if self.outputTextScrollView.contentSize.height > self.outputTextScrollView.frame.size.height {
			UIView.animate(duration: 1.0/3.0, options: .beginFromCurrentState) {
				let offset = CGPoint(x: 0, y: self.outputTextScrollView.contentSize.height - self.outputTextScrollView.frame.size.height)
				self.outputTextScrollView.setContentOffset(offset, animated: false)
			}
		}
	}
	
	fileprivate func clearScrollView() {
		for view in self.outputTextScrollView.subviews where view is UILabel {
			view.removeFromSuperview()
		}
		self.outputTextScrollView.contentSize = CGSize.zero
	}
	
	fileprivate static func animateConstraintChangesInView(_ view: UIView, completion: ((Bool) -> Void)? = nil) {
		UIView.animate(withDuration: 0.333,
			delay: 0,
			options: .beginFromCurrentState,
			animations: {
				view.superview?.layoutIfNeeded()
			},
			completion: completion)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.calculatorViewController.localWebView.identifier {
			if let navCon = segue.destination as? UINavigationController, let webVC = navCon.childViewControllers.first as? LocalWebViewController {
				webVC.urlToDisplay = Bundle.main.url(forResource: "Legal", withExtension: "html")
			}
		}
	}
	
	fileprivate func insertTextAtCarat(_ text: String) {
		if let range = self.inputTextField.selectedTextRange {
			self.inputTextField.replace(range, withText: text)
		} else {
			self.inputTextField.text! += text
		}
	}
}

extension CalculatorViewController {
	@IBAction private func inputButtonPushed(_ sender: UIButton) {
		self.insertTextAtCarat(sender.currentTitle!)
	}
	
	@IBAction private func deleteButtonPushed() {
		var currentString = self.inputTextField.text!
		
		if currentString.lengthOfBytes(using: String.Encoding.utf8) > 0 {
			if let selectedRange = self.inputTextField.selectedTextRange {
				if selectedRange.isEmpty {
					self.inputTextField.deleteBackward()
				} else {
					self.inputTextField.replace(selectedRange, withText: "")
				}
			} else {
				currentString.remove(at: currentString.characters.index(before: currentString.endIndex))
				
				// This shouldn't be necessary. It's probably a bug that it is, but whatever
				DispatchQueue.main.async {
					self.inputTextField.text = currentString
				}
			}
		}
	}
	
	@IBAction fileprivate func equalsButtonPushed() {
		let typedExpression = self.inputTextField.text!
		
		if !typedExpression.isEmpty {
			self.lastInput = typedExpression
		}
		
		do {
			let result = try self.muParserWrapper.evaluate(self.lastInput)
			
			self.inputTextField.text = nil
			
			self.addExpression(result.mangledExpression, andResultToDisplay: result.result)
			
			self.scrollToBottomOfScrollView()
		} catch {
			let alertController = UIAlertController(title: "Syntax Error", message: error.localizedDescription, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
			
			self.present(alertController, animated: true, completion: nil)
		}
	}
}

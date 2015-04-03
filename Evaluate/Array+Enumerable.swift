//
//  Array+Enumerable.swift
//  Enumerable
//
//  Created by Aaron Lynch on 2015-02-17.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

import Foundation

extension Array {
	func all(block: (T -> Bool)) -> Bool {
		for obj in self {
			if !block(obj) {
				return false
			}
		}
		
		return true
	}
	
	func any(block: (T -> Bool)) -> Bool {
		for obj in self {
			if block(obj) {
				return true
			}
		}
		
		return false
	}
	
	func chunk<K>(block: (T -> K)) -> [K : [T]] {
		var outValue = [K : [T]]()
		
		for obj in self {
			let key = block(obj)
			
			var valArr = outValue[key] ?? []
			valArr.append(obj)
			outValue[key] = valArr
		}
		
		return outValue
	}
	
	func collect<K>(block: (T -> K)) -> [K] {
		return map(block)
	}
	
	func collectConcat<K>(block: (T -> [K])) -> [K] {
		var outs = [[K]]()
		
		for obj in self {
			outs.append(block(obj))
		}
		
		return flatten(outs)
	}
	
	func cycle(count: Int, block: (T -> Void)) {
		for _ in 0..<count {
			for obj in self {
				block(obj)
			}
		}
	}
	
	func detect(block: (T -> Bool)) -> T? {
		for obj in self {
			if block(obj) {
				return obj
			}
		}
		
		return nil
	}
	
	func detectWithIndex(block: (T -> Bool)) -> (object: T, index: Int)? {
		for (index, object) in enumerate(self) {
			if block(object) {
				return (object, index)
			}
		}
		
		return nil
	}
	
	func drop(count: Int) -> [T] {
		if count >= self.count {
			return []
		} else {
			return Array(self[count..<self.count])
		}
	}
	
	func dropWhile(block: (T -> Bool)) -> [T] {
		var firstAcceptableIndex = -1
		
		for (index, obj) in enumerate(self) {
			if !block(obj) {
				firstAcceptableIndex = index
				break
			}
		}
		
		if firstAcceptableIndex == -1 {
			return []
		} else {
			return Array(self[firstAcceptableIndex..<self.count])
		}
	}
	
	func eachCons(count: Int, block: (ArraySlice<T> -> Void)) {
		for startIndex in 0..<self.count {
			let endIndex = startIndex+count
			
			if endIndex <= self.count {
				block(self[startIndex..<endIndex])
			} else {
				break
			}
		}
	}
	
	func eachSlice(count: Int, block: (ArraySlice<T> -> Void)) {
		for (var startIndex = 0; startIndex < self.count; startIndex += count) {
			let endIndex = min(startIndex+count, self.count)
			block(self[startIndex..<endIndex])
		}
	}
	
	func eachWithIndex(block: ((index: Int, object: T) -> Void)) {
		for (i, o) in enumerate(self) {
			block(index: i, object: o)
		}
	}
	
	func eachWithObject<U>(initial: U, block: (U, T) -> U) -> U {
		return reduce(initial, combine: block)
	}
	
	func find(block: (T -> Bool)) -> T? {
		return detect(block)
	}
	
	func findAll(block: (T -> Bool)) -> [T] {
		var outArr = [T]()
		
		for obj in self {
			if block(obj) {
				outArr.append(obj)
			}
		}
		
		return outArr
	}
	
	func findIndex(object objectToFind: T, comparator: (lhs: T, rhs: T) -> Bool) -> Int? {
		for (index, object) in enumerate(self) {
			if comparator(lhs: object, rhs: objectToFind) {
				return index
			}
		}
		
		return nil
	}
	
	func findWithIndex(block: (T -> Bool)) -> (object: T, index: Int)? {
		return detectWithIndex(block)
	}
	
	func first(count: Int) -> ArraySlice<T> {
		return self[0..<count]
	}
	
	func flatMap<K>(block: (T -> [K])) -> [K] {
		return collectConcat(block)
	}
	
	func groupBy<K>(block: (T -> K)) -> [K : [T]] {
		return chunk(block)
	}
	
	func includes(object: T, comparator: (lhs: T, rhs: T) -> Bool) -> Bool {
		if let index = findIndex(object: object, comparator: comparator) {
			return true
		} else {
			return false
		}
	}
	
	func inject<U>(initial: U, block: (U, T) -> U) -> U {
		return eachWithObject(initial, block: block)
	}
	
	func none(block: (T -> Bool)) -> Bool {
		return !any(block)
	}
	
	func objectOrNilAtIndex(index: Int) -> T? {
		if index < self.count && index >= 0 {
			return self[index]
		} else {
			return nil
		}
	}
	
	func one(block: (T -> Bool)) -> Bool {
		var truths = 0
		
		for obj in self {
			if block(obj) {
				if truths++ > 1 {
					return false
				}
			}
		}
		
		switch truths {
		case 0:
			return false
			
		case 1:
			return true
			
		default: // Good to be safe
			return false
		}
	}
	
	func partition(block: (T -> Bool)) -> [Bool : [T]] {
		return groupBy(block)
	}
	
	func reject(block: (T -> Bool)) -> [T] {
		var outArr = [T]()
		
		for obj in self {
			if !block(obj) {
				outArr.append(obj)
			}
		}
		
		return outArr
	}
	
	func reverseEach(block: (T -> Void)) {
		for (var i = self.count-1; i >= 0; i--) {
			block(self[i])
		}
	}
	
	func select(block: (T -> Bool)) -> [T] {
		return findAll(block)
	}
	
	func sliceAfter(block: (T -> Bool)) -> [ArraySlice<T>] {
		var outArr = [ArraySlice<T>]()
		
		var startIndex = 0
		
		for (index, object) in enumerate(self) {
			if block(object) {
				outArr.append(self[startIndex...index])
				startIndex = index+1
			}
		}
		
		return outArr
	}
	
//	func sliceBefore(block: (T -> Bool)) -> [Slice<T>] {
//	}
	
	func sliceWhen(block:((a: T, b: T) -> Bool)) -> [ArraySlice<T>] {
		if self.count == 0 {
			return []
		}
		
		var outArr = [ArraySlice<T>]()
		var startIndex = 0
		
		for (var i=0; i<self.count-1; i++) {
			if (block(a: self[i], b: self[i+1])) {
				outArr.append(self[startIndex...i])
				startIndex = i+1
			}
		}
		
		outArr.append(self[startIndex..<self.count])
		
		return outArr
	}
	
	func take(count: Int) -> ArraySlice<T> {
		let end = min(self.count, count)
		
		return self[0..<end]
	}
	
	func takeWhile(block: (T -> Bool)) -> ArraySlice<T> {
		for (index, object) in enumerate(self) {
			if !block(object) {
				return self[0..<index]
			}
		}
		
		return self[0..<self.count]
	}
	
	func zip(a: [T]...) -> [[T?]] {
		var outArr = [[T?]]()
		
		for (index, object) in enumerate(self) {
			var innerArr: [T?] = [object]
			
			for otherArr in a {
				innerArr.append(otherArr.objectOrNilAtIndex(index))
			}
			
			outArr.append(innerArr)
		}
		
		return outArr
	}
}

public func flatten<T>(array: [[T]]) -> [T] {
	var outArr = [T]()
	
	for obj in array {
		outArr += obj
	}
	
	return outArr
}
//
//  TablePickerView.swift
//  Butter
//
//  Created by Moorice on 12-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import UIKit

@objc public protocol TablePickerViewDelegate {
	@objc optional func tablePickerView(_ tablePickerView: TablePickerView, didSelect item: String)
	@objc optional func tablePickerView(_ tablePickerView: TablePickerView, didDeselect item: String)
	@objc optional func tablePickerView(_ tablePickerView: TablePickerView, didClose items: [String])
	@objc optional func tablePickerView(_ tablePickerView: TablePickerView, willClose items: [String])
	@objc optional func tablePickerView(_ tablePickerView: TablePickerView, didChange items: [String])
}

open class TablePickerView: UIView, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet fileprivate var view: UIView!
	@IBOutlet open weak var tableView: UITableView!
	@IBOutlet open weak var toolbar: UIToolbar!
	@IBOutlet open weak var button: UIBarButtonItem!
	
	open var delegate : TablePickerViewDelegate?
	fileprivate var superView : UIView?
	fileprivate var dataSourceKeys = [String]()
	fileprivate var dataSourceValues = [String]()
	fileprivate (set) open var _selectedItems = [String]()
	fileprivate var cellBackgroundColor : UIColor?
	fileprivate var cellBackgroundColorSelected : UIColor?
	fileprivate var cellTextColor : UIColor?
	fileprivate var multipleSelect : Bool = true
	fileprivate var nullAllowed : Bool = true
	fileprivate var speed : Double = 0.2
	
	// MARK: Init methods
	
	public init(superView: UIView) {
		super.init(frame: CGRect.zero)
		self.superView = superView
		prepareView()
	}
	
	public init(superView: UIView, sourceDict: [String : String]?, _ delegate: TablePickerViewDelegate?) {
		super.init(frame: CGRect.zero)
		self.superView = superView
		
		if let sourceDict = sourceDict {
			self.setSourceDictionay(sourceDict)
		}
		
		self.delegate = delegate
		prepareView()
	}
	
	public init(superView: UIView, sourceArray: [String]?, _ delegate: TablePickerViewDelegate?) {
		super.init(frame: CGRect.zero)
		self.superView = superView
		
		if let sourceArray = sourceArray {
			self.setSourceArray(sourceArray)
		}

		self.delegate = delegate
		prepareView()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		prepareView()
	}
	
	// MARK: Set source and get selectted items
	
	open func setSourceDictionay(_ source : [String : String]) {
		let sortedKeysAndValues = source.sorted(by: { $0.1 < $1.1 })
		for (key, value) in sortedKeysAndValues {
			self.dataSourceKeys.append(key)
			self.dataSourceValues.append(value)
		}
		tableView?.reloadData()
	}
	
	open func setSourceArray(_ source : [String]) {
		self.dataSourceKeys = source
		self.dataSourceValues = source
		tableView?.reloadData()
	}
	
	open func setSelected(_ items : [String]) {
		_selectedItems = items
		tableView?.reloadData()
	}
	
	open func setMultipleSelect(_ multiple : Bool) {
		multipleSelect = multiple
	}
	
	open func setNullAllowed(_ multiple : Bool) {
		nullAllowed = multiple
	}
	
	open func deselect(_ item : String) {
		if let index = _selectedItems.index(of: item) {
			_selectedItems.remove(at: index)
			tableView?.reloadData()
			delegate?.tablePickerView?(self, didDeselect: item)
		}
	}
	
	open func deselectButThis(_ item : String) {
		for _item in _selectedItems {
			if _item != item {
				delegate?.tablePickerView?(self, didDeselect: item)
			}
		}
		
		_selectedItems = [item]
		tableView?.reloadData()
	}
	
	open func selectedItems() -> [String] {
		return _selectedItems
	}
	
	// MARK: Style TablePickerView
	// You can also style this view directly since the IBOutlets are public
	
	open func setButtonText(_ text : String) {
		button.title = text
	}

	open func setToolBarBackground(_ color : UIColor) {
		toolbar.backgroundColor = color
	}
	
	open func setCellBackgroundColor(_ color : UIColor) {
		cellBackgroundColor = color
	}
	
	open func setCellBackgroundColorSelected(_ color : UIColor) {
		cellBackgroundColorSelected = color
	}
	
	open func setCellTextColor(_ color : UIColor) {
		cellTextColor = color
	}
	
	open func setCellSeperatorColor(_ color : UIColor) {
		self.tableView.separatorColor = color
	}
	
	open func setAnimationSpeed(_ speed : Double) {
		self.speed = speed
	}
	
	// MARK: Show / hide view
	
	open func show() {
		if let superView = superView {
			self.isHidden = false
			
			var newFrame = self.frame
			newFrame.origin.y = superView.frame.height - self.frame.height
			
			UIView.animate(withDuration: speed, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
				self.frame = newFrame
			}, completion: { (finished) in })
		}
	}
	
	open func hide() {
		if isVisibe() {
			if let superView = superView {
				var newFrame = self.frame
				newFrame.origin.y = superView.frame.height
				
				delegate?.tablePickerView?(self, willClose: selectedItems())
				
				UIView.animate(withDuration: speed, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
					self.frame = newFrame
				}, completion: { (finished) in
					self.isHidden = true
					self.delegate?.tablePickerView?(self, didClose: self.selectedItems())
				})
			}
		}
	}
	
	open func toggle() {
		if isVisibe() {
			hide()
		} else {
			show()
		}
	}
	
	open func isVisibe() -> Bool {
		return !self.isHidden
	}
	
	
	// MARK: UITabelView
	
	open func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSourceKeys.count
	}
	
	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		cell.textLabel?.text = dataSourceValues[indexPath.row]
		
		if let cellBackgroundColor = cellBackgroundColor {
			cell.backgroundColor = cellBackgroundColor
		}
		
		if let cellBackgroundColorSelected = cellBackgroundColorSelected {
			let bg = UIView()
			bg.backgroundColor = cellBackgroundColorSelected
			cell.selectedBackgroundView = bg
		} else {
			let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
			cell.selectedBackgroundView = blurEffectView
		}
		
		if let cellTextColor = cellTextColor {
			cell.textLabel?.textColor = cellTextColor
			cell.tintColor = cellTextColor
		}
		
		if _selectedItems.contains(dataSourceKeys[indexPath.row]) {
			cell.accessoryType = .checkmark
		} else {
			cell.accessoryType = .none
		}
		
		return cell
	}
	
	open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath)!
		let selectedItem = dataSourceKeys[indexPath.row]

		if _selectedItems.contains(selectedItem) && (nullAllowed || _selectedItems.count > 1) {
			_selectedItems.remove(at: _selectedItems.index(of: selectedItem)!)
			delegate?.tablePickerView?(self, didDeselect: selectedItem)
			delegate?.tablePickerView?(self, didChange: _selectedItems)
			cell.accessoryType = .none
		} else {
			if !multipleSelect && _selectedItems.count > 0 {
				let oldSelected = _selectedItems[0]
				_selectedItems = []
				if let index = dataSourceKeys.index(of: oldSelected) {
					let oldCell = tableView.cellForRow(at: IndexPath(item: index, section: 0))
					oldCell?.accessoryType = .none
				}
			}
			
			_selectedItems.append(selectedItem)
			cell.accessoryType = .checkmark
			delegate?.tablePickerView?(self, didSelect: selectedItem)
			delegate?.tablePickerView?(self, didChange: _selectedItems)
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}

	
	// MARK: Private methods
	
	fileprivate func prepareView() {
		loadNib()
		
		tableView.tableFooterView = UIView.init(frame: CGRect.zero)
		
		let borderTop = CALayer()
		borderTop.frame = CGRect(x: 0.0, y: toolbar.frame.height - 1, width: toolbar.frame.width, height: 0.5);
		borderTop.backgroundColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0).cgColor
		toolbar.layer.addSublayer(borderTop)
		
		if let superView = superView {
			self.isHidden = true
			
			let height = superView.frame.height / 2.7
			let frameSelf = CGRect(x: 0, y: superView.frame.height, width: superView.frame.width, height: height)
			var framePicker = frameSelf
			framePicker.origin.y = 0
			
			self.frame = frameSelf
			self.view.frame = framePicker
		}
	}
	
	fileprivate func loadNib() {
		UINib(nibName: "TablePickerView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? UIView
		self.addSubview(self.view)
	}
	
	@IBAction func done(_ sender: AnyObject) {
		hide()
	}
}

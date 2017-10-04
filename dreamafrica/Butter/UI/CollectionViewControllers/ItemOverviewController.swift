//
//  ItemOverviewController.swift
//  Butter
//
//  Created by Moorice on 11-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import UIKit

class ItemOverviewController: UICollectionViewController, UISearchBarDelegate, TablePickerViewDelegate {
    
	var searchBar: UISearchBar?
	var tablePickerView: TablePickerView?
    var refreshControl : UIRefreshControl?
    var nothingFoundLabel : UILabel?
    var searchBarPlaceholder = "Search..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add searchbar
        addSearchbar()
		
		// Add TablePicker for filter
		addTablePicker()
        
        // Add refresh control
        addRefreshControl()
        
        // Add label with Nothing Found text
        addNothingFoundLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ItemOverviewController.handleRequestError(_:)), name:NSNotification.Name(rawValue: "NSURLErrorDomainErrors"), object: nil)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		tablePickerView?.hide()
	}
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NSURLErrorDomainErrors"), object: nil)
    }
	
    func handleRequestError(_ notification: Notification) {
        if let userInfo = notification.userInfo as? Dictionary<String, NSError> {
            if let error = userInfo["error"] {

                let errorAlert = UIAlertController(title: "Oops..", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)

                errorAlert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action: UIAlertAction!) in
                    self.reloadItems()
                }))
                
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                    
                }))
                
                present(errorAlert, animated: true, completion: nil)
            }
        }
    }
    
    func addSearchbar() {
        searchBar = UISearchBar.init(frame: CGRect(x: 0, y: 0, width: self.collectionView!.frame.width, height: 44))
        searchBar?.delegate = self
        searchBar?.searchBarStyle = .minimal
        searchBar?.placeholder = searchBarPlaceholder
        searchBar?.isHidden = true
        searchBar?.alpha = 0.0
        (searchBar?.value(forKey: "searchField") as? UITextField)?.textColor = UIColor.white
        self.collectionView?.addSubview(searchBar!)
    }
	
	func addTablePicker() {
		tablePickerView = TablePickerView(superView: self.view, sourceArray: nil, self)
		tablePickerView?.setCellBackgroundColor(UIColor.clear)
		tablePickerView?.setCellTextColor(UIColor.lightGray)
		tablePickerView?.setCellSeperatorColor(UIColor.darkGray)
		tablePickerView?.tableView.backgroundColor = UIColor.clear
		tablePickerView?.setSelected(["All"])
		let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		tablePickerView?.tableView.backgroundView = blurEffectView
		
		self.tabBarController?.view.addSubview(tablePickerView!)
	}
    
    func setSearchBarPlaceholderTo(_ text : String) {
        searchBar?.placeholder = text
    }
    
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(ItemOverviewController.refreshControlAction), for: UIControlEvents.valueChanged)
        self.collectionView?.addSubview(refreshControl!)
    }
    
    func searchButtonClicked() {
        if let searchBar = self.searchBar {
            UIView.animate(withDuration: 0.2, animations: {
                searchBar.alpha = searchBar.isHidden ? 1 : 0
                (self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = searchBar.isHidden ? UIEdgeInsets(top: 44, left: 5, bottom: 0, right: 5) : UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
                }, completion: {(finished: Bool) in
                    if(finished) {
                        searchBar.isHidden = !searchBar.isHidden
                        if searchBar.isHidden {
                            searchBar.resignFirstResponder()
                            ButterAPIManager.sharedInstance.searchString = ""
                        }
                        if self.collectionView!.numberOfSections > 0 && self.collectionView!.numberOfItems(inSection: 0) > 0 && !searchBar.isHidden {
                            self.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: true)
                        }
                    }
            })
        }
    }
	
	func filterButtonClicked() {
		tablePickerView?.toggle()
	}
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        ButterAPIManager.sharedInstance.searchString = searchBar.text!
        self.reloadItems()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.view.endEditing(true)
            ButterAPIManager.sharedInstance.searchString = ""
            self.reloadItems()
        }
    }
	
	func tablePickerView(_ tablePickerView: TablePickerView, didClose items: [String]) {
        var items = items
		if items.count == 0 {
			items = ["All"]
			tablePickerView.setSelected(items)
		}
		
		ButterAPIManager.sharedInstance.genres = items
		self.reloadItems()
	}
	
	func tablePickerView(_ tablePickerView: TablePickerView, didSelect item: String) {
		if item == "All" {
			tablePickerView.deselectButThis(item)
		} else {
			tablePickerView.deselect("All")
		}
	}
    
    func refreshControlAction() {
        refreshControl?.endRefreshing()
        reloadItems()
    }
    
    func reloadItems() {
        // Override this method
    }
    
    func addNothingFoundLabel() {
        nothingFoundLabel = UILabel(frame: UIScreen.main.bounds)
        nothingFoundLabel!.text = "Nothing found.."
        nothingFoundLabel!.textAlignment = NSTextAlignment.center
        nothingFoundLabel!.textColor = UIColor(red:0.57, green:0.57, blue:0.57, alpha:1.0)
        nothingFoundLabel!.font = UIFont.systemFont(ofSize: 24.0)
        nothingFoundLabel!.isHidden = true
        self.view.addSubview(nothingFoundLabel!)
    }
    
    func showNothingFound(_ show : Bool) {
        nothingFoundLabel!.isHidden = !show
    }
}

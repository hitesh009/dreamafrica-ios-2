//
//  SettingsTableViewController.swift
//  Butter
//
//  Created by Moorice on 11-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import UIKit
import SafariServices
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController, TablePickerViewDelegate {

    let ud = UserDefaults.standard
    
    @IBOutlet weak var switchStreamOnCellular: UISwitch!
    @IBOutlet weak var segmentedQuality: UISegmentedControl!
	@IBOutlet weak var languageButton: UIButton!
	
	var tablePickerView : TablePickerView?
    let qualities = ["480p", "720p", "1080p"]
	
    override func viewDidLoad() {
        super.viewDidLoad()
		addTablePicker()
        showSettings()
    }
    
    func showSettings() {        
        // Set StreamOnCellular
        switchStreamOnCellular.isOn = ud.bool(forKey: "StreamOnCellular")
    }
	
	func addTablePicker() {
		tablePickerView = TablePickerView(superView: self.view, sourceDict: ButterAPIManager.languages, self)
		tablePickerView?.setCellBackgroundColor(UIColor.clear)
		tablePickerView?.setCellTextColor(UIColor.lightGray)
		tablePickerView?.setCellSeperatorColor(UIColor.darkGray)
		tablePickerView?.tableView.backgroundColor = UIColor.clear
		tablePickerView?.setMultipleSelect(false)
		tablePickerView?.setNullAllowed(true)
		let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		tablePickerView?.tableView.backgroundView = blurEffectView
		self.tabBarController?.view.addSubview(tablePickerView!)
	}
    
    func tablePickerView(_ tablePickerView: TablePickerView, didChange items: [String]) {
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		tablePickerView?.hide()
	}
    
    override func viewDidDisappear(_ animated: Bool) {
        ud.synchronize()
    }
    
    @IBAction func logoutUser(_ sender: UIButton) {
        FBSDKLoginManager().logOut()
        ud.set(false, forKey: "logginIn")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginvc = storyboard.instantiateViewController(withIdentifier: "loginView") as! FacebookLoginViewConroller
        let navigationController = UINavigationController(rootViewController: loginvc)
        
        appDelegate.window?.rootViewController = navigationController
        appDelegate.window?.makeKeyAndVisible()
    }
    
    @IBAction func streamOnCellular(_ sender: UISwitch) {
        ud.set(sender.isOn, forKey: "StreamOnCellular")
    }
    
    @IBAction func preferredQuality(_ control: UISegmentedControl) {
        let resultAsText = control.titleForSegment(at: control.selectedSegmentIndex)
        ud.set(resultAsText, forKey: "PreferredQuality")
    }
	
	@IBAction func preferredSubtitleLanguage(_ sender: AnyObject) {
		tablePickerView?.toggle()
	}
    
    @IBAction func authorizeTraktTV(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Not yet supported", message: "Trakt.TV integration is in development.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showTwitter(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://twitter.com/butterproject")!)
    }
    
    @IBAction func showWebsite(_ sender: AnyObject) {
        openUrl("http://www.wedreamafrica.com/")
    }
    
    func openUrl(_ url : String) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: URL(string: url)!)
            svc.view.tintColor = UIColor(red:0.37, green:0.41, blue:0.91, alpha:1.0)
            self.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
}

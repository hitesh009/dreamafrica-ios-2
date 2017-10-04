//
//  ReportBugViewController.swift
//  Butter
//
//  Created by Moorice on 17-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ReportBugViewController: UITableViewController {
	
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var titleField: UITextField!
	@IBOutlet weak var descriptionField: PlaceholderTextView!
	@IBOutlet var checkMarks: [UILabel]!
	
	let gitLabApiUrl = "" // ToDo: Add Butter Links
	let gitLabProjectUrl = ""
	let gitLabProjectId = ""
	var gitLabToken : String?
	
	override func viewDidLoad() {
		self.hideCheckmarks()
		
		if let username = UserDefaults.standard.object(forKey: "GitLabUsername") as? String {
			usernameField.text = username
		}
	}
	
	@IBAction func reportBug(_ sender: AnyObject) {
		if let _ = gitLabToken {
			if titleField.text?.characters.count < 15 {
				let errorAlert = UIAlertController(title: "Title too short", message: "The title must contain at least 15 characters", preferredStyle: .alert)
				errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in }))
				self.present(errorAlert, animated: true, completion: nil)
				return
			}
			
			if descriptionField.text?.characters.count < 100 {
				let errorAlert = UIAlertController(title: "Description too short", message: "The description must contain at least 100 characters", preferredStyle: .alert)
				self.present(errorAlert, animated: true, completion: nil)
				errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in }))
				return
			}
			
			let systemVersion = UIDevice.current.systemVersion;
			let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
			let appBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
			let deviceName = UIDevice.current.modelName
			let network = (UIApplication.shared.delegate! as! AppDelegate).reachability!.isReachableViaWiFi() ? "WiFi" : "Cellular"

			let title = titleField.text!
			let description = descriptionField.text! + "\n\n\n ----------------- \n\n" + "iOS: " + systemVersion + "\n\n" + "Device: " + deviceName + "\n\n" + "App version: " + appVersion + "\n\n" + "App build: " + appBuild + "\n\n" + "Network: " + network
			
			createIssue(title, description: description, onCompletion: { (issueUrl) -> Void in
				if let issueUrl = issueUrl {
					let errorAlert = UIAlertController(title: "Reported", message: "Thank you for reporting this issue!", preferredStyle: .alert)
					errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
						self.navigationController?.popViewController(animated: true)
					}))
					errorAlert.addAction(UIAlertAction(title: "Open issue", style: .default, handler: { (action: UIAlertAction!) in
						self.navigationController?.popViewController(animated: true)
						UIApplication.shared.openURL(NSURL(string: issueUrl)! as URL)
					}))
					self.present(errorAlert, animated: true, completion: nil)
					
				} else {
					let errorAlert = UIAlertController(title: "Oops..", message: "Something went wrong. Please try it again.", preferredStyle: .alert)
					errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in }))
					self.present(errorAlert, animated: true, completion: nil)
				}
			})
			
		} else {
			let errorAlert = UIAlertController(title: "Oops..", message: "Please login with your GitLab account.", preferredStyle: .alert)
			errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in }))
			errorAlert.addAction(UIAlertAction(title: "Sign up", style: .default, handler: { (action: UIAlertAction!) in
				UIApplication.shared.openURL(URL(string: "")!)
			}))
			
			self.present(errorAlert, animated: true, completion: nil)
		}
	}
	
	@IBAction func titleFieldEditingDidBegin(_ sender: AnyObject) {
		if usernameField.text != "" && passwordField.text != "" {
			getGitLabPrivateToken(usernameField.text!, password: passwordField.text!, onCompletion: { (token) in
				if let token = token {
					self.gitLabToken = token
					self.showCheckmarks()
					UserDefaults.standard.set(self.usernameField.text!, forKey: "GitLabUsername")
				} else {
					self.hideCheckmarks()
					let errorAlert = UIAlertController(title: "Oops..", message: "The entered username and/or password is invalid", preferredStyle: UIAlertControllerStyle.alert)
					errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in }))
					self.present(errorAlert, animated: true, completion: nil)
				}
			})
		}
	}
	
	func getGitLabPrivateToken(_ username : String, password : String, onCompletion: @escaping (String?) -> Void) {
		let jsonBody = [
			"login": username,
			"password": password
		]
		
		do {
			let request = NSMutableURLRequest(url: URL(string: gitLabApiUrl + "session")!)
			request.httpMethod = "POST"
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
			
			RestApiManager.sharedInstance.makeHTTPRequest(request, onCompletion: { (json, error) -> Void in
				if let token = json["private_token"].string {
					onCompletion(token)
				} else {
					onCompletion(nil)
				}
			})
		} catch {
			onCompletion(nil)
		}
	}
	
	func createIssue(_ title : String, description: String, onCompletion: @escaping (String?) -> Void) {
		if let gitLabToken = gitLabToken {
			let jsonBody = [
				"id": gitLabProjectId,
				"title": title,
				"description": description
			]
			
			do {
				let request = NSMutableURLRequest(url: URL(string: gitLabApiUrl + "projects/" + gitLabProjectId + "/issues?private_token=" + gitLabToken)!)
				request.httpMethod = "POST"
				request.addValue("application/json", forHTTPHeaderField: "Content-Type")
				request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
				
				RestApiManager.sharedInstance.makeHTTPRequest(request, onCompletion: { (json, error) -> Void in
					if let issueId = json["iid"].int {
						onCompletion(self.gitLabProjectUrl + "issues/" + String(issueId))
					} else {
						onCompletion(nil)
					}
				})
			} catch {
				onCompletion(nil)
			}
		}
	}
	
	func showCheckmarks() {
		self.checkMarks.foreach{$0.isHidden = false}
	}
	
	func hideCheckmarks() {
		self.checkMarks.foreach{$0.isHidden = true}
	}
}

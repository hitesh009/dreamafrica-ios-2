//
//  RestApiManager.swift
//  Butter
//
//  Created by DjinnGA on 25/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    var task: URLSessionDataTask? = nil
    
    func cancelRequest() {
        if (task != nil) {
            task!.cancel()
            task = nil
        }
    }
    
    func getJSONFromURL(_ url:String, onCompletion: @escaping (JSON) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: url)!)
        makeHTTPRequest(request, onCompletion: { json, err in
            DispatchQueue.main.async {
                onCompletion(json as JSON)
            }
        })
    }
    
    func getJSONFromURL(_ url:String, parameters:[String:AnyObject], onCompletion: @escaping (JSON) -> Void) {
        getJSONFromURL(url, headers: nil, parameters: parameters) { (json) -> Void in
            onCompletion(json)
        }
    }
    
    func getJSONFromURL(_ url:String, headers: [String:String]?, parameters:[String:AnyObject], onCompletion: @escaping (JSON) -> Void) {
        
        let urlToRequest = "\(url)?\(parameters.queryStringWithEncoding())"
        let request = NSMutableURLRequest(url: URL(string: urlToRequest)!)
        
        print(urlToRequest)
        
        if let headers = headers {
            for (field, value) in headers {
                request.addValue(value, forHTTPHeaderField: field)
            }
        }
        
        makeHTTPRequest(request, onCompletion: { json, err in
            DispatchQueue.main.async {
                onCompletion(json as JSON)
            }
        })
    }
    
    func getJSONFromURL(_ url:NSMutableURLRequest, onCompletion: @escaping (JSON) -> Void) {
        makeHTTPRequest(url, onCompletion: { json, err in
            DispatchQueue.main.async {
                onCompletion(json as JSON)
            }
        })
    }
    
	func makeHTTPRequest(_ path: NSMutableURLRequest, onCompletion: @escaping ServiceResponse) {
		path.timeoutInterval = 5.0
		let session = URLSession.shared
		UIApplication.shared.beganNetworkActivity()
		task = session.dataTask(with: path as URLRequest , completionHandler: {data, response, error -> Void in
			DispatchQueue.main.async {
				UIApplication.shared.endedNetworkActivity()
				
				if let error = error {
					print(error)
					NotificationCenter.default.post(name: Notification.Name(rawValue: "NSURLErrorDomainErrors"), object: self, userInfo: ["error" : error])
				}
				
				if let data = data {
					let json = JSON.parse(String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!)
                    print("json---->",json)
                    
                    onCompletion(json, error! as NSError)
				} else {
					onCompletion(JSON(""), error! as NSError)
				}
			}
		})
		task!.resume()
	}
	
    func makeAsyncDataRequest(_ url: String, onCompletion: @escaping (Data) -> Void) {
        let request: URLRequest = URLRequest(url: URL(string:url)!)
        let mainQueue = OperationQueue.main
		UIApplication.shared.beganNetworkActivity()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
			DispatchQueue.main.async {
				UIApplication.shared.endedNetworkActivity()
				if error == nil {
					onCompletion(data!)
				} else {
					print("Error: \(error!.localizedDescription)")
				}
			}
        })
    }
    
    func loadImage(_ url:String, onCompletion: @escaping (UIImage) -> Void) {
        if (url != "") {
            self.makeAsyncDataRequest(url) { data in
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async(execute: {
                        onCompletion(image)
                    })
                } else {
                    print("Could Not Load: \(url)")
                }
            }
        }
    }
}

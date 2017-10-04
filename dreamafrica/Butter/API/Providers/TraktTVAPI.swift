//
//  TraktTVAPI.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation

class TraktTVAPI {
    static let sharedInstance = TraktTVAPI()
    
    func requestMovieInfo(_ imdb: String, onCompletion: @escaping () -> Void) {
        let imdbURL = "https://api-v2launch.trakt.tv/movies/\(imdb)?extended=full,images"
        let url = URL(string:imdbURL)
        let mutableURLRequest = NSMutableURLRequest(url: url!)
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        mutableURLRequest.setValue("", forHTTPHeaderField: "trakt-api-key") // Add Trakt api key
        mutableURLRequest.setValue("2", forHTTPHeaderField: "trakt-api-version")
        mutableURLRequest.httpMethod = "GET"
        
        var ite: ButterItem?
        if (ButterAPIManager.sharedInstance.isSearching) {
            ite = ButterAPIManager.sharedInstance.searchResults[imdb]!
        } else {
            ite = ButterAPIManager.sharedInstance.cachedMovies[imdb]!
        }
        
        RestApiManager.sharedInstance.getJSONFromURL(mutableURLRequest) { json in
            if json["trailer"].string != nil {
                ite!.setProperty("trailer", val: json["trailer"].string! as AnyObject)
            }
			
			if(!ite!.hasProperty("description") || ite!.getProperty("description") as? String
				== "") {
					ite!.setProperty("description", val: json["overview"].string! as AnyObject)
			}
			
            if json["images","fanart","medium"].string != nil {
                let fanUrl: String = json["images","fanart","medium"].string!
                RestApiManager.sharedInstance.loadImage(fanUrl) { image in
                    ite!.setProperty("fanart", val: image)
                    onCompletion()
                }
            }
        }
    }

}

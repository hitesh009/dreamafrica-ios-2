//
//  MovieAPI.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SwiftyJSON

class MovieAPI {
    static let sharedInstance = MovieAPI()
    
    let APIManager: ButterAPIManager = ButterAPIManager.sharedInstance
	
	static let genres = [
		"All"/*,
		"Action",
		"Adventure",
		"Animation",
		"Biography",
		"Comedy",
		"Crime",
		"Documentary",
		"Drama",
		"Family",
		"Fantasy",
		"Film-Noir",
		"History",
		"Horror",
		"Music",
		"Musical",
		"Mystery",
		"Romance",
		"Sci-Fi",
		"Short",
		"Sport",
		"Thriller",
		"War",
		"Western"*/
	]
	
	func load(_ page: Int, onCompletion: @escaping (_ newItems : Bool) -> Void) {
        //Build the query
        var url = APIManager.moviesAPIEndpoint
        if self.APIManager.isSearching {
            url = APIManager.moviesAPIEndpoint + "&search=" + APIManager.searchString
        }
        print(url)
		
        RestApiManager.sharedInstance.getJSONFromURL(url)  { json in
            
			let movies = json["posts"]
            for (index, movie) in movies {
                
                if !self.APIManager.isSearching {
                    if let _ = self.APIManager.cachedMovies[movie["title"].string!] { //Check it hasn't already been loaded
                        let title = movie["title"].string!
                        print("Duplicate movie: \(title) - From page: \(page + 1)")
                        continue
                    }
                }
                
                _ = self.createMovieFromJson(Int(index)!, movie)
                
            }
			
            onCompletion(movies.count > 0)
        }
    }
    
	func getMovie(_ id: String, onCompletion: @escaping (_ loadedFromCache : Bool) -> Void) {
        //Request the data from the API
        if let _ = self.APIManager.cachedMovies[id] {
            //print("Movie already cached")
            onCompletion(true)
        } else {
            let URL = Foundation.URL(string: APIManager.moviesAPIEndpoint + "?query_term=\(id)&limit=1&lang=\(Locale.get2LetterLanguageCode())")
			let mutableURLRequest = NSMutableURLRequest(url: URL!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0 as TimeInterval!)
			mutableURLRequest.setValue(APIManager.moviesAPIEndpointCloudFlareHost, forHTTPHeaderField: "Host")
			mutableURLRequest.httpMethod = "GET"
			
            RestApiManager.sharedInstance.getJSONFromURL(mutableURLRequest) { json in
                let movie = json["posts",0]
                if (json["status"].string == "ok") {
                    if let iteID = movie["id"].int {
                        _ = self.createMovieFromJson(iteID, movie)
                    }
                }
                
                onCompletion(false)
            }
        }
    }
    
    func createMovieFromJson(_ id : Int, _ json : JSON) -> ButterItem {
        let ite: ButterItem = ButterItem(id: id, torrentURL:json["torrent"].string!, quality:"720p", size:"1293")
        ite.setProperty("title", val: json["title"].string! as AnyObject)
        
        let htmlString = json["synopsis"].string!
        var description = NSAttributedString(string: "DreamAfrica - your access to multicultural and multilingual stories.")
        do {
        description = try NSAttributedString(data: htmlString.data(using: String.Encoding.utf8)!,
                                                 options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                 documentAttributes: nil)
        } catch {
            // TODO: Log this error
        }
        
        ite.setProperty("description", val: description.string as AnyObject)
        if let tmp = json["MovieRating"].string {
            ite.setProperty("rating", val: Float(tmp)! as AnyObject)
        }
        ite.setProperty("imdb", val: json["id"].string! as AnyObject)
        ite.setProperty("ImdbCode", val: json["id"].string! as AnyObject)
        if let tmp = json["year"].string {
//            ite.setProperty("year", val: Int(tmp)!)
            ite.setProperty("year", val: Int(tmp) as AnyObject)
        }
        
        ite.setProperty("runtime", val: 0 as AnyObject)
        ite.setProperty("coverURL", val: json["cover_image"].string! as AnyObject)
//        ite.setProperty("genres", val: json["category"].string!) // Provide default value for when category is not set.
        
        if (self.APIManager.isSearching) {
            self.APIManager.searchResults[json["id"].string!] = ite
        } else {
            self.APIManager.cachedMovies[json["id"].string!] = ite
        }
        
        RestApiManager.sharedInstance.loadImage(ite.getProperty("coverURL") as! String, onCompletion: { image in
            ite.setProperty("cover", val: image)
        })
        
        return ite
    }
}

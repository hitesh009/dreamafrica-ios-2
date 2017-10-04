//
//  ButterAPIManager.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation

class ButterAPIManager: NSObject {
    static let sharedInstance = ButterAPIManager()
    
//    let moviesAPIEndpoint: String = "http://www.wedreamafrica.com/api.php?uid=1624587927857822&email=communications@thepearldream.com&orderby=popularity&count=100" // TODO: Add uid plus email with full access.
    
    let moviesAPIEndpoint: String = "http://api.wedreamafrica.com/api/torrents/?uid=1397122510363563&email=communications@thepearldream.com&orderby=popularity&count=100"

    
//    let moviesAPIEndpoint: String = "http://www.wedreamafrica.com/api.php?uid=1624587927857822&email=communications@thepearldream.com&orderby=popularity&count=100"
    
    
    let moviesAPIEndpointCloudFlareHost : String = ""
    let TVShowsAPIEndpoint: String = ""
    let animeAPIEndpoint: String = ""
    
    var isSearching = false
    
    var cachedMovies = OrderedDictionary<String,ButterItem>()
    var cachedTVShows = OrderedDictionary<String,ButterItem>()
    var cachedAnime = OrderedDictionary<String,ButterItem>()
	
	var moviesPage = 0
	var showsPage = 0
	var searchPage = 0
	
	static let languages = [
		"ar": "Arabic",
		"eu": "Basque",
		"bs": "Bosnian",
		"br": "Breton",
		"bg": "Bulgarian",
		"zh": "Chinese",
		"hr": "Croatian",
		"cs": "Czech",
		"da": "Danish",
		"nl": "Dutch",
		"en": "English",
		"et": "Estonian",
		"fi": "Finnish",
		"fr": "French",
		"de": "German",
		"el": "Greek",
		"he": "Hebrew",
		"hu": "Hungarian",
		"it": "Italian",
		"lt": "Lithuanian",
		"mk": "Macedonian",
		"fa": "Persian",
		"pl": "Polish",
		"pt": "Portuguese",
		"ro": "Romanian",
		"ru": "Russian",
		"sr": "Serbian",
		"sl": "Slovene",
		"es": "Spanish",
		"sv": "Swedish",
		"th": "Thai",
		"tr": "Turkish",
		"uk": "Ukrainian"
	]
    
    var searchResults = OrderedDictionary<String,ButterItem>()
    
    var amountToLoad: Int = 50
    var mgenres: [String] = ["All"]
    var genres: [String] {
        set(newValue) {
            self.mgenres = newValue
            if (newValue[0] != "All") {
                isSearching = true
				searchPage = 0
            } else {
                isSearching = false
            }
        }
        get {
            return self.mgenres
        }
    }
    var quality: String = "All"
    fileprivate var msearchString: String = ""
    var searchString: String {
        set(newValue) {
            self.msearchString = newValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            searchResults = OrderedDictionary<String,ButterItem>()
            if (newValue != "") {
                isSearching = true
				searchPage = 0
            } else {
                isSearching = false
            }
        }
        get {
            return self.msearchString
        }
    }
    
    func loadMovies(_ onCompletion: @escaping (_ newItems : Bool) -> Void) {
		var page = Int()
        if isSearching {
            page += searchPage
        } else {
            page += moviesPage
        }
		
		MovieAPI.sharedInstance.load(page) { (newItems) in
			onCompletion(newItems)
		}
    }
    
    func loadTVShows(_ onCompletion: @escaping (_ newItems : Bool) -> Void) {
		var page = Int()
        if isSearching {
			page += searchPage
        } else {
			page += showsPage
        }
		
        TVAPI.sharedInstance.load(page) { (newItems) in
			onCompletion(newItems)
        }
    }
    
    func loadAnime(_ onCompletion: @escaping () -> Void) {
		var page = Int()
		if isSearching {
			page += searchPage
		} else {
			page += showsPage
		}
		
        AnimeAPI.sharedInstance.load(page, onCompletion: {
            onCompletion()
        })
    }
    
    func makeMagnetLink(_ torrHash:String, title: String)-> String {
        let torrentHash = torrHash
        let movieTitle = title
        
        let demoniiTracker = "udp://open.demonii.com:1337"
        let istoleTracker = "udp://tracker.istole.it:80"
        let yifyTracker = "http://tracker.yify-torrents.com/announce"
        let publicbtTracker = "udp://tracker.publicbt.com:80"
        let openBTTracker = "udp://tracker.openbittorrent.com:80"
        let copperTracker = "udp://tracker.coppersurfer.tk:6969"
        let desync1Tracker = "udp://exodus.desync.com:6969"
        let desync2Tracker = "http://exodus.desync.com:6969/announce"
        
        let magnetURL = "magnet:?xt=urn:btih:\(torrentHash)&dn=\(movieTitle)&tr=\(demoniiTracker)&tr=\(istoleTracker)&tr=\(yifyTracker)&tr=\(publicbtTracker)&tr=\(openBTTracker)&tr=\(copperTracker)&tr=\(desync1Tracker)&tr=\(desync2Tracker)"
        
        return magnetURL
    }
}

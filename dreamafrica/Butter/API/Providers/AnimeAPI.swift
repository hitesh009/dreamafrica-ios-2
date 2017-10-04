//
//  AnimeAPI.swift
//  Butter
//
//  Created by DjinnGA on 24/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation

class AnimeAPI {
    static let sharedInstance = AnimeAPI()
    
    let APIManager: ButterAPIManager = ButterAPIManager.sharedInstance
    
    func load(_ page: Int, onCompletion: @escaping () -> Void) {
        
        RestApiManager.sharedInstance.getJSONFromURL(APIManager.animeAPIEndpoint, parameters: [ "sort": "popularity" as AnyObject,
                                                                        "limit": APIManager.amountToLoad as AnyObject,
                                                                        "type": "All" as AnyObject,
                                                                        "page": page as AnyObject,
                                                                        "order": "asc" as AnyObject,
                                                                        "search": APIManager.searchString as AnyObject]) { json in
        
            let Animes = json
            for (_, Anime) in Animes {
                if let iteID = Anime["id"].int {
                    let ite: ButterItem = ButterItem(id: iteID, torrents: "")
                    ite.setProperty("title", val: Anime["name"].string! as AnyObject)
                    ite.setProperty("episodes", val: Anime["numep"].int! as AnyObject)
                    ite.setProperty("type", val: Anime["type"].string! as AnyObject)
                    ite.setProperty("coverURL", val: Anime["malimg"].string! as AnyObject)
                    
                    self.APIManager.cachedAnime["\(iteID)"] = ite
                    
                    RestApiManager.sharedInstance.loadImage(ite.getProperty("coverURL") as! String, onCompletion: { image in
                        ite.setProperty("cover", val: image)
                    })
                }
            }
            onCompletion()
        }
    }
}

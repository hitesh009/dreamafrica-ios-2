//
//  MovieFavorites.swift
//  Butter
//
//  Created by Moorice on 28-09-15.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SQLite

open class MovieFavorites {
	
	fileprivate static let movieFavorites = Table("MovieFavorites")
	fileprivate static let imdb_id = Expression<String>("imdb_id")
	
	fileprivate class func prepareTable() throws {
		try DatabaseManager.sharedDb?.run(movieFavorites.create(temporary: false, ifNotExists: true, block: { t in
			t.column(imdb_id, primaryKey: true)
		}))
	}
	
	open class func addFavorite(_ imdbId : String) -> Int64? {
		do {
			try prepareTable()
			let insert = movieFavorites.insert(imdb_id <- imdbId)
			return try DatabaseManager.sharedDb?.run(insert)
		} catch {
			return nil
		}
	}
	
	open class func removeFavorite(_ imdbId : String) -> Int {
		do {
			try prepareTable()
			let media = movieFavorites.filter(imdb_id == imdbId)
			return try DatabaseManager.sharedDb!.run(media.delete())
		} catch {
			return 0
		}
	}
	
	open class func isFavorite(_ imdbId : String) -> Bool {
		do {
			try prepareTable()
			return (try (DatabaseManager.sharedDb?.scalar(movieFavorites.filter(imdb_id == imdbId).count))! > 0)
		} catch {
			return false
		}
	}
	
	open class func getFavorites() -> [String]? {
		do {
			try prepareTable()
			return try DatabaseManager.sharedDb?.prepare(movieFavorites).map({ $0[imdb_id] })
		} catch {
			return nil
		}
	}
	
	open class func toggleFavorite(_ imdbId : String) {
		if isFavorite(imdbId) {
			removeFavorite(imdbId)
		} else {
			addFavorite(imdbId)
		}
	}
}

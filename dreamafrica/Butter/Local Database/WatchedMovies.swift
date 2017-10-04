//
//  WatchedMovies.swift
//  Butter
//
//  Created by Moorice on 01-10-15.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SQLite

open class WatchedMovies {
	
	fileprivate static let watchedMovies = Table("WatchedMovies")
	fileprivate static let imdb_id = Expression<String>("imdb_id")
	fileprivate static let play_time = Expression<Int>("play_time")
	
	fileprivate class func prepareTable() throws {
		try DatabaseManager.sharedDb?.run(watchedMovies.create(temporary: false, ifNotExists: true, block: { t in
			t.column(imdb_id, primaryKey: true)
			t.column(play_time)
		}))
	}
	
	open class func add(_ imdbId : String, playTime : Int) -> Int64? {
		do {
			try prepareTable()
			let insert = watchedMovies.insert(imdb_id <- imdbId, play_time <- playTime)
			return try DatabaseManager.sharedDb?.run(insert)
		} catch {
			return nil
		}
	}
	
	open class func add(_ imdbId : String) -> Int64? {
		return add(imdbId, playTime: 0)
	}
	
	open class func updatePlayTime(_ imdbId : String, playTime : Int) -> Int? {
		do {
			try prepareTable()
			if isWatched(imdbId) {
				let watched = watchedMovies.filter(imdb_id == imdbId)
				return try DatabaseManager.sharedDb?.run(watched.update(play_time <- playTime))
			} else {
				return nil
			}
		} catch {
			return nil
		}
	}
	
	open class func remove(_ imdbId : String) -> Int {
		do {
			try prepareTable()
			let media = watchedMovies.filter(imdb_id == imdbId)
			return try DatabaseManager.sharedDb!.run(media.delete())
		} catch {
			return 0
		}
	}
	
	open class func isWatched(_ imdbId : String) -> Bool {
		do {
			try prepareTable()
			return (try (DatabaseManager.sharedDb?.scalar(watchedMovies.filter(imdb_id == imdbId).count))! > 0)
		} catch {
			return false
		}
	}
	
	open class func getWatched() -> [String]? {
		do {
			try prepareTable()
			return try DatabaseManager.sharedDb?.prepare(watchedMovies).map({ $0[imdb_id] })
		} catch {
			return nil
		}
	}
	
	open class func toggleWatched(_ imdbId : String) {
		if isWatched(imdbId) {
			remove(imdbId)
		} else {
			add(imdbId)
		}
	}
}

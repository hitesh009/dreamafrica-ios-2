//
//  LocalDatabaseManager.swift
//  Butter
//
//  Created by Moorice on 28-09-15.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import Foundation
import SQLite

open class DatabaseManager {
	
	static let sharedDb : Connection? = DatabaseManager.getSharedDatabase()
	
	fileprivate class func getSharedDatabase() -> Connection? {
		do {
			let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			let fileURL = documents.appendingPathComponent("ButterDatabase.sqlite")
			return try Connection(fileURL.absoluteString)
		} catch {
			return nil
		}
	}
}

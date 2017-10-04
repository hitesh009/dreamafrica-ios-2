//
//  Array+Extension.swift
//  Butter
//
//  Created by Moorice on 17-10-15.
//  Copyright © 2015 Butter Project. All rights reserved.
//

import Foundation

extension Array {
	func foreach(_ functor: (Element) -> ()) {
		for element in self {
			functor(element)
		}
	}
}

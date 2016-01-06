//
// Volunteer.swift
//
// Auto-generated by GSParseSchema on 12/17/15.
// https://github.com/Grepstar/GSParseSchema
//

import Parse

class Volunteer : PFObject, PFSubclassing {

	override class func initialize() {
		struct Static {
			static var onceToken : dispatch_once_t = 0;
		}
		dispatch_once(&Static.onceToken) {
			self.registerSubclass()
		}
	}

	class func parseClassName() -> String {
		return "Volunteer"
	}

	// MARK: Parse Keys

	enum Keys: String {
		case isApproved = "isApproved"
		case user = "user"
	}

	// MARK: Properties

	var isApproved: Bool? {
		get { return self["isApproved"] as? Bool }
		set { return self["isApproved"] = newValue }
	}
	@NSManaged var user: User?
}
//
//  EventEntity.swift
//  SeatGeek
//
//  Created by Jeromy Schultz on 5/31/21.
//

import CoreData

/**
 Event Entity to be stored in Core Data. Follows similar structure to Event Structs
 */
@objc (EventEntity)
class EventEntity : NSManagedObject {
    @NSManaged var id : Int32
    @NSManaged var title : String
    @NSManaged var image : String
    @NSManaged var state : String?
    @NSManaged var city : String?
    @NSManaged var country : String?
    @NSManaged var date : Date
    @NSManaged var isFavorite : Bool

}

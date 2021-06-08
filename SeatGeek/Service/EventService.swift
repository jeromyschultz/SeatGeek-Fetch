//
//  EventService.swift
//  SeatGeek
//
//  Created by Jeromy Schultz on 5/31/21.
//

import Foundation
import UIKit
import CoreData

class EventService {
    
    let appDelegate: AppDelegate
    let context: NSManagedObjectContext
    let entity: NSEntityDescription
    
    public init() {
        //Initialize Core Data context
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "EventEntity", in: context)!
    }
    
    /**
     Fetches events from SeatGeek, adds them to Core Data, returns all EventEntities present
     
     -Returns an array of all EventEntities
     */
    public func getEvents() -> [EventEntity] {
        //Get all new events from API
        let newEvents: [Event] = fetchNewEvents()
        
        //Save new events
        save(events: newEvents)
        
        //Get all events from core data
        return getExistingEvents()
        
    }

    
    /**
     Retrieves Events in Core Data
     
     -Returns an array of EventEntities present in Core Data
     */
    public func getExistingEvents() -> [EventEntity]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EventEntity")
        var results: [EventEntity] = [EventEntity]()
        //Parse through existing events
        do {
            results = try context.fetch(request) as! [EventEntity]
        } catch {
            print("Failed to fetch data")
        }
        return results
    }
    
    
    /**
     Fetches new events from the SeatGeek API
     
     -Returns an array of Event structs representing events
     */
    public func fetchNewEvents() -> [Event] {
        //Seatgeek API
        var eventResults = [Event]()
        let request = "https://api.seatgeek.com/2/events?client_id=MjE4MzAyNjl8MTYyMjMwMTYxMi41OTkxNjM1"
        if let url = URL(string: request) {
            if let data = try? Data(contentsOf: url) {
                //API Request succeeded, parse the data
                let decoder = JSONDecoder()
                
                //turn JSON data into Event structs
                if let jsonEvents = try? decoder.decode(Events.self, from: data) {
                    eventResults = jsonEvents.events
                } else {
                    print("Could not parse JSON")
                }
               } else {
                   print("Could not fetch data")
               }
           }
        return eventResults
    }
    
    
    /**
     Saves an array of newly fetched events from the SeatGeek API to Core Data
     
     -Parameter events: Array of Events to be saved
     */
    public func save(events: [Event]) {
        //Set up date format
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        //Parse through new event list
        for event in events {
            
            //Check if event id is not in core data
            if( isUnique(event: event) ){
                
                //Event is unique, create and add entity
                let newEntity = EventEntity(entity: entity, insertInto: context)
                newEntity.id = event.id
                newEntity.title = event.title
                newEntity.image = event.performer[0].image
                newEntity.city = event.city
                newEntity.state = event.state
                newEntity.country = event.country
                newEntity.date = dateformatter.date(from: event.date)!
                newEntity.timeTBD = event.timeTBD
                newEntity.isFavorite = false
                do {
                    //Save data
                    try context.save()
                } catch {
                    print("Error while saving context")
                }
            }
        }
    }
    
    /**
     Checks weather or not an Event is unique
     
     -Parameter event: Event to be checked aganist Core Data entities
     */
    public func isUnique(event: Event) -> Bool {
        //Create core data context for id query
        var count = -1
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EventEntity")
        let predicate = NSPredicate(format: "id == %d", event.id)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            count = try context.count(for: request)
        } catch  {
            print("Could not query data")
        }
        return count == 0

    }
    
    /**
     Toggles the favorite attribute of a given event
     
     -Parameter event: EventEntity to be favorited / unfavorited
     */
    public static func toggleFavorite(event: EventEntity) {
        
        let event = getEventEntity(eventID: event.id)
        event?.isFavorite = !event!.isFavorite

    }
    
    /**
     Returns an EventEntity with the provided ID
     */
    public static func getEventEntity(eventID: Int32) -> EventEntity? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EventEntity")
        let predicate = NSPredicate(format: "id == %d", eventID)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let results = try context.fetch(request) as! [EventEntity]
            return results[0]
        } catch {
            print("Event with that id does not exist")
            return nil
        }
    }
}

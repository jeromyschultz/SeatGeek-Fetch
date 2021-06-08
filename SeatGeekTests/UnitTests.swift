//
//  UnitTests.swift
//  SeatGeekTests
//
//  Created by Jeromy Schultz on 5/31/21.
//

@testable import SeatGeek
import CoreData
import UIKit
import XCTest

class UnitTests: XCTestCase {

    var eventService : EventService!
    
    /**
     Add event to core data upon initialization
     */
    override func setUp() {
        super.setUp()
        eventService = EventService()
        
        //Create reference event
        let event1 = Event(id: 1, title: "Test Title", date: "2012-03-12T18:45:00", state: "Wisconsin", city: "Milwuakee", country: "USA", performer: [Performer(image: "imageurl")])
        
        //Save event
        eventService.save(events: [event1])
    }
    
    override func tearDown() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EventEntity")
        request.returnsObjectsAsFaults = false
        do
        {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EventEntity")
            var results: [EventEntity] = [EventEntity]()
            for result in results {
                if result.id == 1 {
                    context.delete(result)
                    
                    try context.save()
                }
            }
            //Parse through existing events
            do {
                results = try context.fetch(request) as! [EventEntity]
            } catch {
                print("Failed to fetch data")
            }
        } catch let error as NSError {
            print(error)
        }
        eventService = nil
        super.tearDown()
    }
    
    /**
     Test getting events from API call
     */
    func test_api_call() {
        //Get events from API
        let events = eventService.fetchNewEvents()
        
        //Assert at least one event returned
        XCTAssert(events.count > 0)
    }
    
    /**
     Test if an event is unique
     */
    func test_unique_event() {
    
        //Create event with same id
        let event2 = Event(id: 1, title: "Test Title", date: "2012-03-12T18:45:00", state: "Wisconsin", city: "Milwuakee", country: "USA", performer: [Performer(image: "imageurl")])
        
        //Fetch if event is unique
        let shouldNotBeUnique = eventService.isUnique(event: event2)
        
        //Assert not unique
        XCTAssertFalse(shouldNotBeUnique)
        
        //Create unique event
        let event3 = Event(id: 2, title: "Test Title", date: "2012-03-12T18:45:00", state: "Wisconsin", city: "Milwuakee", country: "USA", performer: [Performer(image: "imageurl")])
        
        //Fetch is event is unique
        let shouldBeUnique = eventService.isUnique(event: event3)
        
        //Assert unique
        XCTAssertTrue(shouldBeUnique)
    
    }
    
    /**
     Test toggling isFavorite attribute of event
     */
    func test_toggle_favorite() {
        //Event in core data should not be favorited
        let event = EventService.getEventEntity(eventID: 1)
        
        let shouldNotBeFavorite : Bool = event!.isFavorite
        
        //Assert not favorite
        XCTAssertFalse(shouldNotBeFavorite)
        
        //Favorite event
        EventService.toggleFavorite(event: event!)
        
        let shouldBeFavorite : Bool = event!.isFavorite
        
        //Assert favorite
        XCTAssertTrue(shouldBeFavorite)
        
    }
}

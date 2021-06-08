//
//  ViewController.swift
//  SeatGeek
//
//  Created by Jeromy Schultz on 5/31/21.
//

import UIKit
import CoreData

class EventTableController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var eventTableView: UITableView!
    
    var eventList = [EventEntity]()
    var filteredEventList = [EventEntity]()
    
    let eventService = EventService()
    
    let searchController = UISearchController()
    
    var isFirstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearchController()
        eventTableView.delegate = self
        eventTableView.dataSource = self
        
        //Check if user is starting app
        if ( isFirstLoad ) {
            isFirstLoad = false
            
            //Get events if first load
            eventList = eventService.getEvents()
            
            //deleteData()
        }
    }
    
    /**
     Deletes all data in core data, only used for testing
     */
    private func deleteData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context : NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EventEntity")
        request.returnsObjectsAsFaults = false
        do
        {
            let results = try context.fetch(request)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                context.delete(managedObjectData)
                do {
                    try context.save()
                } catch {
                    print("error")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Events"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
}


extension EventTableController: UITableViewDataSource, UITableViewDelegate {
    
    /**
     Handle tableView number of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Check if user is searching
        if (searchController.isActive) {
            return filteredEventList.count
        }
        return eventList.count
    }
    
    /**
     Handle tableView cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let event: EventEntity?
        
        //Check if user is searching
        if(searchController.isActive) {
            event = filteredEventList[indexPath.row]
        } else {
            event = eventList[indexPath.row]
        }
        
        //Connect cells
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventTableCell
        
        cell.setEvent(event: event!)
        
        return cell
    }
    
    /**
     Handle segue
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailTransition", sender: eventList[indexPath.row])
    }
    
    /**
     Handles updating UI when user favorites event
     */
    override func viewWillAppear(_ animated: Bool) {
        eventTableView.reloadData()
    }
    
    /**
     Set up segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Verify segue
        if (segue.identifier == "detailTransition") {
            let indexPath = self.eventTableView.indexPathForSelectedRow!
            let eventDetail = segue.destination as! EventDetailController
            let event: EventEntity?
            
            //Get event
            if(searchController.isActive) {
                event = filteredEventList[indexPath.row]
            } else {
                event = eventList[indexPath.row]
            }
            
            eventDetail.event = event
            eventTableView.deselectRow(at: indexPath, animated: true)

        }
    }
    
    /**
     Handle user searching in search bar
     */
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let filteredText = searchBar.text!
        filterEvents(filterText: filteredText)
    }
    
    /**
     Filter events based on text
     */
    func filterEvents(filterText: String){
        filteredEventList = eventList.filter{ event in
            
            //Check if event contains search text
            if (filterText != ""){
                return event.title.lowercased().contains(filterText.lowercased())
            } else {
                return true
            }
        }
        eventTableView.reloadData()
    }
}

/**
 Converts string date format from API to formatted Date
 */
extension UILabel {
    func convertDateFormat(date: Date, timeTBD: Bool) {
        let dateFormatter = DateFormatter()
        if( timeTBD ) {
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, MMM d, yyyy")
        } else {
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE d MMM yyyy h:mm a")
        }
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        self.text = dateFormatter.string(from: date)
    }
}





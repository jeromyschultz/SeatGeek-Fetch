//
//  EventModel.swift
//  SeatGeek
//
//  Created by Jeromy Schultz on 5/31/21.
//

import Foundation

/**
 Sample response:
 "stats": {...},
"title": "Houston Rodeo Livestock Show and Rodeo (Zac Brown Band Performance)",
"url": "/houston-rodeo-livestock-show-and-rodeo-zac-brown-band-performance-tickets/sports/2012-03-12/739515/",
"datetime_local": "2012-03-12T18:45:00",
"performers": [...],
"venue": {...},
"short_title": "Houston Rodeo Livestock Show and Rodeo (Zac Brown Band Performance)",
"datetime_utc": "2012-03-12T23:45:00",
"score": 267.608,
"taxonomies": [...],
"type": "sports",
"id": 739515
 
 
 "venue": {
     "city": "Rockford",
     "name": "Rockford MetroCentre",
     "extended_address": null,
     "url": "https://seatgeek.com/rockford-metrocentre-tickets/",
     "country": "US",
     "state": "IL",
     "score": 33.0208,
     "postal_code": "61101",
     "location": {
         "lat": 42.2714,
         "lon": -89.09612
     },
     "address": "300 Elm St.",
     "id": 632
}
 
 "performers: [{
     "name": "Beastie Boys",
     "short_name": "Beastie Boys",
     "url": "https://seatgeek.com/beastie-boys-tickets/",
     "image": "https://chairnerd.global.ssl.fastly.net/images/bandshuge/band_266.jpg",
 }]
 */

/**
 Represents performer array
 */
struct Performer: Decodable {
    let image: String
    
    init(image: String) {
        self.image = image
    }

    enum PerformerKeys: String, CodingKey {
        case image = "image"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: PerformerKeys.self)
        self.image = try values.decode(String.self, forKey: .image)
    }
}

/**
 Represents flattened event item
 */
struct Event: Decodable {
    let id: Int32
    let title: String
    let date: String
    let state: String?
    let city: String?
    let country: String?
    let performer: [Performer]
    
    init(id: Int32, title: String, date: String, state: String, city: String, country: String, performer: [Performer]){
        self.id = id
        self.title = title
        self.date = date
        self.state = state
        self.city = city
        self.country = country
        self.performer = performer
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case date = "datetime_local"
        case venue
        case performer = "performers"
    }

    enum VenueKeys: String, CodingKey {
        case state = "state"
        case city = "city"
        case country = "country"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int32.self, forKey: .id)
        self.title = try values.decode(String.self, forKey: .title)
        self.date = try values.decode(String.self, forKey: .date)
        
        let venue = try values.nestedContainer(keyedBy: VenueKeys.self, forKey: .venue)
        self.state  = try venue.decode(String.self, forKey: .state)
        self.country  = try venue.decode(String.self, forKey: .country)
        self.city  = try venue.decode(String.self, forKey: .city)

        self.performer = try values.decode([Performer].self, forKey: .performer)
    }
    
}

/**
 Represents array of event items
 */
struct Events: Decodable {
    var events: [Event]
}


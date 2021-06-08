//
//  EventDetailScreen.swift
//  SeatGeek
//
//  Created by Jeromy Schultz on 5/31/21.
//

import UIKit
import CoreData


class EventDetailController: UIViewController {
    
    var event: EventEntity?
    
    @IBOutlet weak var eventDetailTitleLabel: UILabel!
    @IBOutlet weak var eventDetailFavoriteButton: UIButton!
    @IBOutlet weak var eventDetailImageView: UIImageView!
    @IBOutlet weak var eventDetailDateLabel: UILabel!
    @IBOutlet weak var eventDetailLocationLabel: UILabel!
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        //Set title
        eventDetailTitleLabel.text = (event?.title)!
        //Set Data
        eventDetailDateLabel.convertDateFormat(date: (event?.date)!)
        //Set image
        let imageURL = URL(string: event!.image)!
        eventDetailImageView.load(url: imageURL)
        
        //Set city, state if applicable, country if not
        if event?.state == nil {
            eventDetailLocationLabel.text = " \(event?.city ?? ""), \(event?.country ?? "")"
        } else {
            eventDetailLocationLabel.text = "\(event?.city ?? ""), \(event?.state ?? "")"
        }
        
        //Set up heart button behavior
        let emptyHeart = UIImage(systemName: "heart")
        let filledHeart = UIImage(systemName: "heart.fill")
        eventDetailFavoriteButton.setImage(emptyHeart, for: .normal)
        eventDetailFavoriteButton.setImage(filledHeart, for: .selected)
        
        //Check if event is favorite
        if (event!.isFavorite) {
            //Fill in heart if true
            eventDetailFavoriteButton.isSelected = true
        }
    }
    
    /**
     Handle user clicking favorite button
     */
    @IBAction func handleFavorite(_ sender: Any) {
        //Toggle UI heart
        eventDetailFavoriteButton.isSelected.toggle()
        
        //Favorite event
        EventService.toggleFavorite(event: self.event!)
        
    }
}

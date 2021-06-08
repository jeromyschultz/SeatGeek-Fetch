//
//  EventTableCell.swift
//  SeatGeek
//
//  Created by Jeromy Schultz on 5/31/21.
//

import UIKit

class EventTableCell: UITableViewCell {
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    @IBOutlet weak var eventImageView: UIImageView!

    @IBOutlet weak var eventLocationLabel: UILabel!

    @IBOutlet weak var isFavoriteImageView: UIImageView!
    
    @IBOutlet weak var eventDateLabel: UILabel!
    
    
    func setEvent(event: EventEntity) {
        
        //Set Image
        let imageURL = URL(string: event.image)!
        eventImageView.load(url: imageURL)
        
        //Set Date
        eventDateLabel.convertDateFormat(date: event.date)
        
        //Set title
        eventTitleLabel.text = event.title
        
        //Set city, state if applicable, country if not
        if event.state == nil {
            eventLocationLabel.text = " \(event.city ?? ""), \(event.country ?? "")"
        } else {
            eventLocationLabel.text = "\(event.city ?? ""), \(event.state ?? "")"
        }
        
        //Set if event is favorited
        if ( event.isFavorite ) {
            isFavoriteImageView.image = UIImage(systemName: "heart.fill")
        } else {
            isFavoriteImageView.image = nil
        }
    }
}


/**
 Asynchronously retrieves the image of an event
 */
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image.roundedImage
                    }
                }
            }
        }
    }
}

/**
 Rounds the corners of an UIImage
 */
extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: 30
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

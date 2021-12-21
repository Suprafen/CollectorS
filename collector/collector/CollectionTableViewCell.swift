//
//  CollectionTableViewCell.swift
//  collector
//
//  Created by Ivan Pryhara on 13.12.21.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {

    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var dateFormatter: DateFormatter = {
       let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        return dateFormatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }  
    
    func updateCell(with item: Item) {
        
        guard let imageDataDirectory = item.imageDataDirectory,
              let data = Item.retrieveData(forDirectory: imageDataDirectory) else {return}
        
        itemImageView.image = UIImage(data: data)
        
        
        itemImageView.layer.cornerRadius = itemImageView.frame.height/2
        itemImageView.clipsToBounds = true
        
        dateLabel.text = dateFormatter.string(from: item.dateOfCreation)
        nameLabel.text = item.name
        descriptionLabel.text = item.itemDescription
        
    }
}

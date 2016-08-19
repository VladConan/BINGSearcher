//
//  SearchTableViewCell.swift
//  searcher
//
//  Created by Vlad Konon on 07.07.16.
//  Copyright © 2016 Vladimir Konon. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var briefLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        titleLabel.text = ""
        briefLabel.text = ""
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Daria on 07.06.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
}

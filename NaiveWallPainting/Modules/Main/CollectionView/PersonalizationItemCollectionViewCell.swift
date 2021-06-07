//
//  PersonalizationItemCollectionViewCell.swift
//  NaiveWallPainting
//
//  Created by Hrvoje Baic on 07.06.2021..
//

import UIKit

final class PersonalizationItemCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    override var isSelected: Bool {
        didSet {
            if isSelected != oldValue {
                set(selected: isSelected, animated: true)
            }
        }
    }

    // MARK: - Outlets

    @IBOutlet var borderView: UIView!
    @IBOutlet var selectedImage: UIImageView!
    @IBOutlet var colorView: UIView!
    @IBOutlet var avatarView: UIImageView!

    // MARK: - Helpers

    private func set(selected: Bool, animated: Bool) {

        selectedImage.isHidden = !selected

        var fromValue: CGFloat
        var toValue: CGFloat
        var imageTransform: CGAffineTransform
        if selected {
            fromValue = 2
            toValue = 8
            imageTransform = .identity
        } else {
            fromValue = 8
            toValue = 2
            imageTransform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }

        if animated {
            let animation = CABasicAnimation(keyPath: "borderWidth")
            animation.duration = 0.3
            animation.fromValue = fromValue
            animation.toValue = toValue
            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false
            borderView.layer.add(animation, forKey: "borderWidth")
        } else {
            borderView.layer.borderWidth = toValue
        }

        UIView.animate(withDuration: 0.3) {
            self.selectedImage.transform = imageTransform
        }
    }

    func configureWith(avatar: UIImage) {
        bringSubviewToFront(avatarView)
        colorView.backgroundColor = .clear
        avatarView.isHidden = false
        avatarView.image = avatar
    }

    func configureWith(color: UIColor) {
        bringSubviewToFront(colorView)
        colorView.isHidden = false
        colorView.backgroundColor = color
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        borderView.layer.cornerRadius = borderView.bounds.height / 2
        borderView.layer.masksToBounds = true
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.borderWidth = 2
        set(selected: false, animated: false)

        selectedImage.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
}

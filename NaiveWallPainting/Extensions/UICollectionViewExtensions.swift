//
//  UICollectionViewExtensions.swift
//  NaiveWallPainting
//
//  Created by Hrvoje Baic on 07.06.2021..
//

import UIKit

public extension UICollectionViewCell {

    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
    static var nibName: String {
        return String(describing: self)
    }
}

extension UICollectionView {

    func registerWithNib<T: UICollectionViewCell>(_ cellClassType: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)

        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }

        return cell
    }
}

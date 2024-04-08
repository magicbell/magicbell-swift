//
// By downloading or using this software made available by MagicBell, Inc.
// ("MagicBell") or any documentation that accompanies it (collectively, the
// "Software"), you and the company or entity that you represent (collectively,
// "you" or "your") are consenting to be bound by and are becoming a party to this
// License Agreement (this "Agreement"). You hereby represent and warrant that you
// are authorized and lawfully able to bind such company or entity that you
// represent to this Agreement.  If you do not have such authority or do not agree
// to all of the terms of this Agreement, you may not download or use the Software.
//
// For more information, read the LICENSE file.
//

import UIKit

public class BadgeBarButtonItem: UIBarButtonItem {

    @IBInspectable public var badgeNumber: Int = 0 {
        didSet {
            self.updateBadge()
        }
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .red
        label.alpha = 0.9
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.layer.zPosition = 1
        return label
    }()

    private func updateBadge() {
        guard let view = self.value(forKey: "view") as? UIView else { return }

        self.label.text = "\(badgeNumber)"

        if self.badgeNumber > 0 && self.label.superview == nil {
            view.addSubview(self.label)

            self.label.widthAnchor.constraint(equalToConstant: 18).isActive = true
            self.label.heightAnchor.constraint(equalToConstant: 18).isActive = true
            self.label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 9).isActive = true
            self.label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -9).isActive = true
        } else if self.badgeNumber == 0 && self.label.superview != nil {
            self.label.removeFromSuperview()
        }
    }
}

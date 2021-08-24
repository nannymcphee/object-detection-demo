//
//  UIView+Ext.swift
//  Object Detector
//
//  Created by Duy Nguyen on 21/08/2021.
//

import UIKit

extension UIView {
    func dropShadow(color: UIColor, alpha: Float, x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / 2
        
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
    func dropShadow(cornerRadius: CGFloat, color: UIColor, alpha: Float, x: CGFloat, y: CGFloat, blur: CGFloat, spread: CGFloat) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = alpha
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowRadius = blur / 2
        
        if spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
        }
    }
    
    func doBounceAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 15)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform(translationX: 0, y: -15)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    self.transform = .identity
                }
            }
            
        }
    }
    
    func doLightBounceAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 4)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
    
    func doLightBounceAnimation(x: CGFloat, y: CGFloat) {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(translationX: x, y: y)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
    
    func doZoomAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }
    
    func setHiddenWithAnim(_ isHidden: Bool) {
        UIView.transition(with: self, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.isHidden = isHidden
        }, completion: nil)
    }
    
    func doShakeAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 5, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 5, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
    func doRotateAnimation(duration: TimeInterval) {
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveLinear], animations: {
                        let angle = Double.pi
                        self.transform = self.transform.rotated(by: CGFloat(angle))
        })
    }
    
    func customRounded(border: CGFloat, color: UIColor) {
        self.layer.borderWidth = border
        self.layer.masksToBounds = false
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    
    func customBorder(cornerRadius: CGFloat, borderWidth: CGFloat, color: UIColor) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func roundCorners(_ corners: UIRectCorner,_ cornerMask: CACornerMask, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask
        } else {
            self.clipsToBounds = true
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.frame
            rectShape.position = self.center
            rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
            self.layer.mask = rectShape
        }
    }
    
    func layerGradientVertical(color1: UIColor, color2: UIColor) {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func layerGradientHorizontal(color1: UIColor, color2: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func layerGradientHorizontal(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.compactMap({$0.cgColor})
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // retrieves all constraints that mention the view
    func getAllConstraints() -> [NSLayoutConstraint] {
        
        // array will contain self and all superviews
        var views = [self]
        
        // get all superviews
        var view = self
        while let superview = view.superview {
            views.append(superview)
            view = superview
        }
        
        // transform views to constraints and filter only those
        // constraints that include the view itself
        return views.flatMap({ $0.constraints }).filter { constraint in
            return constraint.firstItem as? UIView == self ||
                constraint.secondItem as? UIView == self
        }
    }
    
    // Example 1: Get all width constraints involving this view
    // We could have multiple constraints involving width, e.g.:
    // - two different width constraints with the exact same value
    // - this view's width equal to another view's width
    // - another view's height equal to this view's width (this view mentioned 2nd)
    func getWidthConstraints() -> [NSLayoutConstraint] {
        return getAllConstraints().filter( {
            ($0.firstAttribute == .width && $0.firstItem as? UIView == self) ||
                ($0.secondAttribute == .width && $0.secondItem as? UIView == self)
        } )
    }
    
    func getLeadingConstraints() -> NSLayoutConstraint {
        return getAllConstraints().filter( {
            ($0.firstAttribute == .leading && $0.firstItem as? UIView == self) ||
                ($0.secondAttribute == .leading && $0.secondItem as? UIView == self)
        } ).first!
    }
    
    // Example 2: Change width constraint(s) of this view to a specific value
    // Make sure that we are looking at an equality constraint (not inequality)
    // and that the constraint is not against another view
    func changeWidth(to value: CGFloat) {
        
        getAllConstraints().filter( {
            $0.firstAttribute == .width &&
                $0.relation == .equal &&
                $0.secondAttribute == .notAnAttribute
        } ).forEach( {$0.constant = value })
    }
    
    func changeSize(to value: CGFloat) {
        changeWidth(to: value)
        changeHeight(to: value)
    }
    
    // Example 3: Change leading constraints only where this view is
    // mentioned first. We could also filter leadingMargin, left, or leftMargin
    func changeLeading(to value: CGFloat) {
        getAllConstraints().filter( {
            $0.firstAttribute == .leading &&
                $0.firstItem as? UIView == self
        }).forEach({$0.constant = value})
    }
    
    func getHeightConstraints() -> [NSLayoutConstraint] {
        return getAllConstraints().filter( {
            ($0.firstAttribute == .height && $0.firstItem as? UIView == self) ||
                ($0.secondAttribute == .height && $0.secondItem as? UIView == self)
        } )
    }
    
    func changeHeight(to value: CGFloat) {
        getAllConstraints().filter( {
            $0.firstAttribute == .height &&
                $0.relation == .equal &&
                $0.secondAttribute == .notAnAttribute
        } ).forEach( {$0.constant = value })
    }
}

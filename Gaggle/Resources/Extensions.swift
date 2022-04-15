//
//  Extensions.swift
//  Gaggle
//
//  Created by Frank Dulko on 3/2/22.
//

import Foundation
import UIKit
import SwiftUI

extension Color{
    public static var gaggleGreen: Color {
        return Color(UIColor(red: 151/255, green: 255/255, blue: 138/255, alpha: 1.0))
    }
    
    public static var gaggleGray: Color {
        return Color(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0))
    }
    
    public static var gaggleWhite: Color {
        return Color(UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0))
    }
    
    public static var gaggleYellow: Color {
        return Color(UIColor(red: 218/255, green: 255/255, blue: 138/255, alpha: 1.0))
    }
    
    public static var gaggleOrange: Color {
        return Color(UIColor(red: 255/255, green: 152/255, blue: 85/255, alpha: 1.0))
    }
}

extension UIImage {
    
//    public func aspectFittedToHeight(height: Int) -> UIImage{
//        var image = self
//        
//        
//        return UIImage()
//    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

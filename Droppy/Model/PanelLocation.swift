//
//  PanelLocation.swift
//  Droppy
//
//  Created by Victor Johnson on 5/14/26.
//

import Foundation

enum PanelLocation : String, CaseIterable, Identifiable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case custom
    
    var id: Self { self }
}


//enum ChartSpan : String, AppEnum, CaseIterable, Identifiable {
//    case day
//    case week
//    
//    var id: Self { self }
//    
//    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Chart Span"
//    static var caseDisplayRepresentations: [ChartSpan: DisplayRepresentation] = [
//        .day: "Days",
//        .week: "Weeks"
//    ]
//    
//    var component: Calendar.Component {
//        switch self {
//        case .day: .day
//        case .week: .weekOfYear
//        }
//    }
//    
//    var defaultCount: Int {
//        switch self {
//        case .day: 30
//        case .week: 12
//        }
//    }
//}

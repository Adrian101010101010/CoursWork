//
//  TrainerViewFactory.swift
//  CoursWork
//
//  Created by Adrian on 17.11.2025.
//

import UIKit

enum TrainerViewType {
    case create
    case view
    case records
}

final class TrainerViewFactory {
    
    static func createView(type: TrainerViewType) -> UIView {
        switch type {
        case .create:
            return CreateSectionFormView()
        case .view:
            return MySectionsView()
        case .records:
            return BookingsView()
        }
    }
}

//
//  RecordsStrategy.swift
//  CoursWork
//
//  Created by Adrian on 17.11.2025.
//

import UIKit

final class RecordsStrategy: TrainerViewStrategy {
    func createView() -> UIView {
        return TrainerViewFactory.createView(type: .records)
    }
}

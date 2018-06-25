//
//  GCDBlackBox.swift
//  On the Map
//
//  Created by Anthony Lee on 6/25/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

//
//  Array+.swift
//  Mulitmodal Learning
//
//  Created by xo on 04.07.22.
//

import Foundation

extension Array {
    func first(_ count: Int) -> Array {
        return Array(self.prefix(count))
    }
    
    func last(_ count: Int) -> Array {
        return Array(self.suffix(count))
    }
    
    func get(from: Int, to: Int) -> Array {
        Array(self[from..<to])
    }
}

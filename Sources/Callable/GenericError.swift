//
//  GenericError.swift
//  
//
//  Created by Scott Lydon on 4/3/21.
//

import Foundation

public struct GenericError: Error {
    public var text: String
    public var errorWithoutFunc: String

    public init(function: String = #function, error: Error, text: String) {
        self.errorWithoutFunc = error.localizedDescription + "\nError: " + text
        self.text = "\n" + function + "\n" + errorWithoutFunc
    }

    public init(function: String = #function, text: String) {
        self.errorWithoutFunc = text
        self.text = function + "\n" + errorWithoutFunc
    }

    public init(function: String = #function, error: Error) {
        self.errorWithoutFunc = error.localizedDescription
        self.text = function + "\n" + errorWithoutFunc
    }

    public var localizedDescription: String {
        self.text
    }
}

extension GenericError: LocalizedError {
    public var errorDescription: String? {
        errorWithoutFunc
    }
}

//
//  File.swift
//  
//
//  Created by Scott Lydon on 4/3/21.
//

import Foundation
#if canImport(FoundationNetworking)
// Provided for `URL` related objects on Linux platforms.
import FoundationNetworking
#endif

public typealias DataAction = (Data) -> Void
public typealias PromiseAction = (Data?, URLResponse?, Error?) -> Void
public typealias DictionaryAction = ([String: Any]) -> Void
public typealias StringAction = (String) -> Void
public typealias ErrorHandler = (Error) -> Void
public typealias AnyHandler = (Any) -> Void

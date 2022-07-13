import Foundation

public typealias Callable = ProvidesSessionDataTask & HasAbsoluteString

public protocol ProvidesSessionDataTask {
    func session(_ promiseAction: @escaping PromiseAction) -> URLSessionDataTask
}

public protocol HasAbsoluteString {
    var absoluteString: String { get }
}

public protocol ProvidesSessionDownloadDataTask {
    func session(_ downloadCompletion: @escaping DownloadCompletion) -> URLSessionDownloadTask
}

extension ProvidesSessionDataTask where Self: HasAbsoluteString {

    /// attempts to get data from a Callable resource
    /// - Parameter dataAction: access the data here.  Passes nil if could not get the data.
    public func getData(_ dataAction: DataAction? = nil) {
        sessionDataTask(provideData: dataAction).resume()
    }

    /// Attempts to get JSON from a callable resource
    /// - Parameter jsonAction: access the JSON here.  Passes nil if could not get JSON.
    public func callJSON(_ jsonAction: DictionaryAction? = nil) {
        sessionDataTask(provideJSON: jsonAction, errorHandler: { error in
            print(error)
        }).resume()
    }

    /// Attempts to get a codable instance from a callable resource
    /// - Parameters:
    ///   - expressive: If you would like debug information set expressive to true.
    ///   - action: access the codable resource here.  Passes nil if could not get the codable resource.
    public func callCodable<T: Codable>(expressive: Bool = false, _ action: @escaping (T?)->Void) {
        getData { data in
            if expressive && T(data) == nil {
                print("failed: ", data, data.jsonDictionary )
            }
            action(T(data))
        }
    }

    /// Attempts to get either one or another codable instance from a callable resource.
    /// - Parameter action: If the `First` instance is not nil then the `Second` Type will be nil and vice versa.
    ///        If neither could be converted from the data, then both will be nil.
    public func callCodable<First: Codable, Second: Codable>(_ action: @escaping (First?, Second?)->Void) {
        getData { data in
            action(First(data), Second(data))
        }
    }



    private func sessionDataTask(expressive: Bool = false, provideData: DataAction?) -> URLSessionDataTask {
        session { data, response, error in
            guard let data = data else {
                errorPrint()
                provideData?("error: \(error?.localizedDescription ?? "nil")".data(using: .utf8)!)
                return
            }
            provideData?(data)
        }
    }

    private func errorPrint() {
        print("ERROR: data was nil for the call from: \(self), ")
    }

    private func sessionDataTask(provideString: StringAction?) -> URLSessionDataTask {
        session { data, response, error in
            guard let data = data, error == nil, let document = String(data: data, encoding: .utf8) else {
                errorPrint()
                provideString?("")
                return
            }
            provideString?(document)
        }
    }

    private func sessionDataTask(
        provideJSON: DictionaryAction?,
        errorHandler: @escaping ErrorHandler
    ) -> URLSessionDataTask {
        session {
            data, response, error in
            guard let data = data else {
                errorPrint()
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("Warning: we were able to serialize the json but not cast it a [String: Any]...This would seem imposible without catching an error.")
                    return
                }
                provideJSON?(json)
            } catch {
                errorHandler(error)
                print(error.localizedDescription, "for url: \(self)")
                provideJSON?([:])
            }
        }
    }
}

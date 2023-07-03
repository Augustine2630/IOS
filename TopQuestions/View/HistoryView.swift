import SwiftUI
import RealmSwift
import Foundation
import SwiftSoup
import UIKit

struct history: Identifiable {
    var id = UUID()
    var _id: Int
    var name: String = ""
    var status: String = ""
    var time: Date
    
    init(_id: Int, name: String, status: String, time: Date) {
        self._id = _id
        self.name = name
        self.status = status
        self.time = time
    }
}

struct historyPOJO: Decodable {
    var name: String = ""
    var time: String = ""
}

// MARK: - TopQuestionsView
struct HistoryView: View {
    let realm = try! Realm()
    let rest = Rest()
    
    @State var hi = [history]()
    @State private var showingAlert = false
    
    let dateFormatter = DateFormatter()
    let outputFormatter = DateFormatter()
    let inputDateFormatter = DateFormatter()
    
    private func title(name: String) -> String {
        let doc = try! SwiftSoup.parse(name)
        return try! doc.text()
    }
    
    var body: some View {
        NavigationView{
            List(hi) { h in
                Text(title(name: h.name) + " \nDate: " + dateFormatter.string(from: h.time))
            }
            .onAppear{
                let hists = realm.objects(History.self)
                let histsSorted = hists.sorted(by: \.time)
                for h in histsSorted {
                    self.hi.append(history(_id: 1, name: title(name: h.name), status: h.status, time: h.time))
                }
                dateFormatter.dateFormat = "dd-MM-yyyy"
                
                
            }
            .toolbar {
    
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Wipe history", action: {
                            try! realm.write {
                                realm.deleteAll()
                                hi.removeAll()
                            }
                        })
                        Button("Sync with cloud", action: {
                            rest.getStringFromHTTPRequest(urlString: "http://localhost:8080/api/history"){ result in
                                var json: String = try! result.get()
                                if let jsonData = json.data(using: .utf8) {
                                    do {
                                        let historyP = try JSONDecoder().decode([historyPOJO].self, from: jsonData)
                                        for h in historyP {
                                            outputFormatter.dateFormat = "dd-MM-yyyy"
                                            inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
                                            if let date = inputDateFormatter.date(from: h.time){
                                                let formattedDate = outputFormatter.string(from: date)
                                                
                                                let realm2 = try! Realm()
                                                try! realm2.write {
                                                    let date = Date()
                                                    let hoba = History(name: h.name, time: date)
                                                    var persistedObject = realm2.objects(History.self)
                                                    let p = persistedObject.where {
                                                        $0.name == h.name
                                                    }
                                                    if !p.isEmpty {
                                                        showingAlert = true
                                                        DispatchQueue.main.async {
                                                            showAlert()
                                                        }
                                                        return
                                                    } else {
//                                                        print(p)
                                                        self.hi.append(history(_id: 1, name: title(name: h.name), status: "",
                                                                               time: date))
                                                        realm2.add(hoba)

                                                    }
                                                }
                                            }
                                        }
                                    } catch {
                                        print("Error parsing JSON: \(error)")
                                    }
                                }
                            }
                        })
                }
            }
        }
        .navigationTitle("History")
        
    }
    
    

    func addNew(his: [History]){
//        try! realm.write {
//            let date = Date()
//            let h = History(name: "a", time: date)
//            realm.add(h)
//        }
//        let t = realm.objects(History.self)
//        print(t)
        
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Alert", message: "History already sync", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // Present the alert
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    
}

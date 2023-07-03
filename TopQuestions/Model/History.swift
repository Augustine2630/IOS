import Foundation
import RealmSwift


class History: Object {
   @Persisted(primaryKey: true) var _id: ObjectId
   @Persisted var name: String = ""
   @Persisted var status: String = ""
   @Persisted var time: Date

   convenience init(name: String, time: Date) {
       self.init()
       self.name = name
       if #available(iOS 15, *) {
           self.time = Date.now
       } else {
           let date = Date()
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "dd/MM/yyyy"
           self.time = date
       }
   }
}


import SwiftUI
import RealmSwift
import Foundation
import SwiftSoup


// MARK: - QuestionView
struct QuestionView: View {
	@StateObject private var dataModel: QuestionDataModel
    let rest = Rest()
    
    let realm = try! Realm()
	
	init(question: Question) {
		let dataModel = QuestionDataModel(question: question)
		_dataModel = StateObject(wrappedValue: dataModel)
	}
	
    private var questionBody: String {
        let doc = try! SwiftSoup.parse(dataModel.question.body!)
        return try! doc.text()
    }
    
    @State var answer: String = ""
    
	var body: some View {
		ScrollView(.vertical) {
			LazyVStack(alignment: .leading) {
                Details(question: dataModel.question)
//                Text(dataModel.question)
				if dataModel.isLoading {
					ProgressView()
						.frame(maxWidth: .infinity, alignment: .center)
				} else {
                    if dataModel.question.body != nil {
						Text(questionBody)
                        
					}
					if let owner = dataModel.question.owner {
						Owner(user: owner)
							.frame(maxWidth: .infinity, alignment: .trailing)
					}
                    Text("Answer \n")
                        .font(.headline)
                    Text(answer)
                    
				}
			}
			.padding(.horizontal, 20.0)
		}
		.navigationTitle("Detail")
		.onAppear {
			dataModel.loadQuestion()
            addNew(name: dataModel.question.title)
            rest.getAnswerFromHTTPRequest(urlString: "http://localhost:8080/api/answer?id=" + String(dataModel.question.id)){ result in
                answer = try! result.get()
            }
            
		}
	}
    
    func addNew(name: String){
        try! realm.write {
            let date = Date()
            let h = History(name: name, time: date)
            let hoba = History(name: h.name, time: date)
            var persistedObject = realm.objects(History.self)
            let p = persistedObject.where {
                $0.name == h.name
            }
            if !p.isEmpty {
                return
            } else {
                realm.add(h)
            }
        }
    }
}

// MARK: - Owner
struct Owner: View {
	let user: User
	
	private var image: Image {
		guard let profileImage = user.profileImage else {
			return Image(systemName: "questionmark.circle")
		}
		return Image(uiImage: profileImage)
	}
	
	var body: some View {
		HStack(spacing: 16.0) {
			image
				.resizable()
				.frame(width: 48.0, height: 48.0)
				.cornerRadius(8.0)
				.foregroundColor(.secondary)
			VStack(alignment: .leading, spacing: 4.0) {
				Text(user.name ?? "")
					.font(.headline)
				Text(user.reputation?.thousandsFormatting ?? "")
					.font(.caption)
					.foregroundColor(.secondary)
			}
		}
		.padding(.vertical, 8.0)
       
	}
}

struct QuestionView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			QuestionView(question: TestData.Questions[0])
		}
		Owner(user: TestData.user)
			.previewLayout(.sizeThatFits)
	}
}

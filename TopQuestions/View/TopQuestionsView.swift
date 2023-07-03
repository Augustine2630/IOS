import SwiftUI
import RealmSwift
import SwiftSoup
import Foundation


// MARK: - TopQuestionsView
struct TopQuestionsView: View {
	@StateObject private var dataModel = QuestionsDataModel()
    @Binding var signInSuccess: Bool
	
    let realm = try! Realm()
    let rest = Rest()
    
	var body: some View {
        NavigationView {
            List(dataModel.questions) { question in
                NavigationLink(destination: QuestionView(question: question)) {
                    Details(question: question)
                }
            }
            .navigationTitle("Questions")
            .onAppear {
                dataModel.fetchTopQuestions()
//                print(String(data: rest.getHistoryFromCloud(), encoding: .utf8)!)
            
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink(destination: HistoryView()) {
                        Text("History")
                    }
                }
            }
        }
	}
    
    
}

// MARK: - Details
struct Details: View {
	let question: Question

    private var title: String {
        let doc = try! SwiftSoup.parse(question.title)
        return try! doc.text()
    }
	
	private var tags: String {
		question.tags[0] + question.tags.dropFirst().reduce("") { $0 + ", " + $1 }
        
	}
	
    var body: some View {
		VStack(alignment: .leading, spacing: 8.0) {
            Text(title)
				.font(.headline)
			Text(tags)
				.font(.footnote)
				.bold()
				.foregroundColor(.accentColor)
			Text(question.date.formatted)
				.font(.caption)
				.foregroundColor(.secondary)
			ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
				Label("\(question.score.thousandsFormatting)", systemImage: "arrowtriangle.up.circle")
				Label("\(question.answerCount.thousandsFormatting)", systemImage: "ellipses.bubble")
					.padding(.leading, 108.0)
				Label("\(question.answerCount.thousandsFormatting)", systemImage: "eye")
					.padding(.leading, 204.0)
			}
			.foregroundColor(.teal)
		}
		.padding(.top, 24.0)
		.padding(.bottom, 16.0)
        
	}
    
}


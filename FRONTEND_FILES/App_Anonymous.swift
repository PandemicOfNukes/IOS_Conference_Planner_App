import SwiftUI

struct ArticleSched_Anonymous: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var author: String
    var content: String
    private enum CodingKeys: String, CodingKey {
        case id = "ArticleID"
        case title = "Title"
        case author = "Author"
        case content = "Content"
    }
}

struct Schedule_Anonymous: Identifiable, Codable {
    var id: String
    var trackName: String
    var contentResumo: String
    var schedDay: String
    var startTime: String
    var endTime: String
    var room: String
    var article: ArticleSched_Anonymous

    private enum CodingKeys: String, CodingKey {
        case id = "ScheduleID"
        case trackName = "TrackName"
        case contentResumo = "ContentResumo"
        case schedDay = "SchedDay"
        case startTime = "StartTime"
        case endTime = "EndTime"
        case room = "Room"
        case articleID = "ArticleID"
        case articleTitle = "ArticleTitle"
        case articleAuthor = "ArticleAuthor"
        case articleContent = "ArticleContent"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        trackName = try container.decode(String.self, forKey: .trackName)
        contentResumo = try container.decode(String.self, forKey: .contentResumo)
        schedDay = try container.decode(String.self, forKey: .schedDay)
        startTime = try container.decode(String.self, forKey: .startTime)
        endTime = try container.decode(String.self, forKey: .endTime)
        room = try container.decode(String.self, forKey: .room)

        let articleID = try container.decode(String.self, forKey: .articleID)
        let articleTitle = try container.decode(String.self, forKey: .articleTitle)
        let articleAuthor = try container.decode(String.self, forKey: .articleAuthor)
        let articleContent = try container.decode(String.self, forKey: .articleContent)
        article = ArticleSched_Anonymous(id: articleID, title: articleTitle, author: articleAuthor, content: articleContent)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(trackName, forKey: .trackName)
        try container.encode(contentResumo, forKey: .contentResumo)
        try container.encode(schedDay, forKey: .schedDay)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(room, forKey: .room)
        try container.encode(article.id, forKey: .articleID)
        try container.encode(article.title, forKey: .articleTitle)
        try container.encode(article.author, forKey: .articleAuthor)
        try container.encode(article.content, forKey: .articleContent)
    }
}

struct ScheduleResponse_Anonymous: Codable {
    let status: String
    let schedules: [Schedule_Anonymous]
    private enum CodingKeys: String, CodingKey {
        case status
        case schedules
    }
}

struct Question_Anonymous: Identifiable, Codable {
    var id: Int
    var pergunta: String
    var userName: String

    private enum CodingKeys: String, CodingKey {
        case id = "PerguntaID"
        case pergunta = "Pergunta"
        case userName = "UserName"
    }
}

class ScheduleManager_Anonymous: ObservableObject {
    @Published var schedules2: [Schedule_Anonymous] = []

    func fetchSchedules() {
        guard let url = URL(string: "http://\(IP.ip)/Schedule.php") else {
            print("Invalid URL for fetching schedules")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let result = try JSONDecoder().decode(ScheduleResponse_Anonymous.self, from: data)
                DispatchQueue.main.async {
                    self.schedules2 = result.schedules
                }
            } catch {
                print("Error decoding JSON for schedules: \(error)")
            }
        }.resume()
    }
}

struct AppAnonymousView: View {
    @StateObject private var scheduleManager = ScheduleManager_Anonymous()
    @State private var searchText = ""

    var filteredSchedules: [Schedule_Anonymous] {
        if searchText.isEmpty {
            return scheduleManager.schedules2
        } else {
            return scheduleManager.schedules2.filter {
                $0.trackName.localizedCaseInsensitiveContains(searchText) ||
                $0.schedDay.localizedCaseInsensitiveContains(searchText) ||
                $0.contentResumo.localizedCaseInsensitiveContains(searchText) ||
                $0.startTime.localizedCaseInsensitiveContains(searchText) ||
                $0.endTime.localizedCaseInsensitiveContains(searchText) ||
                $0.room.localizedCaseInsensitiveContains(searchText) ||
                $0.article.title.localizedCaseInsensitiveContains(searchText) ||
                $0.article.author.localizedCaseInsensitiveContains(searchText) ||
                $0.article.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            List(filteredSchedules) { schedule in
                NavigationLink(destination: ScheduleDetailsAnonymousView(schedule: schedule)) {
                    VStack(alignment: .leading) {
                        Text("Dia: \(schedule.schedDay) - Sala: \(schedule.room)")
                            .font(.headline)
                        Text("Track: \(schedule.trackName)")
                            .font(.headline)
                        Text("Resumo: \(schedule.contentResumo)")
                            .font(.headline)
                        Text("Horário: \(schedule.startTime) - \(schedule.endTime)")
                            .font(.headline)
                        Text("Artigo: \(schedule.article.title) POR \(schedule.article.author)")
                            .foregroundColor(.blue)
                    }
                }
            }
            .onAppear {
                scheduleManager.fetchSchedules()
            }
            .navigationBarTitle("Horários")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                HStack {
                    SearchBar_Anonymous(text: $searchText)
                        .frame(width: 180)
                }
            )
        }
    }
}

struct SearchBar_Anonymous: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.vertical, 8)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.primary)
            Image(systemName: "magnifyingglass")
                .padding(.trailing, 8)
                .foregroundColor(.gray)
        }
    }
}


struct ScheduleDetailsAnonymousView: View {
    var schedule: Schedule_Anonymous
    @State private var questions: [Question_Anonymous] = []
    @State private var isPDFPresent: Bool = false
    @State private var pdfName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DetailRow(key: "Track", value: schedule.trackName)
            DetailRow(key: "Dia", value: schedule.schedDay)
            DetailRow(key: "Horas", value: "\(schedule.startTime) - \(schedule.endTime)")
            DetailRow(key: "Sala", value: schedule.room)
            DetailRow(key: "Título Do Artigo", value: schedule.article.title)
            DetailRow(key: "Autor Do Artigo", value: schedule.article.author)
            DetailRow(key: "Conteudo Do Artigo", value: schedule.article.content)

            Text("Perguntas:")
            .font(.headline)
            ForEach(questions) { question in
                Text("\(question.userName) perguntou: \(question.pergunta)")
                .font(.subheadline)
            }
            
            if isPDFPresent, let pdfName = pdfName {
                Button(action: {
                    if let url = URL(string: "http://\(IP.ip)/PDF/\(pdfName)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Ver PDF")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }


            Spacer()
        }
        .navigationTitle("Detalhes Do Horário")
        .onAppear {
            fetchQuestions()
            checkPDFPresence()
        }
    }

    private func fetchQuestions() {
        guard let url = URL(string: "http://\(IP.ip)/Perguntas_Artigos.php?articleID=\(schedule.article.id)") else {
            print("Invalid URL for fetching questions")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let result = try JSONDecoder().decode(QuestionResponse_Anonymous.self, from: data)
                DispatchQueue.main.async {
                    self.questions = result.questions
                }
            } catch {
                print("Error decoding JSON for questions: \(error)")
            }
        }.resume()
    }
    
    private func checkPDFPresence() {
        guard let url = URL(string: "http://\(IP.ip)/check_pdf_presence.php?articleID=\(schedule.article.id)") else {
            print("Invalid URL for checking PDF presence")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(PDFPresenceResponse.self, from: data)
                DispatchQueue.main.async {
                    self.isPDFPresent = result.pdfPresent
                    self.pdfName = result.pdfName
                    print(self.isPDFPresent)
                }
            } catch {
                print("Error decoding JSON for PDF presence: \(error)")
            }
        }.resume()
    }

    private struct DetailRow: View {
        var key: String
        var value: String

        var body: some View {
            HStack {
                Text(key + ":")
                    .fontWeight(.bold)
                Text(value)
            }
            .font(.headline)
        }
    }
}

struct QuestionResponse_Anonymous: Codable {
    let status: String
    let questions: [Question_Anonymous]

    private enum CodingKeys: String, CodingKey {
        case status
        case questions = "perguntas"
    }
}

struct PDFPresenceResponse_Anonymous: Codable {
    let pdfPresent: Bool
    let pdfName: String?

    private enum CodingKeys: String, CodingKey {
        case pdfPresent = "pdfPresent"
        case pdfName = "pdfName"
    }
}

struct AppAnonymousView_Previews: PreviewProvider {
    static var previews: some View {
        AppAnonymousView()
    }
}


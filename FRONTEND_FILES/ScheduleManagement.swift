import SwiftUI

struct ArticleSched: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var author: String

    private enum CodingKeys: String, CodingKey {
        case id = "ArticleID"
        case title = "Title"
        case author = "Author"
    }
}

struct Schedule: Identifiable, Codable {
    var id: String
    var trackName: String
    var contentResumo: String
    var schedDay: String
    var startTime: String
    var endTime: String
    var room: String
    var article: ArticleSched

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
        article = ArticleSched(id: articleID, title: articleTitle, author: articleAuthor)
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
    }
}

struct ScheduleResponse: Codable {
    let status: String
    let schedules: [Schedule]

    private enum CodingKeys: String, CodingKey {
        case status
        case schedules
    }
}

struct ArticleResponse: Codable {
    let status: String
    let articles: [ArticleSched]

    private enum CodingKeys: String, CodingKey {
        case status
        case articles = "articles"
    }
}

struct ScheduleListView: View {
    @State private var schedules: [Schedule] = []
    @State private var articles: [ArticleSched] = []
    @State private var selectedArticle: ArticleSched?

    var body: some View {
        NavigationView {
            List(schedules) { schedule in
                NavigationLink(destination: ScheduleEditingView(schedule: schedule, articles: $articles)) {
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
                fetchSchedules()
                fetchArticles()
            }
            .navigationTitle("Horários")
            .navigationBarItems(trailing:
                NavigationLink(destination: ScheduleCreationView(articles: $articles)) {
                    Text("Criar Horário")
                }
            )
        }
    }

    func fetchSchedules() {
        guard let url = URL(string: "http://\(IP.ip)/Schedule.php") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let result = try JSONDecoder().decode(ScheduleResponse.self, from: data)
                DispatchQueue.main.async {
                    self.schedules = result.schedules
                }
            } catch {
                print("Error decoding JSON for schedules: \(error)")
            }
        }.resume()
    }

    func fetchArticles() {
        guard let url = URL(string: "http://\(IP.ip)/Artigos.php") else {
            print("Invalid URL for fetching articles")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let result = try JSONDecoder().decode(ArticleResponse.self, from: data)
                DispatchQueue.main.async {
                    self.articles = result.articles
                }
            } catch {
                print("Error decoding JSON for articles: \(error)")
            }
        }.resume()
    }

    struct ArticleResponse: Codable {
        let status: String
        let articles: [ArticleSched]

        private enum CodingKeys: String, CodingKey {
            case status
            case articles = "articles"
        }
    }
}

struct ScheduleEditingView: View {
    @State private var showAlert = false
    @State private var showAlert2 = false
    @State private var alertMessage = ""
    @State private var updatedSchedule: Schedule
    @State private var selectedArticleID: String?
    @Binding var articles: [ArticleSched]

    init(schedule: Schedule, articles: Binding<[ArticleSched]>) {
        _updatedSchedule = State(initialValue: schedule)
        _selectedArticleID = State(initialValue: schedule.article.id)
        _articles = articles
    }

    var body: some View {
        Form {
            Section(header: Text("Detalhes Do Horário")) {
                TextField("Track:", text: $updatedSchedule.trackName)
                
                TextField("Dia", text: $updatedSchedule.schedDay)
                    .onAppear {
                        updatedSchedule.schedDay = "\(updatedSchedule.schedDay)"
                    }
                
                TextField("Hora Inicio", text: $updatedSchedule.startTime)
                    .onAppear {
                        updatedSchedule.startTime = "\(updatedSchedule.startTime)"
                    }
                
                TextField("Hora Fim", text: $updatedSchedule.endTime)
                    .onAppear {
                        updatedSchedule.endTime = "\(updatedSchedule.endTime)"
                    }
                
                TextField("Sala", text: $updatedSchedule.room)
                TextField("Resumo", text: $updatedSchedule.contentResumo)
                
                TextField("ArtigoID", text: Binding(
                    get: { selectedArticleID ?? "" },
                    set: { selectedArticleID = $0 }
                ))
            }


            Section {
                Button("Salvar Mudanças") {
                    updateSchedule()
                }
                Button("Eliminar Horário") {
                    showAlert2 = true
                }
                .foregroundColor(.red)
                .alert(isPresented: $showAlert2) {
                    Alert(
                        title: Text("Eliminar Horário"),
                        message: Text("Tem a certeza de que pretende eliminar este Horário?"),
                        primaryButton: .destructive(Text("Eliminar")) {
                            deleteSchedule()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationTitle("Editar Horário")
        .onAppear {
            fetchArticles()
        }
        .alert(isPresented: $showAlert) {
                    Alert(title: Text("Successo"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func fetchArticles() {
        guard let url = URL(string: "http://\(IP.ip)/Artigos.php") else {
            print("Invalid URL for fetching articles")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let result = try JSONDecoder().decode(ArticleResponse.self, from: data)
                DispatchQueue.main.async {
                    self.articles = result.articles
                }
            } catch {
                print("Error decoding JSON for articles: \(error)")
            }
        }.resume()
    }

    private func updateSchedule() {
        guard let url = URL(string: "http://\(IP.ip)/update_schedule.php") else {
            print("Invalid URL or Schedule ID")
            return
        }

        //let scheduleID = updatedSchedule.id
        let articleID = selectedArticleID ?? ""

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            updatedSchedule.article.id = articleID

            let jsonData = try JSONEncoder().encode(updatedSchedule)
            request.httpBody = jsonData
        } catch {
            print("Error encoding schedule: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Server Response: \(responseString ?? "No response")")

                        if responseString?.contains("success") == true {
                            alertMessage = "Horário Atualizado Com Sucesso!"
                        } else {
                            alertMessage = "Horário Não Atualizado!"
                        }

                        showAlert = true
                    } else if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
        }.resume()
    }
    private func deleteSchedule() {
            guard let url = URL(string: "http://\(IP.ip)/delete_schedule.php") else {
                print("Invalid URL or Schedule ID")
                return
            }

            let scheduleID = updatedSchedule.id

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let data: [String: Any] = ["ScheduleID": scheduleID]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: data)
            } catch {
                print("Error encoding schedule data: \(error)")
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Server Response: \(responseString ?? "No response")")

                    DispatchQueue.main.async {
                        showAlert(message: "Horário deletado com sucesso!")
                    }
                } else if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }.resume()
        }

        // Function to show an alert
        private func showAlert(message: String) {
            let alert = UIAlertController(title: "Sucesso", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
}

struct ScheduleCreationView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    struct NewSchedule: Codable {
        var TrackName: String
        var ContentResumo: String
        var SchedDay: String
        var StartTime: String
        var EndTime: String
        var Room: String
        var ArticleID: String
    }

    @State private var newSchedule = NewSchedule(TrackName: "", ContentResumo: "", SchedDay: "", StartTime: "", EndTime: "", Room: "", ArticleID: "")
    @Binding var articles: [ArticleSched]

    var body: some View {
        Form {
            Section(header: Text("Detalhes Do Horário")) {
                TextField("Track:", text: $newSchedule.TrackName)
                TextField("Resumo:", text: $newSchedule.ContentResumo)
                TextField("Dia em formato Ano-Mes-Dia:", text: $newSchedule.SchedDay)
                TextField("Hora Inicio:", text: $newSchedule.StartTime)
                TextField("Hora Fim:", text: $newSchedule.EndTime)
                TextField("Sala:", text: $newSchedule.Room)
                TextField("ArtigoID:", text: $newSchedule.ArticleID)
            }

            Section {
                Button("Criar Horário") {
                    createSchedule()
                }
            }
        }
        .navigationTitle("Criar Horário")
        .alert(isPresented: $showAlert) {
                    Alert(title: Text("Successo"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
    }

    private func createSchedule() {
        guard let url = URL(string: "http://\(IP.ip)/create_schedule.php") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(newSchedule)
            request.httpBody = jsonData
        } catch {
            print("Error encoding schedule: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Server Response: \(responseString ?? "")")

                        if responseString?.contains("success") == true {
                            alertMessage = "Horário Criado!"
                        } else {
                            alertMessage = "Horário Não Criado!"
                        }

                        showAlert = true
                    } else if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
        }.resume()
    }
}


struct ScheduleListView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleListView()
    }
}

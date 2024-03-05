import SwiftUI

struct QuestionManagementUserView: View {
    @State private var questions: [Question] = []
    var articleID: String
    @State private var isAskingQuestion: Bool = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                List(questions) { question in
                    NavigationLink(destination: QuestionEditingView(question: question, onClose: {
                        fetchQuestions()
                    })) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Utilizador: \(question.userName)")
                                .font(.headline)
                            Text(question.pergunta)
                                .font(.headline)
                        }
                    }
                }
                .onAppear {
                    fetchQuestions()
                }
                .navigationBarTitle("As suas perguntas")

                Button(action: {
                    isAskingQuestion = true
                }) {
                    Text("Faça uma pergunta")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                NavigationLink(destination: AskQuestionView(articleID: articleID), isActive: $isAskingQuestion) {
                    EmptyView()
                }
            }
            .padding()
            .navigationBarTitle("Questões que fez")
        }
    }

    func fetchQuestions() {
        guard let userID = UserDefaults.standard.string(forKey: "UserID") else {
            print("Invalid User for fetching questions")
            return
        }

        guard let url = URL(string: "http://\(IP.ip)/fetch_perguntas.php?userID=\(userID)&articleID=\(articleID)") else {
            print("Invalid URL for fetching questions")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let result = try JSONDecoder().decode(QuestionResponse.self, from: data)
                DispatchQueue.main.async {
                    self.questions = result.questions
                }
            } catch {
                print("Error decoding JSON for questions: \(error)")
            }
        }.resume()
    }
}

struct AskQuestionView: View {
    var articleID: String
    @State private var questionText: String = ""
    @State private var isQuestionSubmitted: Bool = false

    var body: some View {
        VStack {
            TextField("Escreva a sua pergunta", text: $questionText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.sentences)

            Button(action: {
                submitQuestion()
            }) {
                Text("Submita a sua pergunta")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(questionText.isEmpty)

            if isQuestionSubmitted {
                Text("Pergunta Feita Com Sucesso!")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .navigationTitle("Faça uma Pergunta")
    }

    private func submitQuestion() {
        let userID = UserDefaults.standard.integer(forKey: "UserID")

        if userID == 0 {
            print("User invalido")
            return
        }

        guard let url = URL(string: "http://\(IP.ip)/submit_question.php") else {
            print("Invalid URL for submitting questions")
            return
        }

        // Prepare the data to be sent as JSON
        let requestData: [String: Any] = [
            "userID": userID,
            "articleID": articleID,
            "question": questionText
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: requestData)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let rawResponse = String(data: data, encoding: .utf8)
                print("Raw Response: \(rawResponse ?? "")")

                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                if let success = json?["success"] as? Bool, success {
                    DispatchQueue.main.async {
                        self.isQuestionSubmitted = true
                    }
                } else {
                    print("Pergunta Falhou")
                }
            } catch {
                print("Error decoding JSON for question submission: \(error)")
            }
        }.resume()
    }
}

struct QuestionEditingView: View {
    var question: Question
    var onClose: () -> Void
    @State private var updatedQuestionText: String
    @State private var isUpdateSuccessful: Bool = false
    @State private var isDeleteConfirmationShowing: Bool = false

    init(question: Question, onClose: @escaping () -> Void) {
        self.question = question
        self.onClose = onClose
        _updatedQuestionText = State(initialValue: question.pergunta)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Editar Pergunta")) {
                    TextField("Edite a sua Pergunta aqui", text: $updatedQuestionText)
                }

                Section {
                    Button("Salvar Mudanças") {
                        saveChanges()
                    }
                }

                Section {
                    Button("Deletar Pergunta") {
                        isDeleteConfirmationShowing = true
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $isDeleteConfirmationShowing) {
                        Alert(
                            title: Text("Deletar Pergunta"),
                            message: Text("Tem a certeza que quer deletar esta Pergunta?"),
                            primaryButton: .destructive(Text("Deletar")) {
                                deleteQuestion()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .navigationBarTitle("Editar Pergunta")
            .alert(isPresented: $isUpdateSuccessful) {
                Alert(title: Text("Successo"), message: Text("Pergunta Editada Com Sucesso"), dismissButton: .default(Text("OK")) {
                    self.onClose()
                })
            }
        }
    }

    private func saveChanges() {
        guard !updatedQuestionText.isEmpty else {
            return
        }

        var updatedQuestion = question
        updatedQuestion.pergunta = updatedQuestionText

        guard let url = URL(string: "http://\(IP.ip)/update_question.php") else {
            print("Invalid URL for updating questions")
            return
        }

        // Prepare the data to be sent as JSON
        let requestData: [String: Any] = [
            "questionID": updatedQuestion.id,
            "updatedQuestion": updatedQuestionText
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: requestData)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                if let success = json?["success"] as? Bool, success {
                    DispatchQueue.main.async {
                        self.isUpdateSuccessful = true
                    }
                } else {
                    print("Question update failed")
                }
            } catch {
                print("Error decoding JSON for question update: \(error)")
            }
        }.resume()
    }
    
    private func deleteQuestion() {
            guard let url = URL(string: "http://\(IP.ip)/delete_question.php") else {
                print("Invalid URL for deleting questions")
                return
            }

            let requestData: [String: Any] = [
                "questionID": question.id
            ]

            let jsonData = try! JSONSerialization.data(withJSONObject: requestData)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                    if let success = json?["success"] as? Bool, success {
                        DispatchQueue.main.async {
                            self.isUpdateSuccessful = true
                        }
                    } else {
                        print("Pergunta Falhou a ser deletada")
                    }
                } catch {
                    print("Error decoding JSON for question deletion: \(error)")
                }
            }.resume()
        }
}


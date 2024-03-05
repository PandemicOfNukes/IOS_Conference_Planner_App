import SwiftUI

struct Pergunta: Identifiable, Codable {
    var id: Int
    var articleID: Int
    var userID: Int
    var UserName: String
    var pergunta: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "PerguntaID"
        case articleID = "ArticleID"
        case userID = "UserID"
        case UserName
        case pergunta = "Pergunta"
    }
}

struct PerguntaListView: View {
    @State private var perguntas: [Pergunta] = []
    
    var body: some View {
        NavigationView {
            List(perguntas) { pergunta in
                NavigationLink(destination: PerguntaEditingView(pergunta: pergunta)) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Utilizador: \(pergunta.UserName)")
                            .font(.headline)
                        Text(pergunta.pergunta)
                            .font(.headline)
                    }
                }
            }
            .onAppear {
                fetchPerguntas()
            }
            .navigationTitle("Perguntas")
        }
    }
    
    func fetchPerguntas() {
        guard let url = URL(string: "http://\(IP.ip)/Perguntas.php") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let jsonString = String(data: data, encoding: .utf8)
                print("Server Response: \(jsonString ?? "Unable to convert data to string")")
                
                let result = try JSONDecoder().decode(PerguntaResponse.self, from: data)
                DispatchQueue.main.async {
                    self.perguntas = result.perguntas
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }

    struct PerguntaResponse: Codable {
        let status: String
        let perguntas: [Pergunta]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            status = try container.decode(String.self, forKey: .status)
            perguntas = try container.decode([Pergunta].self, forKey: .perguntas)
        }
        
        private enum CodingKeys: String, CodingKey {
            case status
            case perguntas
        }
    }
}

struct PerguntaEditingView: View {
    @State private var updatedPergunta: Pergunta
    @State private var showAlert = false
    @State private var showAlert2 = false
    @State private var alertMessage = ""

    init(pergunta: Pergunta) {
        _updatedPergunta = State(initialValue: pergunta)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Detalhes Da Pergunta")) {
                TextField("Pergunta", text: $updatedPergunta.pergunta)
            }
            
            Section {
                Button("Guardar Alterações") {
                    updatePergunta()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Success"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Button("Eliminar Pergunta") {
                    showAlert2 = true
                }
                .foregroundColor(.red)
                .alert(isPresented: $showAlert2) {
                    Alert(
                        title: Text("Eliminar Pergunta"),
                        message: Text("Tem a certeza de que pretende eliminar esta pergunta?"),
                        primaryButton: .destructive(Text("Eliminar")) {
                            deletePergunta()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .navigationTitle("Editar Pergunta")
        }
    }

    func updatePergunta() {
        guard let url = URL(string: "http://\(IP.ip)/update_pergunta.php") else {
            print("Invalid URL or Pergunta ID")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(updatedPergunta)
            request.httpBody = jsonData
        } catch {
            print("Error encoding pergunta: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            print("Server Response: \(responseString ?? "Unable to convert data to string")")

            if responseString?.contains("success") == true {
                alertMessage = "Pergunta Atualizada Com Sucesso"
                showAlert = true
            } else {
                alertMessage = "Atualização Falhou"
                showAlert = true
            }
        }.resume()
    }

    func deletePergunta() {
        guard let url = URL(string: "http://\(IP.ip)/delete_pergunta.php") else {
            print("Invalid URL or Pergunta ID")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(updatedPergunta)
            request.httpBody = jsonData
        } catch {
            print("Error encoding pergunta: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            print("Server Response: \(responseString ?? "Unable to convert data to string")")

            if responseString?.contains("success") == true {
                alertMessage = "Pergunta Eliminada Com Sucesso"
                showAlert = true
            } else {
                alertMessage = "Pergunta Não Eliminada"
                showAlert = true
            }
        }.resume()
    }
}

struct PerguntaListView_Previews: PreviewProvider {
    static var previews: some View {
        PerguntaListView()
    }
}

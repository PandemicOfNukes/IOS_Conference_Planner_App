import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
import WebKit

struct Article: Identifiable, Codable {
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

struct ArticleDeleteResponse: Codable {
    let status: String
    let message: String
}

struct ArticleListView: View {
    @State private var articles: [Article] = []
    
    var body: some View {
        NavigationView {
            List(articles) { article in
                NavigationLink(destination: ArticleEditingView(article: article)) {
                    VStack(alignment: .leading) {
                        Text("ID Do Artigo: \(article.id)")
                            .font(.headline)
                        Text(article.title)
                            .font(.headline)
                        Text("Autor: \(article.author)")
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                fetchArticles()
            }
            .navigationTitle("Artigos")
            .navigationBarItems(trailing:
                                    NavigationLink(destination: ArticleCreationView()) {
                Text("Criar Artigo")
            }
            )
        }
    }
    
    func fetchArticles() {
        guard let url = URL(string: "http://\(IP.ip)/Artigos.php") else {
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
                
                let result = try JSONDecoder().decode(ArticleResponse.self, from: data)
                DispatchQueue.main.async {
                    self.articles = result.articles
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    
    
    struct ArticleResponse: Codable {
        let status: String
        let articles: [Article]
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            status = try container.decode(String.self, forKey: .status)
            articles = try container.decode([Article].self, forKey: .articles)
        }
        
        private enum CodingKeys: String, CodingKey {
            case status
            case articles
        }
    }
    
    struct ArticleEditingView: View {
        @State private var updatedArticle: Article
        @State private var showAlert = false
        @State private var showAlert2 = false
        @State private var alertMessage = ""
        
        init(article: Article) {
            _updatedArticle = State(initialValue: Article(id: article.id, title: article.title, author: article.author, content: article.content))
        }
        
        var body: some View {
            Form {
                Section(header: Text("Detalhes Do Artigo")) {
                    TextField("Titulo", text: $updatedArticle.title)
                    TextField("Autor", text: $updatedArticle.author)
                    TextEditor(text: $updatedArticle.content)
                }
                
                Section {
                    Button("Guardar Alterações") {
                        updateArticle()
                    }
                    Button("Eliminar Artigo") {
                        showAlert2 = true
                    }
                    .foregroundColor(.red)
                    .alert(isPresented: $showAlert2) {
                        Alert(
                            title: Text("Eliminar Artigo"),
                            message: Text("Tem a certeza de que pretende eliminar este artigo? Todos os Horários e Perguntas relacionado ao artigo serão eliminados!"),
                            primaryButton: .destructive(Text("Eliminar")) {
                                deleteArticle()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .navigationTitle("Editar Artigo")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Success"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        
        func updateArticle() {
            guard let url = URL(string: "http://\(IP.ip)/update_article.php") else {
                print("Invalid URL or Article ID")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                let jsonData = try JSONEncoder().encode(updatedArticle)
                request.httpBody = jsonData
            } catch {
                print("Error encoding article: \(error)")
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                    let responseString = String(data: data, encoding: .utf8)
                    print("Server Response: \(responseString ?? "Unable to convert data to string")")

                    alertMessage = "Artigo Atualizado Com Sucesso"
                    showAlert = true
            }.resume()
        }

        func deleteArticle() {
            guard let url = URL(string: "http://\(IP.ip)/delete_article.php") else {
                print("Invalid URL or Article ID")
                return
            }

            let articleID = updatedArticle.id

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            updatedArticle.id = articleID

            do {
                let jsonData = try JSONEncoder().encode(updatedArticle)
                request.httpBody = jsonData
            } catch {
                print("Error encoding article: \(error)")
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let result = try JSONDecoder().decode(ArticleDeleteResponse.self, from: data)
                        DispatchQueue.main.async {
                            if result.status == "success" {
                                alertMessage = "Artigo Eliminado Com Sucesso"
                                showAlert = true
                            }
                        }
                    } catch {
                        print("Error decoding JSON for delete response: \(error)")
                        alertMessage = "Erro ao processar a resposta do servidor"
                        showAlert = true
                    }
                } else if let error = error {
                    print("Error: \(error.localizedDescription)")
                    alertMessage = "Falha Ao Eliminar o Artigo"
                    showAlert = true
                }
            }.resume()
        }
        }
    }
    
    struct ArticleCreationView: View {
        struct NewArticle: Codable {
            var Title: String
            var Author: String
            var Content: String
        }
        
        @State private var newArticle = NewArticle(Title: "", Author: "", Content: "")
        @State private var showAlert = false
        @State private var alertMessage = ""
        
        var body: some View {
            Form {
                Section(header: Text("Detalhes Artigo")) {
                    TextField("Titulo", text: $newArticle.Title)
                    TextField("Autor", text: $newArticle.Author)
                    TextField("Conteudo",text: $newArticle.Content)
                }
                
                Section {
                    Button("Criar Artigo") {
                        createArticle()
                    }
                }
            }
            .navigationTitle("Criar Artigo")
            .alert(isPresented: $showAlert) {
                        Alert(title: Text("Success"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        
        func createArticle() {
            guard let url = URL(string: "http://\(IP.ip)/create_article.php") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let jsonData = try JSONEncoder().encode(newArticle)
                request.httpBody = jsonData
            } catch {
                print("Error encoding article: \(error)")
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Server Response: \(responseString ?? "")")
                    alertMessage = "Artigo Criado Com Sucesso"
                    showAlert = true
                } else if let error = error {
                    print("Error: \(error.localizedDescription)")
                    alertMessage = "Falha Ao Criar o Artigo"
                    showAlert = true
                }
            }.resume()
        }
    }


struct ArticleListView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleListView()
    }
}

import SwiftUI

struct User: Identifiable, Codable {
    var id: Int
    var email: String
    var fullName: String
    var username: String
    var password: String
    var isAdmin: Bool
    var canSpeak: Bool

    private enum CodingKeys: String, CodingKey {
        case id = "UserID"
        case email = "Email"
        case fullName = "NomeCompleto"
        case username = "Username"
        case password = "Passwd"
        case isAdmin = "IsAdmin"
        case canSpeak = "CanSpeak"
    }
}

struct UserListView: View {
    @State private var users: [User] = []

    var body: some View {
        NavigationView {
            List(users) { user in
                NavigationLink(destination: UserEditingView(user: user)) {
                    VStack(alignment: .leading) {
                        Text(user.fullName)
                            .font(.headline)
                        Text("Username: \(user.username)")
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                fetchUsers()
            }
            .navigationTitle("Users")
        }
    }

    func fetchUsers() {
        guard let url = URL(string: "http://\(IP.ip)/Users.php") else {
            print("URL Invalida")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let result = try JSONDecoder().decode(UserResponse.self, from: data)
                DispatchQueue.main.async {
                    self.users = result.users
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }

    struct UserResponse: Codable {
        let status: String
        let users: [User]
    }
}

struct UserEditingView: View {
    @State private var updatedUser: User
    @State private var showAlert = false
    @State private var showAlert2 = false
    @State private var alertMessage = ""

    init(user: User) {
        _updatedUser = State(initialValue: user)
    }

    var body: some View {
        Form {
            Section(header: Text("Detalhes Do Utilizador")) {
                TextField("Username", text: $updatedUser.username)
                Toggle("Admin", isOn: $updatedUser.isAdmin)
                Toggle("Pode Falar", isOn: $updatedUser.canSpeak)
            }

            Section {
                Button("Atualizar Utilizador") {
                    updateUser()
                }
                Button("Eliminar Utilizador") {
                    showAlert2 = true
                }
                .foregroundColor(.red)
                .alert(isPresented: $showAlert2) {
                    Alert(
                        title: Text("Eliminar Utilizador"),
                        message: Text("Tem a certeza de que pretende eliminar este utilizador? As suas perguntas tambem irão ser eliminadas!"),
                        primaryButton: .destructive(Text("Eliminar")) {
                            deleteUser()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .navigationTitle("Editar Utilizador")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Successo"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func updateUser() {
        guard let url = URL(string: "http://\(IP.ip)/update_user.php") else {
            print("Invalid URL or User ID")
            return
        }

        let userID = updatedUser.id

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        updatedUser.id = userID

        let jsonEncoder = JSONEncoder()
                do {
                    let jsonData = try jsonEncoder.encode(updatedUser)
                    request.httpBody = jsonData
                    print("Request JSON Data: \(String(data: jsonData, encoding: .utf8) ?? "")")
                } catch {
                    print("Error encoding user: \(error)")
                    return
                }


        URLSession.shared.dataTask(with: request) { data, response, error in
            handleResponse(data: data, error: error)
        }.resume()
    }

    func deleteUser() {
        guard let url = URL(string: "http://\(IP.ip)/delete_user.php") else {
            print("Invalid URL or User ID")
            return
        }

        let userID = updatedUser.id

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        updatedUser.id = userID

        do {
            let jsonData = try JSONEncoder().encode(updatedUser)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            handleResponse(data: data, error: error)
        }.resume()
    }

    private func handleResponse(data: Data?, error: Error?) {
        if let data = data {
            let responseString = String(data: data, encoding: .utf8)
            print("Server Response: \(responseString ?? "No response")")
            alertMessage = "Utilizador Atualizado/Deletado"
            showAlert = true
        } else if let error = error {
            print("Error: \(error.localizedDescription)")
            alertMessage = "Falhou Atualizar/Eliminar o Utilizador"
            showAlert = true
        }
    }
}

struct UserManagement_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}

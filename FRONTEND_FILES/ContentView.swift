import SwiftUI

struct IP {  //CHANGE TO RIGHT IP!
    static var ip = ""
}

struct ContentView: View {
    @State private var isLoggingIn = true
    @State private var anonimo = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("icone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()

                Text("Nome Da Empresa")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Text("Nome Da Conferência")
                    .foregroundColor(.gray)
                    .padding()

                if isLoggingIn {
                    LoginView()
                } else {
                    RegisterView()
                }

                Button(action: {
                    isLoggingIn.toggle()
                }) {
                    Text(isLoggingIn ? "Não tem uma conta? Registre-se" : "Já tem uma conta? Faça login")
                        .foregroundColor(.blue)
                        .padding()
                }
                
                Button("Ou pode fazer ir logo para a App anonimamente mas não pode fazer perguntas"){
                    anonimo=true
                }
                .background(
                    NavigationLink("", destination:AppAnonymousView(), isActive: $anonimo)
                        .hidden()
                )
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isAdmin = false
    @State private var errorMessage: String?
    @State private var navigateToList = false
    @State private var navigateToApp = false

    var body: some View {
        VStack {
            TextField("Nome de usuário", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Senha", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Text(errorMessage ?? "")
                .foregroundColor(.red)
                .padding()

            Button("Login") {
                loginUser()
            }
            .padding()

            NavigationLink("", destination: BackofficeView(), isActive:$navigateToList)

            NavigationLink("", destination: AppView(), isActive: $navigateToApp)
            .hidden()
        }
    }

    func loginUser() {
        guard let url = URL(string: "http://\(IP.ip)/login.php") else {
            errorMessage = "Erro interno. Tente novamente mais tarde."
            return
        }

        let body: [String: String] = [
            "username": username,
            "password": password
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let success = response?["success"] as? Bool, success {
                            if let isAdmin = response?["isAdmin"] as? Bool, let userID = response?["userID"] as? Int {
                                UserDefaults.standard.set(userID, forKey: "UserID")
                                if isAdmin {
                                    navigateToList = true
                                } else {
                                    navigateToApp = true
                                }
                            }
                        } else {
                            errorMessage = "Insira o username correto ou a password."
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                } else {
                    errorMessage = "Network error. Verifique a sua conexão"
                }
            }.resume()
                } catch {
                    errorMessage = "Erro interno. Tente novamente mais tarde."
                }
            }
}

struct RegisterView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var NomeCompleto = ""
    @State private var Email = ""
    @State private var registrationStatus: RegistrationStatus? = nil

    enum RegistrationStatus {
        case success, failure
    }

    func registerUser() {
        guard let url = URL(string: "http://\(IP.ip)/register.php") else { return }

        let body: [String: String] = [
            "NomeCompleto":NomeCompleto,
            "Email":Email,
            "username": username,
            "password": password
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let success = response?["success"] as? Bool, success {
                            self.registrationStatus = .success
                        } else {
                            self.registrationStatus = .failure
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                        self.registrationStatus = .failure
                    }
                } else {
                    self.registrationStatus = .failure
                }
            }.resume()
        } catch {
            print("Error creating JSON: \(error)")
            self.registrationStatus = .failure
        }
    }

    var body: some View {
        VStack {
            TextField("Nome Completo", text: $NomeCompleto)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Email", text: $Email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Register") {
                registerUser()
            }
            .padding()

            if let status = registrationStatus {
                Text(status == .success ? "Registro Bem-Sucedido" : "Houve algum problema. Tente novamente mais tarde")
                    .foregroundColor(status == .success ? .green : .red)
                    .padding()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import SwiftUI
import WebKit
struct WebViewContainer: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewContainer

        init(_ parent: WebViewContainer) {
            self.parent = parent
        }
    }
}

struct BackofficeView: View {
    @State private var isArticleManagementActive = false
    @State private var isScheduleManagementActive = false
    @State private var isUserManagementActive = false
    @State private var isQuestionManagementActive = false
    @State private var isAppManagementActive = false
    @State private var isWebViewActive = false

    var body: some View {
        NavigationView {
            VStack {
                Button("Fazer Manage De Artigos") {
                    isArticleManagementActive = true
                }
                .background(
                    NavigationLink("", destination: ArticleListView(), isActive: $isArticleManagementActive)
                        .hidden()
                )

                Button("Fazer Manage De Horários") {
                    isScheduleManagementActive = true
                }
                .background(
                    NavigationLink("", destination: ScheduleListView(), isActive: $isScheduleManagementActive)
                        .hidden()
                )
                
                Button("Fazer Manage De Utilizadores") {
                    isUserManagementActive = true
                }
                .background(
                    NavigationLink("", destination: UserListView(), isActive: $isUserManagementActive)
                        .hidden()
                )
                
                Button("Fazer Manage De Perguntas") {
                    isQuestionManagementActive = true
                }
                .background(
                    NavigationLink("", destination: PerguntaListView(), isActive: $isQuestionManagementActive)
                        .hidden()
                )
                
                Button("Fazer Upload De PDFs") {
                    isWebViewActive = true
                }
                .background(
                    NavigationLink("", destination: WebViewContainer(urlString: "http://\(IP.ip)/Index.html"), isActive: $isWebViewActive)
                    .hidden()
                )
                
                Button("Ir para a App") {
                    isAppManagementActive = true
                }
                .background(
                    NavigationLink("", destination: AppView(), isActive: $isAppManagementActive)
                        .hidden()
                )

                Spacer()
            }
            .navigationTitle("Backoffice")
            .padding()
        }
    }
}

struct BackOfficeView_Previews: PreviewProvider {
    static var previews: some View {
        BackofficeView()
    }
}


import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var notificationsEnabled = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)

            Text("NuDrop")
                .font(.largeTitle.bold())

            Text("Teste de notificações")
                .font(.headline)

            Button("Ativar notificações") {
                UNUserNotificationCenter.current()
                    .requestAuthorization(
                        options: [.alert, .sound, .badge]
                    ) { granted, _ in
                        DispatchQueue.main.async {
                            notificationsEnabled = granted
                        }
                    }
            }
            .buttonStyle(.borderedProminent)

            Text(notificationsEnabled
                 ? "Permissão concedida"
                 : "Aguardando permissão")
                .font(.caption)
        }
        .padding()
    }
}

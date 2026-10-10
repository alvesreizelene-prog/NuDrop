
import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var notificationsEnabled = false
    @State private var amount = "1.200,00"
    @State private var sender = "PAYMANTS BIT LTDA"
    @State private var count = "7"
    @State private var interval = "1"
    @State private var isMinutes = false
    @State private var status = "Pronto"

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 48))
                .foregroundColor(.purple)

            Text("NuDrop")
                .font(.largeTitle.bold())

            TextField("Valor (R$)", text: $amount)
                .textFieldStyle(.roundedBorder)

            TextField("Nome do remetente", text: $sender)
                .textFieldStyle(.roundedBorder)

            HStack {
                TextField("Quantidade", text: $count)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                TextField("Intervalo", text: $interval)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }

            Toggle("Intervalo em minutos", isOn: $isMinutes)

            Button("Ativar notificações") {
                UNUserNotificationCenter.current()
                    .requestAuthorization(
                        options: [.alert, .sound, .badge]
                    ) { granted, error in
                        DispatchQueue.main.async {
                            notificationsEnabled = granted
                            status = granted
                                ? "Permissão concedida"
                                : "Permissão não concedida"

                            if let error = error {
                                status = error.localizedDescription
                            }
                        }
                    }
            }
            .buttonStyle(.bordered)

            Button("Enviar notificação de teste") {
                sendTestNotification()
            }
            .buttonStyle(.borderedProminent)

            Text(status)
                .font(.caption)
                .multilineTextAlignment(.center)

            Spacer()

            Text("desenvolvido by jorranes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func sendTestNotification() {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                DispatchQueue.main.async {
                    status = "Ative as notificações nos Ajustes."
                }
                return
            }

            let delayValue = Double(
                interval.replacingOccurrences(of: ",", with: ".")
            ) ?? 1

            let delay = max(1, delayValue * (isMinutes ? 60 : 1))

            let content = UNMutableNotificationContent()
            content.title = "NuDrop — Teste"
            content.body = "Valor: R$ \(amount) | Remetente: \(sender)"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: delay,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            center.add(request) { error in
                DispatchQueue.main.async {
                    status = error == nil
                        ? "Notificação de teste agendada."
                        : "Erro ao agendar a notificação."
                }
            }
        }
    }
}

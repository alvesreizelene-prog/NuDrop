
import SwiftUI
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }
}

struct ContentView: View {
    @State private var amount = "1.200,00"
    @State private var sender = "PAYMANTS BIT LTDA"
    @State private var interval = "1"
    @State private var isMinutes = false
    @State private var status = "Pronto"

    private let center = UNUserNotificationCenter.current()

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
                TextField("Intervalo", text: $interval)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)

                Toggle("Minutos", isOn: $isMinutes)
                    .labelsHidden()

                Text("Minutos")
                    .font(.caption)
            }

            Button("Ativar notificações") {
                center.requestAuthorization(
                    options: [.alert, .sound, .badge]
                ) { granted, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            status = "Erro: \(error.localizedDescription)"
                        } else {
                            status = granted
                                ? "Permissão concedida"
                                : "Permissão negada nos Ajustes"
                        }
                    }
                }
            }
            .buttonStyle(.bordered)

            Button("Enviar notificação ") {
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
        .onAppear {
            center.delegate = NotificationDelegate.shared
        }
    }

    private func sendTestNotification() {
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized ||
                  settings.authorizationStatus == .provisional else {
                DispatchQueue.main.async {
                    status = "Ative as notificações nos Ajustes."
                }
                return
            }

            let value = Double(
                interval.replacingOccurrences(of: ",", with: ".")
            ) ?? 1

            guard value > 0 else {
                DispatchQueue.main.async {
                    status = "Digite um intervalo maior que zero."
                }
                return
            }

            let delay = max(1, value * (isMinutes ? 60 : 1))

            let content = UNMutableNotificationContent()
            content.title = "Transferência recebida"
            content.body = "Você recebeu R$ \(amount) de \(sender)."
            content.sound = .default
            if let imageURL = Bundle.main.url(
    forResource: "logo",
    withExtension: "png"
) {
    do {
        let attachment = try UNNotificationAttachment(
            identifier: "logo",
            url: imageURL,
            options: nil
        )
        content.attachments = [attachment]
    } catch {
        print("Erro ao anexar imagem: \(error)")
    }
}
                                        

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
                    status = error.map {
                        "Erro: \($0.localizedDescription)"
                    } ?? "Teste agendado para daqui a \(Int(delay)) segundo(s)."
                }
            }
        }
    }
}

extension NotificationDelegate {
    static let shared = NotificationDelegate()
}

import SwiftUI
import UserNotifications

@main
struct NuDropApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

struct ContentView: View {
    @State private var amount: String = "1.200,00"
    @State private var sender: String = "PAYMANTS BIT LTDA"
    @State private var count: String = "7"
    @State private var interval: String = "1"
    @State private var isMinutes: Bool = false
    @State private var isRunning: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Notf jorranesDEV")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Altere o valor (R$)")
                    .font(.caption)
                    .foregroundColor(.gray)
                TextField("1.200,00", text: $amount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Altere o nome / remetente")
                    .font(.caption)
                    .foregroundColor(.gray)
                TextField("PAYMANTS BIT LTDA", text: $sender)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            HStack {
                Button(action: { isMinutes = false }) {
                    Text("Segundos")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isMinutes ? Color.gray : Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: { isMinutes = true }) {
                    Text("Minutos")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isMinutes ? Color.purple : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Quantidade").font(.caption).foregroundColor(.gray)
                    TextField("7", text: $count).textFieldStyle(RoundedBorderTextFieldStyle()).keyboardType(.numberPad)
                }
                VStack(alignment: .leading) {
                    Text("Intervalo").font(.caption).foregroundColor(.gray)
                    TextField("1", text: $interval).textFieldStyle(RoundedBorderTextFieldStyle()).keyboardType(.numberPad)
                }
            }
            .padding(.horizontal)
            
            Button(action: {
                requestPermissionAndFire()
            }) {
                Text(isRunning ? "Parar" : "Disparar")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text("desenvolvido by jorranes")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    func requestPermissionAndFire() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.fireNotifications()
                }
            }
        }
    }
    
    func fireNotifications() {
        let total = Int(count) ?? 7
        let delay = Double(interval) ?? 1.0
        let timeInterval = isMinutes ? delay * 60 : delay
        
        for i in 0..<total {
            let content = UNMutableNotificationContent()
            content.title = "Transferência recebida"
            content.body = "Você recebeu uma transferência de \(amount) de \(sender)."
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(i) * timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
}

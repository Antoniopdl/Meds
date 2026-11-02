import SwiftUI

struct MainTabView: View {
    @State private var tabSeleccionado: Int = 0

    var body: some View {
        TabView(selection: $tabSeleccionado) {
            TodayView()
                .tabItem {
                    Label("Hoy", systemImage: "pills.fill")
                }
                .tag(0)

            HabitTrackerView()
                .tabItem {
                    Label("Hábitos", systemImage: "chart.bar.xaxis")
                }
                .tag(1)

            InventoryView()
                .tabItem {
                    Label("Inventario", systemImage: "shippingbox.fill")
                }
                .tag(2)

            MedicationsListView()
                .tabItem {
                    Label("Catálogo", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
}

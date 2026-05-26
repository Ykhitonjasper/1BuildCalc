import SwiftUI

struct FrontView: View {
    @AppStorage("darkMode") private var darkMode = true
    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("currencyCode") private var currencyCode: String = "USD"

    @StateObject private var areaVM = AreaCalcVM()
    @StateObject private var volumeVM = VolumeCalcVM()
    @StateObject private var wallpaperVM = WallpaperCalcVM()
    @StateObject private var converterVM = UnitConverterVM()

    var units: UnitSystem { useImperial ? .imperial : .metric }

    var body: some View {
        ZStack {
            GlassBg()
            TabView {
                HomeView(units: units, currencyCode: currencyCode)
                    .tabItem { Label("Home", systemImage: "house.fill") }.tag(0)
                CatalogView()
                    .tabItem { Label("Catalog", systemImage: "books.vertical.fill") }.tag(1)
                ProjectsListView(units: units, currencyCode: currencyCode)
                    .tabItem { Label("Projects", systemImage: "folder.fill") }.tag(2)
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }.tag(3)
            }
            .preferredColorScheme(darkMode ? .dark : .light)
            .environmentObject(areaVM)
            .environmentObject(volumeVM)
            .environmentObject(wallpaperVM)
            .environmentObject(converterVM)
        }
        .tint(.orange)
    }
}

struct BuildCalcLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Image("AppIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.8)
                    .padding(.top, 30)
            }
        }
    }
}

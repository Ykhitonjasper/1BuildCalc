import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]

    @AppStorage("useImperial") private var useImperial = false
    @AppStorage("darkMode") private var darkMode = true
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @AppStorage("defaultWastePercent") private var defaultWastePercent: Double = 10
    @AppStorage("defaultTaxPercent") private var defaultTaxPercent: Double = 0

    @State private var showResetAlert = false
    @State private var showCurrencyPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBg()
                ScrollView {
                    VStack(spacing: 18) {
                        // Units & theme
                        GlassCard {
                            VStack(spacing: 0) {
                                ToggleRow(
                                    icon: "ruler", color: .orange,
                                    title: useImperial ? "Imperial (ft, in)" : "Metric (m, cm)",
                                    subtitle: useImperial ? "Feet, inches" : "Meters, centimeters",
                                    isOn: $useImperial
                                )
                                Divider().background(.white.opacity(0.08))
                                ToggleRow(
                                    icon: darkMode ? "moon.fill" : "sun.max.fill",
                                    color: darkMode ? .indigo : .yellow,
                                    title: "Dark mode",
                                    subtitle: darkMode ? "Dark interface" : "Light interface",
                                    isOn: $darkMode
                                )
                            }
                        }

                        // Currency
                        GlassCard {
                            Button {
                                showCurrencyPicker = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "dollarsign.circle.fill").font(.subheadline).foregroundColor(.green).frame(width: 28)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Currency").font(.subheadline).foregroundColor(.white)
                                        Text(Currency.from(code: currencyCode).displayName)
                                            .font(.caption).foregroundColor(.white.opacity(0.4))
                                    }
                                    Spacer()
                                    Text(Currency.from(code: currencyCode).symbol)
                                        .font(.title3.bold()).foregroundColor(.orange)
                                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.white.opacity(0.2))
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        // Defaults for new calculations
                        GlassCard {
                            VStack(spacing: 14) {
                                HStack {
                                    Image(systemName: "scissors").font(.subheadline).foregroundColor(.orange).frame(width: 28)
                                    Text("Default waste").font(.subheadline).foregroundColor(.white)
                                    Spacer()
                                    Text(String(format: "%.0f%%", defaultWastePercent))
                                        .font(.subheadline.bold().monospacedDigit()).foregroundColor(.orange)
                                }
                                Slider(value: $defaultWastePercent, in: 0...30, step: 1).tint(.orange)
                                Divider().background(.white.opacity(0.08))
                                HStack {
                                    Image(systemName: "percent").font(.subheadline).foregroundColor(.blue).frame(width: 28)
                                    Text("Default VAT/tax").font(.subheadline).foregroundColor(.white)
                                    Spacer()
                                    Text(String(format: "%.0f%%", defaultTaxPercent))
                                        .font(.subheadline.bold().monospacedDigit()).foregroundColor(.blue)
                                }
                                Slider(value: $defaultTaxPercent, in: 0...30, step: 1).tint(.blue)
                            }
                        }

                        // Reset
                        GlassCard {
                            Button {
                                showResetAlert = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "trash").font(.subheadline).foregroundColor(.red).frame(width: 28)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Reset all data").font(.subheadline).foregroundColor(.red)
                                        Text("Deletes all projects").font(.caption).foregroundColor(.white.opacity(0.4))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.white.opacity(0.2))
                                }
                            }
                        }

                        // Legal
                        GlassCard {
                            VStack(spacing: 0) {
                                NavigationLink {
                                    WebViewScreen(url: URL(string: "https://buildcalc.info/terms")!, title: "Terms of Service")
                                } label: {
                                    LinkRow(icon: "doc.text", color: .blue, title: "Terms of Service")
                                }
                                Divider().background(.white.opacity(0.08))
                                NavigationLink {
                                    WebViewScreen(url: URL(string: "https://buildcalc.info/privacy")!, title: "Privacy Policy")
                                } label: {
                                    LinkRow(icon: "hand.raised", color: .green, title: "Privacy Policy")
                                }
                            }
                        }

                        // Info
                        GlassCard {
                            VStack(spacing: 0) {
                                InfoRow(icon: "apps.iphone", color: .cyan, title: "Version", value: "2.0.0")
                                Divider().background(.white.opacity(0.08))
                                InfoRow(icon: "hammer", color: .orange, title: "BuildCalc", value: "Pro construction calculator")
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    for p in projects { modelContext.delete(p) }
                    try? modelContext.save()
                }
            } message: {
                Text("All saved projects and line items will be deleted. This action cannot be undone.")
            }
            .sheet(isPresented: $showCurrencyPicker) {
                CurrencyPickerSheet(selection: $currencyCode)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

struct ToggleRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.subheadline).foregroundColor(color).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).foregroundColor(.white)
                Text(subtitle).font(.caption).foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            Toggle("", isOn: $isOn).tint(.orange)
        }
        .padding(.vertical, 12)
    }
}

struct InfoRow: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.subheadline).foregroundColor(color).frame(width: 28)
            Text(title).font(.subheadline).foregroundColor(.white)
            Spacer()
            Text(value).font(.subheadline).foregroundColor(.white.opacity(0.5))
        }
        .padding(.vertical, 12)
    }
}

struct LinkRow: View {
    let icon: String
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.subheadline).foregroundColor(color).frame(width: 28)
            Text(title).font(.subheadline).foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundColor(.white.opacity(0.2))
        }
        .padding(.vertical, 12)
    }
}

private struct CurrencyPickerSheet: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBg()
                List {
                    ForEach(Currency.allCases) { c in
                        Button {
                            selection = c.rawValue
                            dismiss()
                        } label: {
                            HStack {
                                Text(c.symbol).font(.title3.bold()).foregroundColor(.orange).frame(width: 36, alignment: .leading)
                                Text(c.displayName).foregroundColor(.white)
                                Spacer()
                                if selection == c.rawValue {
                                    Image(systemName: "checkmark").foregroundColor(.orange)
                                }
                            }
                        }
                        .listRowBackground(Color.white.opacity(0.04))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
    }
}

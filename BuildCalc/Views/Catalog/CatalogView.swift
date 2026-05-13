import SwiftUI
import SwiftData

struct CatalogView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    @Query(sort: [SortDescriptor(\Material.name)]) private var materials: [Material]
    @State private var filter: MaterialCategory?
    @State private var search = ""
    @State private var newMaterial: Material?

    private var filtered: [Material] {
        materials.filter { m in
            (filter == nil || m.category == filter) &&
            (search.isEmpty || m.name.localizedCaseInsensitiveContains(search))
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBg()
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            chip(label: "All", icon: "list.bullet", selected: filter == nil) { filter = nil }
                            ForEach(MaterialCategory.allCases) { cat in
                                chip(label: cat.displayName, icon: cat.iconSF, selected: filter == cat) { filter = cat }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    if filtered.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "books.vertical").font(.system(size: 50)).foregroundColor(.white.opacity(0.2))
                            Text("No materials").font(.title3).foregroundColor(.white.opacity(0.4))
                            Text("Tap + to add a custom material").font(.caption).foregroundColor(.white.opacity(0.3))
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(filtered) { m in
                                NavigationLink {
                                    MaterialEditView(material: m, isNew: false)
                                } label: {
                                    MaterialRow(material: m, currencyCode: currencyCode)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .onDelete { idx in
                                withAnimation {
                                    idx.forEach { modelContext.delete(filtered[$0]) }
                                    try? modelContext.save()
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Catalog")
            .searchable(text: $search, prompt: "Search materials")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let m = Material(name: "New material", category: .other, consumption: 1.0, isUserCreated: true)
                        modelContext.insert(m)
                        try? modelContext.save()
                        newMaterial = m
                    } label: {
                        Image(systemName: "plus.circle.fill").foregroundColor(.orange)
                    }
                }
            }
            .sheet(item: $newMaterial) { m in
                NavigationStack {
                    MaterialEditView(material: m, isNew: true)
                }
            }
        }
    }

    private func chip(label: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption2)
                Text(label).font(.caption.bold())
            }
            .foregroundColor(selected ? .black : .white.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selected ? Color.white : Color.white.opacity(0.06))
            .cornerRadius(20)
        }
    }
}

private struct MaterialRow: View {
    let material: Material
    let currencyCode: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color(hex: material.hexColor).opacity(0.2)).frame(width: 40, height: 40)
                Image(systemName: material.iconSF).foregroundColor(Color(hex: material.hexColor))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(material.name).font(.subheadline.bold()).foregroundColor(.white)
                Text("\(material.category.displayName) • \(String(format: "%g", material.consumption)) \(material.unit)/m²")
                    .font(.caption).foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(Currency.format(material.pricePerUnit, code: currencyCode))
                    .font(.subheadline.monospacedDigit().bold()).foregroundColor(.green)
                Text("per \(material.unit)").font(.caption2).foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(10)
        .background(.white.opacity(0.03))
        .cornerRadius(12)
    }
}

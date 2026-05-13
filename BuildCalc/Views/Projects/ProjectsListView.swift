import SwiftUI
import SwiftData

struct ProjectsListView: View {
    let units: UnitSystem
    let currencyCode: String

    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Project.updatedAt, order: .reverse)]) private var projects: [Project]
    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(projects) { p in
                            NavigationLink {
                                ProjectDetailView(project: p)
                            } label: {
                                ProjectRow(project: p)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete { idx in
                            withAnimation {
                                idx.forEach { modelContext.delete(projects[$0]) }
                                try? modelContext.save()
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !projects.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showClearAlert = true
                        } label: {
                            Text("Clear").font(.subheadline).foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("Delete all projects?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    for p in projects { modelContext.delete(p) }
                    try? modelContext.save()
                }
            } message: {
                Text("This deletes every saved project and its line items.")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray").font(.system(size: 56)).foregroundColor(.white.opacity(0.15))
            Text("No projects").font(.title3.bold()).foregroundColor(.white.opacity(0.4))
            Text("Save calculations to create your first project").font(.subheadline).foregroundColor(.white.opacity(0.25)).multilineTextAlignment(.center).padding(.horizontal, 40)
        }
    }
}

struct ProjectRow: View {
    let project: Project
    @State private var appear = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "folder.fill")
                .font(.title3).foregroundColor(.orange)
                .frame(width: 40, height: 40)
                .background(.orange.opacity(0.12))
                .cornerRadius(10)
            VStack(alignment: .leading, spacing: 3) {
                Text(project.name).font(.subheadline.bold()).foregroundColor(.white)
                Text("\(project.lineItems.count) items • \(project.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption).foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            if project.total > 0 {
                Text(Currency.format(project.total, code: project.currencyCode))
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundColor(.green)
            }
            Image(systemName: "chevron.right").font(.caption).foregroundColor(.white.opacity(0.2))
        }
        .padding(12)
        .background(.white.opacity(0.03))
        .cornerRadius(14)
        .scaleEffect(appear ? 1 : 0.95)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { appear = true }
        }
    }
}

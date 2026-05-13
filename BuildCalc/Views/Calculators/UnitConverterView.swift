import SwiftUI

struct UnitConverterView: View {
    @EnvironmentObject var vm: UnitConverterVM
    @FocusState private var focused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                GlassCard {
                    VStack(spacing: 10) {
                        Text("CATEGORY").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                        CapsulePicker(items: UnitConverterVM.Category.allCases, selection: $vm.selectedCategory) { cat in cat.icon }
                            .onChange(of: vm.selectedCategory) { _, _ in vm.syncUnits() }
                    }
                }
                GlassCard {
                    VStack(spacing: 14) {
                        VStack(spacing: 6) {
                            Text("FROM").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                            HStack(spacing: 8) {
                                NeoField(label: "Value", text: $vm.inputValue, keyboard: .decimalPad).focused($focused)
                                Menu {
                                    ForEach(vm.units) { u in Button(u.name) { vm.fromUnit = u } }
                                } label: {
                                    Text(vm.fromUnit.name).font(.title3.bold()).foregroundColor(.orange)
                                        .padding(.horizontal, 14).padding(.vertical, 10).background(.white.opacity(0.06)).cornerRadius(10)
                                }
                            }
                        }
                        Button {
                            let tmp = vm.fromUnit; vm.fromUnit = vm.toUnit; vm.toUnit = tmp
                        } label: {
                            Image(systemName: "arrow.left.arrow.right").font(.title3).foregroundColor(.orange.opacity(0.7))
                        }
                        VStack(spacing: 6) {
                            Text("TO").font(.caption).foregroundColor(.white.opacity(0.3)).frame(maxWidth: .infinity, alignment: .leading)
                            HStack(spacing: 8) {
                                ResultCard(icon: vm.selectedCategory.icon, color: .green, title: "Result", value: "\(vm.result) \(vm.toUnit.name)", highlighted: true)
                                Menu {
                                    ForEach(vm.units) { u in Button(u.name) { vm.toUnit = u } }
                                } label: {
                                    Text(vm.toUnit.name).font(.title3.bold()).foregroundColor(.orange)
                                        .padding(.horizontal, 14).padding(.vertical, 10).background(.white.opacity(0.06)).cornerRadius(10)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Converter")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focused = false } }
        }
    }
}

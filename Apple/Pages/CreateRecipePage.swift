import SwiftUI

struct IngredientRow: Identifiable {
    let id = UUID()
    var name: String = ""
    var amount: String = ""
    var unit: String = ""
}

struct CreateRecipePage: View {
    @Binding var savedCocktails: [Cocktail]
    @State private var selectedSpirits: Set<String> = []
    @State private var selectedFlavors: Set<String> = []
    @State private var recipeName: String = ""
    @State private var ingredientRows: [IngredientRow] = [IngredientRow()]
    @State private var instructionSteps: [String] = [""]
    
    // Grid configuration for 3 columns
    private let threeColumnGrid = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    let spirits = ["Whiskey", "Rum", "Tequila", "Gin", "Vodka", "Brandy", "Other"]
    let flavors = ["Smokey", "Fruity", "Herbal", "Spicy", "Sweet", "Citrusy", "Floral", "Bitter"]

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack(spacing: 8) {
                Text("New Recipe")
                    .font(.custom("Pacifico", size: 32))
                    .foregroundColor(DS.cyan)
                Text("Share your latest creation")
                    .font(.custom("Nunito-SemiBold", size: 14))
                    .foregroundColor(DS.textMid)
            }
            .padding(.top, 60)
            .padding(.bottom, 20)

            // MARK: - Scrollable Form
            ScrollView {
                VStack(spacing: 32) {
                    
                    // RECIPE NAME SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        Text("RECIPE NAME")
                            .font(.custom("Nunito-Black", size: 11))
                            .foregroundColor(DS.cyan)
                            .tracking(1.4)
                        
                        TextField("Enter recipe name", text: $recipeName)
                            .textFieldStyle(RecipeTextFieldStyle())
                    }
                    
                    // SPIRITS SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SPIRITS")
                            .font(.custom("Nunito-Black", size: 11))
                            .foregroundColor(DS.cyan)
                            .tracking(1.4)
                        
                        LazyVGrid(columns: threeColumnGrid, spacing: 10) {
                            ForEach(spirits, id: \.self) { spirit in
                                SelectionChip(label: spirit, isSelected: selectedSpirits.contains(spirit)) {
                                    if selectedSpirits.contains(spirit) {
                                        selectedSpirits.remove(spirit)
                                    } else {
                                        selectedSpirits.insert(spirit)
                                    }
                                }
                            }
                        }
                    }

                    // FLAVORS SECTION
                    VStack(alignment: .leading, spacing: 12) {
                        Text("FLAVORS")
                            .font(.custom("Nunito-Black", size: 11))
                            .foregroundColor(DS.cyan)
                            .tracking(1.4)
                        
                        LazyVGrid(columns: threeColumnGrid, spacing: 10) {
                            ForEach(flavors, id: \.self) { flavor in
                                SelectionChip(label: flavor, isSelected: selectedFlavors.contains(flavor)) {
                                    if selectedFlavors.contains(flavor) {
                                        selectedFlavors.remove(flavor)
                                    } else {
                                        selectedFlavors.insert(flavor)
                                    }
                                }
                            }
                        }
                    }

                    // INGREDIENTS SECTION (Table Style)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("INGREDIENTS")
                            .font(.custom("Nunito-Black", size: 11))
                            .foregroundColor(DS.cyan)
                            .tracking(1.4)
                        
                        VStack(spacing: 10) {
                            ForEach($ingredientRows) { $row in
                                HStack(spacing: 8) {
                                    TextField("Ingredient", text: $row.name)
                                        .textFieldStyle(RecipeTextFieldStyle())
                                    
                                    TextField("Amt", text: $row.amount)
                                        .frame(width: 50)
                                        .textFieldStyle(RecipeTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                    
                                    TextField("Unit", text: $row.unit)
                                        .frame(width: 60)
                                        .textFieldStyle(RecipeTextFieldStyle())
                                }
                            }
                            
                            Button(action: { ingredientRows.append(IngredientRow()) }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Ingredient")
                                }
                                .font(.custom("Nunito-Bold", size: 14))
                                .foregroundColor(DS.cyan)
                                .padding(.vertical, 8)
                            }
                        }
                    }

                    // HOW TO MAKE IT SECTION (Step-by-Step Style)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("HOW TO MAKE IT")
                            .font(.custom("Nunito-Black", size: 11))
                            .foregroundColor(DS.cyan)
                            .tracking(1.4)
                        
                        VStack(spacing: 10) {
                            ForEach(instructionSteps.indices, id: \.self) { index in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(index + 1)")
                                        .font(.custom("Nunito-Black", size: 12))
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(DS.cyan)
                                        .clipShape(Circle())
                                        .padding(.top, 8)
                                    
                                    TextField("Step \(index + 1)...", text: $instructionSteps[index], axis: .vertical)
                                        .lineLimit(1...4)
                                        .textFieldStyle(RecipeTextFieldStyle())
                                }
                            }
                            
                            Button(action: { instructionSteps.append("") }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Step")
                                }
                                .font(.custom("Nunito-Bold", size: 14))
                                .foregroundColor(DS.cyan)
                                .padding(.vertical, 8)
                            }
                        }
                    }

                    // SUBMIT BUTTON
                    Button(action: submitRecipe) {
                        Text("SUBMIT RECIPE")
                            .font(.custom("Nunito-Black", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(isFormValid ? DS.cyan : DS.textLight.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: DS.radiusPill))
                            .cardShadow(prominent: isFormValid)
                    }
                    .disabled(!isFormValid)
                    .padding(.bottom, 120)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(DS.bg.ignoresSafeArea())
    }
    
    // Validation Logic
    private var isFormValid: Bool {
        !recipeName.isEmpty &&
        !selectedSpirits.isEmpty &&
        !selectedFlavors.isEmpty &&
        !(ingredientRows.first?.name.isEmpty ?? true) &&
        !(instructionSteps.first?.isEmpty ?? true)
    }
    
    private func submitRecipe() {
        // Create ingredient list as formatted strings
        let ingredients = ingredientRows
            .filter { !$0.name.isEmpty }
            .map { ingredient in
                let amount = ingredient.amount.isEmpty ? "" : ingredient.amount + " "
                let unit = ingredient.unit.isEmpty ? "" : ingredient.unit
                return (amount + unit).trimmingCharacters(in: .whitespaces).isEmpty ? ingredient.name : "\(amount)\(unit) \(ingredient.name)"
            }
        
        // Create steps array filtered to remove empty strings
        let steps = instructionSteps.filter { !$0.isEmpty }
        
        // Create the new cocktail
        let typeString = Array(selectedSpirits).joined(separator: ", ")
        let newCocktail = Cocktail(
            name: recipeName,
            type: typeString,
            ingredients: ingredients,
            steps: steps
        )
        
        // Add to saved cocktails
        savedCocktails.append(newCocktail)
        
        // Reset form
        resetForm()
    }
    
    private func resetForm() {
        recipeName = ""
        selectedSpirits = []
        selectedFlavors = []
        ingredientRows = [IngredientRow()]
        instructionSteps = [""]
    }
}

// MARK: - Reusable UI Components

struct SelectionChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.custom("Nunito-Bold", size: 12))
                .foregroundColor(isSelected ? .white : DS.text)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? DS.cyan : DS.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .cardShadow()
        }
    }
}

struct RecipeTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(DS.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .font(.custom("Nunito-Medium", size: 13))
            .cardShadow()
    }
}

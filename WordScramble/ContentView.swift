//
//  ContentView.swift
//  WordScramble
//
//  Created by Arkasha Zuev on 18.02.2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var usedWord = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var rootScore = 0
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                List(usedWord, id: \.self) { word in
                    HStack{
                        Image(systemName: "\(word.count).circle")
                        Text(word)
                    }
                }
                if rootScore != 0 {
                    Text("Your score: \(rootScore)")
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    Button("New Game") {
                        startGame()
                    }
                }
            })
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) { () -> Alert in
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        newWord = ""
        
        guard isOriginal(word: answer) else {
            wordError(titel: "Word user already", message: "Be more original.")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(titel: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(titel: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        usedWord.insert(answer, at: 0)
        rootScore += 1
    }
    
    func startGame() {
        rootScore = 0
        if usedWord.count > 0 {
            usedWord.removeAll()
        }
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWord.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = word
        for letter in word {
            if let index = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: index)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        if rootWord.elementsEqual(word) || word.utf16.count <= 3 {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(titel: String, message: String) {
        errorTitle = titel
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

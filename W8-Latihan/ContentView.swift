import SwiftUI
import Foundation

struct Card: Codable {
    let object: String
    let total_cards: Int
    let has_more: Bool
    let data: [CardData]
}

struct CardData: Codable {
    let object: String?
    let id: String?
    let oracle_id: String?
    let multiverse_ids: [Int]?
    let mtgo_id: Int?
    let arena_id: Int?
    let tcgplayer_id: Int?
    let cardmarket_id: Int?
    let name: String?
    let lang: String?
    let released_at: String?
    let uri: String?
    let scryfall_uri: String?
    let layout: String?
    let highres_image: Bool?
    let image_status: String?
    let image_uris: ImageURIs?
    let mana_cost: String?
    let cmc: Double?
    let type_line: String?
    let oracle_text: String?
    let colors: [String]?
    let color_identity: [String]?
    let keywords: [String]?
    let legalities: Legalities
    let games: [String]?
    let reserved: Bool?
    let foil: Bool?
    let nonfoil: Bool?
    let finishes: [String]?
    let oversized: Bool?
    let promo: Bool?
    let reprint: Bool?
    let variation: Bool?
    let set_id: String?
    let set: String?
    let set_name: String?
    let set_type: String?
    let set_uri: String?
    let set_search_uri: String?
    let scryfall_set_uri: String?
    let rulings_uri: String?
    let prints_search_uri: String?
    let collector_number: String?
    let digital: Bool?
    let rarity: String?
    let flavor_text: String?
    let card_back_id: String?
    let artist: String?
    let artist_ids: [String]?
    let illustration_id: String?
    let border_color: String?
    let frame: String?
    let frame_effects: [String]?
    let security_stamp: String?
    let full_art: Bool?
    let textless: Bool?
    let booster: Bool?
    let story_spotlight: Bool?
    let promo_types: [String]?
    let edhrec_rank: Int?
    let penny_rank: Int?
    let prices: Prices?
    let related_uris: RelatedURIs?
    let purchase_uris: PurchaseURIs?
}


struct ImageURIs: Codable {
    let small: String?
    let normal: String?
    let large: String?
    let png: String?
    let art_crop: String?
    let border_crop: String?
}

struct Legalities: Codable {
    let standard: String
    let future: String
    let historic: String
    let gladiator: String
    let pioneer: String
    let explorer: String
    let modern: String
    let legacy: String
    let pauper: String
    let vintage: String
    let penny: String
    let commander: String
    let oathbreaker: String
    let brawl: String
    let historicbrawl: String
    let alchemy: String
    let paupercommander: String
    let duel: String
    let oldschool: String
    let premodern: String
    let predh: String
}

struct Prices: Codable {
    let usd: String?
    let usd_foil: String?
    let usd_etched: String?
    let eur: String?
    let eur_foil: String?
    let tix: String?
}

struct RelatedURIs: Codable {
    let gatherer: String?
    let tcgplayer_infinite_articles: String?
    let tcgplayer_infinite_decks: String?
    let edhrec: String?
}

struct PurchaseURIs: Codable {
    let tcgplayer: String?
    let cardmarket: String?
    let cardhoarder: String?
}

struct ContentView: View {
    @State var dataCards: [CardData] = []
    @State var searchCard: String = ""
    var filteredCards: [CardData] {
        if searchCard.isEmpty {
            return dataCards
        } else {
            return dataCards.filter { $0.name?.lowercased().contains(searchCard.lowercased()) ?? false }
        }
    }
    func loadJSONData() {
        if let bundlePath = Bundle.main.path(forResource: "WOT-Scryfall", ofType: "json"),
           let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)) {
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Card.self, from: jsonData)
                
                dataCards = result.data
            } catch {
                print(error)
            }
        }
    }
    var body: some View {
        NavigationView(content: {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 2), spacing: 16) {
                    ForEach(filteredCards, id: \.id) { card in
                        NavigationLink(destination: CardDetailedView(DetailedView: card)) {
                            VStack(alignment: .leading, spacing: 10) {
                                AsyncImage(url: URL(string: card.image_uris?.normal ?? "https://via.placeholder.com/150")!) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Cards")
            .searchable(text: $searchCard, prompt: "Search Card")
        })
        .onAppear {
            loadJSONData()
        }
    }
    
    
}


struct CardDetailedView: View {
    var DetailedView: CardData
    var legalitiesArray: [(String, String)] {
        let mirror = Mirror(reflecting: DetailedView.legalities)
        return mirror.children.map { ($0.label ?? "", $0.value as? String ?? "") }
    }
    // array for prices
    var pricesArray: [(String, String)] {
        let mirror = Mirror(reflecting: DetailedView.prices!)
        return mirror.children.map { ($0.label ?? "", $0.value as? String ?? "") }
    }
    
    var body: some View {
        
        List {
            AsyncImage(url: URL(string: DetailedView.image_uris?.normal ?? "https://via.placeholder.com/150")!) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            
            
            Section(header: Text("Description").font(.title).frame(maxWidth: .infinity, alignment: .leading)) {
                Text("Released at: \(DetailedView.released_at!)").fontWeight(.light)
                Text(DetailedView.oracle_text!).fontWeight(.light)
                Text("Part of \(DetailedView.set_name!) set").fontWeight(.light)
            }
            
            Section(header: Text("Legalities").font(.title).frame(maxWidth: .infinity, alignment: .leading)) {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 10) {
                    ForEach(legalitiesArray, id: \.0) { key, value in
                        ZStack {
                            VStack(spacing: 0) {
                                value == "legal" ? Color.green.opacity(0.7) : Color.red.opacity(0.7)
                            }
                            
                            Text("\(key.capitalized)")
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
            }
            
            // section for prices
            Section(header: Text("Prices").font(.title).frame(maxWidth: .infinity, alignment: .leading)) {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 10) {
                    ForEach(pricesArray, id: \.0) { key, value in
                        ZStack {
                            VStack(spacing: 0) {
                                Color.green.opacity(0.7)
                            }
                            
                            Text("\(key.uppercased()): \(value)")
                    .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
            }
        }
    }
    
}





#Preview {
    ContentView()
}

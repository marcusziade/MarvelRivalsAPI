public struct BattlePass: Codable {
    public let season: Int
    public let seasonName: String
    public let items: [BattlePassItem]
    
    public struct BattlePassItem: Codable {
        public let name: String
        public let image: String
        public let cost: String
        public let isLuxury: Bool
    }
}

// Dev Diaries
public struct DevDiary: Codable {
    public let id: String
    public let title: String
    public let date: String
    public let overview: String
    public let imagePath: String
    public let fullContent: String
}

public struct DevDiariesResponse: Codable {
    public let totalEntries: Int
    public let formattedEntries: [DevDiary]
}

// Heroes and Costumes
public struct HeroLeaderboard: Codable {
    public let heroName: String
    public let platform: String
    public let leaderboard: [LeaderboardEntry]
    
    public struct LeaderboardEntry: Codable {
        public let rank: Int
        public let playerName: String
        public let score: Int
        public let platform: String
    }
}

public struct HeroCostume: Codable {
    public let id: String
    public let name: String
    public let icon: String
    public let rarity: String
    public let description: String
    public let appearance: String
    public let video: String?
}

// Items
public struct ItemsResponse: Codable {
    public let totalItems: Int
    public let items: [Item]
    
    public struct Item: Codable {
        public let id: String
        public let name: String
        public let quality: String
        public let type: String
        public let applicableHero: String
        public let icon: String
        public let slug: String
        public let description: String?
    }
}

// Maps
public struct Map: Codable {
    public let id: String
    public let name: String
    public let type: String
    public let description: String
    public let image: String
}

public struct MapsResponse: Codable {
    public let totalMaps: Int
    public let maps: [Map]
}

// Match History
public struct Match: Codable {
    public let matchDetails: MatchDetails
    
    public struct MatchDetails: Codable {
        public let matchUid: String
        public let gameMode: GameMode
        public let replayId: String
        public let mvpUid: String
        public let mvpHeroId: Int
        public let svpUid: String
        public let svpHeroId: Int
        public let matchPlayers: [MatchPlayer]
        
        public struct GameMode: Codable {
            public let gameModeId: Int
            public let gameModeName: String
        }
        
        public struct MatchPlayer: Codable {
            public let playerUid: String
            public let nickName: String
            public let playerIcon: String
            public let camp: String
            public let curHeroId: Int
            public let curHeroIcon: String
            public let isWin: Bool
            public let kills: Int
            public let deaths: Int
            public let assists: Int
            public let totalHeroDamage: Int
            public let totalHeroHeal: Int
            public let totalDamageTaken: Int
            public let playerHeroes: [PlayerHero]
            
            public struct PlayerHero: Codable {
                public let heroId: Int
                public let playTime: Int
                public let kills: Int
                public let deaths: Int
                public let assists: Int
                public let sessionHitRate: Double
                public let heroIcon: String
            }
        }
    }
}

// Patch Notes
public struct PatchNote: Codable {
    public let patchTitle: String
    public let patchDate: String
    public let patchType: String
    public let previewText: String
    public let imagePath: String
    public let fullContent: String
    public let htmlContent: String
}

public struct PatchNotesResponse: Codable {
    public let totalPatches: Int
    public let formattedPatches: [PatchNote]
}


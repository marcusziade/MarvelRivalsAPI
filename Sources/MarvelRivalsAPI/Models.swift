import Foundation

// MARK: - Hero Models
/// Represents a hero in Marvel Rivals.
public struct Hero: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let role: String
    public let difficulty: Int
    public let description: String
    public let abilities: [Ability]
    public let image: String
    public let backstory: String?
    
    /// Represents a hero ability.
    public struct Ability: Codable, Equatable {
        public let name: String
        public let description: String
        public let cooldown: String?
        public let icon: String
        public let video: String?
    }
}

/// Represents hero statistics.
public struct HeroStats: Codable, Equatable {
    public let heroId: String
    public let heroName: String
    public let pickRate: Double
    public let winRate: Double
    public let banRate: Double
    public let role: String
    public let tierRating: String
    public let playStyle: [String]
    public let counters: [Counter]
    public let strongAgainst: [Counter]
    
    /// Represents a hero counter relationship.
    public struct Counter: Codable, Equatable {
        public let heroId: String
        public let heroName: String
        public let reason: String
        public let icon: String
    }
}

// MARK: - Player Models
/// Represents a player in Marvel Rivals.
public struct Player: Codable, Identifiable, Equatable {
    public let id: String
    public let username: String
    public let level: Int
    public let rank: String
    public let rankIcon: String
    public let recentActivity: [RecentActivity]?
    public let favoriteHeroes: [FavoriteHero]?
    public let region: String?
    public let platform: String
    public let lastUpdated: String
    
    /// Represents a player's recent activity.
    public struct RecentActivity: Codable, Equatable {
        public let type: String
        public let timestamp: String
        public let details: String
    }
    
    /// Represents a player's favorite hero.
    public struct FavoriteHero: Codable, Equatable {
        public let heroId: String
        public let heroName: String
        public let playTime: Int
        public let winRate: Double
        public let icon: String
    }
}

/// Represents player statistics.
public struct PlayerStats: Codable, Equatable {
    public let playerId: String
    public let username: String
    public let seasonStats: SeasonStats
    public let heroStats: [HeroStat]
    public let matchHistory: [MatchSummary]?
    
    /// Represents player statistics for a season.
    public struct SeasonStats: Codable, Equatable {
        public let season: Int
        public let seasonName: String
        public let rank: String
        public let rankIcon: String
        public let matchesPlayed: Int
        public let wins: Int
        public let losses: Int
        public let winRate: Double
        public let kdaRatio: Double
        public let averageDamage: Int
        public let averageHealing: Int
    }
    
    /// Represents player statistics for a hero.
    public struct HeroStat: Codable, Equatable {
        public let heroId: String
        public let heroName: String
        public let matchesPlayed: Int
        public let wins: Int
        public let losses: Int
        public let winRate: Double
        public let kdaRatio: Double
        public let icon: String
    }
    
    /// Represents a summary of a match.
    public struct MatchSummary: Codable, Equatable {
        public let matchId: String
        public let timestamp: String
        public let gameMode: String
        public let map: String
        public let hero: String
        public let result: String
        public let kda: String
        public let damage: Int
        public let healing: Int
    }
}

// MARK: - Game Content Models
/// Represents a battle pass.
public struct BattlePass: Codable, Equatable {
    public let season: Int
    public let seasonName: String
    public let items: [BattlePassItem]
    
    /// Represents an item in the battle pass.
    public struct BattlePassItem: Codable, Equatable {
        public let name: String
        public let image: String
        public let cost: String
        public let isLuxury: Bool
    }
}

/// Represents a dev diary entry.
public struct DevDiary: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let date: String
    public let overview: String
    public let imagePath: String
    public let fullContent: String
}

/// Represents a paginated response of dev diary entries.
public struct DevDiariesResponse: Codable, Equatable {
    public let totalEntries: Int
    public let formattedEntries: [DevDiary]
}

/// Represents a hero leaderboard.
public struct HeroLeaderboard: Codable, Equatable {
    public let heroName: String
    public let platform: String
    public let leaderboard: [LeaderboardEntry]
    
    /// Represents an entry in the leaderboard.
    public struct LeaderboardEntry: Codable, Equatable {
        public let rank: Int
        public let playerName: String
        public let score: Int
        public let platform: String
    }
}

/// Represents a hero costume.
public struct HeroCostume: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let icon: String
    public let rarity: String
    public let description: String
    public let appearance: String
    public let video: String?
}

/// Represents a paginated response of items.
public struct ItemsResponse: Codable, Equatable {
    public let totalItems: Int
    public let items: [Item]
    
    /// Represents an item in the game.
    public struct Item: Codable, Identifiable, Equatable {
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

/// Represents a map in the game.
public struct Map: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let type: String
    public let description: String
    public let image: String
}

/// Represents a paginated response of maps.
public struct MapsResponse: Codable, Equatable {
    public let totalMaps: Int
    public let maps: [Map]
}

/// Represents a match.
public struct Match: Codable, Equatable {
    public let matchDetails: MatchDetails
    
    /// Represents the details of a match.
    public struct MatchDetails: Codable, Equatable {
        public let matchUid: String
        public let gameMode: GameMode
        public let replayId: String
        public let mvpUid: String
        public let mvpHeroId: Int
        public let svpUid: String
        public let svpHeroId: Int
        public let matchPlayers: [MatchPlayer]
        
        /// Represents a game mode.
        public struct GameMode: Codable, Equatable {
            public let gameModeId: Int
            public let gameModeName: String
        }
        
        /// Represents a player in a match.
        public struct MatchPlayer: Codable, Equatable {
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
            
            /// Represents a hero used by a player in a match.
            public struct PlayerHero: Codable, Equatable {
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

/// Represents a patch note.
public struct PatchNote: Codable, Equatable {
    public let patchTitle: String
    public let patchDate: String
    public let patchType: String
    public let previewText: String
    public let imagePath: String
    public let fullContent: String
    public let htmlContent: String
}

/// Represents a paginated response of patch notes.
public struct PatchNotesResponse: Codable, Equatable {
    public let totalPatches: Int
    public let formattedPatches: [PatchNote]
}
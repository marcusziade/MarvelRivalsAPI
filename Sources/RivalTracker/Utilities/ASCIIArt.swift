import Foundation

/// Contains ASCII art for the application.
enum ASCIIArt {
    /// The logo for the application.
    static let logo = """
    ██████╗ ██╗██╗   ██╗ █████╗ ██╗  ████████╗██████╗  █████╗  ██████╗██╗  ██╗███████╗██████╗ 
    ██╔══██╗██║██║   ██║██╔══██╗██║  ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝██╔══██╗
    ██████╔╝██║██║   ██║███████║██║     ██║   ██████╔╝███████║██║     █████╔╝ █████╗  ██████╔╝
    ██╔══██╗██║╚██╗ ██╔╝██╔══██║██║     ██║   ██╔══██╗██╔══██║██║     ██╔═██╗ ██╔══╝  ██╔══██╗
    ██║  ██║██║ ╚████╔╝ ██║  ██║███████╗██║   ██║  ██║██║  ██║╚██████╗██║  ██╗███████╗██║  ██║
    ╚═╝  ╚═╝╚═╝  ╚═══╝  ╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
    """
    
    /// Small logo for headers.
    static let smallLogo = """
    ╦═╗╦╦  ╦╔═╗╦    ╔╦╗╦═╗╔═╗╔═╗╦╔═╔═╗╦═╗
    ╠╦╝║╚╗╔╝╠═╣║     ║ ╠╦╝╠═╣║  ╠╩╗║╣ ╠╦╝
    ╩╚═╩ ╚╝ ╩ ╩╩═╝   ╩ ╩╚═╩ ╩╚═╝╩ ╩╚═╝╩╚═
    """
    
    /// Hero roles.
    enum HeroRole: String {
        case tank = "Tank"
        case damage = "Damage"
        case support = "Support"
        
        /// The ASCII art for the role.
        var ascii: String {
            switch self {
            case .tank:
                return """
                ╔═╗╦ ╦╦╔═╗╦  ╔╦╗
                ╚═╗╠═╣║║╣ ║   ║║
                ╚═╝╩ ╩╩╚═╝╩═╝═╩╝
                """
            case .damage:
                return """
                ╔╦╗╔═╗╔╦╗╔═╗╔═╗╔═╗
                 ║║╠═╣║║║╠═╣║ ╦║╣ 
                ═╩╝╩ ╩╩ ╩╩ ╩╚═╝╚═╝
                """
            case .support:
                return """
                ╔═╗╦ ╦╔═╗╔═╗╔═╗╦═╗╔╦╗
                ╚═╗║ ║╠═╝╠═╝║ ║╠╦╝ ║ 
                ╚═╝╚═╝╩  ╩  ╚═╝╩╚═ ╩ 
                """
            }
        }
    }
    
    /// Generate an ASCII chart for win/loss data.
    /// - Parameters:
    ///   - wins: The number of wins.
    ///   - losses: The number of losses.
    ///   - width: The width of the chart.
    /// - Returns: The ASCII chart.
    static func winLossChart(wins: Int, losses: Int, width: Int = 30) -> String {
        let total = wins + losses
        guard total > 0 else {
            return String(repeating: "▁", count: width)
        }
        
        let winRatio = Double(wins) / Double(total)
        let winWidth = Int(Double(width) * winRatio)
        let lossWidth = width - winWidth
        
        let winPart = String(repeating: "█", count: winWidth)
        let lossPart = String(repeating: "░", count: lossWidth)
        
        return winPart + lossPart + " \(Int(winRatio * 100))%"
    }
    
    /// Generate an ASCII bar for a value.
    /// - Parameters:
    ///   - value: The value to represent.
    ///   - maxValue: The maximum value.
    ///   - width: The width of the bar.
    /// - Returns: The ASCII bar.
    static func bar(value: Double, maxValue: Double, width: Int = 20) -> String {
        guard maxValue > 0 else {
            return String(repeating: "▁", count: width)
        }
        
        let ratio = min(1.0, value / maxValue)
        let barWidth = Int(Double(width) * ratio)
        
        let barPart = String(repeating: "█", count: barWidth)
        let emptyPart = String(repeating: "░", count: width - barWidth)
        
        return barPart + emptyPart + " \(Int(ratio * 100))%"
    }
    
    /// Generate an ASCII sparkline for a series of values.
    /// - Parameters:
    ///   - values: The values to represent.
    ///   - width: The width of the sparkline.
    /// - Returns: The ASCII sparkline.
    static func sparkline(values: [Double], width: Int = 30) -> String {
        guard !values.isEmpty else {
            return String(repeating: "▁", count: width)
        }
        
        // Normalize the values to 0-8 range for ASCII sparklines
        let min = values.min() ?? 0
        let max = values.max() ?? 1
        let range = max - min
        
        if range == 0 {
            return String(repeating: "▄", count: width)
        }
        
        let normalizedValues = values.map { min(7, Int(floor(($0 - min) / range * 8))) }
        
        // Use evenly spaced samples if we have more values than width
        var sampledValues: [Int] = []
        
        if normalizedValues.count <= width {
            sampledValues = normalizedValues
        } else {
            let step = Double(normalizedValues.count) / Double(width)
            for i in 0..<width {
                let index = min(normalizedValues.count - 1, Int(Double(i) * step))
                sampledValues.append(normalizedValues[index])
            }
        }
        
        // Convert to sparkline characters
        let sparkChars = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
        return sampledValues.map { sparkChars[$0] }.joined()
    }
    
    /// Generate an ASCII horizontal legend.
    /// - Parameters:
    ///   - items: The legend items.
    ///   - width: The width of the legend.
    /// - Returns: The ASCII legend.
    static func horizontalLegend(items: [(label: String, symbol: String)], width: Int = 30) -> String {
        let itemWidth = width / items.count
        var result = ""
        
        for (label, symbol) in items {
            let itemText = "\(symbol) \(label)"
            let paddedText = itemText.padding(toLength: itemWidth, withPad: " ", startingAt: 0)
            result += paddedText
        }
        
        return result
    }
}
import Foundation

struct EmailItem: Identifiable, Codable {
    let id: UUID
    let recipient: String
    let subject: String
    let body: String
    let htmlContent: String
    let date: Date
    let hash: String
    
    init(id: UUID = UUID(), recipient: String, subject: String, body: String, htmlContent: String, date: Date = Date(), hash: String) {
        self.id = id
        self.recipient = recipient
        self.subject = subject
        self.body = body
        self.htmlContent = htmlContent
        self.date = date
        self.hash = hash
    }
}


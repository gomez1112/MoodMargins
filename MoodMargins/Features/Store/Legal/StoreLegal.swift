import Foundation

enum StoreLegal {
    static let reviewURL: URL = {
        guard let url = URL(string: "https://apps.apple.com/app/id6819079849?action=write-review") else {
            preconditionFailure("Invalid MoodMargins review URL")
        }
        return url
    }()
    static let privacyURL: URL = {
        guard let url = URL(string: "https://apps.transfinite.us/moodmargins/privacy-policy") else {
            preconditionFailure("Invalid MoodMargins privacy policy URL")
        }
        return url
    }()
    static let termsURL: URL = {
        // This constant is a valid, public HTTPS URL; a failure indicates a programming error.
        guard let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") else {
            preconditionFailure("Invalid Apple standard EULA URL")
        }
        return url
    }()
    static let subscriptionsURL: URL = {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else {
            preconditionFailure("Invalid Apple subscription management URL")
        }
        return url
    }()
}

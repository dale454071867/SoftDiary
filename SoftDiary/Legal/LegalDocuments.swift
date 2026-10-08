import Foundation

enum LegalDocument: String, Identifiable {
    case userAgreement
    case privacyPolicy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .userAgreement: return "Terms of Use"
        case .privacyPolicy: return "Privacy Policy"
        }
    }

    var content: String {
        switch self {
        case .userAgreement: return Self.userAgreementText
        case .privacyPolicy: return Self.privacyPolicyText
        }
    }

    private static let userAgreementText = """
    Welcome to SoftDiary (the “App”). Please read these Terms of Use carefully before using the App. By tapping Agree and entering the App, you acknowledge that you have read and agree to these Terms in full.

    1. Service Description
    1. SoftDiary provides local journal writing, character portraits, hand-drawn sketches, photos, and voice notes.
    2. The App runs primarily on your device. Core journal content is stored locally by default.
    3. We may update features as the product evolves and will notify you in the App or by other reasonable means.

    2. Account and Use
    1. The current version does not require registration; you may use it without an account.
    2. You agree to use the App lawfully and respectfully, and not for any illegal activity.
    3. To the extent permitted by law, SoftDiary is not liable for data loss caused by your actions, device failure, or system limits. Please back up important content regularly.

    3. Intellectual Property
    1. The App’s interface design, copy, portrait style, and related software elements are protected by law.
    2. Journal text, sketches, photos, and recordings you create remain yours. You grant SoftDiary only the rights needed to store and display them locally on your device.

    4. Disclaimer
    1. The App is provided “as is,” without warranties of uninterrupted or error-free service.
    2. SoftDiary is not liable for indirect losses except where caused by intentional misconduct or gross negligence.

    5. Changes and Termination
    1. We may revise these Terms and will present updates in the App or similarly.
    2. If you disagree with the changes, please stop using the App.

    6. Governing Law
    These Terms are governed by the laws of the People’s Republic of China (excluding conflict-of-law rules), except where mandatory local consumer laws apply.

    Questions? Contact us via the developer contact details on the App Store page.
    """

    private static let privacyPolicyText = """
    SoftDiary takes your privacy seriously. This Policy explains how we collect, use, and protect information.

    1. Information We Collect
    1. Journal content: titles, body text, tags, moods, portrait poses, sketches, and any photos or recordings you add.
    2. Device permissions: used only after you grant access, and only for the related feature:
       - Camera: capture journal photos;
       - Photo Library: choose journal photos;
       - Microphone: record voice notes.
    3. The App does not require sign-in by default and does not actively collect sensitive identity details such as your name, phone number, or ID number.

    2. Storage and Use
    1. Journal text, sketches, photos, and recordings are stored locally on your device for display, editing, and playback.
    2. We will not sell your journal content to third parties without your consent.
    3. Cloud sync is not a default feature in this version. If cloud services are added later, we will explain them and obtain any required consent.

    3. Permissions
    1. You can turn off camera, photo library, or microphone access in system Settings at any time. Related features may become unavailable; other local journal features remain available.
    2. We will not request unrelated permissions without explaining their purpose.

    4. Sharing and Disclosure
    1. We will not disclose your journal content to third parties except as required by law, regulators, or to protect users and the public.
    2. If analytics or crash reporting is ever embedded, only the minimum data needed for that service will be processed, with appropriate disclosure.

    5. Children’s Privacy
    If you are a minor, please read this Policy and use the App with a parent or guardian’s guidance.

    6. Your Rights
    1. You can view, edit, or delete journal entries in the App.
    2. Uninstalling the App may clear local data. Back up important content beforehand.

    7. Policy Updates
    We may update this Policy from time to time. Updates will appear on the splash screen or in the App. Continued use means you understand the updated Policy.

    8. Contact Us
    For questions about this Policy, contact us via the developer details on the App Store page.
    """
}

import UIKit
import NovaCrypto

class ViewController: UIViewController {

    @IBOutlet private var messageTextView: UITextView!
    @IBOutlet private var privatePhraseTextView: UITextView!
    @IBOutlet private var privateKeyLabel: UILabel!
    @IBOutlet private var publicKeyLabel: UILabel!
    @IBOutlet private var signatureLabel: UILabel!

    private let keyFactory = NovaCrypto.EDKeyFactory()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        reload()
    }

    private func reload() {
        do {
            let keypair = try createKeypair()

            let privateKeyString = keypair.privateKey().rawData().base64EncodedString()

            let publicKeyString = keypair.publicKey().rawData().base64EncodedString()

            let signer = EDSigner(privateKey: keypair.privateKey())

            guard let messageData = messageTextView.text.data(using: .utf8) else {
                print("Message data must not be nil")
                return
            }

            let signature = try signer.sign(messageData)

            let signatureString = signature.rawData().base64EncodedString()

            privateKeyLabel.text = privateKeyString
            publicKeyLabel.text = publicKeyString
            signatureLabel.text = signatureString
        } catch {
            print("Did receive error \(error)")
        }
    }

    private func createKeypair() throws -> IRCryptoKeypairProtocol {
        var privateKey: IRPrivateKeyProtocol

        if privatePhraseTextView.text.count > 0, let textData = privatePhraseTextView.text.data(using: .utf8) {
            let rawKey = try (textData as NSData).blake2b()
            privateKey = try EDPrivateKey(rawData: rawKey)
            return try keyFactory.derive(fromPrivateKey: privateKey)
        } else {
            return try keyFactory.createRandomKeypair()
        }
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        reload()
    }
}

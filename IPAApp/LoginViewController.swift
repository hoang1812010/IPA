import UIKit

class LoginViewController: UIViewController {
    
    private let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "NODE:0x8A7F4C"
    
    // UI Elements
    private let backgroundView = UIView()
    private let ambientGlow = UIView()
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let udidTitleLabel = UILabel()
    private let udidValueLabel = UILabel()
    private let copyButton = UIButton(type: .system)
    private let udidContainer = UIView()
    
    private let keyTitleLabel = UILabel()
    private let keyTextField = UITextField()
    
    private let errorLabel = UILabel()
    private let submitButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        // Colors
        let bgColor = UIColor(red: 0.02, green: 0.02, blue: 0.03, alpha: 1.0)
        let surfaceColor = UIColor.white.withAlphaComponent(0.03)
        let borderColor = UIColor.white.withAlphaComponent(0.06).cgColor
        let accentCyan = UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0)
        let textSecondary = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
        
        view.backgroundColor = bgColor
        
        ambientGlow.backgroundColor = accentCyan.withAlphaComponent(0.15)
        ambientGlow.layer.cornerRadius = 150
        ambientGlow.layer.shadowColor = accentCyan.cgColor
        ambientGlow.layer.shadowRadius = 80
        ambientGlow.layer.shadowOpacity = 1
        view.addSubview(ambientGlow)
        
        if let icon = UIImage(named: "iconapp") {
            logoImageView.image = icon
        } else {
            logoImageView.image = UIImage(systemName: "shield.righthalf.filled")
            logoImageView.tintColor = accentCyan
        }
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.layer.cornerRadius = 20
        logoImageView.clipsToBounds = true
        logoImageView.layer.shadowColor = accentCyan.cgColor
        logoImageView.layer.shadowRadius = 15
        logoImageView.layer.shadowOpacity = 0.4
        view.addSubview(logoImageView)
        
        titleLabel.text = "Cheat VN"
        titleLabel.font = .systemFont(ofSize: 32, weight: .heavy)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        subtitleLabel.text = "CỔNG BẢO MẬT HỆ THỐNG"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        subtitleLabel.textColor = textSecondary
        subtitleLabel.textAlignment = .center
        let attributedString = NSMutableAttributedString(string: "CỔNG BẢO MẬT HỆ THỐNG")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 2.0, range: NSRange(location: 0, length: attributedString.length))
        subtitleLabel.attributedText = attributedString
        view.addSubview(subtitleLabel)
        
        // UDID Section
        udidTitleLabel.text = "MÃ THIẾT BỊ (UDID)"
        udidTitleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        udidTitleLabel.textColor = textSecondary
        
        udidContainer.backgroundColor = surfaceColor
        udidContainer.layer.cornerRadius = 16
        udidContainer.layer.borderWidth = 1
        udidContainer.layer.borderColor = borderColor
        
        udidValueLabel.text = deviceId
        udidValueLabel.font = .monospacedSystemFont(ofSize: 14, weight: .medium)
        udidValueLabel.textColor = accentCyan
        udidValueLabel.lineBreakMode = .byTruncatingMiddle
        
        copyButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        copyButton.tintColor = textSecondary
        copyButton.addTarget(self, action: #selector(copyUdid), for: .touchUpInside)
        
        udidContainer.addSubview(udidValueLabel)
        udidContainer.addSubview(copyButton)
        view.addSubview(udidTitleLabel)
        view.addSubview(udidContainer)
        
        // Key Section
        keyTitleLabel.text = "MÃ KÍCH HOẠT (KEY)"
        keyTitleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        keyTitleLabel.textColor = textSecondary
        
        keyTextField.placeholder = "Nhập mã kích hoạt của bạn..."
        keyTextField.font = .monospacedSystemFont(ofSize: 15, weight: .medium)
        keyTextField.textColor = .white
        keyTextField.backgroundColor = surfaceColor
        keyTextField.layer.cornerRadius = 16
        keyTextField.layer.borderWidth = 1
        keyTextField.layer.borderColor = borderColor
        keyTextField.autocapitalizationType = .allCharacters
        keyTextField.autocorrectionType = .no
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: keyTextField.frame.height))
        keyTextField.leftView = paddingView
        keyTextField.leftViewMode = .always
        keyTextField.rightView = paddingView
        keyTextField.rightViewMode = .always
        keyTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view.addSubview(keyTitleLabel)
        view.addSubview(keyTextField)
        
        // Error Label
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 13, weight: .medium)
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        view.addSubview(errorLabel)
        
        // Submit Button
        submitButton.setTitle("KÍCH HOẠT HỆ THỐNG", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.layer.cornerRadius = 16
        submitButton.layer.shadowColor = accentCyan.cgColor
        submitButton.layer.shadowRadius = 10
        submitButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        submitButton.layer.shadowOpacity = 0.2
        submitButton.addTarget(self, action: #selector(activateKey), for: .touchUpInside)
        updateSubmitButtonState()
        
        view.addSubview(submitButton)
    }
    
    private func setupConstraints() {
        // Disable autoresizing mask
        [ambientGlow, logoImageView, titleLabel, subtitleLabel, udidTitleLabel, udidContainer, udidValueLabel, copyButton, keyTitleLabel, keyTextField, errorLabel, submitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            ambientGlow.widthAnchor.constraint(equalToConstant: 300),
            ambientGlow.heightAnchor.constraint(equalToConstant: 300),
            ambientGlow.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            ambientGlow.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -12),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -4),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: udidTitleLabel.topAnchor, constant: -40),
            
            udidTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            udidTitleLabel.bottomAnchor.constraint(equalTo: udidContainer.topAnchor, constant: -8),
            
            udidContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            udidContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            udidContainer.heightAnchor.constraint(equalToConstant: 56),
            udidContainer.bottomAnchor.constraint(equalTo: keyTitleLabel.topAnchor, constant: -24),
            
            udidValueLabel.leadingAnchor.constraint(equalTo: udidContainer.leadingAnchor, constant: 16),
            udidValueLabel.centerYAnchor.constraint(equalTo: udidContainer.centerYAnchor),
            udidValueLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -8),
            
            copyButton.trailingAnchor.constraint(equalTo: udidContainer.trailingAnchor, constant: -16),
            copyButton.centerYAnchor.constraint(equalTo: udidContainer.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 24),
            copyButton.heightAnchor.constraint(equalToConstant: 24),
            
            keyTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            keyTitleLabel.bottomAnchor.constraint(equalTo: keyTextField.topAnchor, constant: -8),
            
            keyTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            keyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            keyTextField.heightAnchor.constraint(equalToConstant: 56),
            keyTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50), // Center roughly around here
            
            errorLabel.topAnchor.constraint(equalTo: keyTextField.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            submitButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            submitButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Add Gradient to submit button
        DispatchQueue.main.async {
            let gradient = CAGradientLayer()
            gradient.frame = self.submitButton.bounds
            gradient.colors = [
                UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
                UIColor(red: 0.3, green: 0.67, blue: 1.0, alpha: 1.0).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            gradient.cornerRadius = 16
            
            if let oldLayer = self.submitButton.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
                oldLayer.removeFromSuperlayer()
            }
            self.submitButton.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    @objc private func copyUdid() {
        UIPasteboard.general.string = deviceId
    }
    
    @objc private func textFieldDidChange() {
        updateSubmitButtonState()
        errorLabel.text = ""
        
        let borderColor = UIColor.white.withAlphaComponent(0.06).cgColor
        let accentCyan = UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 0.5).cgColor
        keyTextField.layer.borderColor = (keyTextField.text?.isEmpty ?? true) ? borderColor : accentCyan
    }
    
    private func updateSubmitButtonState() {
        let hasText = !(keyTextField.text?.isEmpty ?? true)
        submitButton.isEnabled = hasText
        submitButton.alpha = hasText ? 1.0 : 0.7
    }
    
    @objc private func activateKey() {
        guard let key = keyTextField.text, !key.isEmpty else { return }
        
        submitButton.isEnabled = false
        submitButton.setTitle("ĐANG XÁC THỰC...", for: .normal)
        errorLabel.text = ""
        
        KeyValidator.shared.validate(key: key, deviceId: deviceId) { [weak self] isValid, message in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.submitButton.setTitle("KÍCH HOẠT HỆ THỐNG", for: .normal)
                self.updateSubmitButtonState()
                
                if isValid {
                    let mainVC = ViewController()
                    mainVC.apiKey = key
                    mainVC.modalPresentationStyle = .fullScreen
                    mainVC.modalTransitionStyle = .crossDissolve
                    self.present(mainVC, animated: true)
                } else {
                    self.errorLabel.text = message ?? "Mã kích hoạt không hợp lệ"
                }
            }
        }
    }
}

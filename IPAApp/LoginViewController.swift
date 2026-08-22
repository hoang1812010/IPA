import UIKit

class LoginViewController: UIViewController {
    
    // Tự động sinh UDID giả (UUID) và lưu vĩnh viễn vào UserDefaults
    private var deviceId: String {
        let key = "Saved_UDID"
        if let savedId = UserDefaults.standard.string(forKey: key), !savedId.isEmpty {
            return savedId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: key)
            return newId
        }
    }
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "KÍCH HOẠT THIẾT BỊ"
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textColor = UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Copy mã UDID dưới đây gửi Admin để mua Key"
        l.font = .systemFont(ofSize: 13)
        l.textColor = .lightGray
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let udidContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        v.layer.cornerRadius = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let udidValueLabel: UILabel = {
        let l = UILabel()
        l.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
        l.textColor = .white
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.5
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let copyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("COPY", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        b.backgroundColor = UIColor.systemBlue
        b.layer.cornerRadius = 6
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let keyTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nhập Key kích hoạt..."
        tf.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        tf.textColor = .white
        tf.layer.cornerRadius = 10
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.font = .systemFont(ofSize: 15)
        tf.translatesAutoresizingMaskIntoConstraints = false
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
        tf.leftView = padding
        tf.leftViewMode = .always
        return tf
    }()
    
    private let activateButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("KÍCH HOẠT", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.4, alpha: 1.0)
        b.layer.cornerRadius = 10
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.12, alpha: 1.0)
        udidValueLabel.text = deviceId
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(udidContainer)
        udidContainer.addSubview(udidValueLabel)
        udidContainer.addSubview(copyButton)
        view.addSubview(keyTextField)
        view.addSubview(activateButton)
        activateButton.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            udidContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            udidContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            udidContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            udidContainer.heightAnchor.constraint(equalToConstant: 50),
            
            udidValueLabel.leadingAnchor.constraint(equalTo: udidContainer.leadingAnchor, constant: 16),
            udidValueLabel.centerYAnchor.constraint(equalTo: udidContainer.centerYAnchor),
            udidValueLabel.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -12),
            
            copyButton.trailingAnchor.constraint(equalTo: udidContainer.trailingAnchor, constant: -8),
            copyButton.centerYAnchor.constraint(equalTo: udidContainer.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: 60),
            copyButton.heightAnchor.constraint(equalToConstant: 34),
            
            keyTextField.topAnchor.constraint(equalTo: udidContainer.bottomAnchor, constant: 24),
            keyTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            keyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            keyTextField.heightAnchor.constraint(equalToConstant: 50),
            
            activateButton.topAnchor.constraint(equalTo: keyTextField.bottomAnchor, constant: 24),
            activateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            activateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            activateButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: activateButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: activateButton.centerYAnchor),
        ])
    }
    
    private func setupActions() {
        copyButton.addTarget(self, action: #selector(copyUdid), for: .touchUpInside)
        activateButton.addTarget(self, action: #selector(activateTapped), for: .touchUpInside)
    }
    
    @objc private func copyUdid() {
        UIPasteboard.general.string = deviceId
        showToast(message: "✅ Đã copy UDID!")
    }
    
    @objc private func activateTapped() {
        guard let key = keyTextField.text, !key.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Lỗi", message: "Vui lòng nhập Key!")
            return
        }
        
        activityIndicator.startAnimating()
        activateButton.setTitle("", for: .normal)
        activateButton.isEnabled = false
        
        // Gọi API Validate
        KeyValidator.validate(key: key, deviceId: deviceId) { [weak self] success, message in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activateButton.setTitle("KÍCH HOẠT", for: .normal)
                self?.activateButton.isEnabled = true
                
                if success {
                    // Lưu trạng thái Active
                    UserDefaults.standard.set(true, forKey: "App_Activated")
                    UserDefaults.standard.set(key, forKey: "Saved_Key")
                    
                    // Chuyển Scene sang ViewController
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        let mainVC = ViewController()
                        let nav = UINavigationController(rootViewController: mainVC)
                        window.rootViewController = nav
                        UIView.transition(with: window, duration: 0.4, options: .transitionFlipFromRight, animations: nil)
                    }
                } else {
                    self?.showAlert(title: "Thất bại", message: message ?? "Key sai hoặc chưa được cấp phép cho UDID này.")
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.font = .systemFont(ofSize: 14, weight: .medium)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastLabel)
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            toastLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),
            toastLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        toastLabel.alpha = 0
        UIView.animate(withDuration: 0.3, animations: { toastLabel.alpha = 1 }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut, animations: { toastLabel.alpha = 0 }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

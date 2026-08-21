import UIKit

class ViewController: UIViewController {
    
    var apiKey: String = ""
    
    private var selectedBundle: String = "com.dts.freefireth"
    private var activeFeature: String? = nil
    private var isProcessing = false
    
    private let features = ["Nhẹ Tâm", "Proxy Body", "Proxy Neck", "Proxy Drag", "Khôi Phục"]
    private let featureIcons = ["wind", "figure.walk", "scope", "hand.point.up.left.fill", "arrow.uturn.backward"]
    
    private func d(_ b64: String) -> String {
        guard let d = Data(base64Encoded: b64), let s = String(data: d, encoding: .utf8) else { return "" }
        return s
    }
    
    private lazy var featureURLs: [String: String] = [
        "Nhẹ Tâm": d("aHR0cHM6Ly9kb3dubG9hZDIyOTcubWVkaWFmaXJlLmNvbS95OGc2eHU4ZHptOWcxTXh3bHVVNFRyY0VCdUN0VHJMc0hRVjZ5N3FmdmZfc3lNTEExRmxrTlRVdy1fcXpmSEFENUdMVE1ZX2pvM3h6eWZwd0JmUG1OZXZULXpvVWxDWVhYLXJ0LTBaTTNiOGdiSXAydmlfM3BrMFdvTGVsTDNYMnlzdHFrSFhrcElqNVd0eFJMR0ptckhacU1Wdi1CVFlGcDNtaFFCNTZYT1Z5a0l3L2M5NWttenhhMGZqZDB0ei9jYWNoZV9yZXMuQ2ZuRmY1OXNyMVNic3FRNkpxVEtzRXVzaktzJTdFM0Q="),
        "Proxy Body": d("aHR0cHM6Ly9kb3dubG9hZDIzOTEubWVkaWFmaXJlLmNvbS9haDNsaWIwdXFudWdiSERmdHNYamZKS281UkRSWHlMMXVmMVZPd1B2N3RybEpKb1dPRnVnN3BFdWlyLWRkdXN2TjM0NHBEZXQwNDdSdDFBRmlFRlRqQkIwWG94VWU1OXhod1RqSWNidWF0RmZYOHN1SVVqbWpjeUNPQUlqR0NzQnBWQ05wMUFwQkM1Zmo4UngyNjJzcXNFcnp6aE94NDRNZks0OU9fekNFU1JEZm9ZL3lrYzIyZGk3MDN3YzUxZi9jYWNoZV9yZXMuQ2ZuRmY1OXNyMVNic3FRNkpxVEtzRXVzaktzJTdFM0Q="),
        "Proxy Neck": d("aHR0cHM6Ly9kb3dubG9hZDIzODkubWVkaWFmaXJlLmNvbS83a3ZjZzc0cG42bGduclYtT0NnbGFKMVJualNqOVZPYU5DZjJtVjctOUgwMGJOSXdQLVVqT0hCVWRPZ3hxOV9Ick1ORkNrMk43V1F2dUdPZ3BDb2FoQTdIRWxNczFpQkVuRUQ1NWNNMzdLODFWejkyMTdHeVpKYmV2cDRXWGZsOFlIN1hGUTZmZzJ2T3NybHVDUjhRS1VyOGNGOUF0enl1TDRGX1hUMTFWbFUtM0JVL2M1aHE4NTEzZXdiMzEycy9jYWNoZV9yZXMuQ2ZuRmY1OXNyMVNic3FRNkpxVEtzRXVzaktzJTdFM0Q="),
        "Proxy Drag": d("aHR0cHM6Ly9kb3dubG9hZDIzOTEubWVkaWFmaXJlLmNvbS9ydXR3dWszdG9iMGdBX3VHeGstOExZZlYwWTRzZWRYU3dnempPWTFqN2NBUXlFWXV5Q2JJckZJeWprXzRWS3lZZXFaX21xd0xaY1g2M1JjWW1jWlMwLXc3TDR4YjRQU3VQWGh6SVhSdmp1UmRJQ0FncGhvU2FGRk9tN2dFaVN2NnctLWRQdEZjUnkyWndxb01NcDV6TGx0WmNZbEI0VEh0Mlh6WkV3bTZpUVJjbWJjLzd1ZW9jb291Zjc1OWoyMi9jYWNoZV9yZXMuQ2ZuRmY1OXNyMVNic3FRNkpxVEtzRXVzaktzJTdFM0Q="),
        "Khôi Phục": d("aHR0cHM6Ly9kb3dubG9hZDEwODUubWVkaWFmaXJlLmNvbS9xbXI0ejBrZDY5MWdPTWRmZ2tWRmFtMzREeTI5OUh5bVc3MEoxUWExaERNaDlWQzlVZXc0bm1XS1JYWVlvd0JrdmRUU2FzOEoyQzc2NFRPRUNkZ01BT1RNU1IyeGJyTDZHeHZnaEx5STFDN0NNa1YwVDNNSkllempKcmZOLXA5RDNKZjMwWGJta2hxaVVfVGhkSmNMZ3hWY1J6SzlwNHVmbHVGb0d3RzRvR2V2QWNVL3VneTZ4MjFlbDhkNnczNy9jYWNoZV9yZXMuQ2ZuRmY1OXNyMVNic3FRNkpxVEtzRXVzaktz")
    ]
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let consoleContainer = UIView()
    
    private var bundleButtons: [UIButton] = []
    private var featureButtons: [UIButton] = []
    
    private let accentCyan = UIColor(red: 0.0, green: 0.95, blue: 1.0, alpha: 1.0)
    private let statusGreen = UIColor(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0)
    private let surfaceColor = UIColor.white.withAlphaComponent(0.03)
    private let borderColor = UIColor.white.withAlphaComponent(0.06)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatus("Hệ thống sẵn sàng. Đang chờ lệnh...", isSuccess: false)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.03, alpha: 1.0)
        
        setupConsole()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.bottomAnchor.constraint(equalTo: consoleContainer.topAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        setupHeader()
        setupLicenseCard()
        setupBundleSection()
        setupFeaturesSection()
    }
    
    private func setupConsole() {
        consoleContainer.translatesAutoresizingMaskIntoConstraints = false
        consoleContainer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        consoleContainer.layer.cornerRadius = 16
        consoleContainer.layer.borderWidth = 1
        consoleContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.03).cgColor
        
        let arrowLabel = UILabel()
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.text = ">"
        arrowLabel.font = .monospacedSystemFont(ofSize: 12, weight: .bold)
        arrowLabel.textColor = accentCyan
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        statusLabel.textColor = .lightGray
        statusLabel.lineBreakMode = .byTruncatingTail
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = accentCyan
        activityIndicator.hidesWhenStopped = true
        
        consoleContainer.addSubview(arrowLabel)
        consoleContainer.addSubview(statusLabel)
        consoleContainer.addSubview(activityIndicator)
        view.addSubview(consoleContainer)
        
        NSLayoutConstraint.activate([
            consoleContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            consoleContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            consoleContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            consoleContainer.heightAnchor.constraint(equalToConstant: 48),
            
            arrowLabel.leadingAnchor.constraint(equalTo: consoleContainer.leadingAnchor, constant: 16),
            arrowLabel.centerYAnchor.constraint(equalTo: consoleContainer.centerYAnchor),
            
            statusLabel.leadingAnchor.constraint(equalTo: arrowLabel.trailingAnchor, constant: 8),
            statusLabel.centerYAnchor.constraint(equalTo: consoleContainer.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: activityIndicator.leadingAnchor, constant: -8),
            
            activityIndicator.trailingAnchor.constraint(equalTo: consoleContainer.trailingAnchor, constant: -16),
            activityIndicator.centerYAnchor.constraint(equalTo: consoleContainer.centerYAnchor)
        ])
    }
    
    private func setupHeader() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let iconView = UIImageView(image: UIImage(named: "iconapp") ?? UIImage(systemName: "shield"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFill
        iconView.layer.cornerRadius = 6
        iconView.clipsToBounds = true
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Cheat VN"
        titleLabel.font = .systemFont(ofSize: 20, weight: .heavy)
        titleLabel.textColor = .white
        
        let safeBadge = UIView()
        safeBadge.translatesAutoresizingMaskIntoConstraints = false
        safeBadge.backgroundColor = statusGreen.withAlphaComponent(0.1)
        safeBadge.layer.cornerRadius = 12
        safeBadge.layer.borderWidth = 1
        safeBadge.layer.borderColor = statusGreen.withAlphaComponent(0.2).cgColor
        
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = statusGreen
        dot.layer.cornerRadius = 3
        
        let safeLabel = UILabel()
        safeLabel.translatesAutoresizingMaskIntoConstraints = false
        safeLabel.text = "AN TOÀN"
        safeLabel.font = .systemFont(ofSize: 10, weight: .bold)
        safeLabel.textColor = statusGreen
        
        safeBadge.addSubview(dot)
        safeBadge.addSubview(safeLabel)
        headerView.addSubview(iconView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(safeBadge)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            safeBadge.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            safeBadge.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            safeBadge.heightAnchor.constraint(equalToConstant: 24),
            
            dot.leadingAnchor.constraint(equalTo: safeBadge.leadingAnchor, constant: 8),
            dot.centerYAnchor.constraint(equalTo: safeBadge.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 6),
            dot.heightAnchor.constraint(equalToConstant: 6),
            
            safeLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
            safeLabel.trailingAnchor.constraint(equalTo: safeBadge.trailingAnchor, constant: -8),
            safeLabel.centerYAnchor.constraint(equalTo: safeBadge.centerYAnchor)
        ])
        
        stackView.addArrangedSubview(headerView)
    }
    
    private func setupLicenseCard() {
        let card = UIView()
        card.backgroundColor = accentCyan.withAlphaComponent(0.05)
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = accentCyan.withAlphaComponent(0.2).cgColor
        
        let leftVStack = UIStackView()
        leftVStack.axis = .vertical
        leftVStack.spacing = 6
        leftVStack.translatesAutoresizingMaskIntoConstraints = false
        
        let keyTitle = UILabel()
        keyTitle.text = "MÃ KÍCH HOẠT"
        keyTitle.font = .systemFont(ofSize: 10, weight: .heavy)
        keyTitle.textColor = accentCyan
        
        let keyValue = UILabel()
        keyValue.text = apiKey.isEmpty ? "XXXX-XXXX" : apiKey
        keyValue.font = .monospacedSystemFont(ofSize: 14, weight: .bold)
        keyValue.textColor = .white
        
        leftVStack.addArrangedSubview(keyTitle)
        leftVStack.addArrangedSubview(keyValue)
        
        let rightVStack = UIStackView()
        rightVStack.axis = .vertical
        rightVStack.alignment = .trailing
        rightVStack.spacing = 6
        rightVStack.translatesAutoresizingMaskIntoConstraints = false
        
        let timeTitle = UILabel()
        timeTitle.text = "THỜI GIAN CÒN LẠI"
        timeTitle.font = .systemFont(ofSize: 10, weight: .heavy)
        timeTitle.textColor = .lightGray
        
        let timeHStack = UIStackView()
        timeHStack.spacing = 6
        
        let clockIcon = UIImageView(image: UIImage(systemName: "clock"))
        clockIcon.tintColor = statusGreen
        clockIcon.contentMode = .scaleAspectFit
        
        let timeValue = UILabel()
        timeValue.text = "6d 23h 59m"
        timeValue.font = .systemFont(ofSize: 14, weight: .heavy)
        timeValue.textColor = .white
        
        timeHStack.addArrangedSubview(clockIcon)
        timeHStack.addArrangedSubview(timeValue)
        
        rightVStack.addArrangedSubview(timeTitle)
        rightVStack.addArrangedSubview(timeHStack)
        
        card.addSubview(leftVStack)
        card.addSubview(rightVStack)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 70),
            leftVStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            leftVStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            rightVStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            rightVStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            clockIcon.widthAnchor.constraint(equalToConstant: 14),
            clockIcon.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        stackView.addArrangedSubview(card)
    }
    
    private func setupBundleSection() {
        let sectionContainer = UIStackView()
        sectionContainer.axis = .vertical
        sectionContainer.spacing = 16
        
        let title = UILabel()
        title.text = "CHỌN PHIÊN BẢN GAME"
        title.font = .systemFont(ofSize: 11, weight: .bold)
        title.textColor = .lightGray
        sectionContainer.addArrangedSubview(title)
        
        let bundles = [
            ("Free Fire (Thường)", "freefireth", "com.dts.freefireth"),
            ("Free Fire MAX", "freefiremax", "com.dts.freefiremax")
        ]
        
        for bundle in bundles {
            let button = createBundleButton(title: bundle.0, imageName: bundle.1, bundleId: bundle.2)
            bundleButtons.append(button)
            sectionContainer.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(sectionContainer)
        updateBundleSelection()
    }
    
    private func setupFeaturesSection() {
        let sectionContainer = UIStackView()
        sectionContainer.axis = .vertical
        sectionContainer.spacing = 16
        
        let title = UILabel()
        title.text = "DANH SÁCH CHỨC NĂNG"
        title.font = .systemFont(ofSize: 11, weight: .bold)
        title.textColor = .lightGray
        sectionContainer.addArrangedSubview(title)
        
        for (index, feature) in features.enumerated() {
            let button = createFeatureButton(title: feature, iconName: featureIcons[index])
            featureButtons.append(button)
            sectionContainer.addArrangedSubview(button)
        }
        
        stackView.addArrangedSubview(sectionContainer)
        updateFeatureSelection()
    }
    
    private func createBundleButton(title: String, imageName: String, bundleId: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 76).isActive = true
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        
        button.accessibilityIdentifier = bundleId
        button.addTarget(self, action: #selector(bundleTapped(_:)), for: .touchUpInside)
        
        let iconView = UIImageView(image: UIImage(named: imageName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.layer.cornerRadius = 12
        iconView.clipsToBounds = true
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        
        let radioContainer = UIView()
        radioContainer.translatesAutoresizingMaskIntoConstraints = false
        radioContainer.layer.cornerRadius = 11
        radioContainer.layer.borderWidth = 2
        radioContainer.tag = 100
        
        let radioInner = UIView()
        radioInner.translatesAutoresizingMaskIntoConstraints = false
        radioInner.layer.cornerRadius = 6
        radioInner.tag = 101
        
        button.addSubview(iconView)
        button.addSubview(titleLabel)
        button.addSubview(radioContainer)
        radioContainer.addSubview(radioInner)
        
        titleLabel.tag = 200
        iconView.tag = 300
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            radioContainer.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            radioContainer.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            radioContainer.widthAnchor.constraint(equalToConstant: 22),
            radioContainer.heightAnchor.constraint(equalToConstant: 22),
            
            radioInner.centerXAnchor.constraint(equalTo: radioContainer.centerXAnchor),
            radioInner.centerYAnchor.constraint(equalTo: radioContainer.centerYAnchor),
            radioInner.widthAnchor.constraint(equalToConstant: 12),
            radioInner.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        return button
    }
    
    private func createFeatureButton(title: String, iconName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 76).isActive = true
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.clear, for: .normal)
        button.addTarget(self, action: #selector(featureTapped(_:)), for: .touchUpInside)
        
        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.layer.cornerRadius = 12
        iconBg.tag = 301
        
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tag = 300
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.tag = 200
        
        let toggleBg = UIView()
        toggleBg.translatesAutoresizingMaskIntoConstraints = false
        toggleBg.layer.cornerRadius = 12
        toggleBg.tag = 100
        
        let toggleHandle = UIView()
        toggleHandle.translatesAutoresizingMaskIntoConstraints = false
        toggleHandle.backgroundColor = .white
        toggleHandle.layer.cornerRadius = 10
        toggleHandle.layer.shadowColor = UIColor.black.cgColor
        toggleHandle.layer.shadowOffset = CGSize(width: 0, height: 2)
        toggleHandle.layer.shadowOpacity = 0.2
        toggleHandle.layer.shadowRadius = 2
        toggleHandle.tag = 101
        
        button.addSubview(iconBg)
        iconBg.addSubview(iconView)
        button.addSubview(titleLabel)
        button.addSubview(toggleBg)
        toggleBg.addSubview(toggleHandle)
        
        let handleLeading = toggleHandle.leadingAnchor.constraint(equalTo: toggleBg.leadingAnchor, constant: 2)
        handleLeading.identifier = "handleLeading"
        let handleTrailing = toggleHandle.trailingAnchor.constraint(equalTo: toggleBg.trailingAnchor, constant: -2)
        handleTrailing.identifier = "handleTrailing"
        handleTrailing.isActive = false
        handleLeading.isActive = true
        
        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            iconBg.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 44),
            iconBg.heightAnchor.constraint(equalToConstant: 44),
            
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            toggleBg.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            toggleBg.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            toggleBg.widthAnchor.constraint(equalToConstant: 44),
            toggleBg.heightAnchor.constraint(equalToConstant: 24),
            
            toggleHandle.centerYAnchor.constraint(equalTo: toggleBg.centerYAnchor),
            toggleHandle.widthAnchor.constraint(equalToConstant: 20),
            toggleHandle.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return button
    }
    
    @objc private func bundleTapped(_ sender: UIButton) {
        if let bundleId = sender.accessibilityIdentifier {
            selectedBundle = bundleId
            let name = bundleId == "com.dts.freefireth" ? "Free Fire Thường" : "Free Fire MAX"
            updateStatus("Đã chuyển đổi mục tiêu sang: \(name)", isSuccess: false)
            updateBundleSelection()
        }
    }
    
    @objc private func featureTapped(_ sender: UIButton) {
        guard !isProcessing else { return }
        guard let title = sender.title(for: .normal) else { return }

        if activeFeature == title {
            activeFeature = nil
            updateStatus("Đã tắt tất cả các chức năng.", isSuccess: false)
            updateFeatureSelection()
            return
        }

        guard let urlString = featureURLs[title], !urlString.isEmpty else {
            updateStatus("Lỗi: Không tìm thấy URL cho chức năng này.", isSuccess: false)
            return
        }

        isProcessing = true
        updateStatus("Đang tải và xử lý: \(title)...", isSuccess: false)
        activityIndicator.startAnimating()

        DownloadManager.shared.downloadAndInject(
            urlString: urlString,
            bundleID: selectedBundle,
            fileName: "cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D"
        ) { [weak self] success, message, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isProcessing = false
                self.activityIndicator.stopAnimating()

                if success {
                    self.activeFeature = title
                    self.updateStatus("THÀNH CÔNG: Đã bật \(title).", isSuccess: true)
                    self.updateFeatureSelection()
                } else {
                    self.activeFeature = nil
                    self.updateStatus("Lỗi: \(error?.localizedDescription ?? "Không xác định")", isSuccess: false)
                    self.updateFeatureSelection()
                }
            }
        }    
    }
    
    private func updateBundleSelection() {
        for button in bundleButtons {
            let isSelected = button.accessibilityIdentifier == selectedBundle
            
            button.backgroundColor = isSelected ? accentCyan.withAlphaComponent(0.05) : surfaceColor
            button.layer.borderColor = isSelected ? accentCyan.withAlphaComponent(0.3).cgColor : borderColor.cgColor
            
            if let titleLabel = button.viewWithTag(200) as? UILabel {
                titleLabel.textColor = isSelected ? .white : .lightGray
            }
            if let iconView = button.viewWithTag(300) as? UIImageView {
                iconView.alpha = isSelected ? 1.0 : 0.5
            }
            
            if let radioContainer = button.viewWithTag(100) {
                radioContainer.layer.borderColor = isSelected ? accentCyan.cgColor : UIColor.gray.cgColor
                if let radioInner = radioContainer.viewWithTag(101) {
                    radioInner.backgroundColor = isSelected ? accentCyan : .clear
                }
            }
        }
    }
    
    private func updateFeatureSelection() {
        for button in featureButtons {
            let title = button.title(for: .normal)
            let isActive = title == activeFeature
            
            button.backgroundColor = isActive ? accentCyan.withAlphaComponent(0.05) : surfaceColor
            button.layer.borderColor = isActive ? accentCyan.withAlphaComponent(0.3).cgColor : borderColor.cgColor
            
            if let titleLabel = button.viewWithTag(200) as? UILabel {
                titleLabel.textColor = isActive ? .white : .lightGray
            }
            if let iconView = button.viewWithTag(300) as? UIImageView {
                iconView.tintColor = isActive ? accentCyan : .gray
            }
            if let iconBg = button.viewWithTag(301) {
                iconBg.backgroundColor = isActive ? accentCyan.withAlphaComponent(0.1) : .clear
            }
            
            if let toggleBg = button.viewWithTag(100) {
                toggleBg.backgroundColor = isActive ? accentCyan : UIColor.white.withAlphaComponent(0.1)
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
                    for constraint in toggleBg.constraints {
                        if constraint.identifier == "handleLeading" {
                            constraint.isActive = !isActive
                        } else if constraint.identifier == "handleTrailing" {
                            constraint.isActive = isActive
                        }
                    }
                    button.layoutIfNeeded()
                }
            }
        }
    }
    
    private func updateStatus(_ message: String, isSuccess: Bool) {
        statusLabel.text = message
        statusLabel.textColor = isSuccess ? .white : .lightGray
        if let arrowLabel = consoleContainer.subviews.first(where: { ($0 as? UILabel)?.text == ">" }) as? UILabel {
            arrowLabel.textColor = isSuccess ? statusGreen : accentCyan
        }
    }
}

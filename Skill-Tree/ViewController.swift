//
//  ViewController.swift
//  Skill-Tree
//
//  Created by Jagannath on 17/8/2025.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var dateStackView: UIStackView!
    
    private var startOfWeek: Date = Date()
    private var currentWeekDates: [Date] = []
    private var selectedDate: Date?
    
    private let circleSize: CGFloat = 44.0
    private let circleHalf: CGFloat = 22.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startOfWeek = getStartOfWeek(from: Date())
        currentWeekDates = generateWeek(from: startOfWeek)
        
        reloadWeekViews()
    }
    
    // MARK: - Week generation
    
    private func getStartOfWeek(from date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        guard let start = calendar.date(from: comps) else {
            return calendar.startOfDay(for: date)
        }
        return calendar.startOfDay(for: start)
    }
    
    private func generateWeek(from start: Date) -> [Date] {
        var dates: [Date] = []
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        for i in 0..<7 {
            if let d = calendar.date(byAdding: .day, value: i, to: start) {
                dates.append(calendar.startOfDay(for: d))
            }
        }
        return dates
    }
    
    // MARK: - Build UI
    
    private func reloadWeekViews() {
        for v in dateStackView.arrangedSubviews {
            dateStackView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        
        for date in currentWeekDates {
            let btn = createDateButton(for: date)
            dateStackView.addArrangedSubview(btn)
            
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: circleSize),
                btn.heightAnchor.constraint(equalToConstant: circleSize)
            ])
            
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            btn.accessibilityLabel = formatter.string(from: date)
        }
        
        if let todayIndex = currentWeekDates.firstIndex(where: { Calendar.current.isDateInToday($0) }) {
            selectedDate = currentWeekDates[todayIndex]
        } else {
            selectedDate = currentWeekDates.first
        }
        updateSelectionHighlight()
    }
    
    private func createDateButton(for date: Date) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(getDayNumberString(for: date), for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.cornerRadius = circleHalf
        button.clipsToBounds = true
        
        button.accessibilityValue = "\(date.timeIntervalSince1970)"
        
        button.addTarget(self, action: #selector(dateTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Helpers
    
    private func getDayNumberString(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "d"
        return fmt.string(from: date)
    }
    
    private func dateFromButton(_ btn: UIButton) -> Date? {
        guard let s = btn.accessibilityValue, let t = TimeInterval(s) else { return nil }
        return Date(timeIntervalSince1970: t)
    }
    
    // MARK: - Highlighting
    
    private func updateSelectionHighlight() {
        for case let btn as UIButton in dateStackView.arrangedSubviews {
            guard let date = dateFromButton(btn) else { continue }
            
            if Calendar.current.isDate(date, inSameDayAs: selectedDate ?? Date.distantPast) {
                btn.backgroundColor = .systemBlue
                btn.setTitleColor(.white, for: .normal)
                btn.layer.borderWidth = 0
            } else if Calendar.current.isDateInToday(date) {
                btn.backgroundColor = .clear
                btn.setTitleColor(.label, for: .normal)
                btn.layer.borderWidth = 2
                btn.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.6).cgColor
            } else {
                btn.backgroundColor = .clear
                btn.setTitleColor(.label, for: .normal)
                btn.layer.borderWidth = 0
            }
        }
    }
    
    // MARK: - Button action
    
    @objc private func dateTapped(_ sender: UIButton) {
        guard let tappedDate = dateFromButton(sender) else { return }
        selectedDate = tappedDate
        updateSelectionHighlight()
        print("Selected date: \(tappedDate)")
    }
}

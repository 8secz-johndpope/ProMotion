//
//  ViewController.swift
//  HackWestern
//
//  Created by Rafit Jamil on 2020-11-20.
//

import UIKit
import Vision
import Charts
import TinyConstraints

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

class ViewController: UIViewController {
        
    private var cameraViewController: CameraViewController!
    private var detectionViewController: DetectionViewController!
    private var overlayParentView: UIView!

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var chartContainerView: UIView!
    
    @IBOutlet weak var activityIndicatorContainer: UIStackView!
    
    // charts
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.axisMinimum = 0.0
        chartView.xAxis.axisRange = 10.0
        
        chartView.largeContentTitle = "Performance"
        
        return chartView;
    }()
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    let yValues: [ChartDataEntry] = [
        ChartDataEntry(x: 0.0, y: 10.0),
        ChartDataEntry(x: 1.0, y: 15.0),
        ChartDataEntry(x: 2.0, y: 32.0),
        ChartDataEntry(x: 3.0, y: 41.0),
        ChartDataEntry(x: 4.0, y: 55.0),
        ChartDataEntry(x: 5.0, y: 51.0),
        ChartDataEntry(x: 6.0, y: 76.0),
        ChartDataEntry(x: 7.0, y: 88.0),
        ChartDataEntry(x: 8.0, y: 89.0),
        ChartDataEntry(x: 9.0, y: 93.0),
        
    ]
    
    @objc func updateGraph(sender: UIButton!) {
        let newY = Int.random(in: 1..<100)
        
        
    }
    
    
    func setData() {
        let set1 = LineChartDataSet(entries: yValues)
        set1.mode = .cubicBezier
        set1.circleRadius = 4
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup camera view
        cameraViewController = CameraViewController()
        cameraViewController.view.frame = view.bounds
                
        addChild(cameraViewController)
        
        cameraViewController.beginAppearanceTransition(true, animated: true)
        view.addSubview(cameraViewController.view)
        cameraViewController.endAppearanceTransition()
        cameraViewController.didMove(toParent: self)
        
        overlayParentView = UIView(frame: view.bounds)
        overlayParentView.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        overlayParentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayParentView)
        NSLayoutConstraint.activate([
            overlayParentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            overlayParentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            overlayParentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            overlayParentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        
        // Setup chart
        chartContainerView.addSubview(lineChartView)

        lineChartView.width(200)
        lineChartView.height(150)
        
//        lineChartView.width(400)
//        lineChartView.height(200)
        setData()
//        let num = 15
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
//        label.backgroundColor = UIColor(rgb: 0x66f268)
//        label.textAlignment = .center
//        label.text = "Rating: " + String(num) + "%"
//        label.frame.origin = CGPoint(x:50, y:50)
//        label.layer.cornerRadius = 6
//        label.layer.masksToBounds = true
        
//        view.addSubview(label)
//        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
//        button.setTitle("hello", for: .normal)
//        button.frame.origin = CGPoint(x:100, y: 500)
        detectionViewController = DetectionViewController()
        
//        button.backgroundColor = UIColor.red
//        view.addSubview(button)
//        button.addTarget(self, action: #selector(updateGraph), for: .touchUpInside)
        presentController(detectionViewController)

        bottomView.layer.cornerRadius = 12.0
        view.bringSubviewToFront(bottomView)
        
        reportView.layer.cornerRadius = 12.0
        view.bringSubviewToFront(reportView)
        
        activityIndicatorContainer.layer.cornerRadius = 12.0
        view.bringSubviewToFront(activityIndicatorContainer)
    }

    func presentController(_ controllerToPresent: UIViewController) {
        
        // TODO: remove old overlay if present
        
        // Present the new controller
         let newOverlay = controllerToPresent
            newOverlay.view.frame = overlayParentView.bounds
            addChild(newOverlay)
            newOverlay.beginAppearanceTransition(true, animated: true)
            overlayParentView.addSubview(newOverlay.view)
            newOverlay.endAppearanceTransition()
            newOverlay.didMove(toParent: self)
        

        
        if let cameraVC = cameraViewController {
            let viewRect = cameraVC.view.frame
            let videoRect = cameraVC.viewRectForVisionRect(CGRect(x: 0, y: 0, width: 1, height: 1))
            let insets = controllerToPresent.view.safeAreaInsets
            let additionalInsets = UIEdgeInsets(
                    top: videoRect.minY - viewRect.minY - insets.top,
                    left: videoRect.minX - viewRect.minX - insets.left,
                    bottom: viewRect.maxY - videoRect.maxY - insets.bottom,
                    right: viewRect.maxX - videoRect.maxX - insets.right)
            controllerToPresent.additionalSafeAreaInsets = additionalInsets
        }
        
        if let outputDelegate = controllerToPresent as? CameraViewControllerOutputDelegate {
            self.cameraViewController.outputDelegate = outputDelegate
        }
            
    }
}

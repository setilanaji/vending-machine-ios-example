//
//  ViewController.swift
//  vending machine example
//
//  Created by Yudha S on 2021/7/26.
//  Copyright © 2021 Macx. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "vendingItem"
fileprivate let screenWidth = UIScreen.main.bounds.width

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    let vendingMachine: VendingMachine
    var currentSelection: VendingSelection?
    var quantity = 1
    
    required init?(coder: NSCoder) {
        do {
            let dictionary = try PlistConverter.dictionary(fromFile: "VendingInventory", ofType: "plist")
            
            let inventory = try InventoryUnarchiver.vendingInventory(fromDictionary: dictionary)
            
            self.vendingMachine = FoodVendingMachine(inventory: inventory)
            
        } catch let error {
            fatalError("\(error)")
        }
        
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionViewCells()
        
        balanceLabel.text = "Rp,\(vendingMachine.amountDeposited)"
        totalLabel.text = "00.00"
        priceLabel.text = "Rp.0"
        quantityLabel.text = "1"
        
        updateDisplayWith(balance: vendingMachine.amountDeposited,
                          totalPrice: 0, itemPrice: 0, itemQuantity: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup
    
    func setupCollectionViewCells() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        let padding: CGFloat = 10
        let itemWidth = screenWidth/3 - padding
        let itemHeight = screenWidth/3 - padding
        
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - VendingMachine
    
    @IBAction func purchase() {
        if let currentSelection = currentSelection {
            do {
                try vendingMachine.vend(selection: currentSelection, quantity: Int(quantityStepper.value))
                updateDisplayWith(balance: vendingMachine.amountDeposited, totalPrice: 0.0, itemPrice: 0, itemQuantity: 1)
            } catch {
                // FIXME : Error handling
            }
            
            if let indePath = collectionView.indexPathsForSelectedItems?.first{
                collectionView.deselectItem(at: indePath, animated: true)
                updateCell(having: indePath, selected: false)
            }
        } else {
            // FIXME: Alert user for selction
        }
    }
    
    func updateDisplayWith(balance: Double? = nil, totalPrice: Double? = nil, itemPrice: Double? = nil, itemQuantity: Int? = nil) {
        
        if let balanceValue = balance {
            balanceLabel.text = "$\(balanceValue)"
        }
        
        if let totalValue = totalPrice {
            totalLabel.text = "Rp.\(totalValue)"
        }
        
        if let priceValue = itemPrice {
            priceLabel.text = "Rp.\(priceValue)"
        }
        
        if let quantityValue = itemQuantity {
            quantityLabel.text = "\(quantityValue)"
        }
    }
    
    func updateTotalPrice(for item: VendingItem) {
        let totalPrice = item.price * quantityStepper.value
        updateDisplayWith(totalPrice: totalPrice)
    }
    
    @IBAction func updateQuantity(_ sender: UIStepper) {
        quantityLabel.text = "\(Int(quantityStepper.value))"
        updateDisplayWith(itemQuantity: quantity)
    
        if let currentSelection = currentSelection, let item = vendingMachine.item(forSelection: currentSelection){
           updateTotalPrice(for: item)
        }
        
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 12
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? VendingItemCell else {
            fatalError()
        }
        
        let item = vendingMachine.selection[indexPath.row]
        cell.iconView.image = item.icon()
        return cell
    }
    
    // MARK: - UICollectionViewdelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
        quantityStepper.value = 1
                
        updateDisplayWith(totalPrice: 0, itemQuantity: 1 )

        currentSelection = vendingMachine.selection[indexPath.row]
        
        if let currentSelection = currentSelection, let item = vendingMachine.item(forSelection: currentSelection) {
            let totalPrice = item.price * quantityStepper.value
            updateDisplayWith(totalPrice: totalPrice, itemPrice: item.price)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        updateCell(having: indexPath, selected: true)
    }
    
    func updateCell(having indexPath: IndexPath, selected: Bool) {
        let selectedBackgroundColor = UIColor(red: 41/255.0, green: 211/255/0, blue: 241/255.0, alpha: 1.0)
        
        let defaultBackgroundColor = UIColor(red: 27/255.0, green: 32/255.0, blue: 36/255.0, alpha: 1.0)
        
        if let cell = collectionView.cellForItem(at: indexPath){
            cell.contentView.backgroundColor = selected ? selectedBackgroundColor : defaultBackgroundColor
            
        }
     }
    
}


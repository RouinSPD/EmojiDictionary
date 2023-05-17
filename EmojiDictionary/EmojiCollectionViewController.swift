// EmojiDictionary

import UIKit

private let reuseIdentifier = "Item"
private let headerIdentifier = "Header"
private let headerKind = "header"
private let columnReuseIdentifier = "ColumnItem"


class EmojiCollectionViewController: UICollectionViewController {
    
    @IBOutlet var layoutButton: UIBarButtonItem! 
    
    var emojis: [Emoji] = [
        Emoji(symbol: "😀", name: "Grinning Face", description: "A typical smiley face.", usage: "happiness"),
        Emoji(symbol: "😕", name: "Confused Face", description: "A confused, puzzled face.", usage: "unsure what to think; displeasure"),
        Emoji(symbol: "😍", name: "Heart Eyes", description: "A smiley face with hearts for eyes.", usage: "love of something; attractive"),
        Emoji(symbol: "🧑‍💻", name: "Developer", description: "A person working on a MacBook (probably using Xcode to write iOS apps in Swift).", usage: "apps, software, programming"),
        Emoji(symbol: "🐢", name: "Turtle", description: "A cute turtle.", usage: "something slow"),
        Emoji(symbol: "🐘", name: "Elephant", description: "A gray elephant.", usage: "good memory"),
        Emoji(symbol: "🍝", name: "Spaghetti", description: "A plate of spaghetti.", usage: "spaghetti"),
        Emoji(symbol: "🎲", name: "Die", description: "A single die.", usage: "taking a risk, chance; game"),
        Emoji(symbol: "⛺️", name: "Tent", description: "A small tent.", usage: "camping"),
        Emoji(symbol: "📚", name: "Stack of Books", description: "Three colored books stacked on each other.", usage: "homework, studying"),
        Emoji(symbol: "💔", name: "Broken Heart", description: "A red, broken heart.", usage: "extreme sadness"),
        Emoji(symbol: "💤", name: "Snore", description: "Three blue \'z\'s.", usage: "tired, sleepiness"),
        Emoji(symbol: "🏁", name: "Checkered Flag", description: "A black-and-white checkered flag.", usage: "completion")
    ]
    
    var sections: [Section] = []
    
    enum Layout {
        case grid
        case column
    }
    
    var layout: [Layout: UICollectionViewLayout] = [:]
    
    var activeLayout: Layout = .grid {
        didSet {
            if let layout = layout[activeLayout] {
                self.collectionView.reloadItems(
                    at: self.collectionView.indexPathsForVisibleItems)
                
                collectionView.setCollectionViewLayout(layout, animated: true) { (_) in
                    switch self.activeLayout {
                    case .grid:
                        self.layoutButton.image = UIImage(systemName: "rectangle.grid.1x2")
                    case .column:
                        self.layoutButton.image = UIImage(systemName: "square.grid.2x2")
                    }
                }
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register the header as a supplementary view for the collection view
        collectionView.register(EmojiCollectionViewHeader.self,
                                forSupplementaryViewOfKind: headerKind, withReuseIdentifier: headerIdentifier)
        
        layout[.grid] = generateGridLayout()
        layout[.column] = generateColumnarLayout()
        
        if let layout = layout[activeLayout] {
            collectionView.collectionViewLayout = layout
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //sections are updated before updating the collection view
        updateSections()
        collectionView.reloadData()
    }
    
   
    func generateGridLayout() -> UICollectionViewLayout {
        let padding: CGFloat = 20
        
        //set dimensions of the item to take 100% of the container
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
        
        //set dimensions of the group
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                // width 100% of the container
                widthDimension:.fractionalWidth(1.0),
                // height 25% of the container
                heightDimension: .fractionalHeight(1/4)
            ),
            subitem: item,
            //two items to have two cells across in the grid layout
            count: 2)
        
        //space to make everything readable and delineated
        //interior space between cells contained by the group
        group.interItemSpacing = .fixed(padding)
        
        //set the padding on the deges of the group
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: padding,
            bottom: 0,
            trailing: padding)
        
        //create section from the group
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = padding
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: padding,
            leading: 0,
            bottom: padding,
            trailing: 0)
        
        //all layouts will have a supplementary item attached
        section.boundarySupplementaryItems = [generateHeader()]
        
    
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func generateColumnarLayout() -> UICollectionViewLayout{
        let padding: CGFloat = 10
        
        let item = NSCollectionLayoutItem(layoutSize:NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)))
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension:.fractionalWidth(1.0),
                heightDimension: .absolute(150)),
            subitem: item,
            count: 1)
        
        
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: padding,
            bottom: 0,
            trailing: padding)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = padding
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: padding,
            leading: 0,
            bottom: padding,
            trailing: 0)
        
        section.boundarySupplementaryItems = [generateHeader()]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    
    func updateSections() {
        //empty out the sections array. The sections array is only used for display
        sections.removeAll()
        
        //creates a dictionary with keys being the first letter and the values being the emojis that start with that letter. It groups the emoji by first letter
        let grouped = Dictionary(grouping: emojis, by: {$0.sectionTitle})
        
        //loop over the grouped dictionary to sort the entries by section titles and creates a bew Section from each key/value pair
        //inside the section the emojis are sorted by name before being stored and the section appended to the sections array
        for (title, emojis) in grouped.sorted(by: {$0.0 < $1.0}){
            sections.append(
                Section(
                    title: title,
                    emojis: emojis.sorted(by: {$0.name < $1.name})
                )
            )
        }
    }
    
    
    @IBAction func switchLayouts(sender: UIBarButtonItem) {
        switch activeLayout {
        case .grid:
            activeLayout = .column
        case .column:
            activeLayout = .grid
        }
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let emojisBySection = sections[section].emojis
        return emojisBySection.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = activeLayout == .grid ? reuseIdentifier : columnReuseIdentifier
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! EmojiCollectionViewCell
    
        //Step 2: Fetch model object to display
        let emoji = sections[indexPath.section].emojis[indexPath.item]

        //Step 3: Configure cell
        cell.update(with: emoji)

        //Step 4: Return cell
        return cell
    }
    
    
    // this method is called when the collection view asks for a header
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! EmojiCollectionViewHeader
        
        header.titleLabel.text = sections[indexPath.section].title
        
        return header
    }
    
    //create the header´s layout for the compositional layout
    func generateHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                //full width of the container
                widthDimension: .fractionalWidth(1.0),
                //40 points high
                heightDimension: .absolute(40)),
            //matches the configuration from UICollectionViewDataSource
            elementKind: headerKind,
            alignment: .top)
        
        //creates a "sticky" header pinned to the top of the collection view and only scrolls off when its associated container is no longer visible
        header.pinToVisibleBounds = true
        
        return header
    }
    
    @IBSegueAction func addEditEmoji(_ coder: NSCoder, sender: Any?) -> AddEditEmojiTableViewController? {
        if let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
            // Editing Emoji
            let emojiToEdit = sections[indexPath.section].emojis[indexPath.item]
            return AddEditEmojiTableViewController(coder: coder, emoji: emojiToEdit)
        } else {
            // Adding Emoji
            return AddEditEmojiTableViewController(coder: coder, emoji: nil)
        }
    }
   
    func indexPath(for emoji: Emoji) -> IndexPath? {
        
        //find the appropiate section for the emoji using the sectionTitle and attempts to find the emoji´s index in the emojis array of the section
        if let sectionIndex = sections.firstIndex(where: {$0.title == emoji.sectionTitle}),
           let index = sections[sectionIndex].emojis.firstIndex(where: {$0 == emoji})
        {
            //if both indexes are found
            return IndexPath(item: index, section: sectionIndex)
        }
        //if an IndexPath cannot be determined
        return nil
    }
    
    @IBAction func unwindToEmojiTableView(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind",
            let sourceViewController = segue.source as? AddEditEmojiTableViewController,
            let emoji = sourceViewController.emoji else { return }
        //checks the selected collection view to see if one is selected
        if let path = collectionView.indexPathsForSelectedItems?.first,
           let i = emojis.firstIndex(where: {$0 == emoji})
        {
            //update the emoji
            emojis[i] = emoji
            updateSections()
            
            collectionView.reloadItems(at: [path])
        } else {
            //add an emoji
            emojis.append(emoji)
            updateSections()
            
            if let newIndexPath = indexPath(for: emoji){
                collectionView.insertItems(at: [newIndexPath])
            }
        }
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (elements) -> UIMenu? in
            let delete = UIAction(title: "Delete") { (action) in
                self.deleteEmoji(at: indexPath)
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [delete])
        }
        
        return config
    }

    func deleteEmoji(at indexPath: IndexPath) {
        // find the emoji to be deleted using indexPath
        let emoji = sections[indexPath.section].emojis[indexPath.item]
        //determine the index of the emoji in the data source
        guard let index = emojis.firstIndex(where: {$0 == emoji })
        else {return}
        
        //remove from the data source
        emojis.remove(at: index)
        //remove from the sections
        sections[indexPath.section].emojis.remove(at: indexPath.item)
        //delete from the collectionView
        collectionView.deleteItems(at: [indexPath])
    }
}

/*
 ***************************
 * File: AppDelegate.h
 * Name: Jinke He
 * University ID: 201219022
 * Departmental ID: x6jh
 ***************************
 */
#import <Cocoa/Cocoa.h>
#import "Album.h"
#import <AVFoundation/AVFoundation.h>

// Credit: the icons are from https://www.vecteezy.com/

/* The controller layer */

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource>

// this music player can play a sample track
@property AVAudioPlayer *musicPlayer;

// the volume slider
@property (weak) IBOutlet NSSlider *volumeSlider;

// the numeric display of the current volume
@property (weak) IBOutlet NSTextField *volumeDisplay;

// the basic play button
@property (weak) IBOutlet NSButtonCell *playButton;

// the play-next-track button
@property (weak) IBOutlet NSButton *nextButton;

// the play-previous-track button
@property (weak) IBOutlet NSButton *previousButton;

// the "load album" button
@property (weak) IBOutlet NSView *loadAlbumBtn;

// the label of the artist name
@property (weak) IBOutlet NSTextField *artistLabel;

// the label of the album name
@property (weak) IBOutlet NSTextField *albumLabel;

// the label of the track that is currently playing
@property (weak) IBOutlet NSTextField *trackLabel;

// the image view that displays the album cover
@property (weak) IBOutlet NSImageView *imageView;

// the table view that displays the track list
@property (weak) IBOutlet NSTableView *tableView;

// the view that contains the table view
@property (weak) IBOutlet NSScrollView *trackListView;

// the button to play the selected track in the list
@property (weak) IBOutlet NSButton *playSelectedBtn;

// the button to play the track of the number that user types in
@property (weak) IBOutlet NSButton *playNumBtn;

// the text field that allows user to type in a track number
@property (weak) IBOutlet NSTextField *numTextField;

// the label that shows "Playing: "
@property (weak) IBOutlet NSTextField *playingLabel;

// the switch button of the view of track list and album cover
@property (weak) IBOutlet NSSegmentedCell *viewSwitchBtn;

// the progress bar that shows the progress of a track
@property (weak, nonatomic) IBOutlet NSSlider *progressBar;

// the volume icon
@property (weak) IBOutlet NSButton *volumeIcon;

// the label that shows how long the current track has been played
@property (weak) IBOutlet NSTextField *timeLabel;

// the history view
@property (weak) IBOutlet NSScrollView *historyView;

// the table view of the playing history
@property (weak) IBOutlet NSTableView *historyTableView;

// the help view
@property (weak) IBOutlet NSScrollView *helpView;

// "playing history" or "Help" Label
@property (weak) IBOutlet NSTextField *titleLabel;

// the history button
@property (weak) IBOutlet NSButton *historyBtn;

// the help button
@property (weak) IBOutlet NSButton *helpBtn;

// the about panel showing the information of the author
@property (weak) IBOutlet NSPanel *aboutPanel;

// user can click any track in the playing history to play it again
- (IBAction) historyDoubleClicked: (id)sender;

// user can click the help button to get help
- (IBAction) helpBtnClicked: (id)sender;

// user can click the history button to see the playing history
- (IBAction) historyBtnClicked: (id)sender;

// user can click the button to load a album
- (IBAction) loadAlbum: (id)sender;

// user can click the button to play a track
- (IBAction) playButtonClicked: (id)sender;

// user can click the button to play the next track
- (IBAction) playNext: (id)sender;

// user can click the button to play the previous track
- (IBAction) playPrevious: (id)sender;

// user can click the segmented button to switch the view
- (IBAction) switchView: (id)sender;

// user can drag the slider to change the volume
- (IBAction) changeVolume: (id)sender;

// user can double-click a row or click the button to play the selected track in the list (table)
- (IBAction) playSelected: (id)sender;

// user can type in a track number and play the track by pressing "enter" or click the button
- (IBAction) playTypedInTrack: (id)sender;

// update the progress of the music player when the progress bar is moved through
- (IBAction) updateProgressOfPlayer: (id)sender;

// If user clicks the volume icon once, the volume will be set to 0.
// If user clicks the volume icon again, the volume will be changed back to its previous value.
- (IBAction) volumeIconClicked: (id) sender;

// if user clicks the title "JINKE's Music Player", an about panel will be shown
- (IBAction)showAboutPanel:(id)sender;

@end


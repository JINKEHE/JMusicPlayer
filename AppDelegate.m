/*
 ***************************
 * File: AppDelegate.m
 * Name: Jinke He
 * University ID: 201219022
 * Departmental ID: x6jh
 ***************************
 */
#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate {
    
    // the model of the application: the album
    Album *theAlbum;
    
    // whether a track is currently playing
    BOOL isPlaying;
    
    // the current volume of the player
    NSInteger volume;
    
    // whether the player is set to be slient
    BOOL isSilent;
}

// once the window is closed, the application will quit
- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) application {
    return YES;
}

// initialize the model
- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
    isPlaying = NO;
    isSilent = NO;
    volume = 100;
    // initialize the table view
    [self.tableView setAllowsMultipleSelection: NO];
    // make the "load album" button the first responder
    [self.window makeFirstResponder: self.loadAlbumBtn];
    // this music player can play a sample music
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"mp3"];
    NSURL *SampleURL = [NSURL fileURLWithPath: path];
    self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: SampleURL error: nil];
    [self.musicPlayer prepareToPlay];
    // initialize the progress bar
    [self.progressBar setDoubleValue: 0];
    [self.progressBar setMaxValue: self.musicPlayer.duration];
    // create a new thread to update the progress bar
    [NSThread detachNewThreadSelector: @selector(updateProgress) toTarget: self withObject: nil];
}

// release the resources
- (void) applicationWillTerminate: (NSNotification *) aNotification {
    theAlbum = nil;
}

// the numeric display of volume will change as the volume slider is moved
- (IBAction) changeVolume: (id) sender {
    if (isSilent == NO) volume = [self.volumeSlider integerValue];
    [self.volumeDisplay setIntegerValue: volume];
    if ([self.volumeSlider doubleValue] == 0) {
        [self.volumeIcon setState: 1];
    } else {
        [self.volumeIcon setState: 0];
    }
    isSilent = NO;
    [self.musicPlayer setVolume: (float) self.volumeSlider.integerValue/100];
}

// user has to click a confirmation button if the file to load is not a txt file
- (NSInteger) loadConfirm {
    NSAlert *confirm = [[NSAlert alloc] init];
    confirm.messageText = @"Loading Confirm";
    [confirm setAlertStyle: NSAlertStyleCritical];
    [confirm setInformativeText: @"The chosen file is not a text file. Are you sure to continue?"];
    [confirm addButtonWithTitle: @"Cancel"];
    [confirm addButtonWithTitle: @"Continue"];
    NSInteger response = [confirm runModal];
    return response;
}

// load a new album (user clicks the Load Album Button)
- (IBAction) loadAlbum: (id) sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        NSURL *albumURL = [panel URL];
        // check whether the file is a txt file, ask user to confirm
        if (![[albumURL pathExtension] isEqualToString: @"txt"]) {
            NSInteger response = [self loadConfirm];
            if (response == NSAlertFirstButtonReturn) { return; }
        }
        // create a new Album Model
        theAlbum = [[Album alloc] initWithFilePath: albumURL];
        // update the view
        [self.artistLabel setStringValue: theAlbum.artistName];
        [self.albumLabel setStringValue: theAlbum.albumTitle];
        // update the tables
        [self.tableView reloadData];
        [self.historyTableView reloadData];
        // display the cover of the album
        [self updateAlbumCover];
        // after a album is loaded, unhide labels and enable buttons
        [self unhideElements];
        // initialize the playing
        [self playTheTrack: 0 playNow: NO];
    }
}

// display the cover of the album
- (void) updateAlbumCover {
    // if the image is found, display it
    if (theAlbum.albumCover != nil) {
        [self.imageView setImage: theAlbum.albumCover];
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Loaded Successfully";
        [alert setAlertStyle: NSAlertStyleInformational];
        [alert beginSheetModalForWindow: self.window completionHandler: nil];
    } else {
        // if the image cannot be found, display "Image Not Found" image
        [self.imageView setImage: [NSImage imageNamed: @"imageNotFound.png"]];
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Warning";
        [alert setInformativeText: @"Album Cover Was Not Found."];
        [alert setAlertStyle: NSAlertStyleCritical];
        [alert beginSheetModalForWindow: self.window completionHandler:nil];
    }
}

// after a album is loaded, unhide the hidden labels and enable the disabled buttons
- (void) unhideElements {
    [self.playButton setEnabled: YES];
    [self.nextButton setEnabled: YES];
    [self.previousButton setEnabled: YES];
    [self.volumeSlider setEnabled: YES];
    [self.numTextField setEnabled: YES];
    [self.playSelectedBtn setEnabled: YES];
    [self.playNumBtn setEnabled: YES];
    [self.playingLabel setHidden: NO];
    [self.trackLabel setHidden: NO];
    [self.viewSwitchBtn setEnabled: YES forSegment: 0];
    [self.viewSwitchBtn setEnabled: YES forSegment: 1];
    [self.artistLabel setHidden: NO];
    [self.progressBar setEnabled: YES];
    [self.albumLabel setHidden: NO];
    NSString *range = [NSString stringWithFormat: @"%d-%lu", 1, ([theAlbum.trackList count])];
    [self.numTextField setPlaceholderString: range];
}

// user clicks the play button
- (IBAction) playButtonClicked: (id) sender {
    if (isPlaying == NO) {
        [self.playButton setImage: [NSImage imageNamed: @"pauseImage"]];
        isPlaying = YES;
        [self.musicPlayer play];
    } else {
        [self.playButton setImage: [NSImage imageNamed: @"playImage"]];
        isPlaying = NO;
        [self.musicPlayer pause];
    }
}

// user clicks the play next button
- (IBAction)playNext:(id)sender {
    [self playTheTrack: (theAlbum.currentTrackIndex+1) playNow: YES];
}

// user clicks the play previous button
- (IBAction)playPrevious:(id)sender {
    [self playTheTrack: (theAlbum.currentTrackIndex-1) playNow: YES];
}

// play a track according to its index
- (void) playTheTrack: (NSInteger) index playNow: (BOOL) playNow {
    // stop the current playing
    [self.musicPlayer pause];
    [self.musicPlayer setCurrentTime: 0];
    [self.musicPlayer setNumberOfLoops: 0];
    theAlbum.currentTrackIndex = index;
    [self.trackLabel setStringValue: theAlbum.trackList[theAlbum.currentTrackIndex]];
    [self.progressBar setDoubleValue: 0];
    [self.tableView reloadData];
    [self playButtonControl];
    if (playNow == YES) {
        isPlaying = YES;
        [self.playButton setImage: [NSImage imageNamed: @"pauseImage"]];
        // play the sample music
        [self.musicPlayer play];
    } else {
        isPlaying = NO;
        [self.playButton setImage: [NSImage imageNamed: @"playImage"]];
    }
    // synchronize
    [self.numTextField setIntegerValue: theAlbum.currentTrackIndex+1];
    [self.numTextField.window makeFirstResponder: self.tableView];
    NSIndexSet *selectedRows = [NSIndexSet indexSetWithIndex: theAlbum.currentTrackIndex];
    [self.tableView selectRowIndexes: selectedRows byExtendingSelection: NO];
    [self.tableView reloadData];
    // play a simple sound
    [[NSSound soundNamed: @"Ping"] play];
    // update the playing history
    [theAlbum createNewRecord];
    // update the two table views
    [self.tableView reloadData];
    [self.tableView scrollRowToVisible: self.tableView.selectedRow];
    [self.historyTableView reloadData];

}

// enable the buttons that can be clicked and disable the buttons that shouldn't be clicked
- (void) playButtonControl
{
    [self.previousButton setEnabled: YES];
    [self.nextButton setEnabled: YES];
    if (theAlbum.currentTrackIndex == 0) {
        [self.previousButton setEnabled: NO];
    } else if (theAlbum.currentTrackIndex == [theAlbum.trackList count]-1) {
        [self.nextButton setEnabled: NO];
    }
}

/* 
 * play the selected track in the table
 *
 * the function can be called in two ways:
 * 1. user double-clicks a row in the table
 * 2. user selects a row and clicks the "Play Selected Track" Button
 */
- (IBAction) playSelected: (id) sender {
    NSInteger selectedRow = [self.tableView selectedRow];
    [self playTheTrack: selectedRow playNow: YES];
}

/*
 * play the track according to the number in the text field
 *
 * the function can be called in two ways:
 * 1. user types in a number and presses "enter"
 * 2. user types in a number and clicks the "Play It" Button
 */
- (IBAction) playTypedInTrack: (id) sender {
    NSInteger number;
    NSString *str = [self.numTextField stringValue];
    NSScanner *scanner = [NSScanner scannerWithString: str];
    [scanner scanInteger: &number];
    if ([scanner isAtEnd] == YES && number >= 1 && number <= theAlbum.trackList.count) {
        NSInteger index = number - 1;
        [self playTheTrack: index playNow: YES];
    } else {
        [self.numTextField setStringValue: @""];
    }
}

// update the time display according to the current progress
- (void) updateTimeDisplay {
    double currentTime = [self.progressBar doubleValue];
    int minutes = (int) currentTime / 60;
    int seconds = (int) currentTime % 60;
    int duration = self.progressBar.maxValue;
    int durationMin = (int) duration / 60;
    int durationSec = (int) duration % 60;
    NSString *durationStr = [NSString stringWithFormat: @"%d%d:%d%d", durationMin/10, durationMin%10, durationSec/10, durationSec%10];
    NSString *timeStr = [NSString stringWithFormat: @"%d%d:%d%d/%@", minutes/10, minutes%10, seconds/10, seconds%10, durationStr];
    [self.timeLabel setStringValue: timeStr];
}

// update the progress of the music player when the progress bar is moved through
- (IBAction) updateProgressOfPlayer: (id)sender {
    [self.playButton setImage: [NSImage imageNamed: @"pauseImage"]];
    isPlaying = YES;
    self.musicPlayer.currentTime = self.progressBar.doubleValue;
    [self.musicPlayer play];
}

// update the progress bar according to the progress of the music player
- (void) updateProgress {
    while (YES) {
        if (isPlaying == YES) {
            // in Cocoa Mac, UI must be updated in the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                // by default, when a playing ends, play the next track in the list
                if (self.musicPlayer.currentTime >= self.musicPlayer.duration-0.005) {
                    if (theAlbum.currentTrackIndex < theAlbum.trackList.count-1) {
                        [self playTheTrack: (theAlbum.currentTrackIndex+1) playNow: YES];
                    } else {
                        [self playTheTrack: theAlbum.currentTrackIndex playNow: YES];
                    }
                }
                [self.progressBar setDoubleValue: self.musicPlayer.currentTime];
                [self.progressBar setNeedsDisplay];
                [self updateTimeDisplay];
                
            });
        }
    }
}

// switch between the album cover and the track list
- (IBAction) switchView: (id) sender {
    NSInteger identifier =  [self.viewSwitchBtn selectedSegment];
    if (identifier == 0) {
        [self.imageView setHidden: YES];
        [self.trackListView setHidden: NO];
    } else {
        [self.imageView setHidden: NO];
        [self.trackListView setHidden: YES];
    }
}

// return the number of rows (this method is essential to update the two tables)
- (NSInteger) numberOfRowsInTableView: (NSTableView *) tableView {
    if (tableView == self.tableView) {
        return [theAlbum.trackList count];
    } else {
        return [theAlbum.history count];
    }
}

// return the item in each cell (this method is essential to update the two tables)
- (id) tableView: (NSTableView *) tableView objectValueForTableColumn: (NSTableColumn *) tableColumn row: (NSInteger) row {
    NSString *identifier = [tableColumn identifier];
    if (tableView == self.tableView) {
        if ([identifier isEqualToString: @"Num"]) {
            return @(row+1);
        } else {
            if (theAlbum.currentTrackIndex == row) {
                return [NSString stringWithFormat: @"-> %@", theAlbum.trackList[row]];
            } else {
                return theAlbum.trackList[row];
            }
        }
    } else {
        if ([identifier isEqualToString: @"Time"]) {
            return theAlbum.history[row][0];
        } else {
            NSInteger index = [theAlbum.history[row][1] integerValue];
            return theAlbum.trackList[index];
        }
    }
}

// If user clicks the volume icon once, the volume will be set to 0.
// If user clicks the volume icon again, the volume will be changed back to its previous value.
- (IBAction) volumeIconClicked: (id) sender {
    if (isSilent == NO) {
        [self.volumeSlider setIntegerValue: 0];
        [self.musicPlayer setVolume: 0];
        isSilent = YES;
    } else {
        isSilent = NO;
        [self.volumeSlider setIntegerValue: volume];
        [self.musicPlayer setVolume: (float) self.volumeSlider.integerValue/100];
    }
    [self.volumeDisplay setIntegerValue: self.volumeSlider.integerValue];
}

// show the about panel
- (IBAction) showAboutPanel: (id)sender {
    // if the panel is not visible, show it
    if ([self.aboutPanel isVisible] == NO) {
        // make sure that the panel will appear at the left-top corner of the main window
        NSPoint origin = self.window.frame.origin;
        origin.x -= self.aboutPanel.frame.size.width;
        origin.y += (self.window.frame.size.height - self.aboutPanel.frame.size.height);
        [self.aboutPanel setFrameOrigin: origin];
        [self.aboutPanel setIsVisible: YES];
    // if the panel is already visible, close it
    } else {
        [self.aboutPanel setIsVisible: NO];
    }
}

// If user clicks the help button, a help view will be shown
- (IBAction) helpBtnClicked: (id)sender {
    if ([self.helpView isHidden]) {
        [self.titleLabel setStringValue: @"Help"];
        [self.titleLabel setHidden: NO];
    } else {
        [self.titleLabel setHidden: YES];
    }
    [self.historyBtn setState: 0];
    [self.helpView setHidden: ![self.helpView isHidden]];
    [self.historyView setHidden: YES];
}

// If user clicks the history, the playing history will be shown
- (IBAction) historyBtnClicked: (id)sender {
    if ([self.historyView isHidden]) {
        [self.titleLabel setHidden: NO];
        [self.titleLabel setStringValue: @"Playing History"];
    } else {
        [self.titleLabel setHidden: YES];
    }
    [self.helpBtn setState: 0];
    [self.historyView setHidden: ![self.historyView isHidden]];
    [self.helpView setHidden: YES];
}

// If user double-clicks a track in the playing history, the player will play that track
- (IBAction) historyDoubleClicked: (id)sender {
    NSInteger index = [theAlbum.history[[self.historyTableView selectedRow]][1] integerValue];
    [self playTheTrack: index playNow: YES];
}

@end

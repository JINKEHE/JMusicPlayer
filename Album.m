/*
 ***************************
 * File: Album.m
 * Name: Jinke He
 * University ID: 201219022
 * Departmental ID: x6jh
 ***************************
 */
#import "Album.h"

@implementation Album

// the initialize method
- (instancetype) initWithFilePath: (NSURL *) albumURL {
    self = [super init];
    if (self) {
        // extract information from the file
        NSString *file = [NSString stringWithContentsOfURL: albumURL encoding: NSASCIIStringEncoding error: NULL];
        NSArray *info = [file componentsSeparatedByString: @"\n"];
        self.trackList = [NSMutableArray arrayWithArray: info];
        // get the artist name
        self.artistName = self.trackList[0];
        [self.trackList removeObjectAtIndex: 0];
        // get the album title
        self.albumTitle = self.trackList[0];
        [self.trackList removeObjectAtIndex: 0];
        // clean the track list
        [self.trackList removeObject: @""];
        // load album cover
        NSURL *imageURL = [albumURL URLByAppendingPathExtension: @"jpg"];
        self.albumCover = [[NSImage alloc] initWithContentsOfURL: imageURL];
        self.history = [[NSMutableArray alloc] init];
    }
    return self;
}

// create a new record and add it to the playing history
- (void) createNewRecord {
    NSArray *newRecord= @[[self getCurrentTime], @(self.currentTrackIndex)];
    [self.history addObject: newRecord];
}

// get the current time in the format of HH:mm:ss
- (NSString *) getCurrentTime {
    NSDate *newDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"HH:mm:ss"];
    return [dateFormatter stringFromDate: newDate];
}

@end

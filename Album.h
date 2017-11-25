/*
 ***************************
 * File: Album.m
 * Name: Jinke He
 * University ID: 201219022
 * Departmental ID: x6jh
 ***************************
 */
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

/* The model layer */

@interface Album : NSObject

/* the use of 'copy' is to make sure that the album object owns these properties */

// the name of the artist
@property (copy) NSString *artistName;

// the title of the album
@property (copy) NSString *albumTitle;

// the track list of the album
@property (strong, nonatomic) NSMutableArray *trackList;

// the cover of the album
@property (copy) NSImage *albumCover;

// the index of the track that is currently selected or being played
@property (nonatomic) NSInteger currentTrackIndex;

@property (strong, nonatomic) NSMutableArray *history;

// initialize an album with its file path
- (instancetype) initWithFilePath: (NSURL *) albumURL;

// create a new record and add it to the playing history
- (void) createNewRecord;

@end

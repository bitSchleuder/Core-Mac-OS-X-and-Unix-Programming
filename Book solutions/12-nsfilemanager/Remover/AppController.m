#import "AppController.h"
#import "DirEntry.h"

@implementation AppController

- (id)init
{
    [super init];
    directories = [[NSMutableArray alloc] init];
    return self;
}

// Begin Private Methods

// This method causes the browser to be completely cleared,  and only 
// the left-most column gets reloaded
- (void)reload
{
    NSMutableArray *root;

    // Clear the columns
    [directories removeAllObjects];

    // Create the left-most column
    root = [DirEntry entriesAtPath:@"/" withParent:nil];
    [directories addObject:root];
}

// This gets called to ensure that 'directories' is loaded with the 
// the data for the selected row and column.
// If column == -1,  no selection
- (void)updateDirectoriesForSelectedRow:(int)row column:(int)column
{
    NSArray *items;
    DirEntry *dirEntry;

    // No selection?  Reload the left-most column
    if (column == -1) {
        [self reload];
        return;
    }

    // Discard the arrays of entries to the right of the selection
    while ([directories count] > column + 1) {
        [directories removeLastObject];
    }

    // Look up the selected dirEntry
    items = [directories objectAtIndex:column];
    dirEntry = [items objectAtIndex:row];

    // If the selection is a directory,  load its children
    if ([dirEntry isDirectory]){
        NSArray *newItems = [dirEntry children];
        [directories addObject:newItems];
    } 
}

// Returns the last item in the selection array
- (DirEntry *)selectedDirEntry
{
    int row, col;
    NSArray *items;

    // What row and column are currently selected?
    col = [browser selectedColumn];
    row = [browser selectedRowInColumn:col];

    // Is there no selection?
    if (col < 0) {
        return nil;
    }

    // Get the selected DirEntry
    items = [directories objectAtIndex:col];
    return [items objectAtIndex:row];
}
// End of Private Methods


- (void)awakeFromNib
{
    [self reload];
}


// Begin NSBrowser Delegate Methods

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
    int selectedRow, selectedCol;

    // What is currently selected in the browser?
    selectedCol = [browser selectedColumn];
    selectedRow = [browser selectedRowInColumn:selectedCol];

    // If the column being asked about is to the right of the selected
    // column, then the user has clicked on a directory.
    // Thus we need to load the selectedEntry's children into the
    // directories array
    if (column == selectedCol + 1) {
        [self updateDirectoriesForSelectedRow:selectedRow 
                                       column:selectedCol];
    }

    // If we are being asked about something beyond the directories
    // array,  just return zero
    if (column < [directories count]) {
        return [[directories objectAtIndex:column] count];
    } else {
        return 0;
    }
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell 
          atRow:(int)row column:(int)column
{
    NSArray *items = [directories objectAtIndex:column];
    DirEntry *dirEntry = [items objectAtIndex:row];
    [cell setLeaf:![dirEntry isDirectory]];
    [cell setStringValue:[dirEntry filename]];
    [cell setLoaded:YES];
}

- (void)dealloc
{
    [directories release];
    [super dealloc];
}



// An action method that tries to delete the selected directory entry
// from the file system and updates the selection in the browser
// accordingly

- (IBAction)deleteSelection:(id)sender
{
    int response;
    BOOL successful;
    DirEntry *dirEntry, *parent;
    NSString *path;
    NSMutableArray *items;
    int selectedRow, selectedColumn;

    // What DirEntry is the user trying to delete?
    dirEntry = [self selectedDirEntry];

    // Is nothing selected?
    if (dirEntry == nil) {
        NSRunAlertPanel(@"Delete", @"Nothing selected", nil, nil, nil);
        return;
    }

    // Get the path of what we are about to delete
    path = [dirEntry fullPath];

    // Show an alert panel to confirm delete
    response = NSRunAlertPanel(@"Delete", @"Really delete %@?", @"Yes", 
                               @"No", nil, path);

    // Did the user choose NO?
    if (response == NSAlertAlternateReturn){
        return;
    }

    // Use the browser to find out what the row and column of the
    // selected entry is.
    selectedColumn = [browser selectedColumn];
    selectedRow = [browser selectedRowInColumn:selectedColumn];

    // The parent will be selected after successful delete
    parent = [dirEntry parent];

    NSLog(@"will delete %i, %i, %@",selectedRow,selectedColumn, path);

    // Try to delete it.
    successful = [[NSFileManager defaultManager] removeFileAtPath:path 
                                                          handler:self];

    // Did the delete work?
    if (successful) {

        // Figure out the new selected column and row
        selectedColumn--;

        // Is any column selected?
        if (selectedColumn >= 0) {

            // Figure out the selected row
            items = [directories objectAtIndex:selectedColumn];
            selectedRow = [items indexOfObject:parent];

            // Change the browser's selection and reload
            [browser selectRow:selectedRow inColumn:selectedColumn];
        } else {

            // Unselect everything
            [[browser matrixInColumn:0] deselectAllCells];

            // Reload the left-most column
            [browser loadColumnZero];
        }
    } else {
         NSRunAlertPanel(@"Delete", @"Delete was not successful", 
                         nil, nil, nil);
    }
}

// This gets called if something goes wrong with the delete
- (BOOL)fileManager:(NSFileManager *)manager
        shouldProceedAfterError:(NSDictionary *)errorInfo
{
    NSLog(@"error = %@", errorInfo);
    return NO;
}


@end
